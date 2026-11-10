import '../core/time.dart';
import '../domain/rounding.dart';
import 'database.dart' show TeamShift;

enum ThemeSeed { system, akaiRed, terracotta, blue, green, violet }

enum AppThemeMode { system, light, dark }

/// How the week strip on the Home tab marks lunch and evening shifts.
enum WeekMarkStyle { icons, bars }

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

/// The restaurant's open shifts, and for the team planner the staff needed
/// per weekday and shift by default (F11). 0 means the shift is closed.
/// See docs/02-design.md §3, §4.1 and §4.9.
class StaffNeeds {
  /// [values]: 14 numbers, Monday lunch, Monday evening, … Sunday evening.
  const StaffNeeds(this.values);

  /// The week of a typical small restaurant: closed on Monday, open for
  /// lunch and evening on the other days, with [openDefault] staff.
  static const standard = StaffNeeds([
    0,
    0,
    2,
    3,
    2,
    3,
    2,
    3,
    2,
    3,
    2,
    3,
    2,
    3,
  ]);

  /// Staff needed when a shift is switched open: 2 at lunch, 3 in the
  /// evening.
  static int openDefault(TeamShift shift) => switch (shift) {
    TeamShift.lunch => 2,
    TeamShift.evening => 3,
  };

  final List<int> values;

  /// [weekday]: `DateTime.monday` … `DateTime.sunday`.
  int needed(int weekday, TeamShift shift) =>
      values[(weekday - 1) * 2 + shift.index];

  bool isOpen(int weekday, TeamShift shift) => needed(weekday, shift) > 0;

  StaffNeeds withNeeded(int weekday, TeamShift shift, int needed) =>
      StaffNeeds([...values]..[(weekday - 1) * 2 + shift.index] = needed);

  /// The switch view of the counts: closed is 0, open is [openDefault].
  /// An open shift stays at its count.
  StaffNeeds withOpen(int weekday, TeamShift shift, bool open) =>
      open == isOpen(weekday, shift)
      ? this
      : withNeeded(weekday, shift, open ? openDefault(shift) : 0);

  /// Parses `2,3;2,3;…` (seven days of `lunch,evening`).
  static StaffNeeds? parse(String? text) {
    final days = text?.split(';');
    if (days == null || days.length != 7) return null;
    final values = <int>[];
    for (final day in days) {
      final pair = day.split(',').map(int.tryParse).toList();
      if (pair.length != 2 || pair.any((n) => n == null || n < 0)) return null;
      values.addAll(pair.cast<int>());
    }
    return StaffNeeds(values);
  }

  @override
  String toString() =>
      [for (var d = 0; d < 7; d++) '${values[d * 2]},${values[d * 2 + 1]}']
          .join(';');

  @override
  bool operator ==(Object other) =>
      other is StaffNeeds && other.toString() == toString();

  @override
  int get hashCode => toString().hashCode;
}

/// Team planner: the normal start of lunch and evening (F11).
class TeamStarts {
  const TeamStarts(this.lunch, this.evening);

  final Minutes lunch;
  final Minutes evening;

  Minutes of(TeamShift shift) => switch (shift) {
    TeamShift.lunch => lunch,
    TeamShift.evening => evening,
  };

  TeamStarts withStart(TeamShift shift, Minutes start) => switch (shift) {
    TeamShift.lunch => TeamStarts(start, evening),
    TeamShift.evening => TeamStarts(lunch, start),
  };

  /// Parses `HH:mm,HH:mm`.
  static TeamStarts? parse(String? text) {
    final parts = text?.split(',');
    if (parts == null || parts.length != 2) return null;
    final lunch = ShiftTimes._parseHm(parts[0]);
    final evening = ShiftTimes._parseHm(parts[1]);
    return lunch == null || evening == null ? null : TeamStarts(lunch, evening);
  }

  @override
  String toString() => '${minutesToHhmm(lunch)},${minutesToHhmm(evening)}';
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
    this.themeSeed = ThemeSeed.akaiRed,
    this.themeMode = AppThemeMode.system,
    this.weekMarks = WeekMarkStyle.icons,
    this.locale,
    this.onboardingDone = false,
    this.autostartConfirmed = false,
    this.appIconChosen = false,
    this.teamPlanner = false,
    this.tipPool = false,
    this.teamStaffNeeded = StaffNeeds.standard,
    this.teamStarts = const TeamStarts(12 * 60, 17 * 60 + 30),
    this.restaurant = '',
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
  final ThemeSeed themeSeed;
  final AppThemeMode themeMode;
  final WeekMarkStyle weekMarks;

  /// `de`, `en` or null for the phone's language.
  final String? locale;
  final bool onboardingDone;

  /// Xiaomi: the user said Autostart is allowed (Android can't tell us).
  final bool autostartConfirmed;

  /// The launcher icon was set once (Xiaomi: squircle). The chosen variant
  /// itself lives in Android's package manager, see AppIcons.
  final bool appIconChosen;

  /// Team planner (F11): shows the fifth tab.
  final bool teamPlanner;

  /// "Daily pool": the pool card on the Pay tab and the "Add the tips"
  /// prompt on Home. Off on a fresh install, on for installs from 1.5.0
  /// and earlier (see fromMap).
  final bool tipPool;

  /// Team planner: staff needed per weekday and shift by default.
  final StaffNeeds teamStaffNeeded;

  /// Team planner: the normal start of lunch and evening.
  final TeamStarts teamStarts;

  /// Where the user works, '' if not set. Shown in the calendar events,
  /// the export and the team plan picture; "AKAI" also offers the AKAI
  /// sign icon (see `isAkaiRestaurant`).
  final String restaurant;

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
      themeSeed: pick(ThemeSeed.values, 'themeSeed', d.themeSeed),
      themeMode: pick(AppThemeMode.values, 'themeMode', d.themeMode),
      weekMarks: pick(WeekMarkStyle.values, 'weekMarks', d.weekMarks),
      locale: m['locale'],
      onboardingDone: m['onboardingDone'] == 'true',
      autostartConfirmed: m['autostartConfirmed'] == 'true',
      appIconChosen: m['appIconChosen'] == 'true',
      teamPlanner: m['teamPlanner'] == 'true',
      // Installs from before the switch (1.5.0 and earlier) had the pool;
      // a fresh install starts without it.
      tipPool: (m['tipPool'] ?? m['onboardingDone']) == 'true',
      teamStaffNeeded:
          StaffNeeds.parse(m['teamStaffNeeded']) ?? d.teamStaffNeeded,
      teamStarts: TeamStarts.parse(m['teamStarts']) ?? d.teamStarts,
      // Installs from before the setting (1.4.1 and earlier) were all at
      // AKAI; a fresh install asks in the setup.
      restaurant:
          m['restaurant'] ??
          (m['onboardingDone'] == 'true' ? 'AKAI' : d.restaurant),
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
    'themeSeed': themeSeed.name,
    'themeMode': themeMode.name,
    'weekMarks': weekMarks.name,
    'locale': locale,
    'onboardingDone': '$onboardingDone',
    'autostartConfirmed': '$autostartConfirmed',
    'appIconChosen': '$appIconChosen',
    'teamPlanner': '$teamPlanner',
    'tipPool': '$tipPool',
    'teamStaffNeeded': '$teamStaffNeeded',
    'teamStarts': '$teamStarts',
    'restaurant': restaurant,
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
    ThemeSeed? themeSeed,
    AppThemeMode? themeMode,
    WeekMarkStyle? weekMarks,
    String? Function()? locale,
    bool? onboardingDone,
    bool? autostartConfirmed,
    bool? appIconChosen,
    bool? teamPlanner,
    bool? tipPool,
    StaffNeeds? teamStaffNeeded,
    TeamStarts? teamStarts,
    String? restaurant,
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
    themeSeed: themeSeed ?? this.themeSeed,
    themeMode: themeMode ?? this.themeMode,
    weekMarks: weekMarks ?? this.weekMarks,
    locale: locale != null ? locale() : this.locale,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    autostartConfirmed: autostartConfirmed ?? this.autostartConfirmed,
    appIconChosen: appIconChosen ?? this.appIconChosen,
    teamPlanner: teamPlanner ?? this.teamPlanner,
    tipPool: tipPool ?? this.tipPool,
    teamStaffNeeded: teamStaffNeeded ?? this.teamStaffNeeded,
    teamStarts: teamStarts ?? this.teamStarts,
    restaurant: restaurant ?? this.restaurant,
  );
}
