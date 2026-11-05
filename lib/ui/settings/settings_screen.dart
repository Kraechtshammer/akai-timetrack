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
import '../../l10n/labels.dart';
import '../common.dart';
import 'calendar_pickers.dart';
import 'reliability.dart';
import 'update_tiles.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  var _allReliable = true;

  /// Saves a change. [resync] updates reminders and the calendar afterwards.
  Future<void> _update(
    AppSettings Function(AppSettings) change, {
    bool resync = false,
    bool calendarEvents = false,
  }) async {
    final services = ref.services;
    await services.settings.update(change);
    if (calendarEvents) await services.shifts.markAllEventsDirty();
    if (resync || calendarEvents) await services.syncAll();
  }

  Future<void> _editTitle() async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: ref.settings.eventTitle);
    final title = await showDialog<String>(
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
    if (title != null && title.isNotEmpty) {
      await _update((s) => s.copyWith(eventTitle: title), calendarEvents: true);
    }
  }

  Future<void> _changeLanguage(String? locale) async {
    // The event descriptions are written in the app's language, too.
    await _update(
      (s) => s.copyWith(locale: () => locale),
      calendarEvents: true,
    );
    final services = ref.services;
    // Notification channel names and texts follow the language.
    await services.notifications.createChannels(await services.l10n());
    await services.syncAll();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = ref.settings;
    final calendarSet = s.calendarId != null;

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
      if (value != null) await _update((_) => apply(value), resync: true);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Offstage(
            offstage: _allReliable,
            child: Panel(
              color: context.colors.tertiaryContainer,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(l10n.reliabilityTitle, style: context.text.titleMedium),
                  Text(l10n.reliabilityBody),
                  ReliabilityChecklist(
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
          _Section(l10n.sectionCalendar, [
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
              onTap: _editTitle,
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
                    : CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(s.eventColor!),
                      ),
                onTap: () => showEventColorPicker(context, ref),
              ),
            if (calendarSet) const _SyncNowTile(),
          ]),
          _Section(l10n.sectionDefaultTimes, const [DefaultTimesTiles()]),
          _Section(l10n.sectionReminders, [
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
          _Section(l10n.sectionRecording, [
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
                  await _update((s) => s.copyWith(roundingMode: mode));
                }
              },
            ),
          ]),
          _Section(l10n.sectionAppearance, [
            ListTile(
              leading: const SettingsTileIcon(Icons.palette_outlined),
              title: Text(l10n.color),
              subtitle: Text(themeSeedLabel(s.themeSeed, l10n)),
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
                      selected: s.themeSeed == seed,
                      onTap: () => _update((s) => s.copyWith(themeSeed: seed)),
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
                    _update((s) => s.copyWith(themeMode: modes.single)),
              ),
            ),
            SettingsTile(
              icon: Icons.apps,
              title: l10n.appIcon,
              value: switch (ref.watch(appIconProvider).value) {
                null => '',
                final icon => appIconLabel(icon, l10n),
              },
              onTap: () async {
                final current = ref.read(appIconProvider).value;
                final icon = await pickOption(
                  context,
                  title: l10n.appIcon,
                  options: AppIcon.values,
                  selected: current ?? AppIcon.round,
                  label: (i) => appIconLabel(i, l10n),
                );
                if (icon == null || icon == current || !context.mounted) {
                  return;
                }
                // Android closes the app when the launcher entry it was
                // started from is switched off, so say so first.
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(appIconLabel(icon, l10n)),
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
                await AppIcons.set(icon);
                ref.invalidate(appIconProvider);
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
                  await _update((s) => s.copyWith(weekMarks: style));
                }
              },
            ),
            SettingsTile(
              icon: Icons.language,
              title: l10n.language,
              value: switch (s.locale) {
                'de' => l10n.languageGerman,
                'en' => l10n.languageEnglish,
                _ => l10n.languageSystem,
              },
              onTap: () async {
                final choice = await pickOption<String>(
                  context,
                  title: l10n.language,
                  options: const ['system', 'de', 'en'],
                  selected: s.locale ?? 'system',
                  label: (code) => switch (code) {
                    'de' => l10n.languageGerman,
                    'en' => l10n.languageEnglish,
                    _ => l10n.languageSystem,
                  },
                );
                if (choice != null) {
                  await _changeLanguage(choice == 'system' ? null : choice);
                }
              },
            ),
          ]),
          _Section(l10n.sectionUpdate, const [UpdateTiles()]),
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

/// "Jetzt synchronisieren", with the sync status as subtitle.
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

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(
          title,
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

class _SeedSwatch extends StatelessWidget {
  const _SeedSwatch({
    required this.seed,
    required this.selected,
    required this.onTap,
  });

  final ThemeSeed seed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = seedColors[seed];
    return Tooltip(
      message: themeSeedLabel(seed, context.l10n),
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
