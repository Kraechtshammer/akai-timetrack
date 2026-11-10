import 'package:drift/drift.dart' show Value;

import '../core/time.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import '../data/roster_repository.dart';
import '../data/settings_repository.dart';
import '../data/shift_repository.dart';
import 'roster.dart';
import 'shift_info.dart';
import 'team_sync.dart';

/// Default times for a new shift. Lunch ends earlier when there is an
/// evening shift on the same day.
ShiftTimes defaultTimes(
  ShiftType type,
  AppSettings settings, {
  bool eveningSameDay = false,
}) => switch (type) {
  ShiftType.lunch =>
    eveningSameDay ? settings.lunchBeforeEvening : settings.lunch,
  ShiftType.evening => settings.evening,
  ShiftType.custom => const ShiftTimes(18 * 60, 22 * 60),
};

enum ToggleResult {
  added,
  removed,

  /// Removed, and the user was taken out of the team shift too.
  removedFromTeam,
  keptRecorded,
}

/// Planning on the Plan tab: add, change and remove shifts.
class PlanningService {
  PlanningService(
    this._shifts,
    this._settings,
    this._onChanged, {
    this._roster,
  });

  final ShiftRepository _shifts;
  final SettingsRepository _settings;

  /// For "Sync my shifts with Plan"; null in tests that don't need it.
  final RosterRepository? _roster;

  /// Runs calendar sync and notification updates after a change.
  final Future<void> Function() _onChanged;

  /// Tap on "Lunch" or "Evening": adds the shift or removes it again.
  /// Recorded or running shifts are never removed this way.
  Future<ToggleResult> toggle(DateTime day, ShiftType type) async {
    final shifts = await _shiftsOn(day);
    final existing = shifts.where((s) => s.type == type).firstOrNull;

    final ToggleResult result;
    if (existing == null) {
      final settings = await _settings.load();
      final hasEvening = shifts.any((s) => s.type == ShiftType.evening);
      final times = defaultTimes(type, settings, eveningSameDay: hasEvening);
      final (start, end) = timesOn(day, times.start, times.end);
      await _shifts.create(
        day: day,
        type: type,
        plannedStart: start,
        plannedEnd: end,
      );
      result = ToggleResult.added;
    } else if (existing.isRecorded || existing.isRunning) {
      return ToggleResult.keptRecorded;
    } else {
      await _shifts.delete(existing);
      result = await _leaveTeamShift(existing)
          ? ToggleResult.removedFromTeam
          : ToggleResult.removed;
    }

    await _adjustLunch(day);
    await _onChanged();
    return result;
  }

  /// Creates a shift from the edit sheet with all its values in one step.
  Future<Shift> create(
    DateTime day,
    ShiftType type,
    DateTime plannedStart,
    DateTime plannedEnd, {
    required bool plannedCustomized,
    DateTime? actualStart,
    DateTime? actualEnd,
    int breakMinutes = 0,
  }) async {
    final shift = await _shifts.create(
      day: day,
      type: type,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      plannedCustomized: plannedCustomized,
      actualStart: actualStart,
      actualEnd: actualEnd,
      breakMinutes: breakMinutes,
    );
    await _adjustLunch(day);
    await _onChanged();
    return shift;
  }

  /// Saves a shift the edit sheet held for a while. Returns false (and
  /// writes nothing) if the shift changed meanwhile, e.g. from the
  /// notification.
  Future<bool> saveEdited(Shift shift) async {
    if (!await _shifts.saveEdited(shift)) return false;
    await _adjustLunch(shift.dayDate);
    await _onChanged();
    return true;
  }

  Future<void> save(Shift shift) async {
    await _shifts.save(shift);
    await _adjustLunch(shift.dayDate);
    await _onChanged();
  }

  /// Returns true if the user was taken out of the team shift too.
  Future<bool> delete(Shift shift) async {
    await _shifts.delete(shift);
    final left = await _leaveTeamShift(shift);
    await _adjustLunch(shift.dayDate);
    await _onChanged();
    return left;
  }

  /// Undo of [delete]: a copied team shift also goes back into the team
  /// plan, with its special start.
  Future<void> restore(Shift shift) async {
    await _shifts.restore(shift);
    final me = await _syncedMe();
    final team = teamShiftOf(shift.type);
    final linked = shift.teamStart;
    if (me != null && team != null && linked != null) {
      final normal = (await _settings.load()).teamStarts.of(team);
      await _roster!.assignAt(
        TeamSlot(shift.dayDate, team),
        me.id,
        linked == normal ? null : linked,
      );
    }
    await _adjustLunch(shift.dayDate);
    await _onChanged();
  }

  /// "Sync my shifts with Plan" on, with a person marked "This is me".
  Future<TeamMember?> _syncedMe() async {
    final roster = _roster;
    if (roster == null) return null;
    final settings = await _settings.load();
    if (!settings.teamPlanner || !settings.teamSyncPlan) return null;
    return roster.me();
  }

  /// A copied team shift was removed on Plan: take the user out of the
  /// team shift too, so both agree. Returns whether that happened.
  Future<bool> _leaveTeamShift(Shift shift) async {
    final team = teamShiftOf(shift.type);
    if (shift.teamStart == null || team == null) return false;
    final me = await _syncedMe();
    if (me == null) return false;
    await _roster!.unassign(TeamSlot(shift.dayDate, team), me.id);
    return true;
  }

  /// "Sync my shifts with Plan" (docs/02-design.md §4.9): makes the Plan
  /// tab match the team shifts of the person marked "This is me", from
  /// [today] on (see [teamSyncActions]). Does nothing while the setting
  /// is off or nobody is marked. Returns the number of changes.
  Future<int> syncTeamShifts(DateTime today) async {
    final me = await _syncedMe();
    if (me == null) return 0;
    final settings = await _settings.load();
    final from = dateOnly(today);
    final actions = teamSyncActions(
      mine: await _roster!.assignmentsOf(me.id, from),
      shifts: await _shifts.getDays(from, addDays(from, 400)),
      today: from,
      settings: settings,
    );
    // Evenings first, so a lunch on the same day gets the shorter default.
    int order(TeamSyncAction a) =>
        a is AddTeamShift && a.type == ShiftType.evening ? 0 : 1;
    for (final action in [...actions]..sort((a, b) => order(a) - order(b))) {
      final DateTime day;
      switch (action) {
        case AddTeamShift(:final type, :final start):
          day = action.day;
          final shifts = await _shiftsOn(day);
          if (shifts.any((s) => s.type == type)) continue;
          final times = defaultTimes(
            type,
            settings,
            eveningSameDay: shifts.any((s) => s.type == ShiftType.evening),
          );
          final (plannedStart, plannedEnd) = timesOn(
            day,
            start ?? times.start,
            times.end,
          );
          await _shifts.create(
            day: day,
            type: type,
            plannedStart: plannedStart,
            plannedEnd: plannedEnd,
            plannedCustomized: start != null && start != times.start,
            teamStart: start ?? times.start,
          );
        case MoveTeamShift(:final shift, :final start):
          day = shift.dayDate;
          final normal = defaultTimes(
            shift.type,
            settings,
            eveningSameDay:
                shift.type == ShiftType.lunch &&
                (await _shiftsOn(day)).any((s) => s.type == ShiftType.evening),
          ).start;
          final (plannedStart, _) = timesOn(day, start, start);
          await _shifts.save(
            shift.copyWith(
              plannedStart: plannedStart,
              plannedCustomized: start != normal,
              teamStart: Value(start),
            ),
          );
        case RemoveTeamShift(:final shift):
          day = shift.dayDate;
          await _shifts.delete(shift);
      }
      await _adjustLunch(day);
    }
    if (actions.isNotEmpty) await _onChanged();
    return actions.length;
  }

  /// "Add my shifts to Plan" on the team board (docs/02-design.md §4.9).
  /// Adds each shift unless the user already has one of that kind on that
  /// day, with the default times, or with a special start (the end stays,
  /// and the shift counts as edited by hand). Returns how many were added.
  Future<int> addFromTeamPlan(
    List<({DateTime day, ShiftType type, Minutes? start})> wanted,
  ) async {
    // Evenings first, so a lunch on the same day gets the shorter default.
    final sorted = [...wanted]
      ..sort(
        (a, b) => (a.type == ShiftType.evening ? 0 : 1).compareTo(
          b.type == ShiftType.evening ? 0 : 1,
        ),
      );
    final settings = await _settings.load();
    var added = 0;
    for (final w in sorted) {
      final shifts = await _shiftsOn(w.day);
      if (shifts.any((s) => s.type == w.type)) continue;
      final hasEvening = shifts.any((s) => s.type == ShiftType.evening);
      final times = defaultTimes(w.type, settings, eveningSameDay: hasEvening);
      final (start, end) = timesOn(w.day, w.start ?? times.start, times.end);
      await _shifts.create(
        day: w.day,
        type: w.type,
        plannedStart: start,
        plannedEnd: end,
        plannedCustomized: w.start != null && w.start != times.start,
      );
      await _adjustLunch(w.day);
      added++;
    }
    if (added > 0) await _onChanged();
    return added;
  }

  /// Keeps an untouched lunch shift at the right default:
  /// 12:00–15:30 with an evening shift that day, otherwise 12:00–16:00.
  Future<void> _adjustLunch(DateTime day) async {
    final shifts = await _shiftsOn(day);
    final lunch = shifts.where((s) => s.type == ShiftType.lunch).firstOrNull;
    if (lunch == null ||
        lunch.plannedCustomized ||
        lunch.isRecorded ||
        lunch.isRunning) {
      return;
    }
    final hasEvening = shifts.any((s) => s.type == ShiftType.evening);
    final times = defaultTimes(
      ShiftType.lunch,
      await _settings.load(),
      eveningSameDay: hasEvening,
    );
    final (start, end) = timesOn(day, times.start, times.end);
    if (start != lunch.plannedStart || end != lunch.plannedEnd) {
      await _shifts.save(lunch.copyWith(plannedStart: start, plannedEnd: end));
    }
  }

  Future<List<Shift>> _shiftsOn(DateTime day) =>
      _shifts.getDays(dateOnly(day), addDays(day, 1));
}
