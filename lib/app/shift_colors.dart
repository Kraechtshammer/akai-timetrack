import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Colours with one meaning each, on top of the theme's [ColorScheme]
/// (docs/02-design.md §8): recorded, not recorded, lunch, evening, and the
/// border that marks today.
///
/// Each role has a list of candidate seed colours. The first one that keeps
/// its distance on the colour wheel from the theme colour (and from the roles
/// picked before it) wins, so the roles never look like the theme colour.
/// This also works for the wallpaper-based "System color".
@immutable
class ShiftColors extends ThemeExtension<ShiftColors> {
  const ShiftColors({
    required this.recorded,
    required this.recordedContainer,
    required this.onRecordedContainer,
    required this.missed,
    required this.missedContainer,
    required this.onMissedContainer,
    required this.lunch,
    required this.onLunch,
    required this.evening,
    required this.onEvening,
    required this.today,
    this.picks = const {},
  });

  /// Recorded shifts: week bars, day circles, check icons, "Recorded" hours.
  final Color recorded;
  final Color recordedContainer;
  final Color onRecordedContainer;

  /// Shifts that ended without a recording.
  final Color missed;
  final Color missedContainer;
  final Color onMissedContainer;

  /// Lunch and evening shifts (Plan toggles and row labels).
  final Color lunch;
  final Color onLunch;
  final Color evening;
  final Color onEvening;

  /// The border around today (week strip, Plan, team planner).
  final Color today;

  /// The candidate chosen per role, by name. For tests.
  final Map<ShiftColorRole, String> picks;

  /// The colours for [scheme]. [today] overrides the today border, which is
  /// otherwise the scheme's primary colour.
  factory ShiftColors.forScheme(ColorScheme scheme, {Color? today}) {
    final b = scheme.brightness;
    final primaryHue = _hue(scheme.primary);
    final chosenHues = <double>[];
    final roles = <ShiftColorRole, (String, ColorScheme)>{};
    for (final role in ShiftColorRole.values) {
      (String, ColorScheme)? pick;
      (String, ColorScheme)? best;
      var bestScore = -1.0;
      for (final (name, seed) in role.candidates) {
        final s = _schemeOf(seed, b);
        final hue = _hue(s.primary);
        final score = [
          _distance(hue, primaryHue) / _minFromPrimary,
          for (final other in chosenHues) _distance(hue, other) / _minBetween,
        ].reduce((x, y) => x < y ? x : y);
        if (score > bestScore) {
          bestScore = score;
          best = (name, s);
        }
        if (score >= 1) {
          pick = (name, s);
          break;
        }
      }
      pick ??= best!;
      roles[role] = pick;
      chosenHues.add(_hue(pick.$2.primary));
    }
    final done = roles[ShiftColorRole.recorded]!.$2;
    final warn = roles[ShiftColorRole.missed]!.$2;
    final lunch = roles[ShiftColorRole.lunch]!.$2;
    final evening = roles[ShiftColorRole.evening]!.$2;
    return ShiftColors(
      recorded: done.primary,
      recordedContainer: done.primaryContainer,
      onRecordedContainer: done.onPrimaryContainer,
      missed: warn.primary,
      missedContainer: warn.primaryContainer,
      onMissedContainer: warn.onPrimaryContainer,
      lunch: lunch.primary,
      onLunch: lunch.onPrimary,
      evening: evening.primary,
      onEvening: evening.onPrimary,
      today: today ?? scheme.primary,
      picks: {for (final e in roles.entries) e.key: e.value.$1},
    );
  }

  /// Minimum hue distance (degrees) from the theme colour.
  static const _minFromPrimary = 30.0;

  /// Minimum hue distance (degrees) between two roles.
  static const _minBetween = 15.0;

  static final _schemes = <(int, Brightness), ColorScheme>{};

  static ColorScheme _schemeOf(Color seed, Brightness b) =>
      _schemes[(seed.toARGB32(), b)] ??= ColorScheme.fromSeed(
        seedColor: seed,
        brightness: b,
      );

  static double _hue(Color c) => perceptualHue(c);

  static double _distance(double a, double b) {
    final d = (a - b).abs() % 360;
    return d > 180 ? 360 - d : d;
  }

  @override
  ShiftColors copyWith({
    Color? recorded,
    Color? recordedContainer,
    Color? onRecordedContainer,
    Color? missed,
    Color? missedContainer,
    Color? onMissedContainer,
    Color? lunch,
    Color? onLunch,
    Color? evening,
    Color? onEvening,
    Color? today,
  }) => ShiftColors(
    recorded: recorded ?? this.recorded,
    recordedContainer: recordedContainer ?? this.recordedContainer,
    onRecordedContainer: onRecordedContainer ?? this.onRecordedContainer,
    missed: missed ?? this.missed,
    missedContainer: missedContainer ?? this.missedContainer,
    onMissedContainer: onMissedContainer ?? this.onMissedContainer,
    lunch: lunch ?? this.lunch,
    onLunch: onLunch ?? this.onLunch,
    evening: evening ?? this.evening,
    onEvening: onEvening ?? this.onEvening,
    today: today ?? this.today,
    picks: picks,
  );

  @override
  ShiftColors lerp(ShiftColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return ShiftColors(
      recorded: l(recorded, other.recorded),
      recordedContainer: l(recordedContainer, other.recordedContainer),
      onRecordedContainer: l(onRecordedContainer, other.onRecordedContainer),
      missed: l(missed, other.missed),
      missedContainer: l(missedContainer, other.missedContainer),
      onMissedContainer: l(onMissedContainer, other.onMissedContainer),
      lunch: l(lunch, other.lunch),
      onLunch: l(onLunch, other.onLunch),
      evening: l(evening, other.evening),
      onEvening: l(onEvening, other.onEvening),
      today: l(today, other.today),
      picks: t < 0.5 ? picks : other.picks,
    );
  }
}

/// The hue of [c] in degrees (0–360) in the OKLCH colour space. Unlike the
/// HSL hue, equal steps look like equal steps: in HSL the green theme's
/// yellow-green is 42° from sage, though the two look almost the same.
double perceptualHue(Color c) {
  double linear(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  double cbrt(double v) => math.pow(v, 1 / 3).toDouble();
  final r = linear(c.r), g = linear(c.g), b = linear(c.b);
  final l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
  final m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
  final s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
  final a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s;
  final bb = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s;
  final hue = math.atan2(bb, a) * 180 / math.pi;
  return hue < 0 ? hue + 360 : hue;
}

/// The roles of [ShiftColors], in the order they are picked.
enum ShiftColorRole {
  recorded([
    ('sage', Color(0xFF4C8C5A)),
    ('teal', Color(0xFF2E8C86)),
    ('aqua', Color(0xFF2A8AA0)),
  ]),
  missed([('honey', Color(0xFFE0A030)), ('mustard', Color(0xFFB8A030))]),
  lunch([
    ('apricot', Color(0xFF845326)),
    ('rose', Color(0xFFA04860)),
    ('sun', Color(0xFFB89A2A)),
  ]),
  evening([
    ('periwinkle', Color(0xFF5B6BB5)),
    ('plum', Color(0xFF7E4F8E)),
    ('steel blue', Color(0xFF3F79A8)),
  ]);

  const ShiftColorRole(this.candidates);

  /// Candidate seed colours, most preferred first.
  final List<(String, Color)> candidates;
}
