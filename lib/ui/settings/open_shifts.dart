// "Open shifts": which shifts the restaurant is open, and, with the team
// planner on, how many people each one needs. Both are the one setting
// `teamStaffNeeded` (0 = closed). Used in Settings › Shifts, on the team
// planner's Settings page and in the first-start setup.
// See docs/02-design.md §4.1 and §7.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../data/app_settings.dart';
import '../../data/database.dart';
import '../../domain/display_rules.dart';
import '../../l10n/app_localizations.dart';
import '../common.dart';
import '../roster/roster_common.dart';
import 'settings_screen.dart';

/// 2024-01-01 was a Monday.
DateTime _dateOf(int weekday) => DateTime(2024, 1, weekday);

/// "Tue–Sun", "11 of 14 shifts" or "Closed" (see [openShiftsSummary]).
String openShiftsLabel(StaffNeeds needs, AppLocalizations l10n, String locale) {
  final summary = openShiftsSummary(needs);
  if (summary.count == 0) return l10n.teamClosed;
  if (summary.days case (final from, final to)) {
    String name(int weekday) => shortWeekday(_dateOf(weekday), locale);
    return from == to ? name(from) : '${name(from)}–${name(to)}';
  }
  return l10n.openShiftsCount(summary.count);
}

/// The Settings row that opens [OpenShiftsSheet].
class OpenShiftsTile extends ConsumerWidget {
  const OpenShiftsTile({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SettingsTile(
    icon: icon,
    title: title,
    value: openShiftsLabel(
      ref.settings.teamStaffNeeded,
      context.l10n,
      context.locale,
    ),
    onTap: () => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const OpenShiftsSheet(),
    ),
  );
}

/// Switches per shift, or counters while the team planner is on.
class OpenShiftsSheet extends ConsumerWidget {
  const OpenShiftsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final counts = ref.settings.teamPlanner;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              counts ? l10n.teamStaffNeeded : l10n.openShifts,
              style: context.text.titleLarge,
            ),
            Text(
              counts ? l10n.staffNeededHint : l10n.openShiftsHint,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            OpenShiftsGrid(counts: counts),
          ],
        ),
      ),
    );
  }
}

/// A header with Lunch and Evening, then one row per weekday with a switch
/// per shift, or with [counts] a counter per shift.
class OpenShiftsGrid extends ConsumerWidget {
  const OpenShiftsGrid({super.key, required this.counts});

  final bool counts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final needs = ref.settings.teamStaffNeeded;
    final names = [
      for (var wd = DateTime.monday; wd <= DateTime.sunday; wd++)
        shortWeekday(_dateOf(wd), context.locale),
    ];
    final nameStyle = context.text.titleSmall;
    final nameWidth = textColumnWidth(context, nameStyle, names, min: 32);

    Future<void> save(StaffNeeds Function(StaffNeeds) change) => ref
        .services
        .settings
        .update((s) => s.copyWith(teamStaffNeeded: change(s.teamStaffNeeded)));

    // Each cell shrinks rather than overflow on a narrow phone or with a
    // large font.
    Widget cell(Widget child) => Expanded(
      child: Center(
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: nameWidth),
            for (final shift in TeamShift.values)
              cell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Icon(
                      teamShiftIcon(shift),
                      size: 18,
                      color: context.colors.outline,
                    ),
                    Text(
                      teamShiftLabel(shift, l10n),
                      style: context.text.labelLarge,
                    ),
                  ],
                ),
              ),
          ],
        ),
        for (var wd = DateTime.monday; wd <= DateTime.sunday; wd++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: nameWidth,
                  child: Text(names[wd - 1], style: nameStyle),
                ),
                for (final shift in TeamShift.values)
                  cell(
                    counts
                        ? _Counter(
                            value: needs.needed(wd, shift),
                            onChanged: (n) =>
                                save((v) => v.withNeeded(wd, shift, n)),
                          )
                        : Switch(
                            value: needs.isOpen(wd, shift),
                            onChanged: (open) =>
                                save((v) => v.withOpen(wd, shift, open)),
                          ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// "− 2 +" with 0 shown as "Closed".
class _Counter extends StatelessWidget {
  const _Counter({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      M3EIconButton(
        icon: const Icon(Icons.remove),
        tooltip: '−',
        onPressed: value > 0 ? () => onChanged(value - 1) : null,
      ),
      SizedBox(
        width: textColumnWidth(context, context.text.labelSmall, [
          context.l10n.teamClosed,
        ], min: 32),
        child: Text(
          value == 0 ? context.l10n.teamClosed : '$value',
          textAlign: TextAlign.center,
          style: value == 0
              ? context.text.labelSmall
              : context.text.titleMedium,
        ),
      ),
      M3EIconButton(
        icon: const Icon(Icons.add),
        tooltip: '+',
        onPressed: value < 9 ? () => onChanged(value + 1) : null,
      ),
    ],
  );
}
