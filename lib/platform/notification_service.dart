import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:running_progress/running_progress.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/time.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import '../domain/reminder_planner.dart';
import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';

/// Button ids in notifications. See AppServices.handleNotificationAction.
abstract final class NotificationAction {
  static const start = 'start';
  static const later = 'later';
  static const stop = 'stop';
  static const stopAtPlannedEnd = 'stopAtPlannedEnd';
  static const keepGoing = 'keepGoing';
}

const _remindersChannel = 'reminders';
const _recordingChannel = 'recording';
const _overrunChannel = 'overrun';

/// Accent of the running notification and its progress bar (AKAI-Rot).
const _accentColor = 0xFFC62828;

/// Shows and schedules the app's notifications.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Called once by the app (not by the background isolate).
  Future<void> initialize({
    required void Function(NotificationResponse) onResponse,
    required void Function(NotificationResponse) onBackgroundResponse,
    required AppLocalizations l10n,
  }) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
    await createChannels(l10n);
  }

  /// Creates the channels (or renames them after a language change).
  /// Users can tune each channel in Android's settings.
  Future<void> createChannels(AppLocalizations l10n) async {
    final android = _android;
    if (android == null) return;
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        _remindersChannel,
        l10n.channelReminders,
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        _recordingChannel,
        l10n.channelRecording,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        _overrunChannel,
        l10n.channelOverrun,
        importance: Importance.high,
      ),
    );
  }

  /// Brings scheduled and shown notifications in line with the shifts:
  /// start reminders, the "still working?" question and the running timer.
  Future<void> reconcile({
    required List<Shift> shifts,
    required Shift? running,
    required AppSettings settings,
    required AppLocalizations l10n,
    required DateTime now,
  }) async {
    final wanted = planReminders(shifts, settings, now);
    final wantedIds = wanted.map((r) => r.id).toSet();

    // Remove start/overrun reminders that are no longer wanted, and snoozes
    // whose shift is gone, started or recorded.
    final pendingRequests = await _plugin.pendingNotificationRequests();
    for (final id in staleSnoozeIds(
      pendingRequests.map((p) => p.id),
      shifts,
      now,
    )) {
      await _plugin.cancel(id: id);
    }
    for (final pending in pendingRequests) {
      final kind = pending.id % 10;
      final managed =
          kind == ReminderKind.start.code || kind == ReminderKind.overrun.code;
      if (managed && !wantedIds.contains(pending.id)) {
        await _plugin.cancel(id: pending.id);
      }
    }

    final exact = await _android?.canScheduleExactNotifications() ?? false;
    for (final reminder in wanted) {
      await _schedule(reminder, settings, l10n, exact: exact);
    }

    if (running != null) {
      await _showRunning(running, l10n);
      await _plugin.cancel(id: notificationId(running, ReminderKind.snooze));
    } else {
      await _plugin.cancel(id: runningNotificationId);
      await _stopProgress();
    }
  }

  /// "Later": the start reminder once more, in 10 minutes.
  Future<void> snooze(
    Shift shift,
    AppSettings settings,
    AppLocalizations l10n,
  ) async {
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    final at = DateTime.now().add(const Duration(minutes: 10));
    await _schedule(
      PlannedReminder(shift, ReminderKind.snooze, at),
      settings,
      l10n,
      exact: exact,
    );
  }

  Future<void> _schedule(
    PlannedReminder reminder,
    AppSettings settings,
    AppLocalizations l10n, {
    required bool exact,
  }) async {
    final shift = reminder.shift;
    final shiftText = l10n.notifShiftBody(
      shiftTypeLabel(shift.type, l10n),
      hhmm(shift.plannedStart),
      hhmm(shift.plannedEnd),
    );
    final (title, body, details) = switch (reminder.kind) {
      ReminderKind.start || ReminderKind.snooze => (
        l10n.notifStartTitle(
          shift.plannedStart.difference(reminder.at).inMinutes,
        ),
        shiftText,
        _details(_remindersChannel, Importance.high, [
          AndroidNotificationAction(NotificationAction.start, l10n.actionStart),
          AndroidNotificationAction(NotificationAction.later, l10n.actionLater),
        ]),
      ),
      ReminderKind.overrun => (
        l10n.notifOverrunTitle,
        l10n.notifOverrunBody(hhmm(shift.plannedEnd)),
        _details(_overrunChannel, Importance.high, [
          AndroidNotificationAction(
            NotificationAction.stopAtPlannedEnd,
            l10n.actionEndAt(hhmm(shift.plannedEnd)),
          ),
          AndroidNotificationAction(
            NotificationAction.stop,
            l10n.actionStopNow,
          ),
          AndroidNotificationAction(
            NotificationAction.keepGoing,
            l10n.actionKeepGoing,
          ),
        ]),
      ),
    };
    await _plugin.zonedSchedule(
      id: reminder.id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(reminder.at, tz.local),
      notificationDetails: details,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: shift.id,
    );
  }

  /// The ongoing "Recording" notification. Android draws the running
  /// timer itself from the start time, so the app doesn't need to run. The
  /// progress bar (from the start to the planned end) is moved forward by
  /// the running_progress plugin; on Android 16 it becomes a Live Update.
  Future<void> _showRunning(Shift shift, AppLocalizations l10n) async {
    final start = shift.rawStart!;
    final end = shift.plannedEnd.isAfter(start)
        ? shift.plannedEnd
        : start.add(const Duration(hours: 1));
    await _postRunning(
      shift,
      l10n,
      runningProgress(start, end, DateTime.now()),
    );
    try {
      await RunningProgress.start(
        notificationId: runningNotificationId,
        start: start,
        end: end,
        color: _accentColor,
      );
    } catch (e) {
      // The notification still shows the bar from the moment it was posted.
      debugPrint('Running progress failed: $e');
    }
  }

  Future<void> _stopProgress() async {
    try {
      await RunningProgress.stop();
    } catch (e) {
      debugPrint('Running progress stop failed: $e');
    }
  }

  Future<void> _postRunning(Shift shift, AppLocalizations l10n, int progress) =>
      _plugin.show(
        id: runningNotificationId,
        title: l10n.recordingRunning,
        body: l10n.notifRunningBody(
          shiftTypeLabel(shift.type, l10n),
          hhmm(shift.rawStart!),
          hhmm(shift.plannedEnd),
        ),
        payload: shift.id,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _recordingChannel,
            l10n.channelRecording,
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            silent: true,
            usesChronometer: true,
            when: shift.rawStart!.millisecondsSinceEpoch,
            category: AndroidNotificationCategory.stopwatch,
            color: const Color(_accentColor),
            showProgress: true,
            maxProgress: runningProgressSteps,
            progress: progress,
            actions: [
              AndroidNotificationAction(
                NotificationAction.stop,
                l10n.actionStop,
              ),
            ],
          ),
        ),
      );

  /// Progress of [now] between [start] and [end], in [runningProgressSteps].
  @visibleForTesting
  static int runningProgress(DateTime start, DateTime end, DateTime now) {
    final total = end.difference(start).inMilliseconds;
    if (total <= 0) return runningProgressSteps;
    final done = now.difference(start).inMilliseconds;
    return (done * runningProgressSteps ~/ total).clamp(
      0,
      runningProgressSteps,
    );
  }

  static const runningProgressSteps = 1000;

  NotificationDetails _details(
    String channel,
    Importance importance,
    List<AndroidNotificationAction> actions,
  ) => NotificationDetails(
    android: AndroidNotificationDetails(
      channel,
      channel,
      importance: importance,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      actions: actions,
    ),
  );

  /// The notification the app was opened from, if any.
  Future<NotificationResponse?> launchResponse() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp == true
        ? details!.notificationResponse
        : null;
  }

  Future<bool> canScheduleExact() async =>
      await _android?.canScheduleExactNotifications() ?? false;
}
