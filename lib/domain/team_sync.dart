// "Sync my shifts with Plan": the team shifts of the person marked "This
// is me" on the Plan tab. Pure Dart. See docs/02-design.md §4.9.

import '../core/time.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import 'planning.dart';
import 'shift_info.dart';

ShiftType shiftTypeOf(TeamShift shift) =>
    shift == TeamShift.lunch ? ShiftType.lunch : ShiftType.evening;

TeamShift? teamShiftOf(ShiftType type) => switch (type) {
  ShiftType.lunch => TeamShift.lunch,
  ShiftType.evening => TeamShift.evening,
  ShiftType.custom => null,
};

/// One change to the Plan tab.
sealed class TeamSyncAction {
  const TeamSyncAction();
}

/// A team shift without a shift of its kind on Plan: add it, with the
/// special start if it has one.
class AddTeamShift extends TeamSyncAction {
  const AddTeamShift(this.day, this.type, this.start);

  final DateTime day;
  final ShiftType type;
  final Minutes? start;

  @override
  bool operator ==(Object other) =>
      other is AddTeamShift &&
      other.day == day &&
      other.type == type &&
      other.start == start;

  @override
  int get hashCode => Object.hash(day, type, start);

  @override
  String toString() => 'add ${dayKey(day)} ${type.name} $start';
}

/// The team shift's start changed: move the copy's start to [start].
class MoveTeamShift extends TeamSyncAction {
  const MoveTeamShift(this.shift, this.start);

  final Shift shift;
  final Minutes start;

  @override
  bool operator ==(Object other) =>
      other is MoveTeamShift &&
      other.shift.id == shift.id &&
      other.start == start;

  @override
  int get hashCode => Object.hash(shift.id, start);

  @override
  String toString() => 'move ${shift.day} ${shift.type.name} $start';
}

/// The team shift is gone: remove its copy.
class RemoveTeamShift extends TeamSyncAction {
  const RemoveTeamShift(this.shift);

  final Shift shift;

  @override
  bool operator ==(Object other) =>
      other is RemoveTeamShift && other.shift.id == shift.id;

  @override
  int get hashCode => shift.id.hashCode;

  @override
  String toString() => 'remove ${shift.day} ${shift.type.name}';
}

/// What to change on Plan so it matches [mine], the team shifts of the
/// person marked "This is me". Only days from [today] on are touched, so
/// the past stays as it was.
///
/// - A team shift with no Lunch or Evening shift of its kind that day is
///   added. A shift the user added there by hand is left as it is.
/// - A copy (`teamStart` set) whose team shift is gone is removed.
/// - A copy follows a changed start, unless its start was edited by hand
///   (it differs from `teamStart`).
/// - Recorded or running shifts are never changed.
List<TeamSyncAction> teamSyncActions({
  required List<TeamAssignment> mine,
  required List<Shift> shifts,
  required DateTime today,
  required AppSettings settings,
}) {
  final first = dayKey(today);
  final future = [
    for (final s in shifts)
      if (s.day.compareTo(first) >= 0) s,
  ];
  Shift? shiftOf(String day, ShiftType type) =>
      future.where((s) => s.day == day && s.type == type).firstOrNull;
  bool locked(Shift s) => s.isRecorded || s.isRunning;

  final wanted = <String, TeamAssignment>{
    for (final a in mine)
      if (a.day.compareTo(first) >= 0) '${a.day} ${a.shift.index}': a,
  };
  final actions = <TeamSyncAction>[];

  for (final a in wanted.values) {
    final type = shiftTypeOf(a.shift);
    final existing = shiftOf(a.day, type);
    final day = parseDayKey(a.day);
    if (existing == null) {
      actions.add(AddTeamShift(day, type, a.startMinutes));
      continue;
    }
    final linked = existing.teamStart;
    if (linked == null || locked(existing)) continue;
    if (minutesOf(existing.plannedStart) != linked) continue;
    final eveningSameDay =
        type == ShiftType.lunch &&
        (wanted.containsKey('${a.day} ${TeamShift.evening.index}') ||
            shiftOf(a.day, ShiftType.evening) != null);
    final start =
        a.startMinutes ??
        defaultTimes(type, settings, eveningSameDay: eveningSameDay).start;
    if (start != linked) actions.add(MoveTeamShift(existing, start));
  }

  for (final s in future) {
    if (s.teamStart == null || locked(s)) continue;
    final team = teamShiftOf(s.type);
    if (team == null || wanted.containsKey('${s.day} ${team.index}')) continue;
    actions.add(RemoveTeamShift(s));
  }
  return actions;
}
