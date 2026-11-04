import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time.dart';
import '../../data/app_settings.dart';
import '../../data/database.dart';
import '../../domain/month_summary.dart';
import '../../domain/recording.dart';
import '../../domain/rounding.dart';
import '../../domain/shift_info.dart';
import '../../l10n/labels.dart';
import '../common.dart';

/// "Heute": next shift or running recording, month overview, this week.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key, required this.onOpenPlan});

  final ValueChanged<DateTime> onOpenPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.now;
    final today = dateOnly(now);
    final week = weekStart(now);
    final running = ref.watch(runningShiftProvider).value;
    final monthShifts =
        ref
            .watch(shiftsProvider((monthStart(now), nextMonthStart(now))))
            .value ??
        const [];
    final weekShifts =
        ref.watch(shiftsProvider((week, addDays(week, 7)))).value ?? const [];
    final upcoming =
        ref.watch(shiftsProvider((today, addDays(today, 15)))).value ??
        const [];
    final next = upcoming
        .where(
          (s) => !s.isRecorded && !s.isRunning && s.plannedEnd.isAfter(now),
        )
        .firstOrNull;
    final summary = summarizeMonth(monthShifts, now);
    final missed = monthShifts
        .where((s) => s.statusAt(now) == ShiftStatus.missed)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        PageHeader(
          title: context.l10n.tabToday,
          subtitle: DateFormat.MMMMEEEEd(context.locale).format(now),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            spacing: 12,
            children: [
              if (running != null)
                _RunningCard(shift: running)
              else
                _NextShiftCard(next: next, todays: upcoming, now: now),
              if (missed != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ActionChip(
                    avatar: Icon(
                      Icons.warning_amber,
                      color: context.colors.error,
                    ),
                    label: Text(
                      context.l10n.missedShifts(summary.missedShifts),
                    ),
                    onPressed: () => onOpenPlan(missed.dayDate),
                  ),
                ),
              _MonthCard(summary: summary, now: now, running: running != null),
              _WeekStrip(
                style: ref.settings.weekMarks,
                week: week,
                shifts: weekShifts,
                now: now,
                onOpenPlan: () => onOpenPlan(week),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NextShiftCard extends ConsumerWidget {
  const _NextShiftCard({
    required this.next,
    required this.todays,
    required this.now,
  });

  final Shift? next;
  final List<Shift> todays;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final next = this.next;
    final lead = ref.settings.reminderLeadMinutes;

    Future<void> start() async {
      // Start the shift that is about to begin, otherwise create one now.
      final candidate = shiftToStart(
        todays.where((s) => s.day == dayKey(now)).toList(),
        now,
      );
      await ref.services.recording.start(shiftId: candidate?.id);
    }

    if (next == null) {
      return Panel(
        color: colors.surfaceContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(l10n.noShiftPlanned, style: context.text.titleLarge),
            Text(
              l10n.noShiftPlannedHint,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            M3EButton.icon(
              style: M3EButtonStyle.tonal,
              onPressed: start,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.startAnyway),
            ),
          ],
        ),
      );
    }

    final reminder = next.plannedStart.subtract(Duration(minutes: lead));
    return Panel(
      color: colors.primaryContainer,
      radius: 32,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.onPrimaryContainer),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.nextShift,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Chip(
                  label: Text(_countdown(context, next)),
                  side: BorderSide.none,
                  backgroundColor: colors.surfaceContainerLowest,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              shiftTypeLabel(next.type, l10n),
              style: context.text.titleLarge?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            Text(
              '${hhmm(next.plannedStart)} – ${hhmm(next.plannedEnd)}',
              style: context.text.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onPrimaryContainer,
                fontFeatures: tabularFigures,
              ),
            ),
            if (reminder.isAfter(now))
              Row(
                spacing: 6,
                children: [
                  const Icon(Icons.notifications_outlined, size: 18),
                  Text(l10n.reminderAt(hhmm(reminder))),
                ],
              ),
            const SizedBox(height: 16),
            M3EButton.icon(
              size: M3EButtonSize.md,
              decoration: M3EButtonDecoration.styleFrom(
                minimumSize: const Size.fromHeight(64),
                textStyle: context.text.titleMedium,
              ),
              onPressed: start,
              icon: const Icon(Icons.play_arrow, size: 28),
              label: Text(l10n.startRecording),
            ),
          ],
        ),
      ),
    );
  }

  String _countdown(BuildContext context, Shift next) {
    final l10n = context.l10n;
    final minutes = next.plannedStart.difference(now).inMinutes;
    if (minutes <= 0) return l10n.runningNow;
    if (minutes < 60) return l10n.startsInMinutes(minutes);
    if (next.day == dayKey(now)) return l10n.startsAt(hhmm(next.plannedStart));
    return DateFormat.MMMEd(context.locale).format(next.plannedStart);
  }
}

/// The recording that is running right now, with a live timer.
class _RunningCard extends ConsumerStatefulWidget {
  const _RunningCard({required this.shift});

  final Shift shift;

  @override
  ConsumerState<_RunningCard> createState() => _RunningCardState();
}

class _RunningCardState extends ConsumerState<_RunningCard> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Future<void> _changeStart() async {
    final rawStart = widget.shift.rawStart!;
    final picked = await pickTime(context, minutesOf(rawStart));
    if (picked == null) return;
    final start = atMinutes(rawStart, picked);
    if (start.isBefore(DateTime.now())) {
      await ref.services.recording.changeStart(start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final shift = widget.shift;
    final now = DateTime.now();
    final elapsed = now.difference(shift.rawStart!);
    final (roundedStart, roundedEnd) = roundShift(
      shift.rawStart!,
      now,
      ref.settings.roundingMode,
    );
    final roundedMinutes = roundedEnd.difference(roundedStart).inMinutes;

    return Column(
      spacing: 12,
      children: [
        Panel(
          color: colors.primary,
          radius: 32,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: colors.onPrimary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: colors.primaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.recordingRunning)),
                    Chip(
                      label: Text(shiftTypeLabel(shift.type, l10n)),
                      side: BorderSide.none,
                      backgroundColor: colors.primaryContainer,
                    ),
                  ],
                ),
                Text(
                  _clock(elapsed),
                  style: context.text.displayLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontFeatures: tabularFigures,
                  ),
                ),
                Text(
                  l10n.recordingStarted(
                    hhmm(shift.rawStart!),
                    hhmm(roundedStart),
                  ),
                ),
                Text(l10n.plannedEndAt(hhmm(shift.plannedEnd))),
                const SizedBox(height: 20),
                M3EButton.icon(
                  size: M3EButtonSize.md,
                  decoration: M3EButtonDecoration.styleFrom(
                    minimumSize: const Size.fromHeight(64),
                    backgroundColor: colors.surface,
                    foregroundColor: colors.primary,
                    textStyle: context.text.titleMedium,
                  ),
                  onPressed: () => ref.services.recording.stop(),
                  icon: const Icon(Icons.stop, size: 28),
                  label: Text(l10n.stopRecording),
                ),
                const SizedBox(height: 8),
                M3EButton.icon(
                  style: M3EButtonStyle.outlined,
                  decoration: M3EButtonDecoration.styleFrom(
                    foregroundColor: colors.onPrimary,
                    side: BorderSide(color: colors.primaryContainer),
                  ),
                  onPressed: _changeStart,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.changeStart),
                ),
              ],
            ),
          ),
        ),
        Panel(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            spacing: 16,
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  Icons.timer_outlined,
                  color: colors.onPrimaryContainer,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.ifStoppedNow, style: context.text.labelMedium),
                    Text(
                      '${hhmm(roundedStart)} – ${hhmm(roundedEnd)}',
                      style: context.text.titleMedium,
                    ),
                    Text(l10n.roundedHint, style: context.text.bodySmall),
                  ],
                ),
              ),
              Text(
                l10n.hours(formatHours(roundedMinutes, context.locale)),
                style: context.text.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _clock(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.inHours}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.summary,
    required this.now,
    required this.running,
  });

  final MonthSummary summary;
  final DateTime now;
  final bool running;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.locale;
    Widget figure(String label, int minutes, Color color) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.labelMedium),
        Text(
          l10n.hours(formatHours(minutes, locale)),
          style: context.text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
            fontFeatures: tabularFigures,
          ),
        ),
      ],
    );

    return Panel(
      color: context.colors.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat.MMMM(locale).format(now),
                  style: context.text.titleMedium,
                ),
              ),
              Text(l10n.monthAsOfToday, style: context.text.bodySmall),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: figure(
                  l10n.monthRecorded,
                  summary.recordedMinutes,
                  context.colors.primary,
                ),
              ),
              Expanded(
                child: figure(
                  l10n.monthExpected,
                  summary.expectedMinutes,
                  context.colors.onSurface,
                ),
              ),
            ],
          ),
          WavyProgress(value: summary.progress),
          Text(
            running
                ? l10n.monthRunningHint
                : l10n.monthProgress(
                    (summary.progress * 100).round(),
                    formatHours(summary.upcomingMinutes, locale),
                    summary.upcomingShifts,
                  ),
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Seven small day circles for the current week. Lunch and evening shifts
/// are marked under each day as icons or as two bars ([WeekMarkStyle]).
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.style,
    required this.week,
    required this.shifts,
    required this.now,
    required this.onOpenPlan,
  });

  final WeekMarkStyle style;
  final DateTime week;
  final List<Shift> shifts;
  final DateTime now;
  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final legendStyle = context.text.bodySmall;
    final legendIconSize = (legendStyle?.fontSize ?? 12) + 2;
    WidgetSpan icon(IconData data) => WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Icon(data, size: legendIconSize, color: colors.onSurfaceVariant),
    );

    return Panel(
      color: colors.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.thisWeek(isoWeekNumber(week)),
                  style: context.text.titleSmall,
                ),
              ),
              M3EButton(
                style: M3EButtonStyle.text,
                onPressed: onOpenPlan,
                child: Text(l10n.toPlan),
              ),
            ],
          ),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(child: _day(context, addDays(week, i))),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            switch (style) {
              WeekMarkStyle.icons => TextSpan(
                children: [
                  icon(Icons.light_mode),
                  TextSpan(text: ' ${l10n.shiftLunch} · '),
                  icon(Icons.dark_mode),
                  TextSpan(
                    text: ' ${l10n.shiftEvening} · ${l10n.weekLegendRecorded}',
                  ),
                ],
              ),
              WeekMarkStyle.bars => TextSpan(text: l10n.weekLegendBars),
            },
            style: legendStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _day(BuildContext context, DateTime day) {
    final l10n = context.l10n;
    final colors = context.colors;
    final ofDay = shifts.where((s) => s.day == dayKey(day)).toList();
    final recordedMinutes = ofDay
        .where((s) => s.isRecorded)
        .fold(0, (sum, s) => sum + s.workedMinutes!);
    final isToday = day == dateOnly(now);

    final (Color? fill, Color text) = recordedMinutes > 0
        ? (colors.primary, colors.onPrimary)
        : ofDay.isNotEmpty
        ? (colors.primaryContainer, colors.onPrimaryContainer)
        : (null, colors.onSurfaceVariant);

    return Column(
      spacing: 4,
      children: [
        Text(shortWeekday(day, context.locale), style: context.text.labelSmall),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: colors.primary, width: 2)
                : null,
          ),
          child: Text(
            '${day.day}',
            style: TextStyle(color: text, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 16, child: _marks(context, ofDay)),
        Text(
          recordedMinutes > 0
              ? l10n.hours(formatHours(recordedMinutes, context.locale))
              : ofDay.isEmpty
              ? l10n.dayOff
              : '',
          style: context.text.labelSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Custom shifts count as lunch if they start before 15:00.
  static bool _isLunchSlot(Shift s) =>
      s.type == ShiftType.lunch ||
      (s.type == ShiftType.custom && s.plannedStart.hour < 15);

  Widget _marks(BuildContext context, List<Shift> ofDay) {
    final colors = context.colors;
    Color markColor(bool recorded) =>
        recorded ? colors.primary : colors.outline;

    switch (style) {
      case WeekMarkStyle.icons:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final s in ofDay)
              Icon(
                switch (s.type) {
                  ShiftType.lunch => Icons.light_mode,
                  ShiftType.evening => Icons.dark_mode,
                  ShiftType.custom => Icons.schedule,
                },
                size: 15,
                color: markColor(s.isRecorded),
              ),
          ],
        );
      case WeekMarkStyle.bars:
        // One slot per shift time; a slot counts as recorded if any of its
        // shifts is.
        Widget bar(Iterable<Shift> slot) => Container(
          width: 13,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: slot.isEmpty
                ? colors.surfaceContainerHighest
                : markColor(slot.any((s) => s.isRecorded)),
            borderRadius: BorderRadius.circular(3),
          ),
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            bar(ofDay.where(_isLunchSlot)),
            bar(ofDay.where((s) => !_isLunchSlot(s))),
          ],
        );
    }
  }
}
