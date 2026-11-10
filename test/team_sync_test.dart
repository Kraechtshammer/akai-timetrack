import 'package:akai_timetrack/core/time.dart';
import 'package:akai_timetrack/data/app_settings.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/data/roster_repository.dart';
import 'package:akai_timetrack/data/settings_repository.dart';
import 'package:akai_timetrack/data/shift_repository.dart';
import 'package:akai_timetrack/domain/planning.dart';
import 'package:akai_timetrack/domain/roster.dart';
import 'package:akai_timetrack/domain/team_sync.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

// "Sync my shifts with Plan", docs/02-design.md §4.9.

final today = DateTime(2026, 11, 10);
final thursday = DateTime(2026, 11, 12);
final yesterday = DateTime(2026, 11, 9);
final created = DateTime(2026, 11, 1);
const settings = AppSettings();

TeamAssignment mine(DateTime day, TeamShift shift, {int? start}) =>
    TeamAssignment(
      id: 'a-${dayKey(day)}-${shift.name}',
      day: dayKey(day),
      shift: shift,
      memberId: 'me',
      startMinutes: start,
      createdAt: created,
      updatedAt: created,
    );

/// A copy from the team plan, taken with [teamStart].
Shift copy(
  DateTime day,
  ShiftType type, {
  String planned = '17:30-23:00',
  int teamStart = 17 * 60 + 30,
  String? actual,
}) => testShift(
  day: day,
  type: type,
  planned: planned,
  actual: actual,
).copyWith(teamStart: Value(teamStart));

List<TeamSyncAction> actions(
  List<TeamAssignment> assignments,
  List<Shift> shifts,
) => teamSyncActions(
  mine: assignments,
  shifts: shifts,
  today: today,
  settings: settings,
);

void main() {
  group('what to change', () {
    test('a team shift without a shift on Plan is added', () {
      expect(
        actions([
          mine(thursday, TeamShift.lunch),
          mine(thursday, TeamShift.evening, start: 18 * 60 + 30),
        ], const []),
        [
          AddTeamShift(thursday, ShiftType.lunch, null),
          AddTeamShift(thursday, ShiftType.evening, 18 * 60 + 30),
        ],
      );
    });

    test('a shift the user added by hand is left as it is', () {
      final own = testShift(day: thursday);
      expect(actions([mine(thursday, TeamShift.evening)], [own]), isEmpty);
      expect(actions(const [], [own]), isEmpty);
    });

    test('a copy whose team shift is gone is removed, unless recorded', () {
      final planned = copy(thursday, ShiftType.evening);
      final recorded = copy(today, ShiftType.evening, actual: '17:30-23:00');
      expect(actions(const [], [planned, recorded]), [
        RemoveTeamShift(planned),
      ]);
    });

    test('a copy follows a new start, unless edited by hand', () {
      final shift = copy(thursday, ShiftType.evening);
      final later = mine(thursday, TeamShift.evening, start: 18 * 60 + 30);
      expect(actions([later], [shift]), [MoveTeamShift(shift, 18 * 60 + 30)]);

      final edited = copy(thursday, ShiftType.evening, planned: '18:00-23:00');
      expect(actions([later], [edited]), isEmpty);

      final recorded = copy(today, ShiftType.evening, actual: '17:30-23:00');
      expect(
        actions([mine(today, TeamShift.evening, start: 19 * 60)], [recorded]),
        isEmpty,
      );
    });

    test('a special start taken away goes back to the normal start', () {
      final shift = copy(
        thursday,
        ShiftType.evening,
        planned: '18:30-23:00',
        teamStart: 18 * 60 + 30,
      );
      expect(actions([mine(thursday, TeamShift.evening)], [shift]), [
        MoveTeamShift(shift, 17 * 60 + 30),
      ]);
    });

    test('the past is never changed', () {
      final old = copy(yesterday, ShiftType.evening);
      expect(actions([mine(yesterday, TeamShift.lunch)], [old]), isEmpty);
    });
  });

  group('on the Plan tab', () {
    late AppDatabase db;
    late RosterRepository roster;
    late ShiftRepository shifts;
    late SettingsRepository settingsRepo;
    late PlanningService planning;
    late TeamMember me;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      roster = RosterRepository(db);
      shifts = ShiftRepository(db);
      settingsRepo = SettingsRepository(db);
      planning = PlanningService(
        shifts,
        settingsRepo,
        () async {},
        roster: roster,
      );
      me = await roster.addMember('Me', isMe: true);
      await settingsRepo.update(
        (s) => s.copyWith(teamPlanner: true, teamSyncPlan: true),
      );
    });
    tearDown(() => db.close());

    Future<List<Shift>> onThursday() =>
        shifts.getDays(thursday, addDays(thursday, 1));

    test('only while "Sync my shifts with Plan" is on', () async {
      await roster.assign(TeamSlot(thursday, TeamShift.evening), me.id);
      await settingsRepo.update((s) => s.copyWith(teamSyncPlan: false));
      expect(await planning.syncTeamShifts(today), 0);
      expect(await onThursday(), isEmpty);
    });

    test('copies come and go with the team plan', () async {
      await roster.assign(TeamSlot(thursday, TeamShift.lunch), me.id);
      await roster.assign(TeamSlot(thursday, TeamShift.evening), me.id);
      expect(await planning.syncTeamShifts(today), 2);
      var day = await onThursday();
      final lunch = day.firstWhere((s) => s.type == ShiftType.lunch);
      expect(hhmm(lunch.plannedEnd), '15:30'); // evening that day
      expect(lunch.teamStart, 12 * 60);
      expect(await planning.syncTeamShifts(today), 0);

      await roster.unassign(TeamSlot(thursday, TeamShift.evening), me.id);
      expect(await planning.syncTeamShifts(today), 1);
      day = await onThursday();
      expect(day.map((s) => s.type), [ShiftType.lunch]);
      expect(hhmm(day.single.plannedEnd), '16:00');
    });

    test('a special start is copied and followed', () async {
      final slot = TeamSlot(thursday, TeamShift.evening);
      await roster.assignAt(slot, me.id, 18 * 60 + 30);
      await planning.syncTeamShifts(today);
      var evening = (await onThursday()).single;
      expect(hhmm(evening.plannedStart), '18:30');
      expect(evening.plannedCustomized, isTrue);

      final row = (await roster.assignmentsOf(me.id, today)).single;
      await roster.setStart(row, null);
      expect(await planning.syncTeamShifts(today), 1);
      evening = (await onThursday()).single;
      expect(hhmm(evening.plannedStart), '17:30');
      expect(hhmm(evening.plannedEnd), '23:00');
      expect(evening.plannedCustomized, isFalse);
    });

    test('turning a copy off on Plan also leaves the team shift', () async {
      await roster.assign(TeamSlot(thursday, TeamShift.evening), me.id);
      await planning.syncTeamShifts(today);
      final result = await planning.toggle(thursday, ShiftType.evening);
      expect(result, ToggleResult.removedFromTeam);
      expect(await roster.assignmentsOf(me.id, today), isEmpty);
      expect(await planning.syncTeamShifts(today), 0);

      // A shift added by hand is just removed.
      await planning.toggle(thursday, ShiftType.lunch);
      expect(
        await planning.toggle(thursday, ShiftType.lunch),
        ToggleResult.removed,
      );
    });

    test('deleting a copy and undoing puts it back into the team', () async {
      await roster.assignAt(
        TeamSlot(thursday, TeamShift.evening),
        me.id,
        18 * 60,
      );
      await planning.syncTeamShifts(today);
      final shift = (await onThursday()).single;
      expect(await planning.delete(shift), isTrue);
      expect(await roster.assignmentsOf(me.id, today), isEmpty);

      await planning.restore(shift);
      final back = (await roster.assignmentsOf(me.id, today)).single;
      expect(back.startMinutes, 18 * 60);
      expect(await planning.syncTeamShifts(today), 0);
    });
  });
}
