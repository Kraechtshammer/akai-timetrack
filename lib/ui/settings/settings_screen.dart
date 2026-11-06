import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../app/update_controller.dart';
import '../../core/time.dart';
import '../../data/app_settings.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import 'reliability.dart';
import 'settings_pages.dart';

/// The overview: a warning when reminders may not arrive, then one row per
/// category, each opening its own page (settings_pages.dart).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  var _allReliable = true;

  /// Bumped after a category page closes, so the warning checks again
  /// (the Reminders page can fix things without leaving the app).
  var _checkRound = 0;

  Future<void> _open(SettingsCategory category) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SettingsCategoryScreen(category)),
    );
    if (mounted) setState(() => _checkRound++);
  }

  String _summary(SettingsCategory category, AppSettings s) {
    final l10n = context.l10n;
    return switch (category) {
      SettingsCategory.shifts => l10n.settingsShiftsSummary,
      SettingsCategory.reminders => l10n.minutesBefore(s.reminderLeadMinutes),
      SettingsCategory.calendar => s.calendarName ?? l10n.calendarNone,
      SettingsCategory.features => switch ([
        if (s.tipPool) l10n.tipPool,
        if (s.teamPlanner) l10n.teamPlannerSwitch,
      ]) {
        [] => l10n.featuresNone,
        final on => on.join(' · '),
      },
      SettingsCategory.team => l10n.settingsTeamPeople(
        ref.watch(teamMembersProvider).value?.length ?? 0,
      ),
      SettingsCategory.appearance =>
        '${themeSeedLabel(s.themeSeed, l10n, restaurant: s.restaurant)} · '
            '${themeModeLabel(s.themeMode, l10n)}',
      SettingsCategory.general =>
        '${s.restaurant.isEmpty ? l10n.notSet : s.restaurant} · '
            '${languageLabel(s.locale, l10n)}',
      SettingsCategory.update => switch (ref.watch(updateProvider)) {
        UpdateState(latest: final latest?) => l10n.updateAvailableTile(
          '${latest.version}',
        ),
        final update => l10n.settingsUpdateSummary('${update.installed ?? ''}'),
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = ref.settings;
    final updateWaiting = ref.watch(updateProvider).latest != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Offstage(
            offstage: _allReliable,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Panel(
                color: context.colors.tertiaryContainer,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      l10n.reliabilityTitle,
                      style: context.text.titleMedium,
                    ),
                    Text(l10n.reliabilityBody),
                    ReliabilityChecklist(
                      key: ValueKey(_checkRound),
                      items: ReliabilityItem.values,
                      onlyMissing: true,
                      onStatus: (ok) {
                        if (mounted && ok != _allReliable) {
                          setState(() => _allReliable = ok);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SettingsSection(null, [
            for (final category in SettingsCategory.values)
              // The team planner's page only while the feature is on.
              if (category != SettingsCategory.team || s.teamPlanner)
                SettingsTile(
                  icon: settingsCategoryIcon(category),
                  title: settingsCategoryTitle(category, l10n),
                  value: _summary(category, s),
                  trailing: category == SettingsCategory.update && updateWaiting
                      ? Badge(
                          smallSize: 10,
                          backgroundColor: context.colors.primary,
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => _open(category),
                ),
          ]),
        ],
      ),
    );
  }
}

/// The three default shift times. Also used in the onboarding.
class DefaultTimesTiles extends ConsumerWidget {
  const DefaultTimesTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;

    Future<void> edit(
      ShiftTimes times,
      AppSettings Function(ShiftTimes) apply,
    ) async {
      final start = await pickTime(context, times.start);
      if (start == null || !context.mounted) return;
      final end = await pickTime(context, times.end);
      if (end == null) return;
      await ref.services.settings.update((_) => apply(ShiftTimes(start, end)));
    }

    String range(ShiftTimes t) =>
        '${minutesToHhmm(t.start)} – ${minutesToHhmm(t.end)}';

    return Column(
      children: [
        SettingsTile(
          icon: Icons.light_mode_outlined,
          title: l10n.shiftLunch,
          value: range(s.lunch),
          onTap: () => edit(s.lunch, (t) => s.copyWith(lunch: t)),
        ),
        SettingsTile(
          icon: Icons.wb_twilight,
          title: l10n.lunchBeforeEvening,
          value: range(s.lunchBeforeEvening),
          onTap: () => edit(
            s.lunchBeforeEvening,
            (t) => s.copyWith(lunchBeforeEvening: t),
          ),
        ),
        SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: l10n.shiftEvening,
          value: range(s.evening),
          onTap: () => edit(s.evening, (t) => s.copyWith(evening: t)),
        ),
      ],
    );
  }
}

/// A rounded group of tiles, with a heading unless [title] is null (when the
/// page title already says it).
class SettingsSection extends StatelessWidget {
  const SettingsSection(this.title, this.children, {super.key});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title == null)
        const SizedBox(height: 8)
      else
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title!,
            style: context.text.titleSmall?.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
      Panel(
        padding: const EdgeInsets.symmetric(vertical: 4),
        radius: 24,
        color: context.colors.surfaceContainerLow,
        child: Column(children: children),
      ),
    ],
  );
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: SettingsTileIcon(icon),
    title: Text(title),
    subtitle: Text(value),
    trailing: trailing,
    onTap: onTap,
  );
}

class SettingsTileIcon extends StatelessWidget {
  const SettingsTileIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    backgroundColor: context.colors.primaryContainer,
    foregroundColor: context.colors.onPrimaryContainer,
    child: Icon(icon, size: 20),
  );
}
