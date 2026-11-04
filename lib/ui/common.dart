import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/time.dart';
import '../l10n/app_localizations.dart';
import 'settings/settings_screen.dart';

extension ContextHelpers on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  String get locale => l10n.localeName;

  void showSnack(String message, {SnackBarAction? action}) =>
      ScaffoldMessenger.of(this)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message), action: action));
}

/// Big title at the top of a tab, with optional buttons on the right.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.text.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        ...actions,
        IconButton(
          tooltip: context.l10n.settings,
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    ),
  );
}

/// A rounded, tinted card like in the concept screens.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(20),
    this.radius = 28,
  });

  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: child,
  );
}

/// "‹ KW 45 · 2. – 8. Nov. ›"
class WeekSwitcher extends StatelessWidget {
  const WeekSwitcher({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Panel(
    radius: 28,
    padding: const EdgeInsets.all(4),
    color: context.colors.surfaceContainer,
    child: Row(
      children: [
        IconButton(
          tooltip: context.l10n.previousWeek,
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrevious,
        ),
        Expanded(
          child: Column(
            children: [
              Text(title, style: context.text.titleMedium),
              Text(subtitle, style: context.text.bodySmall),
            ],
          ),
        ),
        IconButton(
          tooltip: context.l10n.nextWeek,
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    ),
  );
}

/// Progress bar with a wavy filled part (Material 3 Expressive style).
/// Flutter doesn't have one yet, so it's drawn here.
class WavyProgress extends StatelessWidget {
  const WavyProgress({super.key, required this.value});

  /// 0..1
  final double value;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 12,
    width: double.infinity,
    child: CustomPaint(
      painter: _WavyPainter(
        value: value.clamp(0, 1),
        active: context.colors.primary,
        track: context.colors.secondaryContainer,
      ),
    ),
  );
}

class _WavyPainter extends CustomPainter {
  _WavyPainter({
    required this.value,
    required this.active,
    required this.track,
  });

  final double value;
  final Color active;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 4.0, gap = 6.0, wavelength = 20.0, amplitude = 3.0;
    final mid = size.height / 2;
    final end = size.width * value;
    final paint = Paint()
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (end > stroke) {
      final wave = Path()..moveTo(stroke / 2, mid);
      for (var x = stroke / 2; x <= end; x += 1) {
        wave.lineTo(
          x,
          mid + amplitude * math.sin(x / wavelength * 2 * math.pi),
        );
      }
      canvas.drawPath(wave, paint..color = active);
    }
    final trackStart = end > stroke ? end + gap : stroke / 2;
    if (trackStart < size.width - stroke) {
      canvas.drawLine(
        Offset(trackStart, mid),
        Offset(size.width - stroke / 2, mid),
        paint..color = track,
      );
    }
  }

  @override
  bool shouldRepaint(_WavyPainter old) =>
      old.value != value || old.active != active || old.track != track;
}

/// Lets the user pick a time (24 h). Returns minutes after midnight.
Future<Minutes?> pickTime(BuildContext context, Minutes initial) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  return picked == null ? null : picked.hour * 60 + picked.minute;
}

/// A tappable "time field" with a label above, e.g. "Beginn 17:30".
class TimeField extends StatelessWidget {
  const TimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onPicked,
    this.highlight = false,
  });

  final String label;
  final Minutes value;
  final ValueChanged<Minutes> onPicked;
  final bool highlight;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: () async {
      final picked = await pickTime(context, value);
      if (picked != null) onPicked(picked);
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        enabledBorder: highlight
            ? OutlineInputBorder(
                borderSide: BorderSide(color: context.colors.primary, width: 2),
              )
            : null,
        suffixIcon: const Icon(Icons.schedule),
      ),
      child: Text(
        minutesToHhmm(value),
        style: context.text.bodyLarge?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    ),
  );
}

/// Asks the user to choose one of [options].
Future<T?> pickOption<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T) label,
}) => showDialog<T>(
  context: context,
  builder: (context) => SimpleDialog(
    title: Text(title),
    children: [
      RadioGroup<T>(
        groupValue: selected,
        onChanged: (value) => Navigator.pop(context, value),
        child: Column(
          children: [
            for (final option in options)
              RadioListTile<T>(value: option, title: Text(label(option))),
          ],
        ),
      ),
    ],
  ),
);

const tabularFigures = [FontFeature.tabularFigures()];
