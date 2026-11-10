import 'package:akai_timetrack/core/time.dart';
import 'package:akai_timetrack/data/app_settings.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/data/roster_repository.dart';
import 'package:akai_timetrack/data/settings_repository.dart';
import 'package:akai_timetrack/data/shift_repository.dart';
import 'package:akai_timetrack/domain/planning.dart';
import 'package:akai_timetrack/domain/roster.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Team planner (F11), docs/02-design.md §4.9.

final monday = DateTime(2026, 11, 9);
final tuesday = DateTime(2026, 11, 10);
final created = DateTime(2026, 11, 1);

TeamMember person(String name, {bool core = false}) => TeamMember(
  id: name,
  name: name,
  core: core,
  isMe: false,
  active: true,
  createdAt: created,
  updatedAt: created,
);

/// An answer marking the given shifts.
TeamAnswer answer(
  String memberId,
  AnswerMode mode,
  List<TeamSlot> marked, {
  int? maxShifts,
}) => TeamAnswer(
  id: 'a-$memberId',
  weekStart: dayKey(monday),
  memberId: memberId,
  mode: mode,
  marks: marked.fold(0, (m, s) => withMark(m, s.day, s.shift, true)),
  maxShifts: maxShifts,
  createdAt: created,
  updatedAt: created,
);

/// Someone who can work every shift.
TeamAnswer always(String memberId, {int? maxShifts}) =>
    answer(memberId, AnswerMode.cantWork, const [], maxShifts: maxShifts);

TeamAssignment placed(String memberId, TeamSlot slot, {int? start}) =>
    TeamAssignment(
      id: 'x-$memberId-$slot',
      day: slot.dayKey,
      shift: slot.shift,
      memberId: memberId,
      startMinutes: start,
      createdAt: created,
      updatedAt: created,
    );

/// The week these tests were written for: 2 at lunch and 3 in the
/// evening, closed on Sunday. (Not the app's default since 2026-11-10.)
const monToSat = StaffNeeds([2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 0, 0]);

/// Only Monday is open: 1 at lunch, [evening] in the evening.
StaffNeeds mondayOnly({int lunch = 1, int evening = 1}) =>
    StaffNeeds([lunch, evening, for (var i = 0; i < 12; i++) 0]);

RosterWeek week({
  required List<TeamMember> members,
  List<TeamAnswer> answers = const [],
  List<TeamAssignment> assignments = const [],
  List<TeamNeed> needs = const [],
  StaffNeeds defaults = monToSat,
}) => RosterWeek(
  weekStart: monday,
  members: members,
  answers: answers,
  assignments: assignments,
  needs: needs,
  defaults: defaults,
);

void main() {
  final monLunch = TeamSlot(monday, TeamShift.lunch);
  final monEvening = TeamSlot(monday, TeamShift.evening);
  final tueEvening = TeamSlot(tuesday, TeamShift.evening);
  final sunLunch = TeamSlot(addDays(monday, 6), TeamShift.lunch);

  group('settings', () {
    test('staff counts and start times survive a round trip', () {
      final s = const AppSettings().copyWith(
        teamPlanner: true,
        teamStaffNeeded: StaffNeeds.standard.withNeeded(
          DateTime.friday,
          TeamShift.evening,
          5,
        ),
        teamStarts: const TeamStarts(11 * 60 + 30, 18 * 60),
      );
      final stored = {
        for (final e in s.toMap().entries)
          if (e.value != null) e.key: e.value!,
      };
      final read = AppSettings.fromMap(stored);
      expect(read.teamPlanner, isTrue);
      expect(
        read.teamStaffNeeded.needed(DateTime.friday, TeamShift.evening),
        5,
      );
      expect(read.teamStaffNeeded.needed(DateTime.monday, TeamShift.lunch), 0);
      expect(read.teamStarts.lunch, 11 * 60 + 30);
      expect(read.teamStarts.of(TeamShift.evening), 18 * 60);
    });

    test('broken values fall back to the defaults', () {
      final read = AppSettings.fromMap(const {
        'teamStaffNeeded': '2,3;2',
        'teamStarts': 'noon',
      });
      expect(read.teamStaffNeeded, StaffNeeds.standard);
      expect(read.teamStarts.lunch, 12 * 60);
      expect(read.teamStarts.evening, 17 * 60 + 30);
      expect(read.teamPlanner, isFalse);
    });
  });

  group('availability', () {
    test('marks mean "can" or "can\'t" depending on the mode', () {
      final w = week(
        members: [person('Anna'), person('Ben'), person('Cleo')],
        answers: [
          answer('Anna', AnswerMode.canWork, [monEvening]),
          answer('Ben', AnswerMode.cantWork, [monEvening]),
        ],
      );
      expect(w.availability('Anna', monEvening), Availability.available);
      expect(w.availability('Anna', monLunch), Availability.unavailable);
      expect(w.availability('Ben', monEvening), Availability.unavailable);
      expect(w.availability('Ben', monLunch), Availability.available);
      expect(w.availability('Cleo', monLunch), Availability.noAnswer);
    });

    test('closed shifts are never available', () {
      final w = week(members: [person('Anna')], answers: [always('Anna')]);
      expect(w.isOpen(sunLunch), isFalse);
      expect(w.availability('Anna', sunLunch), Availability.unavailable);
      expect(w.possibleCount('Anna'), 12); // Monday to Saturday, 2 each
    });

    test('a week\'s own staff count overrides the default', () {
      final w = week(
        members: const [],
        needs: [
          TeamNeed(
            id: 'n',
            day: sunLunch.dayKey,
            shift: TeamShift.lunch,
            needed: 2,
          ),
        ],
      );
      expect(w.needed(sunLunch), 2);
      expect(w.defaultNeeded(sunLunch), 0);
      expect(w.shownDays.length, 7);
    });

    test('"Away": answered, no shift possible, none planned', () {
      final w = week(
        members: [person('Anna'), person('Ben'), person('Cleo')],
        answers: [
          answer('Anna', AnswerMode.canWork, const []),
          answer('Ben', AnswerMode.canWork, const []),
        ],
        assignments: [placed('Ben', monLunch)],
      );
      expect(w.isAway('Anna'), isTrue);
      expect(w.isAway('Ben'), isFalse); // placed by hand anyway
      expect(w.isAway('Cleo'), isFalse); // no answer yet
    });

    test('summary names whole days once', () {
      final w = week(
        members: [person('Anna')],
        answers: [
          answer('Anna', AnswerMode.canWork, [
            monLunch,
            monEvening,
            tueEvening,
          ]),
        ],
      );
      final days = w.availableDays('Anna');
      expect(days.length, 2);
      expect(days[0].day, monday);
      expect(days[0].shift, isNull);
      expect(days[1].shift, TeamShift.evening);
    });
  });

  group('shift sheet order', () {
    test('core workers first while the shift has none', () {
      final w = week(
        members: [person('Anna'), person('Ben', core: true), person('Cleo')],
        answers: [always('Anna'), always('Ben'), always('Cleo')],
        assignments: [placed('Ben', tueEvening), placed('Ben', monLunch)],
      );
      // Ben has 2 shifts, the others none, but Ben is the only core worker.
      expect(w.candidates(monEvening).available.map((m) => m.name), [
        'Ben',
        'Anna',
        'Cleo',
      ]);
      // With Ben in the shift, the others come first (fewest shifts).
      expect(w.candidates(monLunch).available.map((m) => m.name), [
        'Anna',
        'Cleo',
        'Ben',
      ]);
    });

    test('with a core worker in, other core workers come last', () {
      final w = week(
        members: [
          person('Anna', core: true),
          person('Ben', core: true),
          person('Cleo'),
        ],
        answers: [always('Anna'), always('Ben'), always('Cleo')],
        assignments: [
          placed('Anna', monLunch),
          placed('Cleo', monEvening),
          placed('Cleo', tueEvening),
        ],
      );
      // Anna (core) is in, so Cleo comes first although Ben has fewer
      // shifts; among the core workers, fewest shifts first.
      expect(w.candidates(monLunch).available.map((m) => m.name), [
        'Cleo',
        'Ben',
        'Anna',
      ]);
    });

    test('groups: available, no answer, can\'t work', () {
      final w = week(
        members: [person('Anna'), person('Ben'), person('Cleo')],
        answers: [always('Anna'), answer('Cleo', AnswerMode.canWork, const [])],
      );
      final c = w.candidates(monLunch);
      expect(c.available.map((m) => m.name), ['Anna']);
      expect(c.noAnswer.map((m) => m.name), ['Ben']);
      expect(c.unavailable.map((m) => m.name), ['Cleo']);
    });
  });

  group('fill', () {
    test('keeps people placed by hand and spreads shifts evenly', () {
      final w = week(
        members: [person('Anna'), person('Ben'), person('Cleo')],
        answers: [always('Anna'), always('Ben'), always('Cleo')],
        assignments: [placed('Anna', monLunch)],
        defaults: mondayOnly(lunch: 2, evening: 2),
      );
      final result = w.fill();
      expect(result.openPlaces, 0);
      expect(result.added.length, 3);
      expect(result.added.any((p) => p.memberId == 'Anna'), isTrue);
      final counts = {
        for (final id in ['Anna', 'Ben', 'Cleo'])
          id:
              (id == 'Anna' ? 1 : 0) +
              result.added.where((p) => p.memberId == id).length,
      };
      expect(counts.values.toSet(), {1, 2});
      expect(counts.values.reduce((a, b) => a + b), 4);
    });

    test('puts a core worker into each shift first', () {
      final w = week(
        members: [
          person('Anna'),
          person('Ben'),
          person('Kim', core: true),
          person('Lu', core: true),
        ],
        answers: [always('Anna'), always('Ben'), always('Kim'), always('Lu')],
        defaults: mondayOnly(lunch: 2, evening: 2),
      );
      final result = w.fill();
      final w2 = week(
        members: w.members,
        answers: [always('Anna'), always('Ben'), always('Kim'), always('Lu')],
        assignments: [for (final p in result.added) placed(p.memberId, p.slot)],
        defaults: mondayOnly(lunch: 2, evening: 2),
      );
      expect(w2.hasCore(monLunch), isTrue);
      expect(w2.hasCore(monEvening), isTrue);
      expect(result.withoutCore, isEmpty);
      for (final m in w.members) {
        expect(w2.shiftCount(m.id), 1, reason: m.name);
      }
    });

    test('round two prefers people who aren\'t core workers', () {
      // One shift for three: the core worker is in after round one; the
      // two other places go to Anna and Ben, although Lu has as few shifts.
      final w = week(
        members: [
          person('Anna'),
          person('Ben'),
          person('Kim', core: true),
          person('Lu', core: true),
        ],
        answers: [always('Anna'), always('Ben'), always('Kim'), always('Lu')],
        defaults: mondayOnly(lunch: 3, evening: 0),
      );
      final names = w.fill().added.map((p) => p.memberId).toSet();
      expect(names, {'Kim', 'Anna', 'Ben'});
    });

    test('core workers still fill places nobody else can', () {
      final w = week(
        members: [
          person('Anna'),
          person('Kim', core: true),
          person('Lu', core: true),
        ],
        answers: [always('Anna'), always('Kim'), always('Lu')],
        defaults: mondayOnly(lunch: 3, evening: 0),
      );
      expect(w.fill().openPlaces, 0);
    });

    test('people without an answer and over their limit stay out', () {
      final w = week(
        members: [person('Anna'), person('Ben')],
        answers: [always('Anna', maxShifts: 1)],
        defaults: mondayOnly(lunch: 1, evening: 1),
      );
      final result = w.fill();
      expect(result.added.length, 1);
      expect(result.added.single.memberId, 'Anna');
      expect(result.openPlaces, 1);
    });

    test('hardest shift first: the only person for it isn\'t used up', () {
      // Ben can only do the evening; Anna can do both. One place each.
      final w = week(
        members: [person('Anna'), person('Ben')],
        answers: [
          always('Anna', maxShifts: 1),
          answer('Ben', AnswerMode.canWork, [monEvening]),
        ],
        defaults: mondayOnly(lunch: 1, evening: 1),
      );
      final result = w.fill();
      final bySlot = {for (final p in result.added) p.slot: p.memberId};
      expect(bySlot[monEvening], 'Ben');
      expect(bySlot[monLunch], 'Anna');
    });

    test('reports shifts without a core worker', () {
      final w = week(
        members: [person('Anna'), person('Kim', core: true)],
        answers: [
          always('Anna'),
          answer('Kim', AnswerMode.canWork, [monLunch]),
        ],
        defaults: mondayOnly(),
      );
      final result = w.fill();
      expect(result.withoutCore, [monEvening]);
      expect(result.openPlaces, 0);
    });

    test('the same input gives the same plan', () {
      RosterWeek make() => week(
        members: [
          for (final n in ['Eva', 'Anna', 'Ben', 'Cleo']) person(n),
        ],
        answers: [
          for (final n in ['Eva', 'Anna', 'Ben', 'Cleo']) always(n),
        ],
      );
      String plan(FillResult r) =>
          r.added.map((p) => '${p.memberId}@${p.slot}').join(',');
      expect(plan(make().fill()), plan(make().fill()));
    });
  });

  group('repository and own shifts', () {
    late AppDatabase db;
    late RosterRepository roster;
    late ShiftRepository shifts;
    late PlanningService planning;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      roster = RosterRepository(db);
      shifts = ShiftRepository(db);
      planning = PlanningService(shifts, SettingsRepository(db), () async {});
    });
    tearDown(() => db.close());

    test('only one person is "me"', () async {
      final a = await roster.addMember('Anna', isMe: true);
      await roster.addMember('Ben', isMe: true);
      final members = await roster.watchMembers().first;
      expect(members.where((m) => m.isMe).map((m) => m.name), ['Ben']);
      await roster.saveMember(a.copyWith(isMe: true));
      final again = await roster.watchMembers().first;
      expect(again.where((m) => m.isMe).map((m) => m.name), ['Anna']);
    });

    test('deleting a person removes their answers and shifts', () async {
      final a = await roster.addMember('Anna');
      final b = await roster.addMember('Ben');
      await roster.setAnswer(monday, a.id, mode: AnswerMode.canWork, marks: 1);
      await roster.assign(monLunch, a.id);
      await roster.assign(monLunch, b.id);
      await roster.deleteMember(a.id);
      expect((await roster.watchMembers().first).map((m) => m.name), ['Ben']);
      expect(await roster.watchAnswers(monday).first, isEmpty);
      expect((await roster.assignmentsOfWeek(monday)).single.memberId, b.id);
      expect(await roster.hasEntries(b.id), isTrue);
    });

    test('a staff count equal to the default removes the row', () async {
      await roster.setNeeded(monLunch, 4, 2);
      expect((await roster.watchNeeds(monday).first).single.needed, 4);
      await roster.setNeeded(monLunch, 2, 2);
      expect(await roster.watchNeeds(monday).first, isEmpty);
    });

    test('clear and undo', () async {
      final a = await roster.addMember('Anna');
      await roster.assign(monLunch, a.id);
      await roster.assign(monLunch, a.id); // twice: still once
      final before = await roster.assignmentsOfWeek(monday);
      expect(before.length, 1);
      expect(await roster.hasEntries(a.id), isTrue);

      final removed = await roster.clearWeek(monday);
      expect(await roster.assignmentsOfWeek(monday), isEmpty);
      await roster.restoreAll(removed);
      expect(
        (await roster.assignmentsOfWeek(monday)).single.id,
        before.single.id,
      );
    });

    test('answers are saved, replaced and removed', () async {
      await roster.setAnswer(
        monday,
        'Anna',
        mode: AnswerMode.canWork,
        marks: 3,
      );
      await roster.setAnswer(
        monday,
        'Anna',
        mode: AnswerMode.cantWork,
        marks: 1,
        maxShifts: 2,
      );
      final saved = (await roster.watchAnswers(monday).first).single;
      expect(saved.mode, AnswerMode.cantWork);
      expect(saved.maxShifts, 2);
      await roster.removeAnswer(monday, 'Anna');
      expect(await roster.watchAnswers(monday).first, isEmpty);
    });

    test('own shifts go onto the Plan tab once', () async {
      final added = await planning.addFromTeamPlan([
        (day: monday, type: ShiftType.lunch, start: null),
        (day: monday, type: ShiftType.evening, start: 18 * 60 + 30),
      ]);
      expect(added, 2);
      final day = await shifts.getDays(monday, tuesday);
      final lunch = day.firstWhere((s) => s.type == ShiftType.lunch);
      final evening = day.firstWhere((s) => s.type == ShiftType.evening);
      expect(hhmm(lunch.plannedEnd), '15:30'); // evening that day
      expect(hhmm(evening.plannedStart), '18:30');
      expect(hhmm(evening.plannedEnd), '23:00');
      expect(evening.plannedCustomized, isTrue);

      final again = await planning.addFromTeamPlan([
        (day: monday, type: ShiftType.lunch, start: null),
      ]);
      expect(again, 0);
    });
  });
}
