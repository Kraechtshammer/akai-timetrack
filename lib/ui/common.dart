import 'material.dart';

import '../app/shift_colors.dart';
import '../core/time.dart';
import '../l10n/app_localizations.dart';
import 'settings/settings_screen.dart';

extension ContextHelpers on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Recorded, not recorded, lunch, evening and today (`app/shift_colors.dart`).
  ShiftColors get shiftColors => Theme.of(this).extension<ShiftColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
  String get locale => l10n.localeName;

  void showSnack(
    String message, {
    SnackBarAction? action,
  }) => ScaffoldMessenger.of(this)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      // A snack bar with an action stays until dismissed unless told not to.
      SnackBar(content: Text(message), action: action, persist: false),
    );
}

/// Width for a column of aligned one-line texts: at least [min], and wide
/// enough for the widest of [samples] at the current text scale and language.
/// At the default scale a column keeps [min] unless a sample is wider.
double textColumnWidth(
  BuildContext context,
  TextStyle? style,
  Iterable<String> samples, {
  double min = 0,
}) {
  final scaler = MediaQuery.textScalerOf(context);
  final direction = Directionality.of(context);
  var width = min;
  for (final sample in samples) {
    final painter = TextPainter(
      text: TextSpan(text: sample, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    // Round up so the last pixel of the glyphs never wraps.
    if (painter.width.ceilToDouble() > width) {
      width = painter.width.ceilToDouble();
    }
    painter.dispose();
  }
  return width;
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
        M3EIconButton(
          variant: M3EIconButtonVariant.standard,
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

/// Rounded card for a day or a list of rows, with the "today" border when
/// [isToday]. Rows inside are separated with [DividedRow].
class DayCard extends StatelessWidget {
  const DayCard({
    super.key,
    required this.child,
    this.isToday = false,
    this.padding,
    this.clip = false,
  });

  final Widget child;
  final bool isToday;
  final EdgeInsets? padding;

  /// Clips the rows to the rounded corners.
  final bool clip;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    clipBehavior: clip ? Clip.antiAlias : Clip.none,
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      border: isToday
          ? Border.all(color: context.shiftColors.today, width: 2)
          : null,
    ),
    child: child,
  );
}

/// A row in a [DayCard], divided from the one above by a hairline.
class DividedRow extends StatelessWidget {
  const DividedRow({
    super.key,
    required this.child,
    required this.minHeight,
    this.padding,
  });

  final Widget child;
  final double minHeight;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minHeight: minHeight),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: context.colors.outlineVariant)),
    ),
    padding: padding,
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
    this.previousTooltip,
    this.nextTooltip,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Default to "previous/next week"; the Export tab switches months.
  final String? previousTooltip;
  final String? nextTooltip;

  @override
  Widget build(BuildContext context) => Panel(
    radius: 28,
    padding: const EdgeInsets.all(4),
    color: context.colors.surfaceContainer,
    child: Row(
      children: [
        M3EIconButton(
          variant: M3EIconButtonVariant.standard,
          tooltip: previousTooltip ?? context.l10n.previousWeek,
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
        M3EIconButton(
          variant: M3EIconButtonVariant.standard,
          tooltip: nextTooltip ?? context.l10n.nextWeek,
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    ),
  );
}

/// Progress bar with a wavy filled part (Material 3 Expressive).
class WavyProgress extends StatelessWidget {
  const WavyProgress({super.key, required this.value, this.color});

  /// 0..1
  final double value;

  /// The wave's colour; the primary colour if null.
  final Color? color;

  @override
  Widget build(BuildContext context) => M3EProgressIndicator.linearWavy(
    value: value.clamp(0, 1),
    color: color ?? context.colors.primary,
    trackColor: context.colors.secondaryContainer,
  );
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

/// A tappable "time field" with a label above, e.g. "Start 17:30".
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

/// A small label above a big number, as on the month cards.
class Figure extends StatelessWidget {
  const Figure({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.text.labelMedium),
      Text(
        value,
        style: context.text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
          fontFeatures: tabularFigures,
        ),
      ),
    ],
  );
}
