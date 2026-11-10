// The "Team planner" page of Settings (F11), shown while the feature is
// on (Settings › Features).
// See docs/02-design.md §7, "Settings".
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../core/time.dart';
import '../../data/database.dart';
import '../common.dart';
import '../settings/open_shifts.dart';
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
        // The same sheet as Settings › Shifts › "Open shifts", with counters.
        OpenShiftsTile(icon: Icons.tune, title: l10n.teamStaffNeeded),
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
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const PeopleScreen())),
        ),
      ],
    );
  }
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
