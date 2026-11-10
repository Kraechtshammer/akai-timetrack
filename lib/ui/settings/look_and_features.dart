// The feature switches and the theme controls, shared by Settings
// (Features, Appearance) and the last step of the first-start setup.
// See docs/02-design.md §7.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/app_settings.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import 'settings_screen.dart';

Future<void> _update(WidgetRef ref, AppSettings Function(AppSettings) change) =>
    ref.services.settings.update(change);

/// One switch per optional feature, with a line on what it does. Turning
/// one off only hides it; its data stays.
class FeatureSwitches extends ConsumerWidget {
  const FeatureSwitches({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;
    return Column(
      children: [
        SwitchListTile(
          secondary: const SettingsTileIcon(Icons.savings_outlined),
          title: Text(l10n.tipPool),
          subtitle: Text(l10n.tipPoolSwitchSubtitle),
          value: s.tipPool,
          onChanged: (on) => _update(ref, (s) => s.copyWith(tipPool: on)),
        ),
        SwitchListTile(
          secondary: const SettingsTileIcon(Icons.groups),
          title: Text(l10n.teamPlannerSwitch),
          subtitle: Text(l10n.teamPlannerSubtitle),
          value: s.teamPlanner,
          onChanged: (on) => _update(ref, (s) => s.copyWith(teamPlanner: on)),
        ),
      ],
    );
  }
}

/// A round swatch per theme colour, the chosen one ticked.
class ThemeSeedSwatches extends ConsumerWidget {
  const ThemeSeedSwatches({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.settings;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final seed in ThemeSeed.values)
          _SeedSwatch(
            seed: seed,
            restaurant: s.restaurant,
            selected: s.themeSeed == seed,
            onTap: () => _update(ref, (s) => s.copyWith(themeSeed: seed)),
          ),
      ],
    );
  }
}

/// Light / Dark / System.
class ThemeModeButtons extends ConsumerWidget {
  const ThemeModeButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return SegmentedButton<AppThemeMode>(
      showSelectedIcon: false,
      segments: [
        for (final mode in [
          AppThemeMode.light,
          AppThemeMode.dark,
          AppThemeMode.system,
        ])
          ButtonSegment(value: mode, label: Text(themeModeLabel(mode, l10n))),
      ],
      selected: {ref.settings.themeMode},
      onSelectionChanged: (modes) =>
          _update(ref, (s) => s.copyWith(themeMode: modes.single)),
    );
  }
}

class _SeedSwatch extends StatelessWidget {
  const _SeedSwatch({
    required this.seed,
    required this.restaurant,
    required this.selected,
    required this.onTap,
  });

  final ThemeSeed seed;

  /// Names the red (see [themeSeedLabel]).
  final String restaurant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = seedColors[seed];
    return Tooltip(
      message: themeSeedLabel(seed, context.l10n, restaurant: restaurant),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color ?? context.colors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? context.colors.onSurface
                  : context.colors.outline,
              width: selected ? 3 : 1,
            ),
          ),
          child: Icon(
            selected ? Icons.check : (color == null ? Icons.wallpaper : null),
            color: color == null ? context.colors.onSurface : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
