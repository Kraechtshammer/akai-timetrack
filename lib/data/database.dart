import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

enum ShiftType { lunch, evening, custom }

/// What the calendar sync still has to do for a shift.
enum SyncState { synced, dirty, pendingDelete }

/// One shift. Keeps planned, raw recorded and counted ("actual") times apart,
/// so a correction never loses information. See docs/02-design.md §3.
@DataClassName('Shift')
class Shifts extends Table {
  /// UUID, so backups can be merged later without id clashes.
  TextColumn get id => text()();

  /// Small number for notification ids (Android needs ints). Device-only.
  IntColumn get notifId => integer().unique()();

  /// Local date the shift belongs to, `yyyy-MM-dd`.
  TextColumn get day => text()();
  IntColumn get type => intEnum<ShiftType>()();

  DateTimeColumn get plannedStart => dateTime()();
  DateTimeColumn get plannedEnd => dateTime()();

  /// Set once planned times were edited by hand: no more automatic changes.
  BoolColumn get plannedCustomized =>
      boolean().withDefault(const Constant(false))();

  /// Exact Start/Stop taps. Started but not stopped = recording is running.
  DateTimeColumn get rawStart => dateTime().nullable()();
  DateTimeColumn get rawEnd => dateTime().nullable()();

  /// Rounded or hand-entered times. These are what counts.
  DateTimeColumn get actualStart => dateTime().nullable()();
  DateTimeColumn get actualEnd => dateTime().nullable()();

  IntColumn get breakMinutes => integer().withDefault(const Constant(0))();

  /// Calendar event this shift is mirrored to. Device-only.
  TextColumn get calendarEventId => text().nullable()();
  TextColumn get calendarId => text().nullable()();
  IntColumn get syncState =>
      intEnum<SyncState>().withDefault(Constant(SyncState.dirty.index))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Key-value settings, read through SettingsRepository.
@DataClassName('SettingEntry')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Shifts, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  /// Raise this and add a migration step for every schema change.
  /// Only add tables or nullable columns; never rename or reuse a column.
  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() => driftDatabase(
    name: 'timetrack',
    // The app and the notification buttons (which run in a background
    // isolate) share one connection, so screens update right away.
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  );
}
