import 'package:akai_timetrack/core/time.dart';
import 'package:akai_timetrack/data/app_settings.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/domain/roster.dart';
import 'package:akai_timetrack/domain/team_hours.dart';
import 'package:flutter_test/flutter_test.dart';

// Team planner (F11): monthly hours limits, docs/02-design.md §4.9.
// Default shift times: lunch 12:00–16:00, lunch before an evening shift
// 12:00–15:30, evening 17:30–23:00.

final created = DateTime(2026, 11, 1);
const settings = AppSettings();

/// 43 hours, about a mini-job in 2026.
const miniJob = 43 * 60;

TeamMember person(String name, {int? limit, bool core = false}) => TeamMember(
  id: name,
  name: name,
  core: core,
  isMe: false,
  active: true,
  maxMonthMinutes: limit,
  createdAt: created,
  updatedAt: created,
);

TeamAssignment placed(
  String memberId,
  DateTime day,
  TeamShift shift, {
  int? start,
}) => TeamAssignment(
  id: 'x-$memberId-${dayKey(day)}-${shift.name}',
  day: dayKey(day),
  shift: shift,
  memberId: memberId,
  startMinutes: start,
  createdAt: created,
  updatedAt: created,
);

TeamAssignment evening(String id, DateTime day) =>
    placed(id, day, TeamShift.evening);

/// Every evening of the days from [from], [count] days long.
List<TeamAssignment> evenings(String id, DateTime from, int count) => [
  for (var i = 0; i < count; i++) evening(id, addDays(from, i)),
];

TeamAnswer always(String memberId, DateTime weekStart) => TeamAnswer(
  id: 'a-$memberId',
  weekStart: dayKey(weekStart),
  memberId: memberId,
  mode: AnswerMode.cantWork,
  marks: 0,
  maxShifts: null,
  createdAt: created,
  updatedAt: created,
);

HoursState state(
  List<TeamAssignment> rows,
  DateTime weekStart, {
  int? limit = miniJob,
}) => weekHoursState(TeamHours(rows, settings), 'A', limit, weekStart);

void main() {
  final nov2 = DateTime(2026, 11, 2); // a Monday
  final nov9 = DateTime(2026, 11, 9);
  final nov30 = DateTime(2026, 11, 30);

  group('hours of a team shift', () {
    test('come from the shift times', () {
      expect(teamShiftMinutes(TeamShift.lunch, null, settings), 240);
      expect(teamShiftMinutes(TeamShift.evening, null, settings), 330);
      expect(
        teamShiftMinutes(TeamShift.lunch, null, settings, eveningSameDay: true),
        210,
      );
    });

    test('a special start counts from that time', () {
      expect(teamShiftMinutes(TeamShift.evening, 18 * 60 + 30, settings), 270);
      // Starting after the end counts nothing.
      expect(teamShiftMinutes(TeamShift.evening, 23 * 60 + 30, settings), 0);
    });

    test('an evening ending after midnight', () {
      final late = settings.copyWith(evening: const ShiftTimes(18 * 60, 60));
      expect(teamShiftMinutes(TeamShift.evening, null, late), 7 * 60);
    });

    test('a lunch before the same person\'s evening ends earlier', () {
      final hours = TeamHours([
        placed('A', nov2, TeamShift.lunch),
        evening('A', nov2),
        placed('B', nov2, TeamShift.lunch),
        evening('A', nov9),
      ], settings);
      expect(hours.between('A', nov2, nov2), 210 + 330);
      expect(hours.between('B', nov2, nov2), 240);
    });

    test('a month counts only its own days', () {
      final hours = TeamHours([
        evening('A', DateTime(2026, 10, 31)),
        evening('A', nov2),
        evening('A', nov30),
        evening('A', DateTime(2026, 12, 1)),
      ], settings);
      expect(hours.inMonth('A', nov9), 660);
      expect(hours.inMonth('A', DateTime(2026, 12, 6)), 330);
    });
  });

  group('the monthly limit of a week', () {
    test('without a limit, everything is fine', () {
      expect(state(evenings('A', nov2, 7), nov2, limit: null), HoursState.ok);
    });

    test('a week may take its share of the limit and one long shift', () {
      // 43 h over the 29 days from 2 November: about 10.4 h a week, plus
      // one evening (5.5 h): up to about 15.9 h.
      final w = weekHours(
        TeamHours(evenings('A', nov2, 2), settings),
        'A',
        miniJob,
        nov2,
      )!;
      expect(w.share, miniJob * 7 ~/ 29);
      expect(w.slack, 330);
      expect(w.allowed, w.share + 330);
      expect(w.weekMinutes, 660);
      expect(w.month, DateTime(2026, 11));
      expect(state(evenings('A', nov2, 2), nov2), HoursState.ok);
      expect(state(evenings('A', nov2, 3), nov2), HoursState.aboveWeekShare);
    });

    test('with nothing planned before, a later week may take more', () {
      // From 16 November, 43 h over 15 days: about 20 h, plus 5.5 h.
      final nov16 = DateTime(2026, 11, 16);
      expect(state(evenings('A', nov16, 4), nov16), HoursState.ok);
      expect(state(evenings('A', nov16, 5), nov16), HoursState.aboveWeekShare);
    });

    test('a single shift is never above the share', () {
      // 33 h before: 10 h left for 22 days, a share of about 3.2 h.
      final full = evenings('A', nov2, 6);
      expect(TeamHours(full, settings).inMonth('A', nov2), 1980);
      expect(state([...full, evening('A', nov9)], nov9), HoursState.ok);
    });

    test('the share comes from what is left before the week', () {
      // 22 h planned before: 21 h left for 22 days, about 6.7 h this week,
      // up to about 12.2 h with the long shift.
      final before = evenings('A', nov2, 4);
      expect(
        state([...before, ...evenings('A', nov9, 2)], nov9),
        HoursState.ok,
      );
      expect(
        state([...before, ...evenings('A', nov9, 3)], nov9),
        HoursState.aboveWeekShare,
      );
    });

    test('later weeks count for the limit, not for the share', () {
      final later = evenings('A', DateTime(2026, 11, 16), 5);
      expect(state([...later, evening('A', nov9)], nov9), HoursState.ok);
      final full = [...later, ...evenings('A', DateTime(2026, 11, 23), 2)];
      expect(state([...full, evening('A', nov9)], nov9), HoursState.overLimit);
    });

    test('a week across two months is checked in both', () {
      // 30 November is a Monday; the week ends on 6 December. 33 h before
      // it in November: the 10 h left may all go into 30 November.
      final november = evenings('A', nov2, 6);
      expect(state([...november, evening('A', nov30)], nov30), HoursState.ok);
      final full = [...november, ...evenings('A', DateTime(2026, 11, 16), 2)];
      expect(
        state([...full, evening('A', nov30)], nov30),
        HoursState.overLimit,
      );
      // December: 4 evenings are far above the share of 6 of 31 days.
      expect(
        state(evenings('A', DateTime(2026, 12, 1), 4), nov30),
        HoursState.aboveWeekShare,
      );
    });
  });

  group('in the team plan', () {
    RosterWeek week(
      List<TeamMember> members, {
      List<TeamAssignment> assignments = const [],
      List<TeamAssignment> month = const [],
      // Only Monday evening is open, for one person.
      StaffNeeds needs = const StaffNeeds([
        0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
      ]),
    }) => RosterWeek(
      weekStart: nov9,
      members: members,
      answers: [for (final m in members) always(m.id, nov9)],
      assignments: assignments,
      needs: const [],
      defaults: needs,
      monthAssignments: [...month, ...assignments],
      settings: settings,
    );

    final monEvening = TeamSlot(nov9, TeamShift.evening);

    test('hours left and the state with a shift added', () {
      final w = week(
        [person('A', limit: 10 * 60), person('B')],
        month: [evening('A', nov2)],
      );
      expect(w.monthMinutes('A', nov9), 330);
      expect(w.minutesLeft('A', nov9), 600 - 330);
      expect(w.minutesLeft('B', nov9), isNull);
      expect(w.hoursState('A'), HoursState.ok);
      expect(w.hoursState('A', adding: monEvening), HoursState.overLimit);
      expect(w.hoursState('B', adding: monEvening), HoursState.ok);
    });

    test('an assigned shift is not counted twice when "adding" it', () {
      final w = week(
        [person('A', limit: miniJob)],
        assignments: [evening('A', nov9)],
      );
      expect(w.hoursState('A', adding: monEvening), w.hoursState('A'));
      expect(w.monthMinutes('A', nov9), 330);
    });

    test('warnings of a person, most serious first', () {
      final members = [person('A', limit: 600), person('B')];
      final month = [evening('A', nov2)];
      final assignments = [evening('A', nov9)];
      final w = week(members, month: month, assignments: assignments);
      final tueEvening = TeamSlot(addDays(nov9, 1), TeamShift.evening);
      expect(w.warningsOf('A'), [TeamWarning.overLimit]);
      expect(w.warningsOf('A', slot: monEvening), [TeamWarning.overLimit]);
      // Tuesday is closed, so nobody can work it.
      expect(w.warningsOf('A', slot: tueEvening), [
        TeamWarning.cantWork,
        TeamWarning.overLimit,
      ]);
      expect(w.warningsOf('B', slot: monEvening), isEmpty);

      final unanswered = RosterWeek(
        weekStart: nov9,
        members: members,
        answers: const [],
        assignments: assignments,
        needs: const [],
        defaults: const StaffNeeds([
          0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
        ]),
        monthAssignments: [...month, ...assignments],
        settings: settings,
      );
      expect(unanswered.warningsOf('A', slot: monEvening), [
        TeamWarning.overLimit,
        TeamWarning.noAnswer,
      ]);
      expect(unanswered.warningsOf('B', slot: monEvening), [
        TeamWarning.noAnswer,
      ]);
      // Without a shift, the answer is not looked at.
      expect(unanswered.warningsOf('B'), isEmpty);
    });

    test('above the week\'s share is the mildest warning', () {
      final w = week(
        [person('A', limit: 12 * 60)],
        assignments: [evening('A', nov9), evening('A', addDays(nov9, 1))],
      );
      expect(w.warningsOf('A', slot: monEvening), [TeamWarning.aboveWeekShare]);
    });

    test('Fill never goes over a monthly limit', () {
      final w = week([person('A', limit: 600)], month: [evening('A', nov2)]);
      final result = w.fill();
      expect(result.added, isEmpty);
      expect(result.openPlaces, 1);
    });

    test('Fill never goes above the week\'s share', () {
      // A has fewer shifts, but a second evening would put A above the
      // week's share of 12 h (about 3.8 h plus 5.5 h); B has no limit.
      final w = week(
        [person('A', limit: 12 * 60), person('B')],
        assignments: [
          evening('A', addDays(nov9, 1)),
          ...evenings('B', addDays(nov9, 1), 2),
        ],
      );
      expect(w.hoursState('A'), HoursState.ok);
      expect(w.hoursState('A', adding: monEvening), HoursState.aboveWeekShare);
      final picks = w.fill().added;
      expect(picks.single.memberId, 'B');
      expect(picks.single.slot, monEvening);
    });
  });
}
