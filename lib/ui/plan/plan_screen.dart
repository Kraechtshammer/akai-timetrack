import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time.dart';
import '../../data/database.dart';
import '../../domain/planning.dart';
import '../../domain/shift_info.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../shift_sheet.dart';

/// "Plan": one week, Mittag/Abend toggles per day.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({
    super.key,
    required this.week,
    required this.onWeekChanged,
  });

  final DateTime week;
  final ValueChanged<DateTime> onWeekChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.locale;
    final now = ref.now;
    final shifts =
        ref.watch(shiftsProvider((week, addDays(week, 7)))).value ?? const [];
    final recorded = shifts
        .where((s) => s.isRecorded)
        .fold(0, (sum, s) => sum + s.workedMinutes!);
    final total = shifts.fold(0, (sum, s) => sum + s.expectedMinutes);
    final dates = DateFormat.MMMd(locale);

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        PageHeader(
          title: l10n.tabPlan,
          subtitle: l10n.planSubtitle,
          actions: [
            M3EIconButton(
              variant: M3EIconButtonVariant.standard,
              tooltip: l10n.currentWeek,
              icon: const Icon(Icons.today_outlined),
              onPressed: () => onWeekChanged(weekStart(now)),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeekSwitcher(
                title: l10n.weekLabel(isoWeekNumber(week)),
                subtitle:
                    '${dates.format(week)} – ${dates.format(addDays(week, 6))}',
                onPrevious: () => onWeekChanged(addDays(week, -7)),
                onNext: () => onWeekChanged(addDays(week, 7)),
              ),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    avatar: Icon(
                      Icons.check_circle,
                      color: context.shiftColors.recorded,
                    ),
                    label: Text(
                      l10n.weekRecorded(formatHours(recorded, locale)),
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.schedule),
                    label: Text(l10n.weekTotal(formatHours(total, locale))),
                  ),
                ],
              ),
              for (var i = 0; i < 7; i++)
                _DayCard(
                  day: addDays(week, i),
                  shifts: shifts
                      .where((s) => s.day == dayKey(addDays(week, i)))
                      .toList(),
                  now: now,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({required this.day, required this.shifts, required this.now});

  final DateTime day;
  final List<Shift> shifts;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isToday = day == dateOnly(now);

    Future<void> toggle(ShiftType type) async {
      final result = await ref.services.planning.toggle(day, type);
      if (result == ToggleResult.keptRecorded && context.mounted) {
        context.showSnack(l10n.recordedNotRemovable);
      }
    }

    final shiftColors = context.shiftColors;
    Widget toggleButton(ShiftType type, String label) {
      final on = shifts.any((s) => s.type == type);
      // Planned toggles wear the shift type's colour.
      final (background, foreground) = type == ShiftType.lunch
          ? (shiftColors.lunch, shiftColors.onLunch)
          : (shiftColors.evening, shiftColors.onEvening);
      return on
          ? M3EButton.icon(
              decoration: M3EButtonDecoration.styleFrom(
                backgroundColor: background,
                foregroundColor: foreground,
              ),
              onPressed: () => toggle(type),
              icon: const Icon(Icons.check, size: 18),
              label: Text(label),
            )
          : M3EButton(
              style: M3EButtonStyle.tonal,
              onPressed: () => toggle(type),
              child: Text(label),
            );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: isToday ? Border.all(color: shiftColors.today, width: 2) : null,
      ),
      child: Column(
        children: [
          Row(
            spacing: 4,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        Text(
                          shortWeekday(day, context.locale),
                          style: context.text.titleMedium,
                        ),
                        if (isToday)
                          Badge(
                            label: Text(l10n.today),
                            backgroundColor: colors.primary,
                            textColor: colors.onPrimary,
                          ),
                      ],
                    ),
                    Text(
                      DateFormat(l10n.exportDayPattern).format(day),
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              toggleButton(ShiftType.lunch, l10n.shiftLunch),
              toggleButton(ShiftType.evening, l10n.shiftEvening),
              M3EIconButton(
                variant: M3EIconButtonVariant.outlined,
                tooltip: l10n.addCustomShift,
                icon: const Icon(Icons.add),
                onPressed: () => showShiftSheet(context, day: day),
              ),
            ],
          ),
          if (shifts.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(l10n.noShift, style: context.text.bodySmall),
              ),
            ),
          for (final shift in shifts) _ShiftRow(shift: shift, now: now),
        ],
      ),
    );
  }
}

class _ShiftRow extends ConsumerWidget {
  const _ShiftRow({required this.shift, required this.now});

  final Shift shift;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final shiftColors = context.shiftColors;
    final status = shift.statusAt(now);
    final (icon, iconColor, statusText) = switch (status) {
      ShiftStatus.recorded => (
        Icons.check_circle,
        shiftColors.recorded,
        l10n.statusRecorded,
      ),
      ShiftStatus.running => (Icons.timer, colors.primary, l10n.statusRunning),
      ShiftStatus.missed => (
        Icons.warning_amber,
        shiftColors.missed,
        l10n.statusMissed,
      ),
      ShiftStatus.planned => (
        Icons.schedule,
        colors.outline,
        l10n.statusPlanned,
      ),
    };

    return InkWell(
      onTap: () => showShiftSheet(context, day: shift.dayDate, shift: shift),
      onLongPress: () => deleteWithUndo(context, ref, shift),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        padding: const EdgeInsets.only(right: 8),
        child: Row(
          spacing: 10,
          children: [
            Icon(icon, size: 20, color: iconColor),
            SizedBox(
              width: 72,
              child: Text(
                shiftTypeLabel(shift.type, l10n),
                style: context.text.labelLarge?.copyWith(
                  color: shift.isLunchSlot
                      ? shiftColors.lunch
                      : shiftColors.evening,
                ),
              ),
            ),
            // Long status texts ("not recorded") left too little room, and
            // the times wrapped onto two lines; shrink them a little instead.
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${hhmm(shift.shownStart)} – ${hhmm(shift.shownEnd)}',
                  style: const TextStyle(fontFeatures: tabularFigures),
                  maxLines: 1,
                ),
              ),
            ),
            Text(
              statusText,
              style: context.text.bodySmall?.copyWith(
                color: status == ShiftStatus.missed ? shiftColors.missed : null,
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                l10n.hours(formatHours(shift.expectedMinutes, context.locale)),
                textAlign: TextAlign.right,
                style: context.text.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deletes a shift and offers "Rückgängig". Recorded shifts ask first.
/// Returns false if the user cancelled.
Future<bool> deleteWithUndo(
  BuildContext context,
  WidgetRef ref,
  Shift shift,
) async {
  final l10n = context.l10n;
  if (shift.isRecorded || shift.isRunning) {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecordedTitle),
        content: Text(l10n.deleteRecordedBody),
        actions: [
          M3EButton(
            style: M3EButtonStyle.text,
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          M3EButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (sure != true || !context.mounted) return false;
  }
  final planning = ref.services.planning;
  final messenger = ScaffoldMessenger.of(context);
  await planning.delete(shift);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.shiftDeleted),
        // A snack bar with an action stays until dismissed unless told not to.
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => planning.restore(shift),
        ),
      ),
    );
  return true;
}
