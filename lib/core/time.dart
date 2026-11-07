// Date and time helpers. Plain Dart, no Flutter.

/// Midnight of the given day (local time).
DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

/// `yyyy-MM-dd`, used as the shift's day key.
String dayKey(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-${_two(t.month)}-${_two(t.day)}';

DateTime parseDayKey(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

/// Monday of the week [t] is in.
DateTime weekStart(DateTime t) => addDays(t, DateTime.monday - t.weekday);

/// Midnight [days] calendar days after [day]. Unlike adding a `Duration`,
/// this stays at midnight across a daylight saving change.
DateTime addDays(DateTime day, int days) =>
    DateTime(day.year, day.month, day.day + days);

/// Calendar days from [from] to [to]. Counted on UTC dates, because a local
/// difference is an hour short across the spring clock change.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

DateTime monthStart(DateTime t) => DateTime(t.year, t.month);
DateTime nextMonthStart(DateTime t) => DateTime(t.year, t.month + 1);

/// ISO 8601 week number ("KW").
int isoWeekNumber(DateTime t) {
  final day = dateOnly(t);
  // The week belongs to the year its Thursday is in.
  final thursday = addDays(day, DateTime.thursday - day.weekday);
  final firstThursday = DateTime(thursday.year, 1, 4);
  final firstWeekStart = weekStart(firstThursday);
  return daysBetween(firstWeekStart, weekStart(thursday)) ~/ 7 + 1;
}

/// A time of day as minutes after midnight, e.g. 17:30 = 1050.
typedef Minutes = int;

Minutes minutesOf(DateTime t) => t.hour * 60 + t.minute;

/// [day] at [minutes] after midnight.
DateTime atMinutes(DateTime day, Minutes minutes) =>
    DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);

/// Start and end on [day]. An end before the start means the next day.
(DateTime, DateTime) timesOn(DateTime day, Minutes start, Minutes end) {
  final from = atMinutes(day, start);
  var to = atMinutes(day, end);
  // The next calendar day, not 24 hours later: on a clock-change night
  // those differ by an hour.
  if (!to.isAfter(from)) to = atMinutes(addDays(day, 1), end);
  return (from, to);
}

/// `HH:mm`
String hhmm(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

String minutesToHhmm(Minutes m) => '${_two(m ~/ 60)}:${_two(m % 60)}';

String _two(int n) => n.toString().padLeft(2, '0');
