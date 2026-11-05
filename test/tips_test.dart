import 'package:akai_timetrack/core/format.dart';
import 'package:akai_timetrack/core/time.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/data/tip_repository.dart';
import 'package:akai_timetrack/domain/tips.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers.dart';

TipDay tipDay(String day, int cents) => TipDay(
  id: 'tip-$day',
  day: day,
  poolCents: cents,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
    await initializeDateFormatting('en');
  });

  group('money', () {
    test('parses what she types', () {
      int? de(String text) => parseEuroCents(text, 'de');
      expect(de('40'), 4000);
      expect(de('40,5'), 4050);
      expect(de('40,50'), 4050);
      expect(de('40.50'), 4050); // keyboard with a dot
      expect(de(' 40,50 € '), 4050);
      expect(de('0'), 0);
      expect(de('0,05'), 5);
      expect(de('1.234,50'), 123450);
      expect(de('1.234'), 123400);
      expect(de('1234,5'), 123450);
      expect(parseEuroCents('1,234.50', 'en'), 123450);
      expect(parseEuroCents('1,234', 'en'), 123400);
      expect(parseEuroCents('40,50', 'en'), 4050);
    });

    test('rejects what is not an amount', () {
      for (final text in [
        '',
        '  ',
        '-5',
        'abc',
        '40,505', // a typo, not 40 505 €
        '40,',
        ',50',
        '1,234,50',
        '1,234.50', // English grouping in German
        '12.34.56',
        '1.23,45',
        '100001',
      ]) {
        expect(parseEuroCents(text, 'de'), isNull, reason: text);
      }
      expect(parseEuroCents('1.234,50', 'en'), isNull);
    });

    test('shows cents only when they are not zero', () {
      expect(formatEuros(4000, 'de'), '40 €');
      expect(formatEuros(4250, 'de'), '42,50 €');
      expect(formatEuros(123450, 'de'), '1.234,50 €');
      expect(formatEuros(4000, 'en'), '€40');
      expect(formatEuros(4250, 'en'), '€42.50');
    });
  });

  group('tip weeks and months', () {
    test('a week counts for the month of its Thursday', () {
      // Mon 30 Nov – Sun 6 Dec 2026: Thursday is 3 Dec.
      expect(tipMonthOf(DateTime(2026, 11, 30)), DateTime(2026, 12));
      expect(tipMonthOf(DateTime(2026, 12, 5)), DateTime(2026, 12));
      // Mon 26 Oct – Sun 1 Nov 2026: Thursday is 29 Oct.
      expect(tipMonthOf(DateTime(2026, 11, 1)), DateTime(2026, 10));
    });

    test('the weeks of a month', () {
      // November 2026: first Thursday 5 Nov, December's 3 Dec.
      expect(tipWeeksOf(DateTime(2026, 11, 17)), (
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 30),
      ));
      // October 2026 starts on a Thursday.
      expect(tipWeeksOf(DateTime(2026, 10)), (
        DateTime(2026, 9, 28),
        DateTime(2026, 11, 2),
      ));
    });

    test('month total', () {
      final month = TipMonth.of([
        TipPayout(
          id: 'a',
          weekStart: '2026-11-02',
          amountCents: 12000,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
        TipPayout(
          id: 'b',
          weekStart: '2026-11-09',
          amountCents: 9550,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ]);
      expect(month.totalCents, 21550);
      expect(month.weeks, 2);
    });
  });

  test('workdays: days with shifts up to today, plus stored totals', () {
    final days = tipWorkdays(
      shifts: [
        testShift(day: DateTime(2026, 11, 2), actual: '17:30-23:00'),
        testShift(day: DateTime(2026, 11, 2), type: ShiftType.lunch),
        testShift(day: DateTime(2026, 11, 4)), // missed still counts
        testShift(day: DateTime(2026, 11, 6)), // after today
      ],
      tipDays: [tipDay('2026-11-03', 5000)], // its shift was deleted
      today: DateTime(2026, 11, 5),
    );
    expect(days, [
      DateTime(2026, 11, 2),
      DateTime(2026, 11, 3),
      DateTime(2026, 11, 4),
    ]);
  });

  group('prompt on Heute', () {
    final monday = DateTime(2026, 11, 2);
    final tuesday = DateTime(2026, 11, 3);
    final lunchDone = testShift(
      day: monday,
      type: ShiftType.lunch,
      planned: '12:00-15:30',
      actual: '12:00-15:30',
    );
    final eveningDone = testShift(day: monday, actual: '17:30-23:00');
    final eveningPlanned = testShift(day: monday);

    DateTime? prompt(
      DateTime now,
      List<Shift> shifts, {
      List<TipDay> tipDays = const [],
      String? dismissed,
    }) => tipPromptDay(
      now: now,
      shifts: shifts,
      tipDays: tipDays,
      dismissedDay: dismissed,
    );

    test('waits until the last shift of the day is done', () {
      final afternoon = DateTime(2026, 11, 2, 16);
      expect(prompt(afternoon, [lunchDone, eveningPlanned]), isNull);
      expect(prompt(afternoon, [lunchDone]), monday);
      expect(
        prompt(DateTime(2026, 11, 2, 23, 10), [lunchDone, eveningDone]),
        monday,
      );
    });

    test('still asks the next morning, also before a shift that day', () {
      final tuesdayEvening = testShift(day: tuesday);
      expect(
        prompt(DateTime(2026, 11, 3, 9), [eveningDone, tuesdayEvening]),
        monday,
      );
      // Two days later it's gone.
      expect(prompt(DateTime(2026, 11, 4, 9), [eveningDone]), isNull);
    });

    test('not for a running or only missed day', () {
      final running = testShift(
        day: monday,
        rawStart: DateTime(2026, 11, 2, 17, 30),
      );
      expect(prompt(DateTime(2026, 11, 2, 20), [running]), isNull);
      expect(prompt(DateTime(2026, 11, 3, 9), [eveningPlanned]), isNull);
    });

    test('not once entered or dismissed', () {
      final night = DateTime(2026, 11, 2, 23, 30);
      expect(
        prompt(night, [eveningDone], tipDays: [tipDay('2026-11-02', 0)]),
        isNull,
      );
      expect(prompt(night, [eveningDone], dismissed: '2026-11-02'), isNull);
    });

    test('today comes before yesterday', () {
      final tuesdayDone = testShift(day: tuesday, actual: '17:30-23:00');
      expect(
        prompt(DateTime(2026, 11, 3, 23, 30), [eveningDone, tuesdayDone]),
        tuesday,
      );
    });
  });

  group('repository', () {
    late AppDatabase db;
    late TipRepository tips;

    setUp(() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      db = AppDatabase(NativeDatabase.memory());
      tips = TipRepository(db);
    });
    tearDown(() => db.close());

    test('day: save, change, clear', () async {
      final day = DateTime(2026, 11, 2);
      Future<List<TipDay>> week() => tips.watchDays(day, addDays(day, 7)).first;

      await tips.setDay(day, 48000);
      final first = (await week()).single;
      expect(first.poolCents, 48000);

      await tips.setDay(day, 0);
      final changed = (await week()).single;
      expect(changed.poolCents, 0);
      expect(changed.id, first.id);

      await tips.setDay(day, null);
      expect(await week(), isEmpty);
      await tips.setDay(day, null); // clearing twice is fine
    });

    test('payout: one per week, range by week start', () async {
      final week = DateTime(2026, 11, 2);
      await tips.setPayout(week, 12000);
      await tips.setPayout(week, 12500);
      await tips.setPayout(DateTime(2026, 11, 30), 9000);
      final november = await tips
          .watchPayouts(week, DateTime(2026, 11, 30))
          .first;
      expect(november.map((p) => p.amountCents), [12500]);
      await tips.setPayout(week, null);
      expect(
        await tips.watchPayouts(week, DateTime(2026, 11, 30)).first,
        isEmpty,
      );
    });
  });
}
