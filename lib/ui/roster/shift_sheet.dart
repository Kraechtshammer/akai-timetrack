// The shift sheet of the team board (F11): staff needed and who works the
// shift. Changes are saved at once. See docs/02-design.md §4.9 and §7.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/time.dart';
import '../../data/database.dart';
import '../../domain/roster.dart';
import '../../domain/team_hours.dart';
import '../common.dart';
import 'roster_common.dart';

Future<void> showTeamShiftSheet(
  BuildContext context, {
  required DateTime week,
  required TeamSlot slot,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  constraints: BoxConstraints(
    maxHeight: MediaQuery.sizeOf(context).height * 0.85,
  ),
  builder: (_) => _TeamShiftSheet(week: week, slot: slot),
);

class _TeamShiftSheet extends ConsumerStatefulWidget {
  const _TeamShiftSheet({required this.week, required this.slot});

  final DateTime week;
  final TeamSlot slot;

  @override
  ConsumerState<_TeamShiftSheet> createState() => _TeamShiftSheetState();
}

class _TeamShiftSheetState extends ConsumerState<_TeamShiftSheet> {
  /// The order of the people when the sheet opened. Ticking someone changes
  /// the counts (and whether a core worker is in), which would reorder the
  /// list under the user's finger, so the first order is kept.
  List<String>? _order;

  List<TeamMember> _keepOrder(List<TeamMember> people) {
    final order = _order!;
    int at(TeamMember m) {
      final i = order.indexOf(m.id);
      return i < 0 ? order.length : i;
    }

    return [...people]..sort((a, b) => at(a).compareTo(at(b)));
  }

  @override
  Widget build(BuildContext context) {
    final week = widget.week;
    final slot = widget.slot;
    final data = ref.watch(rosterWeekProvider(week));
    if (data == null) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final fresh = data.candidates(slot);
    _order ??= [
      for (final m in [
        ...fresh.available,
        ...fresh.noAnswer,
        ...fresh.unavailable,
      ])
        m.id,
    ];
    final l10n = context.l10n;
    final colors = context.colors;
    final roster = ref.services.roster;
    final settings = ref.settings;
    final normalStart = settings.teamStarts.of(slot.shift);
    final candidates = SlotCandidates(
      _keepOrder(fresh.available),
      _keepOrder(fresh.noAnswer),
      _keepOrder(fresh.unavailable),
    );
    final needed = data.needed(slot);
    final inSlot = {for (final a in data.assignmentsIn(slot)) a.memberId: a};

    void setNeeded(int n) =>
        roster.setNeeded(slot, n, data.defaultNeeded(slot));

    Widget row(TeamMember m, {required bool dimmed}) {
      final assignment = inSlot[m.id];
      final ticked = assignment != null;
      final special = assignment?.startMinutes;
      final start = special ?? normalStart;
      final left = data.minutesLeft(m.id, slot.day);
      final hours = ticked
          ? data.hoursState(m.id)
          : data.hoursState(m.id, adding: slot);
      final hoursStyle = hoursStateStyle(context, hours);
      final unavailable =
          ticked && data.availability(m.id, slot) != Availability.available;
      return Opacity(
        opacity: dimmed && !ticked ? 0.6 : 1,
        child: CheckboxListTile(
          value: ticked,
          onChanged: (on) => on == true
              ? roster.assign(slot, m.id)
              : roster.unassign(slot, m.id),
          controlAffinity: ListTileControlAffinity.leading,
          title: Row(
            spacing: 6,
            children: [
              Flexible(child: MemberName(m)),
              // Tap the icon for the explanation; the rest of the row
              // ticks.
              if (unavailable || hoursStyle != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.teamWarnWhy,
                  onPressed: () => showMemberWarnings(
                    context,
                    data,
                    m,
                    slot: slot,
                    adding: !ticked,
                  ),
                  icon: unavailable || hours == HoursState.overLimit
                      ? Icon(Icons.warning_amber, size: 20, color: colors.error)
                      : Icon(
                          hoursStyle!.icon,
                          size: 20,
                          color: hoursStyle.color,
                        ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.teamShiftCount(data.shiftCount(m.id)) +
                    (left == null ? '' : ' · ${hoursLeftText(context, left)}'),
              ),
              if (hoursStyle != null)
                Text(
                  hoursStyle.label,
                  style: context.text.bodySmall?.copyWith(
                    color: hoursStyle.color,
                  ),
                ),
            ],
          ),
          secondary: ticked
              ? M3EButton(
                  style: M3EButtonStyle.text,
                  onPressed: () async {
                    final picked = await pickTime(context, start);
                    if (picked == null) return;
                    await roster.setStart(
                      assignment,
                      picked == normalStart ? null : picked,
                    );
                  },
                  child: Text(
                    minutesToHhmm(start),
                    style: TextStyle(
                      fontWeight: special != null ? FontWeight.bold : null,
                      fontFeatures: tabularFigures,
                    ),
                  ),
                )
              : null,
        ),
      );
    }

    Widget section(String title, List<TeamMember> people) => people.isEmpty
        ? const SizedBox.shrink()
        : ExpansionTile(
            title: Text(title),
            shape: const Border(),
            collapsedShape: const Border(),
            children: [for (final m in people) row(m, dimmed: true)],
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${DateFormat.MMMEd(context.locale).format(slot.day)}'
              ' · ${teamShiftLabel(slot.shift, l10n)}',
              style: context.text.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
            child: Row(
              children: [
                Expanded(child: Text(l10n.teamStaffNeeded)),
                M3EIconButton(
                  variant: M3EIconButtonVariant.standard,
                  icon: const Icon(Icons.remove),
                  onPressed: needed > 0 ? () => setNeeded(needed - 1) : null,
                ),
                SizedBox(
                  width: textColumnWidth(context, context.text.titleMedium, [
                    l10n.teamClosed,
                    '20',
                  ], min: 64),
                  child: Text(
                    needed == 0 ? l10n.teamClosed : '$needed',
                    textAlign: TextAlign.center,
                    style: context.text.titleMedium,
                  ),
                ),
                M3EIconButton(
                  variant: M3EIconButtonVariant.standard,
                  icon: const Icon(Icons.add),
                  onPressed: needed < 20 ? () => setNeeded(needed + 1) : null,
                ),
              ],
            ),
          ),
          if (data.missesCore(slot))
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
              child: Row(
                spacing: 6,
                children: [
                  Icon(Icons.warning_amber, size: 18, color: colors.error),
                  Expanded(
                    child: Text(
                      l10n.teamNoCore,
                      style: context.text.bodyMedium?.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          for (final m in candidates.available) row(m, dimmed: false),
          section(l10n.teamNoAnswer, candidates.noAnswer),
          section(l10n.teamCantWork, candidates.unavailable),
        ],
      ),
    );
  }
}
