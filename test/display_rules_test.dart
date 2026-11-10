import 'package:akai_timetrack/core/time.dart';
import 'package:akai_timetrack/data/app_settings.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/domain/display_rules.dart';
import 'package:akai_timetrack/domain/roster.dart';
import 'package:akai_timetrack/domain/rounding.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  final day = DateTime(2026, 11, 10);
  final noon = DateTime(2026, 11, 10, 12);

  final recorded = testShift(
    day: day,
    planned: '11:00-15:00',
    actual: '11:00-15:00',
    breakMinutes: 30,
  );
  final missed = testShift(day: day, planned: '09:00-10:00');
  final ahead = testShift(day: day, planned: '17:30-23:00');
  final running = testShift(
    day: day,
    planned: '11:00-15:00',
    rawStart: DateTime(2026, 11, 10, 11),
  );

  group('ShiftSums', () {
    test('sums', () {
      final all = [recorded, ahead];
      expect(all.recordedMinutes, 210);
      expect(all.expectedMinutes, 210 + 330);
      expect(all.recordedDays, 1);
    });
    test('missing counts missed and running', () {
      expect([recorded, missed, running, ahead].missingCount(noon), 2);
    });
    test('recorded days are distinct', () {
      final other = testShift(day: addDays(day, 1), actual: '17:30-23:00');
      expect([recorded, other].recordedDays, 2);
    });
  });

  group('selection', () {
    test('next shift skips recorded, running and past', () {
      expect(nextShift([recorded, missed, running, ahead], noon), ahead);
      expect(nextShift([recorded, missed], noon), isNull);
    });
    test('first missed', () {
      expect(firstMissedShift([recorded, ahead, missed], noon), missed);
      expect(firstMissedShift([recorded, ahead], noon), isNull);
    });
  });

  group('status precedence', () {
    test('day', () {
      expect(dayStatus([], noon), DayStatus.off);
      expect(dayStatus([recorded, missed], noon), DayStatus.missed);
      expect(dayStatus([recorded], noon), DayStatus.recorded);
      expect(dayStatus([recorded, ahead], noon), DayStatus.open);
      expect(dayStatus([running], noon), DayStatus.open);
    });
    test('slot', () {
      expect(slotStatus([missed, recorded], noon), SlotStatus.recorded);
      expect(slotStatus([missed, running], noon), SlotStatus.running);
      expect(slotStatus([missed, ahead], noon), SlotStatus.missed);
      expect(slotStatus([ahead], noon), SlotStatus.planned);
      expect(slotStatus([], noon), SlotStatus.planned);
    });
  });

  test('stop preview rounds and subtracts the break', () {
    final shift = testShift(
      day: day,
      planned: '11:00-15:00',
      breakMinutes: 30,
      rawStart: DateTime(2026, 11, 10, 11, 4),
    );
    final p = stopPreview(
      shift,
      DateTime(2026, 11, 10, 15, 8),
      RoundingMode.nearestQuarter,
    );
    expect(p.start, DateTime(2026, 11, 10, 11));
    expect(p.end, DateTime(2026, 11, 10, 15, 15));
    expect(p.minutes, 255 - 30);
  });

  group('payColumns', () {
    final now = DateTime(2026, 11, 10);
    final current = monthStart(now);
    final past = DateTime(2026, 10);
    final future = DateTime(2026, 12);
    test('current month shows both', () {
      final c = payColumns(month: current, now: now);
      expect((c.earned, c.expected), (true, true));
    });
    test('past month: expected only with a difference', () {
      expect(payColumns(month: past, now: now).expected, isFalse);
      expect(
        payColumns(
          month: past,
          now: now,
          earnedCents: 5,
          expectedCents: 5,
        ).expected,
        isFalse,
      );
      expect(
        payColumns(
          month: past,
          now: now,
          earnedCents: 5,
          expectedCents: 9,
        ).expected,
        isTrue,
      );
      expect(payColumns(month: past, now: now).earned, isTrue);
    });
    test('future month shows expected only', () {
      final c = payColumns(month: future, now: now);
      expect((c.earned, c.expected), (false, true));
    });
  });

  group('Plan toggles', () {
    // Week 46 of 2026: Monday 9 Nov … Sunday 15 Nov.
    final saturday = DateTime(2026, 11, 14);
    final sunday = DateTime(2026, 11, 15);
    // The defaults, but Saturday is open in the evening only.
    final defaults = StaffNeeds.standard.withNeeded(
      DateTime.saturday,
      TeamShift.lunch,
      0,
    );
    final needs = WeekNeeds(const [], defaults);
    const both = [ShiftType.lunch, ShiftType.evening];

    test('team planner off: both toggles every day', () {
      expect(planToggles(sunday, const [], null), both);
      expect(planDayShown(sunday, const [], null), isTrue);
    });
    test('closed shifts have no toggle, closed days are hidden', () {
      expect(planToggles(day, const [], needs), both);
      expect(planToggles(saturday, const [], needs), [ShiftType.evening]);
      expect(planToggles(sunday, const [], needs), isEmpty);
      expect(planDayShown(sunday, const [], needs), isFalse);
    });
    test("the week's own number wins over the default", () {
      final open = WeekNeeds([
        TeamNeed(
          id: 'n',
          day: dayKey(sunday),
          shift: TeamShift.evening,
          needed: 2,
        ),
        TeamNeed(id: 'm', day: dayKey(day), shift: TeamShift.lunch, needed: 0),
      ], defaults);
      expect(planToggles(sunday, const [], open), [ShiftType.evening]);
      expect(planToggles(day, const [], open), [ShiftType.evening]);
    });
    test('a shift in a closed slot keeps its toggle and its day', () {
      final lunch = testShift(
        day: saturday,
        type: ShiftType.lunch,
        planned: '12:00-16:00',
      );
      expect(planToggles(saturday, [lunch], needs), both);
      final custom = testShift(day: sunday, type: ShiftType.custom);
      expect(planToggles(sunday, [custom], needs), isEmpty);
      expect(planDayShown(sunday, [custom], needs), isTrue);
    });
    test('shifts are picked by start day', () {
      final shifts = [ahead, testShift(day: sunday)];
      expect(shifts.on(day), [ahead]);
    });
  });
}
