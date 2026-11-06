import 'package:intl/intl.dart';

import '../core/format.dart';
import '../core/time.dart';
import '../data/database.dart';
import '../l10n/app_localizations.dart';
import 'shift_info.dart';

/// The monthly message for the boss, grouped by ISO week, e.g.
///
///     Arbeitszeiten Oktober 2026 – AKAI
///
///     KW 40 (01.10.–04.10.)
///     Do 01.10.: 12:00–16:00 (4,0 h)
///     Woche gesamt: 4,0 h
///
///     KW 44 (26.10.–31.10.)
///     Fr 30.10.: 12:00–15:30 (3,5 h), 17:30–23:00, 30 min Pause (5,0 h)
///     Woche gesamt: 8,5 h
///
///     Oktober gesamt: 12,5 h
///
/// Weeks that overlap the month's edges are cut to the days inside the month;
/// their other days belong to the neighbouring month's export. Weeks without
/// recorded shifts are left out. Only recorded shifts are listed. The last
/// line says "bisher" ("so far") while [now] is still inside the month.
/// The header names the [restaurant] when it is set.
String buildExportText({
  required DateTime month,
  required List<Shift> shifts,
  required DateTime now,
  required AppLocalizations l10n,
  String restaurant = '',
}) {
  final locale = l10n.localeName;
  final from = monthStart(month);
  final to = nextMonthStart(month); // exclusive
  final recorded =
      shifts
          .where(
            (s) =>
                s.isRecorded &&
                !s.dayDate.isBefore(from) &&
                s.dayDate.isBefore(to),
          )
          .toList()
        ..sort((a, b) => a.actualStart!.compareTo(b.actualStart!));

  final dayFormat = DateFormat(l10n.exportDayPattern, locale);
  final monthName = DateFormat.yMMMM(locale).format(from);
  final lines = <String>[
    restaurant.trim().isEmpty
        ? l10n.exportHeader(monthName)
        : l10n.exportHeaderAt(monthName, restaurant.trim()),
  ];

  var monthMinutes = 0;
  for (var week = weekStart(from); week.isBefore(to); week = addDays(week, 7)) {
    final first = week.isBefore(from) ? from : week;
    final weekEnd = addDays(week, 7);
    final end = weekEnd.isAfter(to) ? to : weekEnd; // exclusive
    final dayLines = <String>[];
    var weekMinutes = 0;
    for (var day = first; day.isBefore(end); day = addDays(day, 1)) {
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
      dayLines.add(
        '${shortWeekday(day, locale)} ${dayFormat.format(day)}: '
        '${parts.join(', ')}',
      );
    }
    if (dayLines.isEmpty) continue;
    monthMinutes += weekMinutes;
    lines
      ..add('')
      ..add(
        l10n.exportWeekHeader(
          isoWeekNumber(week),
          dayFormat.format(first),
          dayFormat.format(addDays(end, -1)),
        ),
      )
      ..addAll(dayLines)
      ..add(l10n.exportWeekTotal(formatHours(weekMinutes, locale)));
  }

  final name = DateFormat.MMMM(locale).format(from);
  final hours = formatHours(monthMinutes, locale);
  lines
    ..add('')
    ..add(
      now.isBefore(to)
          ? l10n.exportMonthSoFar(name, hours)
          : l10n.exportMonthTotal(name, hours),
    );
  return lines.join('\n');
}
