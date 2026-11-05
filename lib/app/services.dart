import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/time.dart';
import '../data/database.dart';
import '../data/database_connection.dart';
import '../data/settings_repository.dart';
import '../data/shift_repository.dart';
import '../data/tip_repository.dart';
import '../data/wage_repository.dart';
import '../domain/planning.dart';
import '../domain/recording.dart';
import '../l10n/app_localizations.dart';
import '../platform/calendar_sync.dart';
import '../platform/notification_service.dart';

/// Everything the app works with, created once per isolate: by the app on
/// start and by the background isolate when a notification button is tapped.
class AppServices {
  AppServices._({
    required this.db,
    required this.shifts,
    required this.settings,
    required this.tips,
    required this.wages,
    required this.notifications,
    required this.calendar,
  }) {
    planning = PlanningService(shifts, settings, syncAll);
    recording = RecordingService(shifts, settings, syncAll);
  }

  final AppDatabase db;
  final ShiftRepository shifts;
  final SettingsRepository settings;
  final TipRepository tips;
  final WageRepository wages;
  final NotificationService notifications;
  final CalendarSync calendar;
  late final PlanningService planning;
  late final RecordingService recording;

  static Future<AppServices> create() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    }
    final db = openAppDatabase();
    final shifts = ShiftRepository(db);
    final settings = SettingsRepository(db);
    return AppServices._(
      db: db,
      shifts: shifts,
      settings: settings,
      tips: TipRepository(db),
      wages: WageRepository(db),
      notifications: NotificationService(),
      calendar: CalendarSync(shifts, settings),
    );
  }

  /// Texts in the app's language (also for notifications and the calendar).
  Future<AppLocalizations> l10n() async {
    final chosen = (await settings.load()).locale;
    final code = chosen ?? PlatformDispatcher.instance.locale.languageCode;
    return lookupAppLocalizations(Locale(code == 'en' ? 'en' : 'de'));
  }

  Future<void> _lastSync = Future.value();

  /// How the last calendar sync in this isolate ended.
  CalendarSyncResult? lastCalendarResult;

  /// The "Jetzt synchronisieren" button: syncs everything and asks Android
  /// to upload the calendar to Google right away.
  Future<CalendarSyncResult> syncNow() async {
    await syncAll();
    final result = lastCalendarResult ?? CalendarSyncResult.failed;
    if (result == CalendarSyncResult.done) await calendar.requestUpload();
    return result;
  }

  /// Updates notifications and the calendar after a change. Runs one at a
  /// time, so quick changes don't sync in parallel.
  Future<void> syncAll() => _lastSync = _lastSync.then((_) => _sync());

  Future<void> _sync() async {
    try {
      final now = DateTime.now();
      final l10n = await this.l10n();
      await notifications.reconcile(
        shifts: await shifts.getFrom(dateOnly(now)),
        running: await shifts.running(),
        settings: await settings.load(),
        l10n: l10n,
        now: now,
      );
      lastCalendarResult = await calendar.run(l10n);
    } catch (e, stack) {
      lastCalendarResult = CalendarSyncResult.failed;
      debugPrint('Sync failed: $e\n$stack');
    }
  }

  /// A button in one of our notifications was tapped.
  Future<void> handleNotificationAction(NotificationResponse response) async {
    final shiftId = response.payload;
    switch (response.actionId) {
      case NotificationAction.start:
        await recording.start(shiftId: shiftId);
      case NotificationAction.later:
        final shift = shiftId == null ? null : await shifts.get(shiftId);
        if (shift != null) {
          await notifications.snooze(
            shift,
            await settings.load(),
            await l10n(),
          );
        }
      case NotificationAction.stop:
        await recording.stop();
      case NotificationAction.stopAtPlannedEnd:
        await recording.stop(atPlannedEnd: true);
      case NotificationAction.keepGoing:
        await syncAll(); // asks again later
      default:
        break; // the notification itself was tapped: the app just opens
    }
    await _lastSync;
  }
}

/// Entry point for notification buttons while the app isn't open. Runs in
/// a separate background isolate, so it sets up its own services.
@pragma('vm:entry-point')
Future<void> onNotificationActionInBackground(
  NotificationResponse response,
) async {
  DartPluginRegistrant.ensureInitialized();
  final services = await AppServices.create();
  await services.handleNotificationAction(response);
}
