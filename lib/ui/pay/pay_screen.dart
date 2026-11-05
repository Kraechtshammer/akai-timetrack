import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time.dart';
import '../../data/database.dart';
import '../../domain/tips.dart';
import '../common.dart';
import 'money_sheet.dart';

/// "Lohn": the tips of one week, and the month's total. Salary comes later
/// (docs/02-design.md §7 and §14.2).
class PayScreen extends ConsumerStatefulWidget {
  const PayScreen({super.key});

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen> {
  /// Each visit starts a fresh screen (see HomeShell), so this is the
  /// current week on every visit.
  late var _week = weekStart(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.locale;
    final now = ref.now;
    final week = _week;
    final weekEnd = addDays(week, 7);
    final shifts = ref.watch(shiftsProvider((week, weekEnd))).value ?? const [];
    final tipDays =
        ref.watch(tipDaysProvider((week, weekEnd))).value ?? const [];
    final payout = ref
        .watch(tipPayoutsProvider((week, addDays(week, 1))))
        .value
        ?.firstOrNull;
    final workdays = tipWorkdays(
      shifts: shifts,
      tipDays: tipDays,
      today: dateOnly(now),
    );
    final dates = DateFormat.MMMd(locale);

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        PageHeader(
          title: l10n.tabPay,
          subtitle: l10n.paySubtitle,
          actions: [
            M3EIconButton(
              variant: M3EIconButtonVariant.standard,
              tooltip: l10n.currentWeek,
              icon: const Icon(Icons.today_outlined),
              onPressed: () => setState(() => _week = weekStart(now)),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TipMonthCard(month: tipMonthOf(week)),
              WeekSwitcher(
                title: l10n.weekLabel(isoWeekNumber(week)),
                subtitle:
                    '${dates.format(week)} – ${dates.format(addDays(week, 6))}',
                onPrevious: () => setState(() => _week = addDays(week, -7)),
                onNext: () => setState(() => _week = addDays(week, 7)),
              ),
              _PayoutCard(week: week, payout: payout),
              _PoolCard(workdays: workdays, shifts: shifts, tipDays: tipDays),
            ],
          ),
        ),
      ],
    );
  }
}

/// "November · Trinkgeld 312 € · aus 3 Wochen"
class _TipMonthCard extends ConsumerWidget {
  const _TipMonthCard({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.locale;
    final payouts =
        ref.watch(tipPayoutsProvider(tipWeeksOf(month))).value ?? const [];
    final total = TipMonth.of(payouts);
    return Panel(
      color: context.colors.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            DateFormat.yMMMM(locale).format(month),
            style: context.text.titleMedium,
          ),
          Text(l10n.tips, style: context.text.labelMedium),
          Text(
            formatEuros(total.totalCents, locale),
            style: context.text.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.colors.primary,
              fontFeatures: tabularFigures,
            ),
          ),
          Text(l10n.tipsMonthWeeks(total.weeks), style: context.text.bodySmall),
        ],
      ),
    );
  }
}

/// "Ausgezahlt": the week's cash payout, or "Eintragen".
class _PayoutCard extends ConsumerWidget {
  const _PayoutCard({required this.week, required this.payout});

  final DateTime week;
  final TipPayout? payout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final payout = this.payout;
    void edit() => showTipPayoutSheet(
      context,
      ref,
      week: week,
      current: payout?.amountCents,
    );

    return Material(
      color: context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: edit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            spacing: 12,
            children: [
              Icon(Icons.payments_outlined, color: context.colors.primary),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.tipPayout, style: context.text.titleMedium),
                    Text(l10n.tipPayoutHint, style: context.text.bodySmall),
                  ],
                ),
              ),
              if (payout == null)
                M3EButton(
                  style: M3EButtonStyle.tonal,
                  onPressed: edit,
                  child: Text(l10n.tipEnter),
                )
              else
                Text(
                  formatEuros(payout.amountCents, context.locale),
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: tabularFigures,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Tagestopf": one row per workday, and the week's sum.
class _PoolCard extends ConsumerWidget {
  const _PoolCard({
    required this.workdays,
    required this.shifts,
    required this.tipDays,
  });

  final List<DateTime> workdays;
  final List<Shift> shifts;
  final List<TipDay> tipDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.locale;
    final colors = context.colors;
    final sum = tipDays.fold(0, (sum, t) => sum + t.poolCents);

    Widget dayRow(DateTime day) {
      final key = dayKey(day);
      final tip = tipDays.where((t) => t.day == key).firstOrNull;
      final types = {
        for (final s in shifts)
          if (s.day == key) s.type,
      };
      return InkWell(
        onTap: () =>
            showTipDaySheet(context, ref, day: day, current: tip?.poolCents),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 10,
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  shortWeekday(day, locale),
                  style: context.text.titleSmall,
                ),
              ),
              SizedBox(
                width: 52,
                child: Text(
                  DateFormat(l10n.exportDayPattern).format(day),
                  style: context.text.bodySmall,
                ),
              ),
              for (final type in ShiftType.values)
                if (types.contains(type))
                  Icon(
                    switch (type) {
                      ShiftType.lunch => Icons.light_mode,
                      ShiftType.evening => Icons.dark_mode,
                      ShiftType.custom => Icons.schedule,
                    },
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
              const Spacer(),
              Text(
                tip == null ? '–' : formatEuros(tip.poolCents, locale),
                style: context.text.titleMedium?.copyWith(
                  fontFeatures: tabularFigures,
                  color: tip == null ? colors.outline : null,
                ),
              ),
              Icon(Icons.edit_outlined, size: 18, color: colors.outline),
            ],
          ),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              spacing: 12,
              children: [
                Icon(Icons.savings_outlined, color: colors.primary),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.tipPool, style: context.text.titleMedium),
                      Text(l10n.tipPoolHint, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (workdays.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.tipNoWorkdays, style: context.text.bodyMedium),
            )
          else ...[
            for (final day in workdays) dayRow(day),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 44, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.tipPoolSum,
                      style: context.text.labelLarge,
                    ),
                  ),
                  Text(
                    formatEuros(sum, locale),
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
