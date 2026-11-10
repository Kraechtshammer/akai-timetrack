import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/time.dart';
import 'database.dart';

/// Reads and writes shifts. Every change marks the shift for the calendar
/// sync (`SyncState.dirty`).
class ShiftRepository {
  ShiftRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Shifts with a day in [from, to), deleted ones left out, in time order.
  Stream<List<Shift>> watchDays(DateTime from, DateTime to) =>
      _daysQuery(from, to).watch();

  Future<List<Shift>> getDays(DateTime from, DateTime to) =>
      _daysQuery(from, to).get();

  Future<Shift?> get(String id) =>
      (_db.select(_db.shifts)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// The shift that is being recorded right now, if any.
  Future<Shift?> running() => _runningQuery().getSingleOrNull();

  Stream<Shift?> watchRunning() => _runningQuery().watchSingleOrNull();

  /// Shifts from [from] on (for reminders), deleted ones left out.
  Future<List<Shift>> getFrom(DateTime from) => _daysQuery(from, null).get();

  /// Shifts the calendar sync still has to handle.
  Future<List<Shift>> needingSync() => (_db.select(
    _db.shifts,
  )..where((s) => s.syncState.equalsValue(SyncState.synced).not())).get();

  /// How many shifts still wait for the calendar sync.
  Stream<int> watchPendingSyncCount() {
    final count = _db.shifts.id.count();
    return (_db.selectOnly(_db.shifts)
          ..addColumns([count])
          ..where(_db.shifts.syncState.equalsValue(SyncState.synced).not()))
        .map((row) => row.read(count) ?? 0)
        .watchSingle();
  }

  /// Shifts that have a calendar event.
  Future<List<Shift>> withEvents() => (_db.select(
    _db.shifts,
  )..where((s) => s.calendarEventId.isNotNull())).get();

  Future<Shift> create({
    required DateTime day,
    required ShiftType type,
    required DateTime plannedStart,
    required DateTime plannedEnd,
    bool plannedCustomized = false,
    int? teamStart,
    DateTime? actualStart,
    DateTime? actualEnd,
    int breakMinutes = 0,
  }) {
    final now = DateTime.now();
    // The id lookup and the insert share a transaction, so two creations
    // can't get the same notification id.
    return _db.transaction(() async {
      final shift = Shift(
        id: _uuid.v4(),
        notifId: await _nextNotifId(),
        day: dayKey(day),
        type: type,
        plannedStart: plannedStart,
        plannedEnd: plannedEnd,
        plannedCustomized: plannedCustomized,
        teamStart: teamStart,
        actualStart: actualStart,
        actualEnd: actualEnd,
        breakMinutes: breakMinutes,
        syncState: SyncState.dirty,
        createdAt: now,
        updatedAt: now,
      );
      await _db.into(_db.shifts).insert(shift);
      return shift;
    });
  }

  /// Saves a changed shift and marks it for the calendar sync. For callers
  /// that read the shift right before: it overwrites the whole row.
  Future<void> save(Shift shift) =>
      _db.update(_db.shifts).replace(_touched(shift));

  /// Like [save], but only if the stored shift still has the `updatedAt` of
  /// [shift] (nobody changed it since it was read, e.g. the notification
  /// started a recording). Returns whether the row was written.
  Future<bool> saveEdited(Shift shift) async {
    final rows =
        await (_db.update(_db.shifts)..where(
              (s) =>
                  s.id.equals(shift.id) & s.updatedAt.equals(shift.updatedAt),
            ))
            .write(_touched(shift).toCompanion(false));
    return rows > 0;
  }

  Shift _touched(Shift shift) {
    // `updatedAt` is stored in whole seconds; keep it strictly increasing so
    // two changes within a second still differ for [saveEdited].
    final now = DateTime.now();
    final floor = shift.updatedAt.add(const Duration(seconds: 1));
    return shift.copyWith(
      syncState: shift.syncState == SyncState.pendingDelete
          ? SyncState.pendingDelete
          : SyncState.dirty,
      updatedAt: now.isAfter(floor) ? now : floor,
    );
  }

  /// Stores the calendar event of a shift after a sync. The shift only counts
  /// as synced if nobody changed it meanwhile ([seenUpdatedAt]).
  Future<void> setSynced(
    String id, {
    required String? eventId,
    required String? calendarId,
    required DateTime seenUpdatedAt,
  }) => _db.transaction(() async {
    await (_db.update(_db.shifts)..where((s) => s.id.equals(id))).write(
      ShiftsCompanion(
        calendarEventId: Value(eventId),
        calendarId: Value(calendarId),
      ),
    );
    await (_db.update(_db.shifts)..where(
          (s) =>
              s.id.equals(id) &
              s.updatedAt.equals(seenUpdatedAt) &
              s.syncState.equalsValue(SyncState.dirty),
        ))
        .write(ShiftsCompanion(syncState: Value(SyncState.synced)));
  });

  /// Forgets all calendar events (e.g. when sync is switched off) and marks
  /// the shifts for a fresh sync.
  Future<void> forgetEvents() =>
      (_db.update(_db.shifts)..where(
            (s) => s.syncState.equalsValue(SyncState.pendingDelete).not(),
          ))
          .write(
            ShiftsCompanion(
              calendarEventId: const Value(null),
              calendarId: const Value(null),
              syncState: Value(SyncState.dirty),
            ),
          );

  /// Deleted shifts whose events can't be removed any more (no calendar).
  Future<void> purgeDeleted() => (_db.delete(
    _db.shifts,
  )..where((s) => s.syncState.equalsValue(SyncState.pendingDelete))).go();

  /// Deletes a shift. If it has a calendar event, the row stays until the
  /// calendar sync has removed the event.
  Future<void> delete(Shift shift) async {
    if (shift.calendarEventId == null) {
      await removeRow(shift.id);
    } else {
      await _db
          .update(_db.shifts)
          .replace(
            shift.copyWith(
              syncState: SyncState.pendingDelete,
              updatedAt: DateTime.now(),
            ),
          );
    }
  }

  /// Brings back a shift that was just deleted ("Undo").
  Future<void> restore(Shift shift) => _db
      .into(_db.shifts)
      .insertOnConflictUpdate(shift.copyWith(syncState: SyncState.dirty));

  Future<void> removeRow(String id) =>
      (_db.delete(_db.shifts)..where((s) => s.id.equals(id))).go();

  /// Marks every shift with a calendar event for a re-sync (e.g. new color).
  Future<void> markAllEventsDirty() =>
      (_db.update(_db.shifts)..where(
            (s) =>
                s.calendarEventId.isNotNull() &
                s.syncState.equalsValue(SyncState.synced),
          ))
          .write(ShiftsCompanion(syncState: Value(SyncState.dirty)));

  SimpleSelectStatement<$ShiftsTable, Shift> _daysQuery(
    DateTime from,
    DateTime? to,
  ) => _db.select(_db.shifts)
    ..where((s) {
      var condition =
          s.day.isBiggerOrEqualValue(dayKey(from)) &
          s.syncState.equalsValue(SyncState.pendingDelete).not();
      if (to != null) {
        condition = condition & s.day.isSmallerThanValue(dayKey(to));
      }
      return condition;
    })
    ..orderBy([(s) => OrderingTerm.asc(s.plannedStart)]);

  SimpleSelectStatement<$ShiftsTable, Shift> _runningQuery() =>
      _db.select(_db.shifts)
        ..where(
          (s) =>
              s.rawStart.isNotNull() &
              s.rawEnd.isNull() &
              s.syncState.equalsValue(SyncState.pendingDelete).not(),
        )
        ..limit(1);

  Future<int> _nextNotifId() async {
    final max = _db.shifts.notifId.max();
    final row = await (_db.selectOnly(
      _db.shifts,
    )..addColumns([max])).getSingle();
    return (row.read(max) ?? 0) + 1;
  }
}
