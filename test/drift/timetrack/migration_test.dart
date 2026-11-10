// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // v1 -> v2 only adds the tip tables; shifts and settings must survive.
  test('migration from v1 to v2 does not corrupt data', () async {
    final start = DateTime.utc(2026, 11, 2, 11).millisecondsSinceEpoch ~/ 1000;
    final end = DateTime.utc(2026, 11, 2, 15).millisecondsSinceEpoch ~/ 1000;
    final oldShiftsData = [
      v1.ShiftsData(
        id: 'a1b2',
        notifId: 7,
        day: '2026-11-02',
        type: 0,
        plannedStart: start,
        plannedEnd: end,
        plannedCustomized: 0,
        actualStart: start,
        actualEnd: end,
        breakMinutes: 15,
        calendarEventId: '42',
        calendarId: '3',
        syncState: 0,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final expectedNewShiftsData = [
      v2.ShiftsData(
        id: 'a1b2',
        notifId: 7,
        day: '2026-11-02',
        type: 0,
        plannedStart: start,
        plannedEnd: end,
        plannedCustomized: 0,
        actualStart: start,
        actualEnd: end,
        breakMinutes: 15,
        calendarEventId: '42',
        calendarId: '3',
        syncState: 0,
        createdAt: start,
        updatedAt: end,
      ),
    ];

    final oldSettingsData = [
      const v1.SettingsData(key: 'eventTitle', value: 'Kellnern'),
    ];
    final expectedNewSettingsData = [
      const v2.SettingsData(key: 'eventTitle', value: 'Kellnern'),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.shifts, oldShiftsData);
        batch.insertAll(oldDb.settings, oldSettingsData);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.tipDays).get(), isEmpty);
        expect(await newDb.select(newDb.tipPayouts).get(), isEmpty);
        expect(expectedNewShiftsData, await newDb.select(newDb.shifts).get());
        expect(
          expectedNewSettingsData,
          await newDb.select(newDb.settings).get(),
        );
      },
    );
  });

  // v2 -> v3 only adds the wage rates table; everything else must survive.
  test('migration from v2 to v3 does not corrupt data', () async {
    final start = DateTime.utc(2026, 11, 2, 11).millisecondsSinceEpoch ~/ 1000;
    final end = DateTime.utc(2026, 11, 2, 15).millisecondsSinceEpoch ~/ 1000;
    final oldShiftsData = [
      v2.ShiftsData(
        id: 'a1b2',
        notifId: 7,
        day: '2026-11-02',
        type: 0,
        plannedStart: start,
        plannedEnd: end,
        plannedCustomized: 0,
        actualStart: start,
        actualEnd: end,
        breakMinutes: 15,
        calendarEventId: '42',
        calendarId: '3',
        syncState: 0,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final expectedNewShiftsData = [
      v3.ShiftsData(
        id: 'a1b2',
        notifId: 7,
        day: '2026-11-02',
        type: 0,
        plannedStart: start,
        plannedEnd: end,
        plannedCustomized: 0,
        actualStart: start,
        actualEnd: end,
        breakMinutes: 15,
        calendarEventId: '42',
        calendarId: '3',
        syncState: 0,
        createdAt: start,
        updatedAt: end,
      ),
    ];

    final oldSettingsData = [
      const v2.SettingsData(key: 'eventTitle', value: 'Kellnern'),
    ];
    final expectedNewSettingsData = [
      const v3.SettingsData(key: 'eventTitle', value: 'Kellnern'),
    ];

    final oldTipDaysData = [
      v2.TipDaysData(
        id: 't1',
        day: '2026-11-02',
        poolCents: 4000,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final expectedNewTipDaysData = [
      v3.TipDaysData(
        id: 't1',
        day: '2026-11-02',
        poolCents: 4000,
        createdAt: start,
        updatedAt: end,
      ),
    ];

    final oldTipPayoutsData = [
      v2.TipPayoutsData(
        id: 'p1',
        weekStart: '2026-11-02',
        amountCents: 12000,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final expectedNewTipPayoutsData = [
      v3.TipPayoutsData(
        id: 'p1',
        weekStart: '2026-11-02',
        amountCents: 12000,
        createdAt: start,
        updatedAt: end,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.shifts, oldShiftsData);
        batch.insertAll(oldDb.settings, oldSettingsData);
        batch.insertAll(oldDb.tipDays, oldTipDaysData);
        batch.insertAll(oldDb.tipPayouts, oldTipPayoutsData);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.wageRates).get(), isEmpty);
        expect(expectedNewShiftsData, await newDb.select(newDb.shifts).get());
        expect(
          expectedNewSettingsData,
          await newDb.select(newDb.settings).get(),
        );
        expect(expectedNewTipDaysData, await newDb.select(newDb.tipDays).get());
        expect(
          expectedNewTipPayoutsData,
          await newDb.select(newDb.tipPayouts).get(),
        );
      },
    );
  });
  // v3 -> v4 only adds the team planner tables; everything else must survive.
  test('migration from v3 to v4 does not corrupt data', () async {
    final start = DateTime.utc(2026, 11, 2, 11).millisecondsSinceEpoch ~/ 1000;
    final end = DateTime.utc(2026, 11, 2, 15).millisecondsSinceEpoch ~/ 1000;
    final oldShiftsData = [
      v3.ShiftsData(
        id: 'a1b2',
        notifId: 7,
        day: '2026-11-02',
        type: 0,
        plannedStart: start,
        plannedEnd: end,
        plannedCustomized: 0,
        actualStart: start,
        actualEnd: end,
        breakMinutes: 15,
        calendarEventId: '42',
        calendarId: '3',
        syncState: 0,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final expectedNewShiftsData = [
      v4.ShiftsData(
        id: 'a1b2',
        notifId: 7,
        day: '2026-11-02',
        type: 0,
        plannedStart: start,
        plannedEnd: end,
        plannedCustomized: 0,
        actualStart: start,
        actualEnd: end,
        breakMinutes: 15,
        calendarEventId: '42',
        calendarId: '3',
        syncState: 0,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final oldSettingsData = [
      const v3.SettingsData(key: 'eventTitle', value: 'Kellnern'),
    ];
    final expectedNewSettingsData = [
      const v4.SettingsData(key: 'eventTitle', value: 'Kellnern'),
    ];
    final oldTipDaysData = [
      v3.TipDaysData(
        id: 't1',
        day: '2026-11-02',
        poolCents: 4000,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final expectedNewTipDaysData = [
      v4.TipDaysData(
        id: 't1',
        day: '2026-11-02',
        poolCents: 4000,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final oldTipPayoutsData = [
      v3.TipPayoutsData(
        id: 'p1',
        weekStart: '2026-11-02',
        amountCents: 12000,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final expectedNewTipPayoutsData = [
      v4.TipPayoutsData(
        id: 'p1',
        weekStart: '2026-11-02',
        amountCents: 12000,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final oldWageRatesData = [
      v3.WageRatesData(
        id: 'w1',
        validFrom: '2026-11-01',
        hourlyCents: 1450,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final expectedNewWageRatesData = [
      v4.WageRatesData(
        id: 'w1',
        validFrom: '2026-11-01',
        hourlyCents: 1450,
        createdAt: start,
        updatedAt: end,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.shifts, oldShiftsData);
        batch.insertAll(oldDb.settings, oldSettingsData);
        batch.insertAll(oldDb.tipDays, oldTipDaysData);
        batch.insertAll(oldDb.tipPayouts, oldTipPayoutsData);
        batch.insertAll(oldDb.wageRates, oldWageRatesData);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.teamMembers).get(), isEmpty);
        expect(await newDb.select(newDb.teamAnswers).get(), isEmpty);
        expect(await newDb.select(newDb.teamAssignments).get(), isEmpty);
        expect(await newDb.select(newDb.teamNeeds).get(), isEmpty);
        expect(expectedNewShiftsData, await newDb.select(newDb.shifts).get());
        expect(
          expectedNewSettingsData,
          await newDb.select(newDb.settings).get(),
        );
        expect(expectedNewTipDaysData, await newDb.select(newDb.tipDays).get());
        expect(
          expectedNewTipPayoutsData,
          await newDb.select(newDb.tipPayouts).get(),
        );
        expect(
          expectedNewWageRatesData,
          await newDb.select(newDb.wageRates).get(),
        );
      },
    );
  });
  // v4 -> v5 adds the monthly hours limit to team members; people and their
  // shifts must survive, without a limit.
  test('migration from v4 to v5 keeps the team, without hour limits', () async {
    final start = DateTime.utc(2026, 11, 2, 11).millisecondsSinceEpoch ~/ 1000;
    final oldMembers = [
      v4.TeamMembersData(
        id: 'm1',
        name: 'Anna',
        core: 1,
        isMe: 0,
        active: 1,
        createdAt: start,
        updatedAt: start,
      ),
    ];
    final expectedMembers = [
      v5.TeamMembersData(
        id: 'm1',
        name: 'Anna',
        core: 1,
        isMe: 0,
        active: 1,
        maxMonthMinutes: null,
        createdAt: start,
        updatedAt: start,
      ),
    ];
    final oldAssignments = [
      v4.TeamAssignmentsData(
        id: 'a1',
        day: '2026-11-03',
        shift: 1,
        memberId: 'm1',
        startMinutes: 1110,
        createdAt: start,
        updatedAt: start,
      ),
    ];
    final expectedAssignments = [
      v5.TeamAssignmentsData(
        id: 'a1',
        day: '2026-11-03',
        shift: 1,
        memberId: 'm1',
        startMinutes: 1110,
        createdAt: start,
        updatedAt: start,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 4,
      newVersion: 5,
      createOld: v4.DatabaseAtV4.new,
      createNew: v5.DatabaseAtV5.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.teamMembers, oldMembers);
        batch.insertAll(oldDb.teamAssignments, oldAssignments);
      },
      validateItems: (newDb) async {
        expect(expectedMembers, await newDb.select(newDb.teamMembers).get());
        expect(
          expectedAssignments,
          await newDb.select(newDb.teamAssignments).get(),
        );
      },
    );
  });
  // v5 -> v6 adds the team plan link to shifts; existing shifts keep their
  // data and count as added by the user.
  test('migration from v5 to v6 keeps shifts, not linked', () async {
    final start = DateTime.utc(2026, 11, 2, 11).millisecondsSinceEpoch ~/ 1000;
    final end = DateTime.utc(2026, 11, 2, 15).millisecondsSinceEpoch ~/ 1000;
    final old = [
      v5.ShiftsData(
        id: 'a1b2',
        notifId: 7,
        day: '2026-11-02',
        type: 0,
        plannedStart: start,
        plannedEnd: end,
        plannedCustomized: 0,
        breakMinutes: 0,
        syncState: 1,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    final expected = [
      v6.ShiftsData(
        id: 'a1b2',
        notifId: 7,
        day: '2026-11-02',
        type: 0,
        plannedStart: start,
        plannedEnd: end,
        plannedCustomized: 0,
        teamStart: null,
        breakMinutes: 0,
        syncState: 1,
        createdAt: start,
        updatedAt: end,
      ),
    ];
    await verifier.testWithDataIntegrity(
      oldVersion: 5,
      newVersion: 6,
      createOld: v5.DatabaseAtV5.new,
      createNew: v6.DatabaseAtV6.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insertAll(oldDb.shifts, old),
      validateItems: (newDb) async =>
          expect(expected, await newDb.select(newDb.shifts).get()),
    );
  });
}
