/// How recorded Start/Stop times become counted times.
enum RoundingMode {
  /// Both to the nearest quarter hour (default).
  nearestQuarter,

  /// Start down, end up.
  inFavour,

  /// Start up, end down.
  strict,
}

const _quarter = 15 * 60; // seconds

enum _Direction { nearest, down, up }

DateTime _round(DateTime t, _Direction direction) {
  final hour = DateTime(t.year, t.month, t.day, t.hour);
  final seconds = t.difference(hour).inSeconds;
  final quarters = switch (direction) {
    // Exactly 7:30 past rounds up.
    _Direction.nearest => (seconds + _quarter ~/ 2) ~/ _quarter,
    _Direction.down => seconds ~/ _quarter,
    _Direction.up => (seconds + _quarter - 1) ~/ _quarter,
  };
  return hour.add(Duration(seconds: quarters * _quarter));
}

/// Rounds a recorded shift. The result is always at least 15 minutes long.
(DateTime, DateTime) roundShift(
  DateTime start,
  DateTime end,
  RoundingMode mode,
) {
  final (startDir, endDir) = switch (mode) {
    RoundingMode.nearestQuarter => (_Direction.nearest, _Direction.nearest),
    RoundingMode.inFavour => (_Direction.down, _Direction.up),
    RoundingMode.strict => (_Direction.up, _Direction.down),
  };
  final from = _round(start, startDir);
  var to = _round(end, endDir);
  if (!to.isAfter(from)) to = from.add(const Duration(minutes: 15));
  return (from, to);
}
