// The "Team" tab (F11): the week board, answers, Fill, Clear and Share.
// See docs/02-design.md §4.9 and §7.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time.dart';
import '../../data/database.dart';
import '../../domain/roster.dart';
import '../../domain/team_hours.dart';
import '../common.dart';
import 'answer_screen.dart';
import 'hours_screen.dart';
import 'people_screen.dart';
import 'roster_common.dart';
import 'share_screen.dart';
import 'shift_sheet.dart';

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  late DateTime _week = nextPlanWeek(DateTime.now());

  void _push(Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  void _shift(int weeks) => setState(() => _week = addDays(_week, 7 * weeks));

  Future<void> _addMine(RosterWeek week) async {
    final me = week.me!;
    final added = await ref.services.planning.addFromTeamPlan([
      for (final a in week.assignments)
        if (a.memberId == me.id)
          (
            day: parseDayKey(a.day),
            type: a.shift == TeamShift.lunch
                ? ShiftType.lunch
                : ShiftType.evening,
            start: a.startMinutes,
          ),
    ]);
    if (!mounted) return;
    context.showSnack(
      added == 0
          ? context.l10n.teamMyShiftsAlready
          : context.l10n.teamAddedMyShifts(added),
    );
  }

  Future<void> _fill(RosterWeek week) async {
    final l10n = context.l10n;
    final roster = ref.services.roster;
    final result = week.fill();
    final rows = await roster.addAll(result.added);
    if (!mounted) return;
    if (result.added.isEmpty) {
      context.showSnack(
        result.openPlaces == 0 ? l10n.teamAllFilled : l10n.teamNobodyFits,
      );
      return;
    }
    context.showSnack(
      l10n.teamFilled(result.added.length) +
          (result.openPlaces > 0
              ? ' · ${l10n.teamStillOpen(result.openPlaces)}'
              : ''),
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () => roster.removeAll(rows),
      ),
    );
  }

  Future<void> _clear(RosterWeek week) async {
    final l10n = context.l10n;
    final roster = ref.services.roster;
    final rows = await roster.clearWeek(week.weekStart);
    if (!mounted) return;
    context.showSnack(
      l10n.teamCleared,
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () => roster.restoreAll(rows),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final week = ref.watch(rosterWeekProvider(_week));
    final me = week?.me;
    final canAddMine = me != null && week!.shiftCount(me.id) > 0;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        PageHeader(
          title: l10n.teamTitle,
          subtitle: l10n.teamSubtitle,
          actions: [
            // The month of the week's Thursday, like ISO weeks.
            M3EIconButton(
              variant: M3EIconButtonVariant.standard,
              tooltip: l10n.teamHoursTitle,
              icon: const Icon(Icons.hourglass_bottom),
              onPressed: () =>
                  _push(TeamHoursScreen(month: monthStart(addDays(_week, 3)))),
            ),
            PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) =>
                  v == 0 ? _push(const PeopleScreen()) : _addMine(week!),
              itemBuilder: (_) => [
                PopupMenuItem(value: 0, child: Text(l10n.teamPeople)),
                if (canAddMine)
                  PopupMenuItem(value: 1, child: Text(l10n.teamAddMyShifts)),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v.abs() > 300) _shift(v < 0 ? 1 : -1);
            },
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WeekSwitcher(
                  title: l10n.weekLabel(isoWeekNumber(_week)),
                  subtitle: weekRange(_week, context.locale),
                  onPrevious: () => _shift(-1),
                  onNext: () => _shift(1),
                ),
                if (_week != nextPlanWeek(DateTime.now()))
                  Align(
                    alignment: Alignment.centerLeft,
                    child: M3EButton(
                      style: M3EButtonStyle.text,
                      onPressed: () =>
                          setState(() => _week = nextPlanWeek(DateTime.now())),
                      child: Text(l10n.teamNextWeek),
                    ),
                  ),
                if (week == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _AnswersCard(
                    week: week,
                    onPeople: () => _push(const PeopleScreen()),
                    onAnswers: () {
                      final ids = [for (final m in week.members) m.id];
                      _push(
                        AnswerScreen(
                          week: _week,
                          memberIds: ids,
                          initialIndex: week.firstUnanswered,
                        ),
                      );
                    },
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      M3EButton.icon(
                        style: M3EButtonStyle.tonal,
                        icon: const Icon(Icons.auto_fix_high, size: 18),
                        label: Text(l10n.teamFill),
                        onPressed: () => _fill(week),
                      ),
                      M3EButton(
                        style: M3EButtonStyle.text,
                        onPressed: week.assignments.isEmpty
                            ? null
                            : () => _clear(week),
                        child: Text(l10n.teamClear),
                      ),
                      M3EButton.icon(
                        icon: const Icon(Icons.share, size: 18),
                        label: Text(l10n.share),
                        onPressed: () =>
                            _push(ShareScreen(week: week.weekStart)),
                      ),
                    ],
                  ),
                  for (final day in week.shownDays)
                    _DayCard(week: week, day: day),
                  _PerPersonCard(week: week),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnswersCard extends StatelessWidget {
  const _AnswersCard({
    required this.week,
    required this.onPeople,
    required this.onAnswers,
  });

  final RosterWeek week;
  final VoidCallback onPeople;
  final VoidCallback onAnswers;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = week.members.length;
    return Panel(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(
              active == 0
                  ? l10n.teamNoPeople
                  : l10n.teamAnswersCount(week.answeredCount, active),
              style: context.text.titleSmall,
            ),
          ),
          M3EButton(
            style: M3EButtonStyle.tonal,
            onPressed: active == 0 ? onPeople : onAnswers,
            child: Text(
              active == 0 ? l10n.teamAddPeople : l10n.teamEnterAnswers,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({required this.week, required this.day});

  final RosterWeek week;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isToday = day == dateOnly(ref.now);
    return DayCard(
      isToday: isToday,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 8,
            children: [
              Text(
                shortWeekday(day, context.locale),
                style: context.text.titleMedium,
              ),
              Text(
                DateFormat.MMMd(context.locale).format(day),
                style: context.text.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final shift in TeamShift.values)
            if (week.slotShown(TeamSlot(day, shift)))
              _SlotRow(week: week, slot: TeamSlot(day, shift)),
        ],
      ),
    );
  }
}

class _SlotRow extends ConsumerWidget {
  const _SlotRow({required this.week, required this.slot});

  final RosterWeek week;
  final TeamSlot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.text;
    final normal = ref.settings.teamStarts.of(slot.shift);
    final needed = week.needed(slot);
    final assignments = week.assignmentsIn(slot);
    final count = assignments.length;
    final countColor = count < needed
        ? colors.error
        : count > needed
        ? colors.tertiary
        : colors.primary;
    final byMember = {for (final a in assignments) a.memberId: a};

    return InkWell(
      onTap: () =>
          showTeamShiftSheet(context, week: week.weekStart, slot: slot),
      child: DividedRow(
        minHeight: 44,
        padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  teamShiftIcon(slot.shift),
                  size: 20,
                  color: colors.outline,
                ),
                Text(teamShiftLabel(slot.shift, l10n), style: text.labelLarge),
                Expanded(
                  child: Text(
                    minutesToHhmm(normal),
                    style: text.bodySmall?.copyWith(
                      fontFeatures: tabularFigures,
                    ),
                  ),
                ),
                Text(
                  '$count/$needed',
                  style: text.labelLarge?.copyWith(
                    color: countColor,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ],
            ),
            if (assignments.isEmpty)
              Text('–', style: text.bodySmall?.copyWith(color: colors.outline))
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final m in week.membersIn(slot))
                    _PersonChip(
                      member: m,
                      start: byMember[m.id]?.startMinutes,
                      warn:
                          week.availability(m.id, slot) !=
                              Availability.available ||
                          week.hoursState(m.id) == HoursState.overLimit,
                    ),
                ],
              ),
            if (week.missesCore(slot))
              Row(
                spacing: 4,
                children: [
                  Icon(Icons.warning_amber, size: 16, color: colors.error),
                  Flexible(
                    child: Text(
                      l10n.teamNoCore,
                      style: text.bodySmall?.copyWith(color: colors.error),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PersonChip extends StatelessWidget {
  const _PersonChip({
    required this.member,
    required this.start,
    required this.warn,
  });

  final TeamMember member;
  final Minutes? start;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final small = context.text.bodySmall;
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(
            child: MemberName(
              member,
              style: context.text.labelLarge?.copyWith(
                color: colors.onSecondaryContainer,
              ),
            ),
          ),
          if (start != null) Text(minutesToHhmm(start!), style: small),
          if (warn) Icon(Icons.warning_amber, size: 16, color: colors.error),
        ],
      ),
    );
  }
}

class _PerPersonCard extends StatelessWidget {
  const _PerPersonCard({required this.week});

  final RosterWeek week;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final people = week.members;
    if (people.isEmpty) return const SizedBox.shrink();
    return Panel(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.teamShiftsPerPerson, style: context.text.titleMedium),
          const SizedBox(height: 4),
          for (final m in people)
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      AnswerScreen(week: week.weekStart, memberIds: [m.id]),
                ),
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: MemberName(m),
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _answerText(context, m),
                          if (hoursStateStyle(context, week.hoursState(m.id))
                              case final s?)
                            // Its own tap target: the explanation.
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => showMemberWarnings(context, week, m),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 4,
                                  children: [
                                    Icon(s.icon, size: 16, color: s.color),
                                    Flexible(
                                      child: Text(
                                        s.label,
                                        style: context.text.bodySmall?.copyWith(
                                          color: s.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _answerText(BuildContext context, TeamMember m) {
    final l10n = context.l10n;
    final colors = context.colors;
    return week.answerOf(m.id) == null
        ? Text(
            l10n.teamNoAnswer,
            style: context.text.bodySmall?.copyWith(color: colors.error),
          )
        : week.isAway(m.id)
        ? Text(
            l10n.teamAwayShort,
            style: context.text.bodySmall?.copyWith(color: colors.outline),
          )
        : Text(
            '${l10n.teamShiftCount(week.shiftCount(m.id))}'
            ' · ${l10n.teamPossible(week.possibleCount(m.id))}',
            style: context.text.bodySmall,
            textAlign: TextAlign.right,
          );
  }
}
