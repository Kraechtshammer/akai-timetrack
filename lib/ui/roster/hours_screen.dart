// Planned hours per person and month, against the monthly limit (F11).
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../domain/team_hours.dart';
import '../common.dart';
import 'people_screen.dart';
import 'roster_common.dart';

class TeamHoursScreen extends ConsumerStatefulWidget {
  const TeamHoursScreen({super.key, required this.month});

  final DateTime month;

  @override
  ConsumerState<TeamHoursScreen> createState() => _TeamHoursScreenState();
}

class _TeamHoursScreenState extends ConsumerState<TeamHoursScreen> {
  late var _month = DateTime(widget.month.year, widget.month.month);

  void _move(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = ref.watch(teamMonthProvider(_month));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.teamHoursTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const SizedBox(height: 8),
          WeekSwitcher(
            title: DateFormat.yMMMM(context.locale).format(_month),
            subtitle: l10n.teamHoursSubtitle,
            onPrevious: () => _move(-1),
            onNext: () => _move(1),
            previousTooltip: l10n.previousMonth,
            nextTooltip: l10n.nextMonth,
          ),
          const SizedBox(height: 12),
          if (rows == null)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(l10n.teamNoPeople)),
            )
          else ...[
            Panel(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
              child: Column(children: [for (final r in rows) _HoursRow(r)]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Text(
                l10n.teamHoursNote,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow(this.row);

  final MemberMonth row;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final locale = context.locale;
    final limit = row.limit;
    final hours = formatHours(row.minutes, locale);
    final small = context.text.bodySmall;
    return InkWell(
      onTap: () => showPersonSheet(context, member: row.member),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MemberName(row.member),
                  ),
                ),
                Text(
                  limit == null
                      ? l10n.teamHoursOnly(hours)
                      : l10n.teamHoursOf(hours, formatHours(limit, locale)),
                  style: context.text.bodyMedium,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            if (limit == null)
              Text(
                l10n.teamHoursNoLimit,
                style: small?.copyWith(color: colors.outline),
              )
            else ...[
              LinearProgressIndicator(
                value: math.min(1, row.minutes / limit),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
                color: row.over ? colors.error : colors.primary,
                backgroundColor: colors.surfaceContainerHighest,
              ),
              Text(
                row.over
                    ? l10n.teamHoursOver(
                        formatHours(row.minutes - limit, locale),
                      )
                    : l10n.teamHoursLeft(
                        formatHours(limit - row.minutes, locale),
                      ),
                style: small?.copyWith(
                  color: row.over ? colors.error : colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
