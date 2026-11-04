import 'dart:ui' show Locale;

import 'package:akai_timetrack/core/format.dart';
import 'package:akai_timetrack/data/app_settings.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/data/settings_repository.dart';
import 'package:akai_timetrack/data/shift_repository.dart';
import 'package:akai_timetrack/l10n/app_localizations.dart';
import 'package:akai_timetrack/platform/calendar_sync.dart';
import 'package:calendar_bridge/calendar_bridge.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'helpers.dart';

/// Records calls instead of talking to Android.
class FakeBridge implements CalendarBridge {
  /// Existing events by id.
  final events = <String, CalendarEvent>{};

  /// Ids that were deleted in Google (eventExists says false).
  final deletedInGoogle = <String>{};

  final inserted = <CalendarEvent>[];
  final updated = <String>[];
  final deleted = <String>[];

  Object? insertError;
  var _next = 1;

  @override
  Future<String> insertEvent(String calendarId, CalendarEvent event) async {
    if (insertError != null) throw insertError!;
    final id = 'new-${_next++}';
    inserted.add(event);
    events[id] = event;
    return id;
  }

  @override
  Future<void> updateEvent(String eventId, CalendarEvent event) async {
    updated.add(eventId);
    events[eventId] = event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    deleted.add(eventId);
    events.remove(eventId);
  }

  @override
  Future<bool> eventExists(String eventId) async =>
      !deletedInGoogle.contains(eventId) && events.containsKey(eventId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late ShiftRepository shifts;
  late SettingsRepository settings;
  late FakeBridge bridge;
  late CalendarSync sync;
  var permission = true;
  final en = lookupAppLocalizations(const Locale('en'));
  final de = lookupAppLocalizations(const Locale('de'));
  final today = DateTime.now();

  setUpAll(() {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    shifts = ShiftRepository(db);
    settings = SettingsRepository(db);
    bridge = FakeBridge();
    permission = true;
    sync = CalendarSync(shifts, settings, bridge, () async => permission);
  });
  tearDown(() => db.close());

  Future<void> chooseCalendar({String? colorKey}) async {
    await settings.update(
      (s) =>
          s.copyWith(calendarId: () => 'cal1', eventColorKey: () => colorKey),
    );
  }

  /// A new dirty shift today.
  Future<Shift> newShift() async {
    final shift = await shifts.create(
      day: today,
      type: ShiftType.evening,
      plannedStart: DateTime(today.year, today.month, today.day, 17, 30),
      plannedEnd: DateTime(today.year, today.month, today.day, 23),
    );
    return (await shifts.get(shift.id))!;
  }

  /// A shift that has an event in calendar `cal1`; dirty again if [dirty].
  Future<Shift> shiftWithEvent(String eventId, {bool dirty = true}) async {
    final shift = await newShift();
    await shifts.setSynced(
      shift.id,
      eventId: eventId,
      calendarId: 'cal1',
      seenUpdatedAt: shift.updatedAt,
    );
    bridge.events[eventId] = eventFor(shift, const AppSettings(), en);
    if (dirty) await shifts.save((await shifts.get(shift.id))!);
    return (await shifts.get(shift.id))!;
  }

  group('CalendarSync.run', () {
    test('no calendar chosen: off, deleted shifts are purged', () async {
      final shift = await newShift();
      await db
          .update(db.shifts)
          .replace(shift.copyWith(syncState: SyncState.pendingDelete));

      expect(await sync.run(en), CalendarSyncResult.off);
      expect(await shifts.get(shift.id), isNull);
      expect(bridge.inserted, isEmpty);
    });

    test('no permission: nothing happens, shifts stay dirty', () async {
      await chooseCalendar();
      final shift = await newShift();
      permission = false;

      expect(await sync.run(en), CalendarSyncResult.noPermission);
      expect(bridge.inserted, isEmpty);
      expect((await shifts.get(shift.id))!.syncState, SyncState.dirty);
    });

    test('dirty shift without event is inserted', () async {
      await chooseCalendar(colorKey: '7');
      final shift = await newShift();

      expect(await sync.run(en), CalendarSyncResult.done);

      expect(bridge.inserted, hasLength(1));
      expect(bridge.inserted.single.title, 'Kellnern');
      expect(bridge.inserted.single.colorKey, '7');
      final after = (await shifts.get(shift.id))!;
      expect(after.syncState, SyncState.synced);
      expect(after.calendarEventId, 'new-1');
      expect(after.calendarId, 'cal1');
      expect(await settings.watchLastCalendarSync().first, isNotNull);
    });

    test('dirty shift with event in the same calendar is updated', () async {
      await chooseCalendar();
      final shift = await shiftWithEvent('ev1');

      expect(await sync.run(en), CalendarSyncResult.done);

      expect(bridge.updated, ['ev1']);
      expect(bridge.inserted, isEmpty);
      final after = (await shifts.get(shift.id))!;
      expect(after.syncState, SyncState.synced);
      expect(after.calendarEventId, 'ev1');
    });

    test('dirty shift with event in another calendar is inserted', () async {
      await chooseCalendar();
      final shift = await shiftWithEvent('ev1');
      await shifts.setSynced(
        shift.id,
        eventId: 'ev1',
        calendarId: 'other',
        seenUpdatedAt: shift.updatedAt,
      );
      await shifts.save((await shifts.get(shift.id))!);

      expect(await sync.run(en), CalendarSyncResult.done);

      expect(bridge.updated, isEmpty);
      expect(bridge.inserted, hasLength(1));
      expect((await shifts.get(shift.id))!.calendarId, 'cal1');
    });

    test('pending delete with event: event deleted, row removed', () async {
      await chooseCalendar();
      final shift = await shiftWithEvent('ev1', dirty: false);
      await shifts.delete((await shifts.get(shift.id))!);
      expect((await shifts.get(shift.id))!.syncState, SyncState.pendingDelete);

      expect(await sync.run(en), CalendarSyncResult.done);

      expect(bridge.deleted, ['ev1']);
      expect(await shifts.get(shift.id), isNull);
    });

    test('event deleted in Google this week is created again', () async {
      await chooseCalendar();
      final shift = await shiftWithEvent('ev1', dirty: false);
      bridge.deletedInGoogle.add('ev1');

      expect(await sync.run(en), CalendarSyncResult.done);

      expect(bridge.inserted, hasLength(1));
      final after = (await shifts.get(shift.id))!;
      expect(after.calendarEventId, 'new-1');
      expect(after.syncState, SyncState.synced);
    });

    test('existing synced event is left alone', () async {
      await chooseCalendar();
      await shiftWithEvent('ev1', dirty: false);

      expect(await sync.run(en), CalendarSyncResult.done);

      expect(bridge.inserted, isEmpty);
      expect(bridge.updated, isEmpty);
    });

    test('insert error: failed, shift stays dirty, no sync time', () async {
      await chooseCalendar();
      final shift = await newShift();
      bridge.insertError = Exception('boom');

      expect(await sync.run(en), CalendarSyncResult.failed);

      expect((await shifts.get(shift.id))!.syncState, SyncState.dirty);
      expect(await settings.watchLastCalendarSync().first, isNull);
    });

    test('permission revoked during sync: noPermission', () async {
      await chooseCalendar();
      final shift = await newShift();
      bridge.insertError = CalendarPermissionException();

      expect(await sync.run(en), CalendarSyncResult.noPermission);
      expect((await shifts.get(shift.id))!.syncState, SyncState.dirty);
    });
  });

  group('eventFor', () {
    final day = DateTime(2026, 11, 6);

    test('planned shift: planned times, no recorded line', () {
      final shift = testShift(day: day, planned: '17:30-23:00');
      final event = eventFor(shift, const AppSettings(), en);

      expect(event.title, 'Kellnern');
      expect(event.start, shift.plannedStart);
      expect(event.end, shift.plannedEnd);
      expect(event.colorKey, isNull);
      expect(event.description.split('\n'), [
        'Planned: 17:30–23:00',
        en.calManaged,
      ]);
    });

    test('recorded shift: actual times and recorded line', () {
      final shift = testShift(
        day: day,
        planned: '17:30-23:00',
        actual: '17:45-23:15',
        breakMinutes: 30,
      );
      final settings = const AppSettings().copyWith(
        eventTitle: 'Dienst',
        eventColorKey: () => '3',
      );
      final event = eventFor(shift, settings, en);

      expect(event.title, 'Dienst');
      expect(event.colorKey, '3');
      expect(event.start, shift.actualStart);
      expect(event.end, shift.actualEnd);
      expect(event.description.split('\n'), [
        'Planned: 17:30–23:00',
        'Recorded: 17:45–23:15 (${formatHours(300, 'en')} h)',
        en.calManaged,
      ]);
    });

    test('description is in the app language', () {
      final shift = testShift(
        day: day,
        planned: '17:30-23:00',
        actual: '17:45-23:15',
      );
      final lines = eventFor(
        shift,
        const AppSettings(),
        de,
      ).description.split('\n');

      expect(lines, hasLength(3));
      expect(lines[0], 'Geplant: 17:30–23:00');
      expect(lines[1], startsWith('Erfasst: 17:45–23:15'));
      expect(lines[1], endsWith(' h)'));
      expect(lines[2], de.calManaged);
      expect(de.calManaged, isNot(en.calManaged));
    });
  });
}
