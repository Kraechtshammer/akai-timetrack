import '../core/time.dart';
import '../data/database.dart';
import 'shift_info.dart';

/// Salary: the user's gross pay from the hours and the hourly wage, without
/// tax and without tips. The rules are in docs/02-design.md §4.8.

/// The hourly rate in cents that applies on [day] (`yyyy-MM-dd`): the newest
/// rate that started on or before it. Days before the first rate use the
/// first rate, so the first rate entered also counts for earlier months.
/// Null if there is no rate. [rates] must be sorted by `validFrom`.
int? rateOn(String day, List<WageRate> rates) {
  if (rates.isEmpty) return null;
  var rate = rates.first;
  for (final r in rates) {
    if (r.validFrom.compareTo(day) > 0) break;
    rate = r;
  }
  return rate.hourlyCents;
}

/// The rates that apply on at least one day of [month], oldest first.
/// Empty if there is no rate. [rates] must be sorted by `validFrom`.
List<WageRate> ratesInMonth(DateTime month, List<WageRate> rates) {
  if (rates.isEmpty) return const [];
  final first = dayKey(monthStart(month));
  final end = dayKey(nextMonthStart(month));
  final inMonth = rates
      .where((r) => r.validFrom.compareTo(first) > 0)
      .where((r) => r.validFrom.compareTo(end) < 0);
  final atStart = rates.lastWhere(
    (r) => r.validFrom.compareTo(first) <= 0,
    orElse: () => rates.first,
  );
  return [if (!inMonth.contains(atStart)) atStart, ...inMonth];
}

/// A month's gross pay.
class MonthPay {
  const MonthPay({
    required this.earnedCents,
    required this.expectedCents,
    required this.earnedMinutes,
    required this.expectedMinutes,
  });

  /// For the recorded shifts ("Earned").
  final int earnedCents;

  /// For the recorded shifts plus all planned, running and missed ones
  /// ("Expected"), like "Planned (incl. recorded)" for the hours.
  final int expectedCents;

  final int earnedMinutes;
  final int expectedMinutes;
}

/// The pay for [shifts], which must be the shifts of one calendar month
/// (salary is paid per month). Each shift is paid at the rate of its day.
/// Null if there is no rate yet.
MonthPay? payForMonth(List<Shift> shifts, List<WageRate> rates, DateTime now) {
  if (rates.isEmpty) return null;
  // Minutes per rate, so cents are rounded once per rate, not per shift.
  final earned = <int, int>{};
  final expected = <int, int>{};
  for (final shift in shifts) {
    final rate = rateOn(shift.day, rates)!;
    expected[rate] = (expected[rate] ?? 0) + shift.expectedMinutes;
    if (shift.statusAt(now) == ShiftStatus.recorded) {
      earned[rate] = (earned[rate] ?? 0) + shift.workedMinutes!;
    }
  }
  int cents(Map<int, int> minutesByRate) => minutesByRate.entries.fold(
    0,
    (sum, e) => sum + (e.key * e.value / 60).round(),
  );
  int minutes(Map<int, int> minutesByRate) =>
      minutesByRate.values.fold(0, (sum, m) => sum + m);
  return MonthPay(
    earnedCents: cents(earned),
    expectedCents: cents(expected),
    earnedMinutes: minutes(earned),
    expectedMinutes: minutes(expected),
  );
}
