import 'package:drift/drift.dart';

import 'database.steps.dart';

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

/// "Tagestopf": the tips of everyone combined on one workday (not her
/// share). One row per day at most. See docs/02-design.md §3 and §4.7.
@DataClassName('TipDay')
class TipDays extends Table {
  /// UUID, so backups can be merged later.
  TextColumn get id => text()();

  /// The workday, `yyyy-MM-dd`.
  TextColumn get day => text().unique()();
  IntColumn get poolCents => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// "Ausgezahlt": the cash she got for one tip week (Monday to Sunday).
/// One row per week at most.
@DataClassName('TipPayout')
class TipPayouts extends Table {
  /// UUID, so backups can be merged later.
  TextColumn get id => text()();

  /// The week's Monday, `yyyy-MM-dd`.
  TextColumn get weekStart => text().unique()();
  IntColumn get amountCents => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The user's gross hourly wage, valid from a day on, so a raise
/// doesn't change past months. One row per start day at most. See
/// docs/02-design.md §3 and §4.8.
@DataClassName('WageRate')
class WageRates extends Table {
  /// UUID, so backups can be merged later.
  TextColumn get id => text()();

  /// The first day this rate applies to, `yyyy-MM-dd`.
  TextColumn get validFrom => text().unique()();
  IntColumn get hourlyCents => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A shift on the team plan (F11). Separate from [ShiftType]: the team plan
/// has no custom shifts. The index is stored, so only add at the end.
enum TeamShift { lunch, evening }

/// What the marks of a team answer mean.
enum AnswerMode { canWork, cantWork }

/// A colleague on the team plan. See docs/02-design.md §3 and §4.9.
@DataClassName('TeamMember')
class TeamMembers extends Table {
  /// UUID, so backups can be merged later.
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Core worker: experienced; each shift should have one.
  BoolColumn get core => boolean().withDefault(const Constant(false))();

  /// This person is the user. At most one row.
  BoolColumn get isMe => boolean().withDefault(const Constant(false))();

  /// Inactive people are left out of new weeks but stay in old plans.
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// When a person can work in a week. No row = no answer yet.
@DataClassName('TeamAnswer')
class TeamAnswers extends Table {
  TextColumn get id => text()();

  /// The week's Monday, `yyyy-MM-dd`.
  TextColumn get weekStart => text()();
  TextColumn get memberId => text()();
  IntColumn get mode => intEnum<AnswerMode>()();

  /// Bit `(weekday - 1) * 2 + shift` for each marked shift.
  IntColumn get marks => integer().withDefault(const Constant(0))();

  /// "At most N shifts"; null = no limit.
  IntColumn get maxShifts => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {weekStart, memberId},
  ];
}

/// A person in a shift of the team plan.
@DataClassName('TeamAssignment')
class TeamAssignments extends Table {
  TextColumn get id => text()();

  /// `yyyy-MM-dd`
  TextColumn get day => text()();
  IntColumn get shift => intEnum<TeamShift>()();
  TextColumn get memberId => text()();

  /// Special start, minutes after midnight; null = the shift's normal start.
  IntColumn get startMinutes => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {day, shift, memberId},
  ];
}

/// Staff needed in one shift of one week, where it differs from the
/// default in the setting `teamStaffNeeded`.
@DataClassName('TeamNeed')
class TeamNeeds extends Table {
  TextColumn get id => text()();

  /// `yyyy-MM-dd`
  TextColumn get day => text()();
  IntColumn get shift => intEnum<TeamShift>()();
  IntColumn get needed => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {day, shift},
  ];
}

@DriftDatabase(
  tables: [
    Shifts,
    Settings,
    TipDays,
    TipPayouts,
    WageRates,
    TeamMembers,
    TeamAnswers,
    TeamAssignments,
    TeamNeeds,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// [executor]: the app's file database (`openAppDatabase()` in
  /// `database_connection.dart`) or an in-memory one in tests. Opening the
  /// file lives elsewhere so drift's schema export can run this file
  /// without Flutter.
  AppDatabase(super.executor);

  /// Raise this and add a migration step for every schema change.
  /// Only add tables or nullable columns; never rename or reuse a column.
  @override
  int get schemaVersion => 4;

  /// Steps are generated by `dart run drift_dev make-migrations` from the
  /// snapshots in `drift_schemas/` (docs/03-dev-setup.md).
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // Tips (F10).
        await m.createTable(schema.tipDays);
        await m.createTable(schema.tipPayouts);
      },
      from2To3: (m, schema) async {
        // Salary: hourly wage rates.
        await m.createTable(schema.wageRates);
      },
      from3To4: (m, schema) async {
        // Team planner (F11).
        await m.createTable(schema.teamMembers);
        await m.createTable(schema.teamAnswers);
        await m.createTable(schema.teamAssignments);
        await m.createTable(schema.teamNeeds);
      },
    ),
  );
}
