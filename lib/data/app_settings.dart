import '../core/time.dart';
import '../domain/rounding.dart';

enum ThemeSeed { system, akaiRed, blue, green, violet }

enum AppThemeMode { system, light, dark }

/// Default start and end of a shift type, in minutes after midnight.
class ShiftTimes {
  const ShiftTimes(this.start, this.end);

  final Minutes start;
  final Minutes end;

  /// Parses `HH:mm-HH:mm`.
  static ShiftTimes? parse(String? text) {
    final parts = text?.split('-');
    if (parts == null || parts.length != 2) return null;
    final start = _parseHm(parts[0]);
    final end = _parseHm(parts[1]);
    return start == null || end == null ? null : ShiftTimes(start, end);
  }

  @override
  String toString() => '${minutesToHhmm(start)}-${minutesToHhmm(end)}';

  static Minutes? _parseHm(String text) {
    final hm = text.split(':').map(int.tryParse).toList();
    if (hm.length != 2 || hm[0] == null || hm[1] == null) return null;
    return hm[0]! * 60 + hm[1]!;
  }
}

/// All settings, with their defaults. Stored as text in the settings table.
class AppSettings {
  const AppSettings({
    this.lunch = const ShiftTimes(12 * 60, 16 * 60),
    this.lunchBeforeEvening = const ShiftTimes(12 * 60, 15 * 60 + 30),
    this.evening = const ShiftTimes(17 * 60 + 30, 23 * 60),
    this.reminderLeadMinutes = 15,
    this.overrunMinutes = 30,
    this.roundingMode = RoundingMode.nearestQuarter,
    this.calendarId,
    this.calendarName,
    this.eventTitle = 'Kellnern',
    this.eventColorKey,
    this.eventColor,
    this.exportMonthTotals = true,
    this.themeSeed = ThemeSeed.akaiRed,
    this.themeMode = AppThemeMode.system,
    this.locale,
    this.onboardingDone = false,
    this.autostartConfirmed = false,
  });

  final ShiftTimes lunch;
  final ShiftTimes lunchBeforeEvening;
  final ShiftTimes evening;
  final int reminderLeadMinutes;

  /// "Still working?" this long after the planned end.
  final int overrunMinutes;
  final RoundingMode roundingMode;

  /// null = no calendar sync.
  final String? calendarId;
  final String? calendarName;
  final String eventTitle;

  /// null = the calendar's own color.
  final String? eventColorKey;
  final int? eventColor;
  final bool exportMonthTotals;
  final ThemeSeed themeSeed;
  final AppThemeMode themeMode;

  /// `de`, `en` or null for the phone's language.
  final String? locale;
  final bool onboardingDone;

  /// Xiaomi: the user said Autostart is allowed (Android can't tell us).
  final bool autostartConfirmed;

  /// Reads settings from the stored key-value pairs. Unknown or broken
  /// values fall back to the defaults.
  factory AppSettings.fromMap(Map<String, String> m) {
    const d = AppSettings();
    T pick<T extends Enum>(List<T> values, String key, T fallback) =>
        values.asNameMap()[m[key]] ?? fallback;
    return AppSettings(
      lunch: ShiftTimes.parse(m['lunch']) ?? d.lunch,
      lunchBeforeEvening:
          ShiftTimes.parse(m['lunchBeforeEvening']) ?? d.lunchBeforeEvening,
      evening: ShiftTimes.parse(m['evening']) ?? d.evening,
      reminderLeadMinutes:
          int.tryParse(m['reminderLeadMinutes'] ?? '') ?? d.reminderLeadMinutes,
      overrunMinutes:
          int.tryParse(m['overrunMinutes'] ?? '') ?? d.overrunMinutes,
      roundingMode: pick(RoundingMode.values, 'roundingMode', d.roundingMode),
      calendarId: m['calendarId'],
      calendarName: m['calendarName'],
      eventTitle: m['eventTitle'] ?? d.eventTitle,
      eventColorKey: m['eventColorKey'],
      eventColor: int.tryParse(m['eventColor'] ?? ''),
      exportMonthTotals: m['exportMonthTotals'] != 'false',
      themeSeed: pick(ThemeSeed.values, 'themeSeed', d.themeSeed),
      themeMode: pick(AppThemeMode.values, 'themeMode', d.themeMode),
      locale: m['locale'],
      onboardingDone: m['onboardingDone'] == 'true',
      autostartConfirmed: m['autostartConfirmed'] == 'true',
    );
  }

  /// The stored form. A null value removes the key.
  Map<String, String?> toMap() => {
    'lunch': '$lunch',
    'lunchBeforeEvening': '$lunchBeforeEvening',
    'evening': '$evening',
    'reminderLeadMinutes': '$reminderLeadMinutes',
    'overrunMinutes': '$overrunMinutes',
    'roundingMode': roundingMode.name,
    'calendarId': calendarId,
    'calendarName': calendarName,
    'eventTitle': eventTitle,
    'eventColorKey': eventColorKey,
    'eventColor': eventColor?.toString(),
    'exportMonthTotals': '$exportMonthTotals',
    'themeSeed': themeSeed.name,
    'themeMode': themeMode.name,
    'locale': locale,
    'onboardingDone': '$onboardingDone',
    'autostartConfirmed': '$autostartConfirmed',
  };

  /// Copy with some values changed. Nullable values are wrapped in a
  /// function (`calendarId: () => null`) so they can be set back to null.
  AppSettings copyWith({
    ShiftTimes? lunch,
    ShiftTimes? lunchBeforeEvening,
    ShiftTimes? evening,
    int? reminderLeadMinutes,
    int? overrunMinutes,
    RoundingMode? roundingMode,
    String? Function()? calendarId,
    String? Function()? calendarName,
    String? eventTitle,
    String? Function()? eventColorKey,
    int? Function()? eventColor,
    bool? exportMonthTotals,
    ThemeSeed? themeSeed,
    AppThemeMode? themeMode,
    String? Function()? locale,
    bool? onboardingDone,
    bool? autostartConfirmed,
  }) => AppSettings(
    lunch: lunch ?? this.lunch,
    lunchBeforeEvening: lunchBeforeEvening ?? this.lunchBeforeEvening,
    evening: evening ?? this.evening,
    reminderLeadMinutes: reminderLeadMinutes ?? this.reminderLeadMinutes,
    overrunMinutes: overrunMinutes ?? this.overrunMinutes,
    roundingMode: roundingMode ?? this.roundingMode,
    calendarId: calendarId != null ? calendarId() : this.calendarId,
    calendarName: calendarName != null ? calendarName() : this.calendarName,
    eventTitle: eventTitle ?? this.eventTitle,
    eventColorKey: eventColorKey != null ? eventColorKey() : this.eventColorKey,
    eventColor: eventColor != null ? eventColor() : this.eventColor,
    exportMonthTotals: exportMonthTotals ?? this.exportMonthTotals,
    themeSeed: themeSeed ?? this.themeSeed,
    themeMode: themeMode ?? this.themeMode,
    locale: locale != null ? locale() : this.locale,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    autostartConfirmed: autostartConfirmed ?? this.autostartConfirmed,
  );
}
