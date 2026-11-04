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
DateTime weekStart(DateTime t) =>
    dateOnly(t).subtract(Duration(days: t.weekday - DateTime.monday));

DateTime addDays(DateTime day, int days) =>
    DateTime(day.year, day.month, day.day + days);

DateTime monthStart(DateTime t) => DateTime(t.year, t.month);
DateTime nextMonthStart(DateTime t) => DateTime(t.year, t.month + 1);

/// ISO 8601 week number ("KW").
int isoWeekNumber(DateTime t) {
  final day = dateOnly(t);
  // The week belongs to the year its Thursday is in.
  final thursday = addDays(day, DateTime.thursday - day.weekday);
  final firstThursday = DateTime(thursday.year, 1, 4);
  final firstWeekStart = weekStart(firstThursday);
  return weekStart(thursday).difference(firstWeekStart).inDays ~/ 7 + 1;
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
  if (!to.isAfter(from)) to = to.add(const Duration(days: 1));
  return (from, to);
}

/// `HH:mm`
String hhmm(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

String minutesToHhmm(Minutes m) => '${_two(m ~/ 60)}:${_two(m % 60)}';

String _two(int n) => n.toString().padLeft(2, '0');
