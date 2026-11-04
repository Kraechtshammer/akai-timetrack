import 'package:akai_timetrack/core/time.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/data/settings_repository.dart';
import 'package:akai_timetrack/data/shift_repository.dart';
import 'package:akai_timetrack/domain/planning.dart';
import 'package:akai_timetrack/domain/recording.dart';
import 'package:akai_timetrack/domain/shift_info.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ShiftRepository shifts;
  late PlanningService planning;
  late RecordingService recording;
  final day = DateTime(2026, 11, 6);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    shifts = ShiftRepository(db);
    final settings = SettingsRepository(db);
    planning = PlanningService(shifts, settings, () async {});
    recording = RecordingService(shifts, settings, () async {});
  });
  tearDown(() => db.close());

  Future<List<Shift>> shiftsOfDay() => shifts.getDays(day, addDays(day, 1));

  test('lunch ends at 15:30 while there is an evening shift', () async {
    await planning.toggle(day, ShiftType.lunch);
    expect(hhmm((await shiftsOfDay()).single.plannedEnd), '16:00');

    await planning.toggle(day, ShiftType.evening);
    var lunch = (await shiftsOfDay()).firstWhere(
      (s) => s.type == ShiftType.lunch,
    );
    expect(hhmm(lunch.plannedEnd), '15:30');

    await planning.toggle(day, ShiftType.evening); // remove it again
    lunch = (await shiftsOfDay()).single;
    expect(hhmm(lunch.plannedEnd), '16:00');
  });

  test('hand-edited lunch times are kept', () async {
    await planning.toggle(day, ShiftType.lunch);
    final lunch = (await shiftsOfDay()).single;
    await planning.save(
      lunch.copyWith(
        plannedEnd: atMinutes(day, 14 * 60),
        plannedCustomized: true,
      ),
    );
    await planning.toggle(day, ShiftType.evening);
    final after = (await shiftsOfDay()).firstWhere(
      (s) => s.type == ShiftType.lunch,
    );
    expect(hhmm(after.plannedEnd), '14:00');
  });

  test('recorded shifts are not removed by the toggle', () async {
    await planning.toggle(day, ShiftType.evening);
    await recording.start(at: DateTime(2026, 11, 6, 17, 32));
    await recording.stop(at: DateTime(2026, 11, 6, 22, 41));

    final result = await planning.toggle(day, ShiftType.evening);
    expect(result, ToggleResult.keptRecorded);
    final shift = (await shiftsOfDay()).single;
    expect(shift.isRecorded, isTrue);
    expect(hhmm(shift.actualStart!), '17:30');
    expect(hhmm(shift.actualEnd!), '22:45');
  });

  test('start without a plan creates a shift by the time of day', () async {
    final started = await recording.start(at: DateTime(2026, 11, 6, 11, 50));
    expect(started!.type, ShiftType.lunch);
    expect(started.isRunning, isTrue);
    // A second start while one is running does nothing.
    expect(await recording.start(at: DateTime(2026, 11, 6, 12)), isNull);
  });

  test('deleted shifts with a calendar event wait for the sync', () async {
    await planning.toggle(day, ShiftType.evening);
    final shift = (await shiftsOfDay()).single;
    await shifts.setSynced(
      shift.id,
      eventId: '42',
      calendarId: '1',
      seenUpdatedAt: shift.updatedAt,
    );
    await planning.delete((await shiftsOfDay()).single);
    expect(await shiftsOfDay(), isEmpty); // hidden right away
    final pending = await shifts.needingSync();
    expect(pending.single.syncState, SyncState.pendingDelete);
  });
}
