import 'package:material_ui/material_ui.dart';

import '../data/app_settings.dart';

/// Seed colors the user can choose. "AKAI-Rot" is the default.
const seedColors = {
  ThemeSeed.akaiRed: Color(0xFFC62828),
  ThemeSeed.terracotta: Color(0xFF8F4C38),
  ThemeSeed.blue: Color(0xFF415F91),
  ThemeSeed.green: Color(0xFF4C662B),
  ThemeSeed.violet: Color(0xFF65558F),
};

/// The color scheme for the chosen seed. "Systemfarbe" uses the phone's
/// wallpaper colors ([dynamicScheme], Android 12+) when available.
ColorScheme schemeFor(
  ThemeSeed seed,
  Brightness brightness,
  ColorScheme? dynamicScheme,
) {
  if (seed == ThemeSeed.system && dynamicScheme != null) return dynamicScheme;
  return ColorScheme.fromSeed(
    seedColor: seedColors[seed] ?? seedColors[ThemeSeed.akaiRed]!,
    brightness: brightness,
    // The default "tonal spot" scheme mutes the seed; AKAI-Rot should stay
    // a clear red. "Vibrant" keeps it colorful but still gives calm dark
    // containers and warm (not complementary) accents.
    dynamicSchemeVariant: seed == ThemeSeed.akaiRed
        ? DynamicSchemeVariant.vibrant
        : DynamicSchemeVariant.tonalSpot,
  );
}

ThemeData buildTheme(ColorScheme scheme) => ThemeData(
  colorScheme: scheme,
  // Material 3 Expressive where Flutter already supports it (icon buttons).
  iconButtonTheme: const IconButtonThemeData(
    variant: StyleVariant.material3Expressive,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: scheme.surfaceContainer,
    indicatorColor: scheme.secondaryContainer,
  ),
  snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
);

ThemeMode themeModeFor(AppThemeMode mode) => switch (mode) {
  AppThemeMode.system => ThemeMode.system,
  AppThemeMode.light => ThemeMode.light,
  AppThemeMode.dark => ThemeMode.dark,
};
