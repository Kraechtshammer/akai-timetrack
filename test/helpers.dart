import 'package:akai_timetrack/core/time.dart';
import 'package:akai_timetrack/data/database.dart';

int _nextNotifId = 1;

/// A shift for tests. Times are `HH:mm` on [day].
Shift testShift({
  required DateTime day,
  ShiftType type = ShiftType.evening,
  String planned = '17:30-23:00',
  String? actual,
  int breakMinutes = 0,
  DateTime? rawStart,
}) {
  (DateTime, DateTime) times(String text) {
    final [from, to] = text.split('-').map((t) {
      final [h, m] = t.split(':').map(int.parse).toList();
      return h * 60 + m;
    }).toList();
    return timesOn(day, from, to);
  }

  final (plannedStart, plannedEnd) = times(planned);
  final actualTimes = actual == null ? null : times(actual);
  return Shift(
    id: 'shift-$_nextNotifId',
    notifId: _nextNotifId++,
    day: dayKey(day),
    type: type,
    plannedStart: plannedStart,
    plannedEnd: plannedEnd,
    plannedCustomized: false,
    rawStart: rawStart,
    actualStart: actualTimes?.$1,
    actualEnd: actualTimes?.$2,
    breakMinutes: breakMinutes,
    syncState: SyncState.synced,
    createdAt: day,
    updatedAt: day,
  );
}
