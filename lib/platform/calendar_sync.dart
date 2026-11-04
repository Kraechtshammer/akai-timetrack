import 'package:calendar_bridge/calendar_bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/format.dart';
import '../core/time.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import '../data/settings_repository.dart';
import '../data/shift_repository.dart';
import '../domain/shift_info.dart';
import '../l10n/app_localizations.dart';

/// How a calendar sync run ended.
enum CalendarSyncResult {
  /// Everything pending was written.
  done,

  /// No calendar chosen.
  off,

  /// The calendar permission is missing.
  noPermission,

  /// Something failed; the shifts stay marked and are retried next time.
  failed,
}

/// Mirrors shifts into the chosen calendar. One way only: the app's
/// database is the truth, the calendar is a copy. See docs/02-design.md §5.
class CalendarSync {
  CalendarSync(
    this._shifts,
    this._settings, [
    this._bridge = const CalendarBridge(),
  ]);

  final ShiftRepository _shifts;
  final SettingsRepository _settings;
  final CalendarBridge _bridge;

  CalendarBridge get bridge => _bridge;

  static Future<bool> hasPermission() =>
      Permission.calendarFullAccess.isGranted;

  /// Writes all pending changes into the calendar. Failures are left for the
  /// next run (the shifts stay marked).
  Future<CalendarSyncResult> run(AppLocalizations l10n) async {
    final settings = await _settings.load();
    final calendarId = settings.calendarId;
    if (calendarId == null) {
      await _shifts.purgeDeleted();
      return CalendarSyncResult.off;
    }
    if (!await hasPermission()) return CalendarSyncResult.noPermission;

    try {
      for (final shift in await _shifts.needingSync()) {
        await _syncShift(shift, calendarId, settings, l10n);
      }
      await _recreateDeletedEvents(calendarId, settings, l10n);
      await _settings.setLastCalendarSync(DateTime.now());
      return CalendarSyncResult.done;
    } on CalendarPermissionException {
      // Permission was taken away; try again next time.
      return CalendarSyncResult.noPermission;
    } catch (e) {
      debugPrint('Calendar sync failed: $e');
      return CalendarSyncResult.failed;
    }
  }

  /// Asks Android to upload the calendar's changes to Google right away
  /// (normally Google syncs on its own within a few minutes).
  Future<void> requestUpload() async {
    final calendarId = (await _settings.load()).calendarId;
    if (calendarId == null || !await hasPermission()) return;
    try {
      await _bridge.requestSync(calendarId);
    } catch (e) {
      debugPrint('Sync request failed: $e');
    }
  }

  /// Uses a different calendar from now on. Events in the old calendar are
  /// removed and created again in the new one.
  Future<void> switchCalendar(CalendarInfo? calendar) async {
    if (await hasPermission()) {
      for (final shift in await _shifts.withEvents()) {
        try {
          await _bridge.deleteEvent(shift.calendarEventId!);
        } catch (_) {
          // Already gone; fine.
        }
      }
    }
    await _shifts.forgetEvents();
    await _settings.update(
      (s) => s.copyWith(
        calendarId: () => calendar?.id,
        calendarName: () => calendar?.name,
        // Event colors belong to the account, so reset the color.
        eventColorKey: () => null,
        eventColor: () => null,
      ),
    );
  }

  Future<void> _syncShift(
    Shift shift,
    String calendarId,
    AppSettings settings,
    AppLocalizations l10n,
  ) async {
    final eventId = shift.calendarEventId;
    if (shift.syncState == SyncState.pendingDelete) {
      if (eventId != null) await _deleteQuietly(eventId);
      await _shifts.removeRow(shift.id);
      return;
    }

    final event = eventFor(shift, settings, l10n);
    String newEventId;
    if (eventId != null &&
        shift.calendarId == calendarId &&
        await _bridge.eventExists(eventId)) {
      await _bridge.updateEvent(eventId, event);
      newEventId = eventId;
    } else {
      newEventId = await _bridge.insertEvent(calendarId, event);
    }
    await _shifts.setSynced(
      shift.id,
      eventId: newEventId,
      calendarId: calendarId,
      seenUpdatedAt: shift.updatedAt,
    );
  }

  /// Events of this week and later that were deleted in Google Calendar are
  /// created again. Older ones stay deleted (maybe cleaned up on purpose).
  Future<void> _recreateDeletedEvents(
    String calendarId,
    AppSettings settings,
    AppLocalizations l10n,
  ) async {
    final shifts = await _shifts.getFrom(weekStart(DateTime.now()));
    for (final shift in shifts) {
      final eventId = shift.calendarEventId;
      if (shift.syncState != SyncState.synced || eventId == null) continue;
      if (await _bridge.eventExists(eventId)) continue;
      final newId = await _bridge.insertEvent(
        calendarId,
        eventFor(shift, settings, l10n),
      );
      await _shifts.setSynced(
        shift.id,
        eventId: newId,
        calendarId: calendarId,
        seenUpdatedAt: shift.updatedAt,
      );
    }
  }

  Future<void> _deleteQuietly(String eventId) async {
    try {
      await _bridge.deleteEvent(eventId);
    } on CalendarPermissionException {
      rethrow;
    } catch (_) {
      // Already gone; fine.
    }
  }
}

/// What a shift looks like in the calendar.
CalendarEvent eventFor(
  Shift shift,
  AppSettings settings,
  AppLocalizations l10n,
) {
  final locale = l10n.localeName;
  final lines = [
    l10n.calPlanned('${hhmm(shift.plannedStart)}–${hhmm(shift.plannedEnd)}'),
    if (shift.isRecorded)
      l10n.calRecorded(
        '${hhmm(shift.actualStart!)}–${hhmm(shift.actualEnd!)}',
        formatHours(shift.workedMinutes!, locale),
      ),
    l10n.calManaged,
  ];
  return CalendarEvent(
    title: settings.eventTitle,
    description: lines.join('\n'),
    start: shift.shownStart,
    end: shift.shownEnd,
    timeZone: tz.local.name,
    colorKey: settings.eventColorKey,
  );
}
