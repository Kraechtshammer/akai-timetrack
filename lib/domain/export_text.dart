import 'package:intl/intl.dart';

import '../core/format.dart';
import '../core/time.dart';
import '../data/database.dart';
import '../l10n/app_localizations.dart';
import 'shift_info.dart';

/// The weekly message for the boss, e.g.
///
///     Arbeitszeiten KW 44 (26.10.–01.11.2026)
///     Mo 26.10.: 12:00–16:00 (4,0 h)
///     Fr 30.10.: 12:00–15:30 (3,5 h), 17:30–23:00, 30 min Pause (5,0 h)
///     Woche gesamt: 29,0 h
///     Oktober gesamt: 86,25 h
///     November bisher: 5,5 h
///
/// [shifts] must cover the first day of [week]'s month up to the week's end,
/// so the month totals are complete. Only recorded shifts are listed.
String buildExportText({
  required DateTime week,
  required List<Shift> shifts,
  required bool includeMonthTotals,
  required AppLocalizations l10n,
}) {
  final locale = l10n.localeName;
  final from = weekStart(week);
  final to = addDays(from, 7); // exclusive
  final recorded = shifts.where((s) => s.isRecorded).toList()
    ..sort((a, b) => a.actualStart!.compareTo(b.actualStart!));
  bool inRange(Shift s, DateTime a, DateTime b) =>
      !s.dayDate.isBefore(a) && s.dayDate.isBefore(b);

  final dayFormat = DateFormat(l10n.exportDayPattern, locale);
  final lines = <String>[
    l10n.exportHeader(
      isoWeekNumber(from),
      dayFormat.format(from),
      DateFormat(
        l10n.exportDateWithYearPattern,
        locale,
      ).format(addDays(to, -1)),
    ),
  ];

  var weekMinutes = 0;
  for (var day = from; day.isBefore(to); day = addDays(day, 1)) {
    final ofDay = recorded.where((s) => s.day == dayKey(day)).toList();
    if (ofDay.isEmpty) continue;
    final parts = ofDay.map((s) {
      weekMinutes += s.workedMinutes!;
      final time = '${hhmm(s.actualStart!)}–${hhmm(s.actualEnd!)}';
      final pause = s.breakMinutes > 0
          ? ', ${l10n.exportBreak(s.breakMinutes)}'
          : '';
      return '$time$pause (${formatHours(s.workedMinutes!, locale)} h)';
    });
    lines.add(
      '${shortWeekday(day, locale)} ${dayFormat.format(day)}: '
      '${parts.join(', ')}',
    );
  }
  lines.add(l10n.exportWeekTotal(formatHours(weekMinutes, locale)));

  if (includeMonthTotals) {
    // One line per month the week touches, counted up to the week's end.
    final months = {monthStart(from), monthStart(addDays(to, -1))};
    for (final month in months) {
      final end = nextMonthStart(month);
      final minutes = recorded
          .where((s) => inRange(s, month, end.isBefore(to) ? end : to))
          .fold(0, (sum, s) => sum + s.workedMinutes!);
      final name = DateFormat.MMMM(locale).format(month);
      final hours = formatHours(minutes, locale);
      lines.add(
        end.isAfter(to)
            ? l10n.exportMonthSoFar(name, hours)
            : l10n.exportMonthTotal(name, hours),
      );
    }
  }
  return lines.join('\n');
}
