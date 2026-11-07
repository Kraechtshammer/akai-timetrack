import '../ui/material.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import '../domain/rounding.dart';
import '../platform/app_icon.dart';
import 'app_localizations.dart';

/// Translated names for enum values.

String shiftTypeLabel(ShiftType type, AppLocalizations l10n) => switch (type) {
  ShiftType.lunch => l10n.shiftLunch,
  ShiftType.evening => l10n.shiftEvening,
  ShiftType.custom => l10n.shiftCustom,
};

IconData shiftTypeIcon(ShiftType type) => switch (type) {
  ShiftType.lunch => Icons.light_mode,
  ShiftType.evening => Icons.dark_mode,
  ShiftType.custom => Icons.schedule,
};

String roundingLabel(RoundingMode mode, AppLocalizations l10n) =>
    switch (mode) {
      RoundingMode.nearestQuarter => l10n.roundingNearest,
      RoundingMode.inFavour => l10n.roundingInFavour,
      RoundingMode.strict => l10n.roundingStrict,
    };

String iconDesignLabel(IconDesign design, AppLocalizations l10n) =>
    switch (design) {
      IconDesign.cloche => l10n.appIconCloche,
      IconDesign.akai => l10n.appIconAkai,
      IconDesign.penguinBlack => l10n.appIconPenguinBlack,
      IconDesign.penguinNavy => l10n.appIconPenguinNavy,
    };

String iconShapeLabel(IconShape shape, AppLocalizations l10n) =>
    switch (shape) {
      IconShape.round => l10n.appIconRound,
      IconShape.squircle => l10n.appIconSquircle,
      IconShape.small => l10n.appIconSmall,
    };

String weekMarksLabel(WeekMarkStyle style, AppLocalizations l10n) =>
    switch (style) {
      WeekMarkStyle.icons => l10n.weekMarksIcons,
      WeekMarkStyle.bars => l10n.weekMarksBars,
    };

/// The red is called "AKAI red" only when the restaurant is AKAI.
String themeSeedLabel(
  ThemeSeed seed,
  AppLocalizations l10n, {
  required String restaurant,
}) => switch (seed) {
  ThemeSeed.system => l10n.colorSystem,
  ThemeSeed.akaiRed =>
    isAkaiRestaurant(restaurant) ? l10n.colorAkai : l10n.colorRed,
  ThemeSeed.terracotta => l10n.colorTerracotta,
  ThemeSeed.blue => l10n.colorBlue,
  ThemeSeed.green => l10n.colorGreen,
  ThemeSeed.violet => l10n.colorViolet,
};

String themeModeLabel(AppThemeMode mode, AppLocalizations l10n) =>
    switch (mode) {
      AppThemeMode.system => l10n.themeSystem,
      AppThemeMode.light => l10n.themeLight,
      AppThemeMode.dark => l10n.themeDark,
    };

/// Names of Google Calendar's event colors by their key ("1".."11").
String? googleEventColorName(String key, AppLocalizations l10n) =>
    switch (key) {
      '1' => l10n.gcolLavender,
      '2' => l10n.gcolSage,
      '3' => l10n.gcolGrape,
      '4' => l10n.gcolFlamingo,
      '5' => l10n.gcolBanana,
      '6' => l10n.gcolTangerine,
      '7' => l10n.gcolPeacock,
      '8' => l10n.gcolGraphite,
      '9' => l10n.gcolBlueberry,
      '10' => l10n.gcolBasil,
      '11' => l10n.gcolTomato,
      _ => null,
    };
