import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../l10n/labels.dart';
import '../../platform/device_setup.dart';
import '../common.dart';
import '../settings/calendar_pickers.dart';
import '../settings/reliability.dart';
import '../settings/settings_screen.dart';

/// First start: language, reminders, calendar, Xiaomi settings, times.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { welcome, reminders, calendar, xiaomi, times }

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  var _steps = [..._Step.values]..remove(_Step.xiaomi);
  var _index = 0;

  @override
  void initState() {
    super.initState();
    DeviceSetup.isXiaomi().then((xiaomi) {
      if (xiaomi && mounted) setState(() => _steps = _Step.values);
    });
  }

  _Step get _step => _steps[_index];
  bool get _isLast => _index == _steps.length - 1;

  Future<void> _next() async {
    if (!_isLast) {
      setState(() => _index++);
      return;
    }
    final services = ref.services;
    await services.settings.update((s) => s.copyWith(onboardingDone: true));
    await services.syncAll();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canSkip = _step == _Step.reminders || _step == _Step.xiaomi;
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index--);
      },
      child: Scaffold(
        appBar: _index == 0
            ? null
            : AppBar(
                leading: BackButton(onPressed: () => setState(() => _index--)),
              ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: switch (_step) {
                      _Step.welcome => const _Welcome(),
                      _Step.reminders => const _Reminders(),
                      _Step.calendar => const _Calendar(),
                      _Step.xiaomi => const _Xiaomi(),
                      _Step.times => const _Times(),
                    },
                  ),
                ),
                _StepDots(count: _steps.length, index: _index),
                const SizedBox(height: 16),
                Row(
                  spacing: 8,
                  children: [
                    if (canSkip)
                      Expanded(
                        child: TextButton(
                          onPressed: _next,
                          child: Text(l10n.skip),
                        ),
                      ),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                        onPressed: _next,
                        child: Text(
                          _index == 0
                              ? l10n.letsGo
                              : _isLast
                              ? l10n.finish
                              : l10n.next,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, size: 36, color: context.colors.onPrimaryContainer),
      ),
      Text(
        title,
        style: context.text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(
        body,
        style: context.text.bodyLarge?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 8),
    ],
  );
}

class _Welcome extends ConsumerWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.settings.locale ?? context.locale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        const SizedBox(height: 48),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.colors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule,
              size: 64,
              color: context.colors.onPrimary,
            ),
          ),
        ),
        Text(
          l10n.welcomeTitle,
          textAlign: TextAlign.center,
          style: context.text.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          l10n.welcomeBody,
          textAlign: TextAlign.center,
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'de', label: Text(l10n.languageGerman)),
            ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
          ],
          selected: {locale == 'en' ? 'en' : 'de'},
          onSelectionChanged: (choice) => ref.services.settings.update(
            (s) => s.copyWith(locale: () => choice.single),
          ),
        ),
      ],
    );
  }
}

class _Reminders extends StatelessWidget {
  const _Reminders();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _StepTitle(
        icon: Icons.notifications_active,
        title: context.l10n.remindersTitle,
        body: context.l10n.remindersBody,
      ),
      const ReliabilityChecklist(
        items: [ReliabilityItem.notifications, ReliabilityItem.exactAlarms],
      ),
    ],
  );
}

class _Calendar extends ConsumerWidget {
  const _Calendar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _StepTitle(
          icon: Icons.event,
          title: l10n.calendarTitle,
          body: l10n.calendarBody,
        ),
        Panel(
          radius: 20,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const Icon(Icons.lightbulb_outline),
                  Expanded(child: Text(l10n.calendarTip)),
                ],
              ),
              TextButton.icon(
                onPressed: () => const AndroidIntent(
                  action: 'action_view',
                  data: 'https://calendar.google.com',
                ).launch(),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.openGoogleCalendar),
              ),
            ],
          ),
        ),
        CalendarChooser(
          selectedId: s.calendarId,
          onSelected: (calendar) async {
            await ref.services.calendar.switchCalendar(calendar);
          },
        ),
        if (s.calendarId != null)
          ListTile(
            leading: const Icon(Icons.format_color_fill),
            title: Text(l10n.eventColor),
            subtitle: Text(
              s.eventColorKey == null
                  ? l10n.colorOfCalendar
                  : googleEventColorName(s.eventColorKey!, l10n) ??
                        l10n.colorWithKey(s.eventColorKey!),
            ),
            onTap: () => showEventColorPicker(context, ref),
          )
        else
          Text(l10n.continueWithoutCalendar, style: context.text.bodySmall),
      ],
    );
  }
}

class _Xiaomi extends StatelessWidget {
  const _Xiaomi();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: [
      _StepTitle(
        icon: Icons.battery_saver,
        title: context.l10n.xiaomiTitle,
        body: context.l10n.xiaomiBody,
      ),
      const ReliabilityChecklist(
        items: [ReliabilityItem.autostart, ReliabilityItem.battery],
      ),
      Text(context.l10n.xiaomiNote, style: context.text.bodySmall),
    ],
  );
}

class _Times extends StatelessWidget {
  const _Times();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _StepTitle(
        icon: Icons.schedule,
        title: context.l10n.timesTitle,
        body: context.l10n.timesBody,
      ),
      const DefaultTimesTiles(),
    ],
  );
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.stepOf(index + 1, count),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= index
                  ? context.colors.primary
                  : context.colors.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    ),
  );
}
