import '../core/time.dart';
import '../data/database.dart';

enum ShiftStatus {
  /// Not recorded yet, still ahead.
  planned,

  /// Recording is running.
  running,

  /// Has counted (actual) times.
  recorded,

  /// Planned end is over, but nothing was recorded ("nicht erfasst").
  missed,
}

/// Handy read-only facts about a shift.
extension ShiftInfo on Shift {
  bool get isRunning => rawStart != null && rawEnd == null;
  bool get isRecorded => actualStart != null && actualEnd != null;

  ShiftStatus statusAt(DateTime now) {
    if (isRecorded) return ShiftStatus.recorded;
    if (isRunning) return ShiftStatus.running;
    if (plannedEnd.isBefore(now)) return ShiftStatus.missed;
    return ShiftStatus.planned;
  }

  DateTime get dayDate => parseDayKey(day);

  int get plannedMinutes => plannedEnd.difference(plannedStart).inMinutes;

  /// Counted minutes after the break, or null if not recorded.
  int? get workedMinutes => isRecorded
      ? actualEnd!.difference(actualStart!).inMinutes - breakMinutes
      : null;

  /// Worked minutes if recorded, otherwise the planned length.
  int get expectedMinutes => workedMinutes ?? plannedMinutes;

  /// Times to show and to put in the calendar.
  DateTime get shownStart => actualStart ?? plannedStart;
  DateTime get shownEnd => actualEnd ?? plannedEnd;
}
