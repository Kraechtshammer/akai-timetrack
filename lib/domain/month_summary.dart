import '../data/database.dart';
import 'shift_info.dart';

/// Figures for the month card on the Home tab.
class MonthSummary {
  const MonthSummary({
    required this.recordedMinutes,
    required this.expectedMinutes,
    required this.upcomingShifts,
    required this.upcomingMinutes,
    required this.missedShifts,
  });

  /// Hours actually worked (after breaks).
  final int recordedMinutes;

  /// Recorded plus everything still planned (including missed shifts).
  final int expectedMinutes;

  /// Planned and running shifts that still count towards the month.
  final int upcomingShifts;
  final int upcomingMinutes;

  /// Shifts in the past that were never recorded ("nicht erfasst").
  final int missedShifts;

  /// Share of the expected hours already recorded, 0..1.
  double get progress =>
      expectedMinutes == 0 ? 0 : recordedMinutes / expectedMinutes;
}

/// Sums up the shifts of one month (the caller picks the month).
MonthSummary summarizeMonth(List<Shift> shifts, DateTime now) {
  var recorded = 0, expected = 0, upcoming = 0, upcomingMinutes = 0;
  var missed = 0;
  for (final shift in shifts) {
    expected += shift.expectedMinutes;
    switch (shift.statusAt(now)) {
      case ShiftStatus.recorded:
        recorded += shift.workedMinutes!;
      case ShiftStatus.planned || ShiftStatus.running:
        upcoming++;
        upcomingMinutes += shift.plannedMinutes;
      case ShiftStatus.missed:
        missed++;
    }
  }
  return MonthSummary(
    recordedMinutes: recorded,
    expectedMinutes: expected,
    upcomingShifts: upcoming,
    upcomingMinutes: upcomingMinutes,
    missedShifts: missed,
  );
}
