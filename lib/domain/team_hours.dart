// Team planner (F11): planned hours per person and month, for people with
// a monthly limit (mini-jobs). Pure Dart. See docs/02-design.md §4.9.

import 'dart:math' as math;

import '../core/time.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import 'planning.dart';

/// Where a person stands against their monthly limit.
enum HoursState { ok, aboveWeekShare, overLimit }

/// Planned minutes of a team shift, from the shift times in Settings ›
/// Shifts: a special start counts from that time, and a lunch of someone
/// who also works that evening ends at "Lunch before an evening shift",
/// like "Add my shifts to Plan" does.
int teamShiftMinutes(
  TeamShift shift,
  Minutes? start,
  AppSettings settings, {
  bool eveningSameDay = false,
}) {
  final times = defaultTimes(
    shift == TeamShift.lunch ? ShiftType.lunch : ShiftType.evening,
    settings,
    eveningSameDay: eveningSameDay,
  );
  // A shift that ends after midnight.
  final end = times.end < times.start ? times.end + 24 * 60 : times.end;
  return math.max(0, end - (start ?? times.start));
}

/// Planned minutes of a list of team shifts (any people, any days).
class TeamHours {
  TeamHours(Iterable<TeamAssignment> assignments, this.settings)
    : _rows = List.unmodifiable(assignments),
      _evenings = {
        for (final a in assignments)
          if (a.shift == TeamShift.evening) '${a.memberId} ${a.day}',
      };

  final AppSettings settings;
  final List<TeamAssignment> _rows;
  final Set<String> _evenings;

  int minutesOf(TeamAssignment a) => teamShiftMinutes(
    a.shift,
    a.startMinutes,
    settings,
    eveningSameDay:
        a.shift == TeamShift.lunch &&
        _evenings.contains('${a.memberId} ${a.day}'),
  );

  /// The person's minutes from [from] to [to], both days included.
  int between(String memberId, DateTime from, DateTime to) {
    final first = dayKey(from), last = dayKey(to);
    var sum = 0;
    for (final a in _rows) {
      if (a.memberId != memberId) continue;
      if (a.day.compareTo(first) < 0 || a.day.compareTo(last) > 0) continue;
      sum += minutesOf(a);
    }
    return sum;
  }

  /// The person's minutes in the calendar month of [month].
  int inMonth(String memberId, DateTime month) =>
      between(memberId, monthStart(month), lastDayOfMonth(month));
}

/// The last day of the month of [t].
DateTime lastDayOfMonth(DateTime t) => addDays(nextMonthStart(t), -1);

/// The longest team shift with the normal start times (Evening, 5.5 h by
/// default): what a week may take on top of its share.
int longestShiftMinutes(AppSettings settings) => math.max(
  teamShiftMinutes(TeamShift.lunch, null, settings),
  teamShiftMinutes(TeamShift.evening, null, settings),
);

/// A week against a person's monthly limit, in one month it touches, with
/// the numbers for the explanation.
class WeekHours {
  const WeekHours({
    required this.state,
    required this.month,
    required this.limit,
    required this.monthMinutes,
    required this.leftBefore,
    required this.share,
    required this.slack,
    required this.weekMinutes,
  });

  final HoursState state;

  /// The first day of the month the numbers are for.
  final DateTime month;
  final int limit;

  /// Planned in the whole month, all weeks.
  final int monthMinutes;

  /// What is left of the limit before the week (negative when over).
  final int leftBefore;

  /// The week's share of [leftBefore]: spread evenly over the rest of the
  /// month, for the week's days in the month.
  final int share;

  /// What the week may take on top of [share]: one long shift.
  final int slack;

  /// Planned in the week's days of [month].
  final int weekMinutes;

  /// Most the week may have before it is above its share.
  int get allowed => share + slack;
}

/// [weekStart]'s week against the person's monthly [limit] (minutes), with
/// all their shifts in the months the week touches in [hours]. null
/// without a limit.
///
/// Over the limit: a touched month has more than [limit] planned.
/// Above the week's share: the week's planned minutes in a month are more
/// than its share of what is left of the limit before the week (spread
/// evenly over the rest of the month) plus one long shift. Later weeks
/// don't count for the share, since planning goes forward. For a week
/// across two months, the month with the worse state is returned, else
/// the month of the week's Thursday.
WeekHours? weekHours(
  TeamHours hours,
  String memberId,
  int? limit,
  DateTime weekStart,
) {
  if (limit == null) return null;
  final weekEnd = addDays(weekStart, 6);
  final slack = longestShiftMinutes(hours.settings);
  WeekHours check(DateTime month) {
    final first = weekStart.isBefore(month) ? month : weekStart;
    final monthEnd = lastDayOfMonth(month);
    final last = weekEnd.isAfter(monthEnd) ? monthEnd : weekEnd;
    final days = daysBetween(first, last) + 1;
    final daysLeft = daysBetween(first, monthEnd) + 1;
    final total = hours.inMonth(memberId, month);
    final left = limit - hours.between(memberId, month, addDays(first, -1));
    final share = math.max(0, left) * days ~/ daysLeft;
    final planned = hours.between(memberId, first, last);
    return WeekHours(
      state: total > limit
          ? HoursState.overLimit
          : planned > share + slack
          ? HoursState.aboveWeekShare
          : HoursState.ok,
      month: month,
      limit: limit,
      monthMinutes: total,
      leftBefore: left,
      share: share,
      slack: slack,
      weekMinutes: planned,
    );
  }

  final thursday = monthStart(addDays(weekStart, 3));
  final checks = [
    check(thursday),
    for (final m in {monthStart(weekStart), monthStart(weekEnd)})
      if (m != thursday) check(m),
  ];
  return checks.reduce((a, b) => b.state.index > a.state.index ? b : a);
}

/// [weekHours] as a state; ok without a limit.
HoursState weekHoursState(
  TeamHours hours,
  String memberId,
  int? limit,
  DateTime weekStart,
) => weekHours(hours, memberId, limit, weekStart)?.state ?? HoursState.ok;

/// One row of "Hours per month".
class MemberMonth {
  const MemberMonth(this.member, this.minutes);

  final TeamMember member;
  final int minutes;

  int? get limit => member.maxMonthMinutes;

  /// Minutes left under the limit (negative when over), null without one.
  int? get left => limit == null ? null : limit! - minutes;

  bool get over => (left ?? 0) < 0;
}

/// Everyone's planned minutes in the month of [month], sorted like
/// [members] (the caller sorts them by name).
List<MemberMonth> monthHours(
  List<TeamMember> members,
  List<TeamAssignment> assignments,
  AppSettings settings,
  DateTime month,
) {
  final hours = TeamHours(assignments, settings);
  return [for (final m in members) MemberMonth(m, hours.inMonth(m.id, month))];
}
