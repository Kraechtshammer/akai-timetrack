import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_settings.dart';
import '../data/database.dart';
import '../data/settings_repository.dart';
import '../core/time.dart';
import '../domain/roster.dart';
import '../domain/team_hours.dart';
import '../platform/app_icon.dart';
import 'services.dart';

/// Set in main() with the services created at start.
final servicesProvider = Provider<AppServices>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(servicesProvider).settings.watch(),
);

/// A range of days: from (inclusive) to (exclusive).
typedef DayRange = (DateTime from, DateTime to);

/// Shifts in a range of days, kept up to date.
final shiftsProvider = StreamProvider.family<List<Shift>, DayRange>(
  (ref, range) =>
      ref.watch(servicesProvider).shifts.watchDays(range.$1, range.$2),
);

/// Daily pool totals with a day in the range.
final tipDaysProvider = StreamProvider.family<List<TipDay>, DayRange>(
  (ref, range) =>
      ref.watch(servicesProvider).tips.watchDays(range.$1, range.$2),
);

/// Weekly payouts ("Paid out") of the weeks starting in the range.
final tipPayoutsProvider = StreamProvider.family<List<TipPayout>, DayRange>(
  (ref, range) =>
      ref.watch(servicesProvider).tips.watchPayouts(range.$1, range.$2),
);

/// The hourly wage rates, oldest first (docs/02-design.md §4.8).
final wageRatesProvider = StreamProvider<List<WageRate>>(
  (ref) => ref.watch(servicesProvider).wages.watchAll(),
);

/// The day whose tip prompt on the Home tab the user closed (`yyyy-MM-dd`).
final tipPromptDismissedProvider = StreamProvider<String?>(
  (ref) => ref
      .watch(servicesProvider)
      .settings
      .watchStatus(SettingsRepository.tipPromptDismissed),
);

/// Team planner (F11): everyone on the team list.
final teamMembersProvider = StreamProvider<List<TeamMember>>(
  (ref) => ref.watch(servicesProvider).roster.watchMembers(),
);

/// Team planner: the answers of the week starting on the given Monday.
final teamAnswersProvider = StreamProvider.family<List<TeamAnswer>, DateTime>(
  (ref, week) => ref.watch(servicesProvider).roster.watchAnswers(week),
);

/// Team planner: who is in which shift that week.
final teamAssignmentsProvider =
    StreamProvider.family<List<TeamAssignment>, DateTime>(
      (ref, week) => ref.watch(servicesProvider).roster.watchAssignments(week),
    );

/// Team planner: the week's own staff counts.
final teamNeedsProvider = StreamProvider.family<List<TeamNeed>, DateTime>(
  (ref, week) => ref.watch(servicesProvider).roster.watchNeeds(week),
);

/// Team planner: who is in which shift from `from` to `to` (days
/// included), for the monthly hours.
final teamAssignmentsBetweenProvider =
    StreamProvider.family<List<TeamAssignment>, ({DateTime from, DateTime to})>(
      (ref, range) => ref
          .watch(servicesProvider)
          .roster
          .watchAssignmentsBetween(range.from, range.to),
    );

/// The days of the months a week touches, for [teamAssignmentsBetweenProvider].
({DateTime from, DateTime to}) monthsOfWeek(DateTime weekStart) =>
    (from: monthStart(weekStart), to: lastDayOfMonth(addDays(weekStart, 6)));

/// Team planner: the whole week with its rules (docs/02-design.md §4.9).
/// null while loading.
final rosterWeekProvider = Provider.family<RosterWeek?, DateTime>((ref, week) {
  final members = ref.watch(teamMembersProvider).value;
  final answers = ref.watch(teamAnswersProvider(week)).value;
  final assignments = ref.watch(teamAssignmentsProvider(week)).value;
  final needs = ref.watch(teamNeedsProvider(week)).value;
  final settings = ref.watch(settingsProvider).value;
  final months = ref
      .watch(teamAssignmentsBetweenProvider(monthsOfWeek(week)))
      .value;
  if (members == null ||
      answers == null ||
      assignments == null ||
      needs == null ||
      settings == null ||
      months == null) {
    return null;
  }
  return RosterWeek(
    weekStart: week,
    members: members,
    answers: answers,
    assignments: assignments,
    needs: needs,
    defaults: settings.teamStaffNeeded,
    monthAssignments: months,
    settings: settings,
  );
});

/// Team planner: everyone's planned hours in the month of `month` ("Hours
/// per month"), sorted by name. null while loading.
final teamMonthProvider = Provider.family<List<MemberMonth>?, DateTime>((
  ref,
  month,
) {
  final members = ref.watch(teamMembersProvider).value;
  final settings = ref.watch(settingsProvider).value;
  final rows = ref
      .watch(
        teamAssignmentsBetweenProvider((
          from: monthStart(month),
          to: lastDayOfMonth(month),
        )),
      )
      .value;
  if (members == null || settings == null || rows == null) return null;
  return monthHours([...members]..sort(compareByName), rows, settings, month);
});

final runningShiftProvider = StreamProvider<Shift?>(
  (ref) => ref.watch(servicesProvider).shifts.watchRunning(),
);

/// When the calendar sync last finished without errors.
final lastCalendarSyncProvider = StreamProvider<DateTime?>(
  (ref) => ref.watch(servicesProvider).settings.watchLastCalendarSync(),
);

/// How many shifts still wait for the calendar sync.
final pendingSyncCountProvider = StreamProvider<int>(
  (ref) => ref.watch(servicesProvider).shifts.watchPendingSyncCount(),
);

/// The launcher icon variant (read from Android). Invalidate after a change.
final appIconProvider = FutureProvider<AppIcon>((ref) => AppIcons.current());

/// The current time, updated every 20 seconds (for countdowns and "today").
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 20), (_) => DateTime.now());
});

extension SettingsOrDefault on WidgetRef {
  AppSettings get settings =>
      watch(settingsProvider).value ?? const AppSettings();
  DateTime get now => watch(nowProvider).value ?? DateTime.now();
  AppServices get services => read(servicesProvider);
}
