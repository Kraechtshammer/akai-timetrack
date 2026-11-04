import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time.dart';
import '../../domain/export_text.dart';
import '../../domain/shift_info.dart';
import '../common.dart';

/// "Export": the weekly text for the boss, to copy or share.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  /// Always starts on the current week; earlier weeks are one tap back.
  var _week = weekStart(DateTime.now());

  /// null = use the setting.
  bool? _monthTotals;
  var _copied = false;

  void _changeWeek(int days) => setState(() {
    _week = addDays(_week, days);
    _copied = false;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final locale = context.locale;
    final now = ref.now;
    final weekEnd = addDays(_week, 7);
    // From the month start, so the month totals are complete.
    final shifts =
        ref.watch(shiftsProvider((monthStart(_week), weekEnd))).value ??
        const [];
    final ofWeek = shifts.where((s) => !s.dayDate.isBefore(_week)).toList();
    final recorded = ofWeek.where((s) => s.isRecorded).toList();
    final minutes = recorded.fold(0, (sum, s) => sum + s.workedMinutes!);
    final days = recorded.map((s) => s.day).toSet().length;
    final missing = ofWeek
        .where(
          (s) => const [
            ShiftStatus.missed,
            ShiftStatus.running,
          ].contains(s.statusAt(now)),
        )
        .length;
    final lastDay = addDays(weekEnd, -1);
    final spansMonths = _week.month != lastDay.month;
    final monthTotals = _monthTotals ?? ref.settings.exportMonthTotals;
    final text = buildExportText(
      week: _week,
      shifts: shifts,
      includeMonthTotals: monthTotals,
      l10n: l10n,
    );
    final dates = DateFormat.MMMd(locale);

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        PageHeader(title: l10n.tabExport, subtitle: l10n.exportSubtitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              WeekSwitcher(
                title: l10n.weekLabel(isoWeekNumber(_week)),
                subtitle: '${dates.format(_week)} – ${dates.format(lastDay)}',
                onPrevious: () => _changeWeek(-7),
                onNext: () => _changeWeek(7),
              ),
              Panel(
                color: colors.primaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.weekTotalLabel,
                            style: TextStyle(color: colors.onPrimaryContainer),
                          ),
                          Text(
                            l10n.hours(formatHours(minutes, locale)),
                            style: context.text.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${l10n.shiftsCount(recorded.length)}\n${l10n.daysCount(days)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: colors.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              if (missing > 0)
                Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.warning_amber, color: colors.error),
                    Expanded(
                      child: Text(
                        '${l10n.missedShifts(missing)}. ${l10n.missedNotExported}',
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ),
              Text(l10n.preview, style: context.text.titleSmall),
              Panel(
                radius: 20,
                padding: const EdgeInsets.all(16),
                color: colors.surfaceContainer,
                child: SelectableText(
                  text,
                  style: const TextStyle(height: 1.5),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.appendMonthTotals),
                subtitle: spansMonths
                    ? Text(
                        l10n.weekSpansMonths(
                          DateFormat.MMMM(locale).format(_week),
                          DateFormat.MMMM(locale).format(lastDay),
                        ),
                      )
                    : null,
                value: monthTotals,
                onChanged: (on) => setState(() {
                  _monthTotals = on;
                  _copied = false;
                }),
              ),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: M3EButton.icon(
                      style: M3EButtonStyle.tonal,
                      size: M3EButtonSize.md,
                      decoration: M3EButtonDecoration.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: text));
                        setState(() => _copied = true);
                      },
                      icon: Icon(_copied ? Icons.check : Icons.content_copy),
                      label: Text(_copied ? l10n.copied : l10n.copy),
                    ),
                  ),
                  Expanded(
                    child: M3EButton.icon(
                      size: M3EButtonSize.md,
                      decoration: M3EButtonDecoration.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () =>
                          SharePlus.instance.share(ShareParams(text: text)),
                      icon: const Icon(Icons.share),
                      label: Text(l10n.share),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
