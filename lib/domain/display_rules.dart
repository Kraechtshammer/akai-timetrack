import '../core/time.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import 'roster.dart';
import 'rounding.dart';
import 'shift_info.dart';

/// Sums over a list of shifts.
extension ShiftSums on Iterable<Shift> {
  /// The shifts starting on [day].
  Iterable<Shift> on(DateTime day) => where((s) => s.day == dayKey(day));

  /// Worked minutes (after breaks) of the recorded shifts.
  int get recordedMinutes =>
      where((s) => s.isRecorded).fold(0, (sum, s) => sum + s.workedMinutes!);

  /// Worked minutes if recorded, otherwise the planned length, summed.
  int get expectedMinutes => fold(0, (sum, s) => sum + s.expectedMinutes);

  int get recordedCount => where((s) => s.isRecorded).length;

  /// Number of distinct days with at least one recorded shift.
  int get recordedDays =>
      where((s) => s.isRecorded).map((s) => s.day).toSet().length;

  /// Shifts that still need attention: missed or still running.
  int missingCount(DateTime now) => where(
    (s) => const [
      ShiftStatus.missed,
      ShiftStatus.running,
    ].contains(s.statusAt(now)),
  ).length;
}

/// How far ahead the Home tab looks for the next shift.
const nextShiftWindowDays = 15;

/// The first shift that is neither recorded nor running and not over yet.
/// [shifts] must be sorted by time.
Shift? nextShift(Iterable<Shift> shifts, DateTime now) => shifts
    .where((s) => !s.isRecorded && !s.isRunning && s.plannedEnd.isAfter(now))
    .firstOrNull;

/// The first shift whose planned end is over without a recording.
Shift? firstMissedShift(Iterable<Shift> shifts, DateTime now) =>
    shifts.where((s) => s.statusAt(now) == ShiftStatus.missed).firstOrNull;

/// What a day circle in the week strip shows.
enum DayStatus {
  /// No shifts.
  off,

  /// At least one shift was missed.
  missed,

  /// Every shift is recorded.
  recorded,

  /// Anything else: still ahead or running.
  open,
}

/// A missed shift wins, then "all recorded"; the rest is neutral.
DayStatus dayStatus(Iterable<Shift> ofDay, DateTime now) {
  if (ofDay.isEmpty) return DayStatus.off;
  final statuses = ofDay.map((s) => s.statusAt(now)).toList();
  if (statuses.contains(ShiftStatus.missed)) return DayStatus.missed;
  if (statuses.every((s) => s == ShiftStatus.recorded)) {
    return DayStatus.recorded;
  }
  return DayStatus.open;
}

/// What a lunch or evening mark in the week strip shows.
enum SlotStatus { recorded, running, missed, planned }

/// A slot counts as recorded if any of its shifts is; then running, then
/// missed.
SlotStatus slotStatus(Iterable<Shift> slot, DateTime now) {
  final statuses = slot.map((s) => s.statusAt(now)).toSet();
  if (statuses.contains(ShiftStatus.recorded)) return SlotStatus.recorded;
  if (statuses.contains(ShiftStatus.running)) return SlotStatus.running;
  if (statuses.contains(ShiftStatus.missed)) return SlotStatus.missed;
  return SlotStatus.planned;
}

/// What stopping the running shift at [now] would save: the rounded times
/// and the minutes counted after the break.
({DateTime start, DateTime end, int minutes}) stopPreview(
  Shift running,
  DateTime now,
  RoundingMode mode,
) {
  final (start, end) = roundShift(running.rawStart!, now, mode);
  return (
    start: start,
    end: end,
    minutes: end.difference(start).inMinutes - running.breakMinutes,
  );
}

/// Which amounts the pay card shows for [month]. The current month shows
/// both; a past month only what was earned, unless shifts are missing; a
/// future month only what is expected. The cents are null while loading.
({bool earned, bool expected}) payColumns({
  required DateTime month,
  required DateTime now,
  int? earnedCents,
  int? expectedCents,
}) {
  final current = monthStart(now);
  return (
    earned: !month.isAfter(current),
    expected:
        !month.isBefore(current) ||
        (earnedCents != null &&
            expectedCents != null &&
            expectedCents != earnedCents),
  );
}

/// The Lunch and Evening toggles the Plan tab offers on [day]
/// (docs/02-design.md §4.1). A closed shift ("Open shifts" off, or
/// "Staff needed" 0 that week) has no toggle, unless the user already has
/// that shift there, so it can still be removed.
List<ShiftType> planToggles(
  DateTime day,
  Iterable<Shift> ofDay,
  WeekNeeds needs,
) => [
  for (final (type, team) in const [
    (ShiftType.lunch, TeamShift.lunch),
    (ShiftType.evening, TeamShift.evening),
  ])
    if (needs.isOpen(TeamSlot(day, team)) || ofDay.any((s) => s.type == type))
      type,
];

/// The Plan tab hides a day with no toggle and no shift, such as a day the
/// restaurant is closed.
bool planDayShown(DateTime day, Iterable<Shift> ofDay, WeekNeeds needs) =>
    ofDay.isNotEmpty || planToggles(day, ofDay, needs).isNotEmpty;

/// The summary of "Open shifts" in Settings: a run of whole open days
/// (`from` … `to`, weekdays 1–7, e.g. Tuesday–Sunday) when every other day
/// is closed, otherwise only the number of open shifts out of 14.
({int count, (int, int)? days}) openShiftsSummary(StaffNeeds needs) {
  bool open(int wd, TeamShift s) => needs.isOpen(wd, s);
  final count = [
    for (var wd = DateTime.monday; wd <= DateTime.sunday; wd++)
      for (final s in TeamShift.values)
        if (open(wd, s)) 1,
  ].length;
  final whole = [
    for (var wd = DateTime.monday; wd <= DateTime.sunday; wd++)
      if (TeamShift.values.every((s) => open(wd, s))) wd,
  ];
  final isRun =
      whole.isNotEmpty &&
      whole.length * 2 == count &&
      whole.last - whole.first == whole.length - 1;
  return (count: count, days: isRun ? (whole.first, whole.last) : null);
}
