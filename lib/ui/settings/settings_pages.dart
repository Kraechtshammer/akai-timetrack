// The category pages behind the Settings overview.
// See docs/02-design.md §7, "Settings".
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../material.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/time.dart';
import '../../data/app_settings.dart';
import '../../domain/rounding.dart';
import '../../platform/app_icon.dart';
import '../../platform/calendar_sync.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../roster/team_settings.dart';
import 'calendar_pickers.dart';
import 'open_shifts.dart';
import 'reliability.dart';
import 'settings_screen.dart';
import 'update_tiles.dart';

/// The categories of the Settings overview, in their order there.
enum SettingsCategory {
  shifts,
  reminders,
  calendar,
  features,
  team,
  appearance,
  general,
  update,
}

String settingsCategoryTitle(
  SettingsCategory category,
  AppLocalizations l10n,
) => switch (category) {
  SettingsCategory.shifts => l10n.sectionShifts,
  SettingsCategory.reminders => l10n.sectionReminders,
  SettingsCategory.calendar => l10n.sectionCalendar,
  SettingsCategory.features => l10n.sectionFeatures,
  SettingsCategory.team => l10n.sectionTeam,
  SettingsCategory.appearance => l10n.sectionAppearance,
  SettingsCategory.general => l10n.sectionGeneral,
  SettingsCategory.update => l10n.sectionUpdate,
};

IconData settingsCategoryIcon(SettingsCategory category) => switch (category) {
  SettingsCategory.shifts => Icons.schedule,
  SettingsCategory.reminders => Icons.notifications_outlined,
  SettingsCategory.calendar => Icons.event,
  SettingsCategory.features => Icons.toggle_on_outlined,
  SettingsCategory.team => Icons.groups,
  SettingsCategory.appearance => Icons.palette_outlined,
  SettingsCategory.general => Icons.tune,
  SettingsCategory.update => Icons.system_update_outlined,
};

/// One category's page, pushed from the overview.
class SettingsCategoryScreen extends StatelessWidget {
  const SettingsCategoryScreen(this.category, {super.key});

  final SettingsCategory category;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(settingsCategoryTitle(category, context.l10n))),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        switch (category) {
          SettingsCategory.shifts => const _ShiftsPage(),
          SettingsCategory.reminders => const _RemindersPage(),
          SettingsCategory.calendar => const _CalendarPage(),
          SettingsCategory.features => const _FeaturesPage(),
          SettingsCategory.team => const SettingsSection(null, [
            TeamSettingsSection(),
          ]),
          SettingsCategory.appearance => const _AppearancePage(),
          SettingsCategory.general => const _GeneralPage(),
          SettingsCategory.update => const SettingsSection(null, [
            UpdateTiles(),
          ]),
        },
      ],
    ),
  );
}

/// Saves a change. [resync] updates reminders and the calendar afterwards;
/// [calendarEvents] also rewrites every calendar event.
Future<void> _update(
  WidgetRef ref,
  AppSettings Function(AppSettings) change, {
  bool resync = false,
  bool calendarEvents = false,
}) async {
  final services = ref.services;
  await services.settings.update(change);
  if (calendarEvents) await services.shifts.markAllEventsDirty();
  if (resync || calendarEvents) await services.syncAll();
}

class _ShiftsPage extends ConsumerWidget {
  const _ShiftsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;
    return Column(
      children: [
        SettingsSection(null, [
          OpenShiftsTile(
            icon: Icons.storefront_outlined,
            title: l10n.openShifts,
          ),
        ]),
        SettingsSection(l10n.sectionDefaultTimes, const [DefaultTimesTiles()]),
        SettingsSection(l10n.sectionRecording, [
          SettingsTile(
            icon: Icons.av_timer,
            title: l10n.rounding,
            value: roundingLabel(s.roundingMode, l10n),
            onTap: () async {
              final mode = await pickOption(
                context,
                title: l10n.rounding,
                options: RoundingMode.values,
                selected: s.roundingMode,
                label: (m) => roundingLabel(m, l10n),
              );
              if (mode != null) {
                await _update(ref, (s) => s.copyWith(roundingMode: mode));
              }
            },
          ),
        ]),
      ],
    );
  }
}

class _RemindersPage extends ConsumerWidget {
  const _RemindersPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;

    Future<void> pickMinutes(
      String title,
      List<int> options,
      int current,
      String Function(int) label,
      AppSettings Function(int) apply,
    ) async {
      final value = await pickOption(
        context,
        title: title,
        options: options,
        selected: current,
        label: label,
      );
      if (value != null) await _update(ref, (_) => apply(value), resync: true);
    }

    return Column(
      children: [
        SettingsSection(null, [
          SettingsTile(
            icon: Icons.notifications_outlined,
            title: l10n.reminderBefore,
            value: l10n.minutesBefore(s.reminderLeadMinutes),
            onTap: () => pickMinutes(
              l10n.reminderBefore,
              [5, 10, 15, 20, 30, 45, 60],
              s.reminderLeadMinutes,
              l10n.minutesBefore,
              (m) => s.copyWith(reminderLeadMinutes: m),
            ),
          ),
          SettingsTile(
            icon: Icons.notification_important_outlined,
            title: l10n.overrunAsk,
            value: l10n.minutesAfterEnd(s.overrunMinutes),
            onTap: () => pickMinutes(
              l10n.overrunAsk,
              [15, 30, 45, 60, 90],
              s.overrunMinutes,
              l10n.minutesAfterEnd,
              (m) => s.copyWith(overrunMinutes: m),
            ),
          ),
        ]),
        // All of them with their status, also the ones that are fine. The
        // overview only warns about the missing ones.
        SettingsSection(l10n.sectionPermissions, [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    l10n.permissionsHint,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const ReliabilityChecklist(items: ReliabilityItem.values),
              ],
            ),
          ),
        ]),
      ],
    );
  }
}

class _CalendarPage extends ConsumerWidget {
  const _CalendarPage();

  Future<void> _editTitle(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text:
          (ref.read(settingsProvider).value ?? const AppSettings()).eventTitle,
    );
    final String? title;
    try {
      title = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.eventTitle),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            M3EButton(
              style: M3EButtonStyle.text,
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            M3EButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
    if (title != null && title.isNotEmpty) {
      await _update(
        ref,
        (s) => s.copyWith(eventTitle: title),
        calendarEvents: true,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;
    final calendarSet = s.calendarId != null;
    return SettingsSection(null, [
      SettingsTile(
        icon: Icons.event,
        title: l10n.calendar,
        value: s.calendarName ?? l10n.calendarNone,
        onTap: () => showCalendarPicker(context, ref),
      ),
      SettingsTile(
        icon: Icons.title,
        title: l10n.eventTitle,
        value: s.eventTitle,
        onTap: () => _editTitle(context, ref),
      ),
      if (calendarSet)
        SettingsTile(
          icon: Icons.format_color_fill,
          title: l10n.eventColor,
          value: s.eventColorKey == null
              ? l10n.colorOfCalendar
              : googleEventColorName(s.eventColorKey!, l10n) ??
                    l10n.colorWithKey(s.eventColorKey!),
          trailing: s.eventColor == null
              ? null
              : CircleAvatar(radius: 12, backgroundColor: Color(s.eventColor!)),
          onTap: () => showEventColorPicker(context, ref),
        ),
      if (calendarSet) const _SyncNowTile(),
    ]);
  }
}

class _AppearancePage extends ConsumerWidget {
  const _AppearancePage();

  /// Asks first, because Android closes the app when the launcher entry it
  /// was started from is switched off.
  Future<void> _changeIcon(
    BuildContext context,
    WidgetRef ref,
    AppIcon from,
    AppIcon to,
    String label,
  ) async {
    if (to == from) return;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: Text(l10n.appIconHint),
        actions: [
          M3EButton(
            style: M3EButtonStyle.text,
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          M3EButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.appIconApply),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AppIcons.set(to);
    ref.invalidate(appIconProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;
    final icon = ref.watch(appIconProvider).value;
    // Watched here, so the people list loads even with the team planner off
    // (the secret designs depend on it).
    final members = ref.watch(teamMembersProvider).value;
    final designs = icon == null || members == null
        ? null
        : iconDesignsOffered(
            members: members,
            restaurant: s.restaurant,
            current: icon.design,
          );
    return SettingsSection(null, [
      ListTile(
        leading: const SettingsTileIcon(Icons.palette_outlined),
        title: Text(l10n.color),
        subtitle: Text(
          themeSeedLabel(s.themeSeed, l10n, restaurant: s.restaurant),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
        child: Wrap(
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
        ),
      ),
      ListTile(
        leading: const SettingsTileIcon(Icons.contrast),
        title: Text(l10n.darkMode),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
        child: SegmentedButton<AppThemeMode>(
          showSelectedIcon: false,
          segments: [
            for (final mode in [
              AppThemeMode.light,
              AppThemeMode.dark,
              AppThemeMode.system,
            ])
              ButtonSegment(
                value: mode,
                label: Text(themeModeLabel(mode, l10n)),
              ),
          ],
          selected: {s.themeMode},
          onSelectionChanged: (modes) =>
              _update(ref, (s) => s.copyWith(themeMode: modes.single)),
        ),
      ),
      // Only when there is a design to choose; usually the cloche is the
      // only one, and then only the shape can change.
      if (icon != null && designs != null && designs.length > 1)
        SettingsTile(
          icon: Icons.apps,
          title: l10n.appIcon,
          value: iconDesignLabel(icon.design, l10n),
          onTap: () async {
            final design = await pickOption(
              context,
              title: l10n.appIcon,
              options: designs,
              selected: icon.design,
              label: (d) => iconDesignLabel(d, l10n),
            );
            if (design == null || !context.mounted) return;
            await _changeIcon(
              context,
              ref,
              icon,
              icon.withDesign(design),
              iconDesignLabel(design, l10n),
            );
          },
        ),
      SettingsTile(
        icon: Icons.crop_square,
        title: l10n.appIconShape,
        value: icon == null ? '' : iconShapeLabel(icon.shape, l10n),
        onTap: () async {
          final current = ref.read(appIconProvider).value;
          final shape = await pickOption(
            context,
            title: l10n.appIconShape,
            options: IconShape.values,
            selected: (current ?? AppIcon.fallback).shape,
            label: (s) => iconShapeLabel(s, l10n),
          );
          if (shape == null || current == null || !context.mounted) return;
          await _changeIcon(
            context,
            ref,
            current,
            current.withShape(shape),
            iconShapeLabel(shape, l10n),
          );
        },
      ),
      SettingsTile(
        icon: Icons.view_week_outlined,
        title: l10n.weekMarks,
        value: weekMarksLabel(s.weekMarks, l10n),
        onTap: () async {
          final style = await pickOption(
            context,
            title: l10n.weekMarks,
            options: WeekMarkStyle.values,
            selected: s.weekMarks,
            label: (m) => weekMarksLabel(m, l10n),
          );
          if (style != null) {
            await _update(ref, (s) => s.copyWith(weekMarks: style));
          }
        },
      ),
    ]);
  }
}

/// Switches for the parts of the app not everyone uses. Turning one off
/// only hides it; its data stays.
class _FeaturesPage extends ConsumerWidget {
  const _FeaturesPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;
    return SettingsSection(null, [
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
    ]);
  }
}

class _GeneralPage extends ConsumerWidget {
  const _GeneralPage();

  Future<void> _editRestaurant(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text:
          (ref.read(settingsProvider).value ?? const AppSettings()).restaurant,
    );
    final String? name;
    try {
      name = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.restaurant),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              helperText: l10n.restaurantHint,
              helperMaxLines: 2,
              // Empty is a valid answer, so make it one tap away.
              suffixIcon: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => controller.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: l10n.clearField,
                        icon: const Icon(Icons.close),
                        onPressed: controller.clear,
                      ),
              ),
            ),
          ),
          actions: [
            M3EButton(
              style: M3EButtonStyle.text,
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            M3EButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
    // Empty is allowed: no restaurant anywhere. The events carry it as
    // their location.
    if (name != null &&
        name !=
            (ref.read(settingsProvider).value ?? const AppSettings())
                .restaurant) {
      await _update(
        ref,
        (s) => s.copyWith(restaurant: name),
        calendarEvents: true,
      );
    }
  }

  Future<void> _changeLanguage(WidgetRef ref, String? locale) async {
    // The event descriptions are written in the app's language, too.
    await _update(
      ref,
      (s) => s.copyWith(locale: () => locale),
      calendarEvents: true,
    );
    final services = ref.services;
    // Notification channel names and texts follow the language.
    await services.notifications.createChannels(await services.l10n());
    await services.syncAll();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;
    return SettingsSection(null, [
      SettingsTile(
        icon: Icons.storefront_outlined,
        title: l10n.restaurant,
        value: s.restaurant.isEmpty ? l10n.notSet : s.restaurant,
        onTap: () => _editRestaurant(context, ref),
      ),
      SettingsTile(
        icon: Icons.language,
        title: l10n.language,
        value: languageLabel(s.locale, l10n),
        onTap: () async {
          final choice = await pickOption<String>(
            context,
            title: l10n.language,
            options: const ['system', 'de', 'en'],
            selected: s.locale ?? 'system',
            label: (code) => languageLabel(code, l10n),
          );
          if (choice != null) {
            await _changeLanguage(ref, choice == 'system' ? null : choice);
          }
        },
      ),
    ]);
  }
}

/// "Language" setting value: null or 'system' follows the phone.
String languageLabel(String? locale, AppLocalizations l10n) => switch (locale) {
  'de' => l10n.languageGerman,
  'en' => l10n.languageEnglish,
  _ => l10n.languageSystem,
};

/// "Sync now", with the sync status as subtitle.
class _SyncNowTile extends ConsumerStatefulWidget {
  const _SyncNowTile();

  @override
  ConsumerState<_SyncNowTile> createState() => _SyncNowTileState();
}

class _SyncNowTileState extends ConsumerState<_SyncNowTile> {
  var _syncing = false;

  Future<void> _syncNow() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _syncing = true);
    final result = await ref.services.syncNow();
    if (!mounted) return;
    setState(() => _syncing = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          CalendarSyncResult.done || CalendarSyncResult.off => l10n.syncDone,
          CalendarSyncResult.noPermission => l10n.calendarPermissionMissing,
          CalendarSyncResult.failed => l10n.syncFailed,
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pending = ref.watch(pendingSyncCountProvider).value ?? 0;
    final last = ref.watch(lastCalendarSyncProvider).value;
    final String status;
    if (pending > 0) {
      status = l10n.syncPending(pending);
    } else if (last == null) {
      status = l10n.syncNever;
    } else {
      final today = dateOnly(ref.now) == dateOnly(last);
      final format = today
          ? DateFormat.Hm(context.locale)
          : DateFormat('E d. MMM, HH:mm', context.locale);
      status = l10n.syncUpToDate(format.format(last));
    }
    return SettingsTile(
      icon: Icons.sync,
      title: l10n.syncNow,
      value: status,
      trailing: _syncing
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : null,
      onTap: _syncing ? null : _syncNow,
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
