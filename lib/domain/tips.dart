import '../core/time.dart';
import '../data/database.dart';
import 'shift_info.dart';

/// Tips (F10): the rules from docs/02-design.md §4.7.

/// Largest amount accepted in the money field: 100 000 €.
const maxTipCents = 10000000;

/// Parses a euro amount as typed: `40`, `40,5`, `40,50`, `40.50`, with or
/// without `€`. Returns cents, or null if the text isn't a valid amount
/// (empty, negative, more than two decimals, too large).
///
/// `,` or `.` is the decimal mark if one or two digits follow it, whatever
/// the language (phone keyboards differ). Thousands may be grouped only with
/// the [locale]'s mark: `1.234,50` in German, `1,234.50` in English. So
/// `40,505` is rejected in German instead of becoming 40 505 €.
int? parseEuroCents(String text, String locale) {
  final t = text.replaceAll(RegExp(r'[\s€\u00a0]'), '');
  final match = RegExp(r'^(\d[\d.,]*?)(?:[.,](\d{1,2}))?$').firstMatch(t);
  if (match == null) return null;
  final whole = match.group(1)!;
  final fraction = match.group(2) ?? '';
  final group = RegExp.escape(locale.startsWith('de') ? '.' : ',');
  if (!RegExp('^(\\d+|\\d{1,3}($group\\d{3})+)\$').hasMatch(whole)) {
    return null;
  }
  final digits = whole.replaceAll(RegExp(r'[.,]'), '');
  final cents = int.parse(digits) * 100 + int.parse(fraction.padRight(2, '0'));
  return cents > maxTipCents ? null : cents;
}

/// The month a tip week counts for: the month of its Thursday, the same
/// rule as ISO week numbers.
DateTime tipMonthOf(DateTime week) =>
    monthStart(addDays(weekStart(week), DateTime.thursday - 1));

/// The Mondays of the tip weeks that count for [month], as [from, to).
(DateTime, DateTime) tipWeeksOf(DateTime month) {
  DateTime firstThursday(DateTime m) {
    final first = monthStart(m);
    return addDays(first, (DateTime.thursday - first.weekday) % 7);
  }

  return (
    weekStart(firstThursday(month)),
    weekStart(firstThursday(nextMonthStart(month))),
  );
}

/// The month's tips: the sum of the payouts of its weeks.
class TipMonth {
  const TipMonth({required this.totalCents, required this.weeks});

  final int totalCents;

  /// How many weeks have a payout.
  final int weeks;

  /// Sums [payouts], which must be the payouts of the month's weeks.
  factory TipMonth.of(List<TipPayout> payouts) => TipMonth(
    totalCents: payouts.fold(0, (sum, p) => sum + p.amountCents),
    weeks: payouts.length,
  );
}

/// The workdays of a week, up to [today]: days with a shift, and days with
/// a stored pool total (so an entry never disappears when its shift is
/// deleted). [shifts] and [tipDays] are those of the week.
List<DateTime> tipWorkdays({
  required List<Shift> shifts,
  required List<TipDay> tipDays,
  required DateTime today,
}) {
  final last = dayKey(today);
  final keys = {
    for (final s in shifts)
      if (s.day.compareTo(last) <= 0) s.day,
    for (final t in tipDays) t.day,
  }.toList()..sort();
  return keys.map(parseDayKey).toList();
}

/// The day the "Add the tips" prompt on the Home tab asks about, or null.
///
/// The newest of today and yesterday that has a recorded shift, no shift
/// still running or planned, no pool total, and wasn't dismissed.
/// [shifts] and [tipDays] must cover at least yesterday and today.
DateTime? tipPromptDay({
  required DateTime now,
  required List<Shift> shifts,
  required List<TipDay> tipDays,
  String? dismissedDay,
}) {
  final today = dateOnly(now);
  for (final day in [today, addDays(today, -1)]) {
    final key = dayKey(day);
    if (key == dismissedDay) continue;
    if (tipDays.any((t) => t.day == key)) continue;
    final ofDay = shifts.where((s) => s.day == key).toList();
    final recorded = ofDay.any((s) => s.isRecorded);
    final open = ofDay.any((s) {
      final status = s.statusAt(now);
      return status == ShiftStatus.running || status == ShiftStatus.planned;
    });
    if (recorded && !open) return day;
  }
  return null;
}
