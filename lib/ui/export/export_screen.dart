import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time.dart';
import '../../domain/display_rules.dart';
import '../../domain/export_text.dart';
import '../common.dart';

/// "Export": the month's hours as text for the boss, grouped by week, to copy
/// or share.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  /// Always starts on the current month; earlier months are one tap back.
  var _month = monthStart(DateTime.now());
  var _copied = false;

  void _changeMonth(int months) => setState(() {
    _month = DateTime(_month.year, _month.month + months);
    _copied = false;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final locale = context.locale;
    final now = ref.now;
    final monthEnd = nextMonthStart(_month);
    final shifts =
        ref.watch(shiftsProvider((_month, monthEnd))).value ?? const [];
    final minutes = shifts.recordedMinutes;
    final days = shifts.recordedDays;
    final missing = shifts.missingCount(now);
    final text = buildExportText(
      month: _month,
      shifts: shifts,
      now: now,
      l10n: l10n,
      restaurant: ref.settings.restaurant,
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
                title: DateFormat.yMMMM(locale).format(_month),
                subtitle:
                    '${dates.format(_month)} – '
                    '${dates.format(addDays(monthEnd, -1))}',
                onPrevious: () => _changeMonth(-1),
                onNext: () => _changeMonth(1),
                previousTooltip: l10n.previousMonth,
                nextTooltip: l10n.nextMonth,
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
                            l10n.monthTotalLabel,
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
                      '${l10n.shiftsCount(shifts.recordedCount)}\n${l10n.daysCount(days)}',
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
                        if (mounted) setState(() => _copied = true);
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
