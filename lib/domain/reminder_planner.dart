import '../data/app_settings.dart';
import '../data/database.dart';
import 'shift_info.dart';

enum ReminderKind {
  /// "Schicht beginnt in 15 min"
  start(1),

  /// "Noch bei der Arbeit?"
  overrun(2),

  /// "Später" on a start reminder: once more, 10 minutes later.
  snooze(3);

  const ReminderKind(this.code);
  final int code;
}

/// A notification that should be scheduled.
class PlannedReminder {
  const PlannedReminder(this.shift, this.kind, this.at);

  final Shift shift;
  final ReminderKind kind;
  final DateTime at;

  int get id => notificationId(shift, kind);
}

/// Notification id for a shift's reminder. The running timer uses id 1.
int notificationId(Shift shift, ReminderKind kind) =>
    shift.notifId * 10 + kind.code;

const runningNotificationId = 1;

/// How far ahead start reminders are scheduled. The app tops them up on
/// every start, which keeps the number of alarms small.
const reminderHorizon = Duration(days: 14);

/// Which start and overrun reminders should exist right now.
List<PlannedReminder> planReminders(
  Iterable<Shift> shifts,
  AppSettings settings,
  DateTime now,
) {
  final reminders = <PlannedReminder>[];
  for (final shift in shifts) {
    switch (shift.statusAt(now)) {
      case ShiftStatus.planned:
        final at = shift.plannedStart.subtract(
          Duration(minutes: settings.reminderLeadMinutes),
        );
        if (at.isAfter(now) && at.isBefore(now.add(reminderHorizon))) {
          reminders.add(PlannedReminder(shift, ReminderKind.start, at));
        }
      case ShiftStatus.running:
        final overrun = Duration(minutes: settings.overrunMinutes);
        var at = shift.plannedEnd.add(overrun);
        // Already past (e.g. "Weiter" was tapped): ask again later.
        if (!at.isAfter(now)) at = now.add(overrun);
        reminders.add(PlannedReminder(shift, ReminderKind.overrun, at));
      case ShiftStatus.recorded || ShiftStatus.missed:
        break;
    }
  }
  return reminders;
}
