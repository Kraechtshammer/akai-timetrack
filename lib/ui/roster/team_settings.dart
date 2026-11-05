// The "Team planner" section of the Settings screen (F11).
// See docs/02-design.md §7, "Settings".
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/time.dart';
import '../../data/database.dart';
import '../common.dart';
import '../settings/settings_screen.dart';
import 'people_screen.dart';
import 'roster_common.dart';

class TeamSettingsSection extends ConsumerWidget {
  const TeamSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;
    final people = ref.watch(teamMembersProvider).value ?? const [];
    final count = people.length;

    return Column(
      children: [
        SwitchListTile(
          secondary: const SettingsTileIcon(Icons.groups),
          title: Text(l10n.teamPlannerSwitch),
          subtitle: Text(l10n.teamPlannerSubtitle),
          value: s.teamPlanner,
          onChanged: (on) =>
              ref.services.settings.update((s) => s.copyWith(teamPlanner: on)),
        ),
        if (s.teamPlanner) ...[
          SettingsTile(
            icon: Icons.tune,
            title: l10n.teamStaffNeeded,
            value: l10n.teamDayNeeded(
              '${s.teamStaffNeeded.needed(DateTime.monday, TeamShift.lunch)}',
              '${s.teamStaffNeeded.needed(DateTime.monday, TeamShift.evening)}',
            ),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (_) => const _StaffNeededSheet(),
            ),
          ),
          SettingsTile(
            icon: Icons.schedule,
            title: l10n.teamStartTimes,
            value:
                '${minutesToHhmm(s.teamStarts.lunch)} · '
                '${minutesToHhmm(s.teamStarts.evening)}',
            onTap: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => const _StartTimesSheet(),
            ),
          ),
          SettingsTile(
            icon: Icons.people_outline,
            title: l10n.teamPeople,
            value: count == 0 ? l10n.teamNobodyYet : '$count',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PeopleScreen()),
            ),
          ),
        ],
      ],
    );
  }
}

/// One row per weekday with a stepper for lunch and for evening.
class _StaffNeededSheet extends ConsumerWidget {
  const _StaffNeededSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needs = ref.settings.teamStaffNeeded;
    final dayName = DateFormat.EEEE(context.locale);
    // 2024-01-01 was a Monday.
    DateTime dateOf(int weekday) => DateTime(2024, 1, weekday);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.teamStaffNeeded, style: context.text.titleLarge),
            const SizedBox(height: 8),
            for (var wd = DateTime.monday; wd <= DateTime.sunday; wd++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dayName.format(dateOf(wd)),
                        style: context.text.titleSmall,
                      ),
                    ),
                    for (final shift in TeamShift.values)
                      _Stepper(
                        shift: shift,
                        value: needs.needed(wd, shift),
                        onChanged: (n) => ref.services.settings.update(
                          (s) => s.copyWith(
                            teamStaffNeeded: s.teamStaffNeeded.withNeeded(
                              wd,
                              shift,
                              n,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "sun − 2 +" with 0 shown as "Closed".
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.shift,
    required this.value,
    required this.onChanged,
  });

  final TeamShift shift;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(teamShiftIcon(shift), size: 18, color: context.colors.outline),
      M3EIconButton(
        icon: const Icon(Icons.remove),
        tooltip: '−',
        onPressed: value > 0 ? () => onChanged(value - 1) : null,
      ),
      SizedBox(
        width: 40,
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

/// Two rows: the start of lunch and of evening.
class _StartTimesSheet extends ConsumerWidget {
  const _StartTimesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final starts = ref.settings.teamStarts;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.teamStartTimes, style: context.text.titleLarge),
            ),
          ),
          for (final shift in TeamShift.values)
            ListTile(
              leading: Icon(teamShiftIcon(shift)),
              title: Text(teamShiftLabel(shift, l10n)),
              trailing: Text(
                minutesToHhmm(starts.of(shift)),
                style: context.text.titleMedium,
              ),
              onTap: () async {
                final picked = await pickTime(context, starts.of(shift));
                if (picked == null) return;
                await ref.services.settings.update(
                  (s) => s.copyWith(
                    teamStarts: s.teamStarts.withStart(shift, picked),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
