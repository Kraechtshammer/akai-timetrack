// The "Team planner" page of Settings (F11), shown while the feature is
// on (Settings › Features).
// See docs/02-design.md §7, "Settings".
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/time.dart';
import '../../data/app_settings.dart';
import '../common.dart';
import '../settings/open_shifts.dart';
import '../settings/settings_screen.dart';
import 'people_screen.dart';

class TeamSettingsSection extends ConsumerWidget {
  const TeamSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;
    final people = ref.watch(teamMembersProvider).value ?? const [];
    final count = people.length;
    final hasMe = people.any((m) => m.isMe);

    String range(ShiftTimes t) =>
        '${minutesToHhmm(t.start)}–${minutesToHhmm(t.end)}';

    return Column(
      children: [
        // The same sheet as Settings › Shifts › "Open shifts", with counters.
        OpenShiftsTile(icon: Icons.tune, title: l10n.teamStaffNeeded),
        // The shift times of Settings › Shifts: the team's start times,
        // and the end times its monthly hours are counted with.
        SettingsTile(
          icon: Icons.schedule,
          title: l10n.teamShiftTimes,
          value:
              '${range(s.lunch)} · '
              '${range(s.evening)}',
          onTap: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (_) => const _ShiftTimesSheet(),
          ),
        ),
        SettingsTile(
          icon: Icons.people_outline,
          title: l10n.teamPeople,
          value: count == 0 ? l10n.teamNobodyYet : '$count',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const PeopleScreen())),
        ),
        SwitchListTile(
          secondary: const SettingsTileIcon(Icons.sync),
          title: Text(l10n.teamSyncPlan),
          subtitle: Text(
            hasMe
                ? l10n.teamSyncPlanSubtitle
                : '${l10n.teamSyncPlanSubtitle} ${l10n.teamSyncPlanNoMe}',
          ),
          value: s.teamSyncPlan,
          onChanged: (on) =>
              ref.services.settings.update((s) => s.copyWith(teamSyncPlan: on)),
        ),
      ],
    );
  }
}

/// The three shift times, the same tiles as Settings › Shifts.
class _ShiftTimesSheet extends StatelessWidget {
  const _ShiftTimesSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(l10n.teamShiftTimes, style: context.text.titleLarge),
            ),
            const DefaultTimesTiles(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                l10n.teamShiftTimesNote,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
