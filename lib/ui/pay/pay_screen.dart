import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time.dart';
import '../../data/database.dart';
import '../../domain/display_rules.dart';
import '../../domain/salary.dart';
import '../../l10n/labels.dart';
import '../../domain/tips.dart';
import '../common.dart';
import 'money_sheet.dart';
import 'wage_sheet.dart';

/// "Pay": the month's pay and tips, and the tips of one week
/// (docs/02-design.md §7).
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
        PageHeader(title: l10n.tabPay, subtitle: l10n.paySubtitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MonthCard(month: tipMonthOf(week)),
              WeekSwitcher(
                title: l10n.weekLabel(isoWeekNumber(week)),
                subtitle:
                    '${dates.format(week)} – ${dates.format(addDays(week, 6))}',
                onPrevious: () => setState(() => _week = addDays(week, -7)),
                onNext: () => setState(() => _week = addDays(week, 7)),
                onHome: week == weekStart(now)
                    ? null
                    : () => setState(() => _week = weekStart(now)),
                homeIsBefore: weekStart(now).isBefore(week),
              ),
              _PayoutCard(week: week, payout: payout),
              if (ref.settings.tipPool)
                _PoolCard(workdays: workdays, shifts: shifts, tipDays: tipDays),
            ],
          ),
        ),
      ],
    );
  }
}

/// The month of the shown week (docs/02-design.md §7): the expected pay
/// on top (what reaches the bank account), then tips, then the totals
/// with tips. The hourly wage is a chip in the header. Pay is for the
/// calendar month; tips for the weeks whose Thursday is in it (§4.7, §4.8).
class _MonthCard extends ConsumerWidget {
  const _MonthCard({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.locale;
    final colors = context.colors;
    final now = ref.now;
    final shifts =
        ref
            .watch(shiftsProvider((monthStart(month), nextMonthStart(month))))
            .value ??
        const [];
    // Null while loading, so "Add hourly wage" doesn't flash up.
    final rates = ref.watch(wageRatesProvider).value;
    final tips = TipMonth.of(
      ref.watch(tipPayoutsProvider(tipWeeksOf(month))).value ?? const [],
    );
    final pay = rates == null ? null : payForMonth(shifts, rates, now);
    final rate = rates == null ? null : ratesInMonth(month, rates).lastOrNull;
    // The current month shows both; a past month only what was earned,
    // unless shifts are missing; a future month only what is expected.
    final columns = payColumns(
      month: month,
      now: now,
      earnedCents: pay?.earnedCents,
      expectedCents: pay?.expectedCents,
    );
    final showEarned = columns.earned;
    final showExpected = columns.expected;
    final divider = Divider(height: 8, color: colors.outlineVariant);
    String hours(int minutes) => formatHours(minutes, locale);

    return Panel(
      color: colors.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat.yMMMM(locale).format(month),
                  style: context.text.titleMedium,
                ),
              ),
              if (rates != null)
                ActionChip(
                  avatar: Icon(
                    rate == null ? Icons.add : Icons.edit_outlined,
                    size: 16,
                  ),
                  label: Text(
                    rate == null
                        ? l10n.wageRate
                        : '${formatEuros(rate.hourlyCents, locale)}/h',
                  ),
                  tooltip: l10n.wageRate,
                  onPressed: () => showWageSheet(context, month: month),
                ),
            ],
          ),
          if (rates != null) ...[
            Text(
              showExpected ? l10n.payExpectedSalary : l10n.paySalary,
              style: context.text.labelLarge,
            ),
            if (pay == null)
              _NoWage(month: month)
            else ...[
              Text(
                formatEuros(
                  showExpected ? pay.expectedCents : pay.earnedCents,
                  locale,
                ),
                style: context.text.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                  fontFeatures: tabularFigures,
                ),
              ),
              Text(
                showEarned && showExpected
                    ? l10n.payEarnedSoFar(
                        formatEuros(pay.earnedCents, locale),
                        hours(pay.earnedMinutes),
                        hours(pay.expectedMinutes),
                      )
                    : l10n.payForHours(
                        hours(
                          showExpected
                              ? pay.expectedMinutes
                              : pay.earnedMinutes,
                        ),
                      ),
                style: context.text.bodyMedium,
              ),
              if (showEarned && showExpected)
                WavyProgress(
                  value: pay.expectedCents == 0
                      ? 0
                      : pay.earnedCents / pay.expectedCents,
                ),
            ],
            divider,
          ],
          Row(
            spacing: 8,
            children: [
              Icon(Icons.payments_outlined, size: 20, color: colors.tertiary),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.tips, style: context.text.labelLarge),
                    Text(
                      l10n.tipsMonthWeeks(tips.weeks),
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                formatEuros(tips.totalCents, locale),
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.tertiary,
                  fontFeatures: tabularFigures,
                ),
              ),
            ],
          ),
          if (pay != null) ...[
            divider,
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: l10n.payTotal),
                  TextSpan(
                    text: ' · ${l10n.payWithTips}',
                    style: context.text.bodySmall,
                  ),
                ],
              ),
              style: context.text.labelLarge,
            ),
            Row(
              children: [
                if (showEarned)
                  Expanded(
                    child: Figure(
                      label: l10n.payEarned,
                      value: formatEuros(
                        pay.earnedCents + tips.totalCents,
                        locale,
                      ),
                      color: colors.primary,
                    ),
                  ),
                if (showExpected)
                  Expanded(
                    child: Figure(
                      label: l10n.payExpected,
                      value: formatEuros(
                        pay.expectedCents + tips.totalCents,
                        locale,
                      ),
                      color: showEarned ? colors.onSurface : colors.primary,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// No hourly wage yet: a hint and "Add hourly wage".
class _NoWage extends StatelessWidget {
  const _NoWage({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: [
      Text(context.l10n.wageMissing, style: context.text.bodyMedium),
      M3EButton.icon(
        style: M3EButtonStyle.tonal,
        onPressed: () => showWageSheet(context, month: month),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.wageAdd),
      ),
    ],
  );
}

/// "Paid out": the week's cash payout, or "Add".
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

/// "Daily pool": one row per workday, and the week's sum.
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
        child: DividedRow(
          minHeight: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 10,
            children: [
              SizedBox(
                width: textColumnWidth(context, context.text.titleSmall, [
                  for (var i = 1; i <= 7; i++)
                    shortWeekday(DateTime(2024, 1, i), locale),
                ], min: 28),
                child: Text(
                  shortWeekday(day, locale),
                  style: context.text.titleSmall,
                ),
              ),
              SizedBox(
                width: textColumnWidth(context, context.text.bodySmall, [
                  for (final month in [1, 5, 8, 10, 12])
                    DateFormat(l10n.exportDayPattern)
                        .format(DateTime(2024, month, 28)),
                ], min: 52),
                child: Text(
                  DateFormat(l10n.exportDayPattern).format(day),
                  style: context.text.bodySmall,
                ),
              ),
              for (final type in ShiftType.values)
                if (types.contains(type))
                  Icon(
                    shiftTypeIcon(type),
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

    return DayCard(
      clip: true,
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
