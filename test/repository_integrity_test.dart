import 'package:akai_timetrack/core/time.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/data/roster_repository.dart';
import 'package:akai_timetrack/data/settings_repository.dart';
import 'package:akai_timetrack/data/shift_repository.dart';
import 'package:akai_timetrack/data/tip_repository.dart';
import 'package:akai_timetrack/data/wage_repository.dart';
import 'package:akai_timetrack/domain/planning.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ShiftRepository shifts;
  late SettingsRepository settings;
  late PlanningService planning;
  var changes = 0;
  final day = DateTime(2026, 11, 6);

  setUp(() {
    changes = 0;
    db = AppDatabase(NativeDatabase.memory());
    shifts = ShiftRepository(db);
    settings = SettingsRepository(db);
    planning = PlanningService(shifts, settings, () async => changes++);
  });
  tearDown(() => db.close());

  Future<Shift> planned() async {
    final (start, end) = timesOn(day, 17 * 60, 22 * 60);
    return shifts.create(
      day: day,
      type: ShiftType.evening,
      plannedStart: start,
      plannedEnd: end,
    );
  }

  group('saveEdited', () {
    test('writes when the row is unchanged', () async {
      final held = (await shifts.get((await planned()).id))!;
      final (start, end) = timesOn(day, 18 * 60, 23 * 60);
      expect(
        await planning.saveEdited(
          held.copyWith(plannedStart: start, plannedEnd: end, breakMinutes: 15),
        ),
        isTrue,
      );
      final stored = (await shifts.get(held.id))!;
      expect(stored.plannedStart, start);
      expect(stored.breakMinutes, 15);
      expect(stored.syncState, SyncState.dirty);
      expect(stored.updatedAt.isAfter(held.updatedAt), isTrue);
      expect(changes, 1);
    });

    test('refuses when the row changed after it was read', () async {
      final held = (await shifts.get((await planned()).id))!;
      // The notification starts a recording meanwhile, even within the
      // same second.
      final raw = DateTime(2026, 11, 6, 17, 31);
      await shifts.save(held.copyWith(rawStart: Value(raw)));

      expect(
        await planning.saveEdited(held.copyWith(breakMinutes: 30)),
        isFalse,
      );
      final stored = (await shifts.get(held.id))!;
      expect(stored.rawStart, raw);
      expect(stored.breakMinutes, 0);
      expect(changes, 0);
    });
  });

  test('create stores all values in one step', () async {
    final (start, end) = timesOn(day, 12 * 60, 16 * 60);
    final (aStart, aEnd) = timesOn(day, 12 * 60, 15 * 60 + 40);
    final shift = await planning.create(
      day,
      ShiftType.lunch,
      start,
      end,
      plannedCustomized: true,
      actualStart: aStart,
      actualEnd: aEnd,
      breakMinutes: 20,
    );
    final stored = (await shifts.get(shift.id))!;
    expect(stored.plannedCustomized, isTrue);
    expect(stored.actualStart, aStart);
    expect(stored.actualEnd, aEnd);
    expect(stored.breakMinutes, 20);
    expect(stored.syncState, SyncState.dirty);
    expect(changes, 1);
  });

  test('create keeps the lunch adjustment', () async {
    await planning.toggle(day, ShiftType.lunch);
    final (start, end) = timesOn(day, 18 * 60, 22 * 60);
    await planning.create(
      day,
      ShiftType.evening,
      start,
      end,
      plannedCustomized: false,
    );
    final lunch = (await shifts.getDays(
      day,
      addDays(day, 1),
    )).firstWhere((s) => s.type == ShiftType.lunch);
    expect(lunch.plannedEnd, atMinutes(day, 15 * 60 + 30));
  });

  test('notification ids stay unique', () async {
    final all = await Future.wait([planned(), planned(), planned()]);
    expect({for (final s in all) s.notifId}, hasLength(3));
  });

  test('settings updates in a row keep both changes', () async {
    await Future.wait([
      settings.update((s) => s.copyWith(calendarName: () => 'A')),
      settings.update((s) => s.copyWith(reminderLeadMinutes: 45)),
    ]);
    final loaded = await settings.load();
    expect(loaded.calendarName, 'A');
    expect(loaded.reminderLeadMinutes, 45);
  });

  test('repeated upserts do not throw', () async {
    final tips = TipRepository(db);
    final wages = WageRepository(db);
    final roster = RosterRepository(db);
    final member = await roster.addMember('Ana');
    await Future.wait([
      tips.setDay(day, 100),
      tips.setDay(day, 200),
      tips.setPayout(day, 100),
      tips.setPayout(day, 200),
      wages.setRate(day, 1300),
      wages.setRate(day, 1400),
      roster.setAnswer(day, member.id, mode: AnswerMode.canWork, marks: 1),
      roster.setAnswer(day, member.id, mode: AnswerMode.canWork, marks: 2),
    ]);
    expect((await wages.watchAll().first).single.hourlyCents, 1400);
    expect(
      (await tips.watchDays(day, addDays(day, 1)).first).single.poolCents,
      200,
    );
  });
}
