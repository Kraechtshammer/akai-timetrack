/// Small bridge to the Android calendar. See CalendarBridgePlugin.kt.
library;

import 'package:flutter/services.dart';

/// A calendar on the phone the app may write to.
class CalendarInfo {
  const CalendarInfo({
    required this.id,
    required this.name,
    required this.accountName,
    required this.accountType,
    required this.color,
    this.synced = true,
  });

  final String id;
  final String name;
  final String accountName;
  final String accountType;
  final int color;

  /// False if the calendar isn't synced to this phone (switched off in
  /// Google Calendar). Events written to it wouldn't reach Google.
  final bool synced;

  bool get isGoogle => accountType == 'com.google';
}

/// An event color offered by the calendar's account.
class EventColor {
  const EventColor({required this.key, required this.color});

  final String key;
  final int color;
}

/// What the app writes into the calendar for one shift.
class CalendarEvent {
  const CalendarEvent({
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.timeZone,
    this.colorKey,
  });

  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String timeZone;

  /// null = the calendar's own color.
  final String? colorKey;

  Map<String, Object?> toMap() => {
    'title': title,
    'description': description,
    'startMs': start.millisecondsSinceEpoch,
    'endMs': end.millisecondsSinceEpoch,
    'timeZone': timeZone,
    'colorKey': colorKey,
  };
}

/// Thrown when the calendar permission is missing.
class CalendarPermissionException implements Exception {}

class CalendarBridge {
  const CalendarBridge();

  static const _channel = MethodChannel('de.garten.calendar_bridge');

  Future<List<CalendarInfo>> writableCalendars() async {
    final list = await _call<List<Object?>>('writableCalendars');
    return [
      for (final item in list ?? const [])
        _calendarFrom((item as Map).cast<String, Object?>()),
    ];
  }

  Future<List<EventColor>> eventColors(String calendarId) async {
    final list = await _call<List<Object?>>('eventColors', {
      'calendarId': calendarId,
    });
    return [
      for (final item in list ?? const [])
        EventColor(
          key: (item as Map)['key'] as String,
          color: item['color'] as int,
        ),
    ];
  }

  /// Returns the new event's id.
  Future<String> insertEvent(String calendarId, CalendarEvent event) async =>
      (await _call<String>('insertEvent', {
        'calendarId': calendarId,
        'event': event.toMap(),
      }))!;

  Future<void> updateEvent(String eventId, CalendarEvent event) =>
      _call<void>('updateEvent', {'eventId': eventId, 'event': event.toMap()});

  Future<void> deleteEvent(String eventId) =>
      _call<void>('deleteEvent', {'eventId': eventId});

  Future<bool> eventExists(String eventId) async =>
      await _call<bool>('eventExists', {'eventId': eventId}) ?? false;

  /// Turns on syncing for a calendar that isn't synced to this phone yet.
  Future<void> enableSync(String calendarId) =>
      _call<void>('enableSync', {'calendarId': calendarId});

  /// Asks Android to sync now: the calendar's account, or without
  /// [calendarId] all accounts (to find newly created calendars).
  Future<void> requestSync([String? calendarId]) =>
      _call<void>('requestSync', {'calendarId': calendarId});

  Future<T?> _call<T>(String method, [Map<String, Object?>? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      if (e.code == 'NO_PERMISSION') throw CalendarPermissionException();
      rethrow;
    }
  }

  CalendarInfo _calendarFrom(Map<String, Object?> map) => CalendarInfo(
    id: map['id'] as String,
    name: map['name'] as String? ?? '',
    accountName: map['accountName'] as String? ?? '',
    accountType: map['accountType'] as String? ?? '',
    color: map['color'] as int? ?? 0,
    synced: map['synced'] as bool? ?? true,
  );
}
