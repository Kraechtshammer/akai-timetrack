// The answer page (F11): when one person can or can't work in the planned
// week. Every tap saves at once. See docs/02-design.md §7.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time.dart';
import '../../data/database.dart';
import '../../domain/roster.dart';
import '../common.dart';
import 'roster_common.dart';

class AnswerScreen extends ConsumerStatefulWidget {
  const AnswerScreen({
    super.key,
    required this.week,
    required this.memberIds,
    this.initialIndex = 0,
  });

  final DateTime week;
  final List<String> memberIds;
  final int initialIndex;

  @override
  ConsumerState<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends ConsumerState<AnswerScreen> {
  late int _index = widget.initialIndex.clamp(
    0,
    widget.memberIds.isEmpty ? 0 : widget.memberIds.length - 1,
  );

  bool get _isLast => _index >= widget.memberIds.length - 1;

  Future<void> _save(
    String id, {
    required AnswerMode mode,
    required int marks,
    required int? maxShifts,
  }) => ref.services.roster.setAnswer(
    widget.week,
    id,
    mode: mode,
    marks: marks,
    maxShifts: maxShifts,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final week = ref.watch(rosterWeekProvider(widget.week));
    final id = widget.memberIds.isEmpty ? null : widget.memberIds[_index];
    final member = id == null ? null : week?.member(id);
    final answer = id == null ? null : week?.answerOf(id);
    final multiple = widget.memberIds.length > 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teamAnswersTitle(isoWeekNumber(widget.week))),
        actions: [
          PopupMenuButton<void>(
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: answer != null,
                onTap: () => ref.services.roster.removeAnswer(widget.week, id!),
                child: Text(l10n.teamRemoveAnswer),
              ),
            ],
          ),
        ],
      ),
      body: week == null
          ? const Center(child: CircularProgressIndicator())
          : member == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (multiple) ...[
                  Text(
                    l10n.teamProgress(_index + 1, widget.memberIds.length),
                    style: context.text.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_index + 1) / widget.memberIds.length,
                  ),
                  const SizedBox(height: 16),
                ],
                MemberName(member, style: context.text.headlineMedium),
                const SizedBox(height: 16),
                _ModeButtons(
                  mode: answer?.mode,
                  onChanged: (mode) => _save(
                    member.id,
                    mode: mode,
                    marks: answer?.marks ?? 0,
                    maxShifts: answer?.maxShifts,
                  ),
                ),
                const SizedBox(height: 8),
                // Vacation: one tap for "no shift this week".
                Align(
                  alignment: Alignment.centerLeft,
                  child: M3EButton.icon(
                    style: M3EButtonStyle.outlined,
                    icon: const Icon(Icons.beach_access_outlined, size: 18),
                    label: Text(l10n.teamAway),
                    onPressed: week.isAway(member.id)
                        ? null
                        : () => _save(
                            member.id,
                            mode: AnswerMode.canWork,
                            marks: 0,
                            maxShifts: null,
                          ),
                  ),
                ),
                if (answer == null) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.teamChooseMode,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                for (final day in week.days)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DayRow(
                      week: week,
                      day: day,
                      mode: answer?.mode ?? AnswerMode.canWork,
                      marks: answer?.marks ?? 0,
                      // Tapping with no answer creates a "can work" answer.
                      onMarks: (marks) => _save(
                        member.id,
                        mode: answer?.mode ?? AnswerMode.canWork,
                        marks: marks,
                        maxShifts: answer?.maxShifts,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Panel(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    availabilitySummary(week, member.id, l10n),
                    style: context.text.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                // Disabled until a mode is chosen, so the limit never
                // creates an answer by itself.
                ListTile(
                  enabled: answer != null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Text(l10n.teamAtMost),
                  trailing: Text(
                    answer?.maxShifts == null
                        ? l10n.teamNoLimit
                        : l10n.teamShiftCount(answer!.maxShifts!),
                    style: context.text.titleMedium,
                  ),
                  onTap: answer == null
                      ? null
                      : () async {
                          // 0 stands for "no limit": a dismissed dialog
                          // returns null and must not clear the limit.
                          final picked = await pickOption<int>(
                            context,
                            title: l10n.teamAtMost,
                            options: [for (var i = 0; i <= 12; i++) i],
                            selected: answer.maxShifts ?? 0,
                            label: (n) => n == 0
                                ? l10n.teamNoLimit
                                : l10n.teamShiftCount(n),
                          );
                          if (picked == null) return;
                          await _save(
                            member.id,
                            mode: answer.mode,
                            marks: answer.marks,
                            maxShifts: picked == 0 ? null : picked,
                          );
                        },
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              if (multiple)
                M3EButton(
                  style: M3EButtonStyle.tonal,
                  onPressed: _index == 0
                      ? null
                      : () => setState(() => _index--),
                  child: Text(l10n.back),
                ),
              const Spacer(),
              M3EButton(
                onPressed: _isLast
                    ? () => Navigator.pop(context)
                    : () => setState(() => _index++),
                child: Text(_isLast ? l10n.done : l10n.next),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButtons extends StatelessWidget {
  const _ModeButtons({required this.mode, required this.onChanged});

  final AnswerMode? mode;
  final ValueChanged<AnswerMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<AnswerMode>(
        emptySelectionAllowed: true,
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: AnswerMode.canWork,
            label: Text(l10n.teamCanWork),
          ),
          ButtonSegment(
            value: AnswerMode.cantWork,
            label: Text(l10n.teamCantWork),
          ),
        ],
        selected: {?mode},
        // Deselecting is not offered; "Remove answer" is in the menu.
        onSelectionChanged: (s) {
          if (s.isNotEmpty) onChanged(s.first);
        },
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.week,
    required this.day,
    required this.mode,
    required this.marks,
    required this.onMarks,
  });

  final RosterWeek week;
  final DateTime day;
  final AnswerMode mode;
  final int marks;
  final ValueChanged<int> onMarks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final open = [
      for (final s in TeamShift.values)
        if (week.isOpen(TeamSlot(day, s))) s,
    ];

    void toggleDay() {
      if (open.isEmpty) return;
      final markAll = open.any((s) => !isMarked(marks, day, s));
      var next = marks;
      for (final s in open) {
        next = withMark(next, day, s, markAll);
      }
      onMarks(next);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: open.isEmpty ? null : toggleDay,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shortWeekday(day, context.locale),
                      style: context.text.titleMedium,
                    ),
                    Text(
                      DateFormat(l10n.exportDayPattern).format(day),
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (final shift in TeamShift.values)
            _ShiftToggle(
              shift: shift,
              enabled: week.isOpen(TeamSlot(day, shift)),
              marked: isMarked(marks, day, shift),
              mode: mode,
              onTap: () => onMarks(
                withMark(marks, day, shift, !isMarked(marks, day, shift)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShiftToggle extends StatelessWidget {
  const _ShiftToggle({
    required this.shift,
    required this.enabled,
    required this.marked,
    required this.mode,
    required this.onTap,
  });

  final TeamShift shift;
  final bool enabled;
  final bool marked;
  final AnswerMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bad = mode == AnswerMode.cantWork;
    final label = teamShiftLabel(shift, context.l10n);
    final bg = !marked
        ? colors.surfaceContainerHighest
        : bad
        ? colors.errorContainer
        : colors.primaryContainer;
    final fg = !marked
        ? colors.onSurfaceVariant
        : bad
        ? colors.onErrorContainer
        : colors.onPrimaryContainer;
    return Opacity(
      opacity: enabled ? 1 : 0.38,
      child: Semantics(
        button: true,
        selected: marked,
        enabled: enabled,
        label: label,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    marked && bad ? Icons.block : teamShiftIcon(shift),
                    color: fg,
                    size: 22,
                  ),
                  Text(
                    label,
                    style: context.text.labelSmall?.copyWith(color: fg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
