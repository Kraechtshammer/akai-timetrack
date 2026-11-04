// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'TimeTrack';

  @override
  String get tabToday => 'Heute';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabExport => 'Export';

  @override
  String get settings => 'Einstellungen';

  @override
  String get back => 'Zurück';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get ok => 'OK';

  @override
  String get next => 'Weiter';

  @override
  String get skip => 'Überspringen';

  @override
  String get later => 'Später';

  @override
  String get done => 'Erledigt';

  @override
  String get open => 'Öffnen';

  @override
  String get allow => 'Erlauben';

  @override
  String get allowed => 'Erlaubt';

  @override
  String get undo => 'Rückgängig';

  @override
  String get today => 'Heute';

  @override
  String get shiftLunch => 'Mittag';

  @override
  String get shiftEvening => 'Abend';

  @override
  String get shiftCustom => 'Individuell';

  @override
  String get statusPlanned => 'geplant';

  @override
  String get statusRecorded => 'erfasst';

  @override
  String get statusMissed => 'nicht erfasst';

  @override
  String get statusRunning => 'läuft';

  @override
  String hours(String hours) {
    return '$hours h';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get nextShift => 'Nächste Schicht';

  @override
  String startsInMinutes(int minutes) {
    return 'in $minutes min';
  }

  @override
  String startsAt(String time) {
    return 'um $time';
  }

  @override
  String get runningNow => 'läuft gerade';

  @override
  String reminderAt(String time) {
    return 'Erinnerung um $time';
  }

  @override
  String get noShiftPlanned => 'Keine Schicht geplant';

  @override
  String get noShiftPlannedHint =>
      'Plane Schichten im Tab „Plan“ oder starte die Erfassung trotzdem.';

  @override
  String get startAnyway => 'Trotzdem starten';

  @override
  String get startRecording => 'Erfassung starten';

  @override
  String get stopRecording => 'Erfassung beenden';

  @override
  String get recordingRunning => 'Erfassung läuft';

  @override
  String recordingStarted(String start, String rounded) {
    return 'Gestartet $start · gerechnet ab $rounded';
  }

  @override
  String plannedEndAt(String time) {
    return 'Geplantes Ende $time';
  }

  @override
  String get changeStart => 'Startzeit ändern';

  @override
  String get ifStoppedNow => 'Wenn du jetzt beendest';

  @override
  String get roundedHint => 'auf Viertelstunden gerundet';

  @override
  String get monthAsOfToday => 'Stand heute';

  @override
  String get monthRecorded => 'Erfasst';

  @override
  String get monthExpected => 'Geplant (inkl. erfasst)';

  @override
  String monthProgress(int percent, String hours, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count geplanten Schichten',
      one: '1 geplanten Schicht',
    );
    return '$percent % erfasst · noch $hours h in $_temp0';
  }

  @override
  String get monthRunningHint => 'Die laufende Schicht zählt nach dem Beenden.';

  @override
  String missedShifts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schichten nicht erfasst',
      one: '1 Schicht nicht erfasst',
    );
    return '$_temp0';
  }

  @override
  String thisWeek(int week) {
    return 'Diese Woche · KW $week';
  }

  @override
  String get toPlan => 'Zum Plan';

  @override
  String get weekLegend => 'M Mittag · A Abend · gefüllt = erfasst';

  @override
  String get lunchLetter => 'M';

  @override
  String get eveningLetter => 'A';

  @override
  String get dayOff => 'frei';

  @override
  String get planSubtitle => 'Tippe Mittag oder Abend zum Planen';

  @override
  String weekLabel(int week) {
    return 'KW $week';
  }

  @override
  String weekRecorded(String hours) {
    return '$hours h erfasst';
  }

  @override
  String weekTotal(String hours) {
    return 'Woche: $hours h';
  }

  @override
  String get previousWeek => 'Vorherige Woche';

  @override
  String get nextWeek => 'Nächste Woche';

  @override
  String get currentWeek => 'Zur aktuellen Woche';

  @override
  String get noShift => 'Keine Schicht';

  @override
  String get addCustomShift => 'Individuelle Schicht hinzufügen';

  @override
  String get recordedNotRemovable =>
      'Diese Schicht ist erfasst. Zum Löschen bitte öffnen.';

  @override
  String get shiftDeleted => 'Schicht gelöscht';

  @override
  String get newShift => 'Neue Schicht';

  @override
  String get planned => 'Geplant';

  @override
  String get actual => 'Tatsächlich';

  @override
  String get start => 'Beginn';

  @override
  String get end => 'Ende';

  @override
  String get pause => 'Pause';

  @override
  String get pauseNone => 'Keine';

  @override
  String get pauseOther => 'Andere';

  @override
  String get pauseOtherTitle => 'Pause in Minuten';

  @override
  String recordedRaw(String from, String to) {
    return 'Aufgezeichnet $from – $to, auf Viertelstunden gerundet';
  }

  @override
  String get takePlanned => 'Wie geplant übernehmen';

  @override
  String get removeActual => 'Erfassung entfernen';

  @override
  String get workingTime => 'Arbeitszeit';

  @override
  String get notRecordedYet => 'Noch nicht erfasst';

  @override
  String get endsNextDay => 'Endet am nächsten Tag';

  @override
  String calendarInfo(String calendar, String title) {
    return 'Kalender „$calendar“ · „$title“';
  }

  @override
  String get deleteRecordedTitle => 'Erfasste Schicht löschen?';

  @override
  String get deleteRecordedBody =>
      'Die erfasste Arbeitszeit geht dabei verloren.';

  @override
  String get startMustBeBeforeEnd => 'Das Ende muss nach dem Beginn liegen.';

  @override
  String get exportSubtitle => 'Arbeitszeiten der Woche als Text';

  @override
  String get weekTotalLabel => 'Woche gesamt';

  @override
  String shiftsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schichten',
      one: '1 Schicht',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'an $count Tagen',
      one: 'an 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get preview => 'Vorschau';

  @override
  String get appendMonthTotals => 'Monatssummen anhängen';

  @override
  String weekSpansMonths(String first, String second) {
    return 'Die Woche umfasst $first und $second';
  }

  @override
  String get copy => 'Kopieren';

  @override
  String get copied => 'Kopiert';

  @override
  String get share => 'Teilen';

  @override
  String get missedNotExported => 'Nicht erfasste Schichten fehlen im Text.';

  @override
  String exportHeader(int week, String from, String to) {
    return 'Arbeitszeiten KW $week ($from–$to)';
  }

  @override
  String get exportDayPattern => 'dd.MM.';

  @override
  String get exportDateWithYearPattern => 'dd.MM.yyyy';

  @override
  String exportBreak(int minutes) {
    return '$minutes min Pause';
  }

  @override
  String exportWeekTotal(String hours) {
    return 'Woche gesamt: $hours h';
  }

  @override
  String exportMonthTotal(String month, String hours) {
    return '$month gesamt: $hours h';
  }

  @override
  String exportMonthSoFar(String month, String hours) {
    return '$month bisher: $hours h';
  }

  @override
  String get reliabilityTitle => 'Damit Erinnerungen zuverlässig kommen';

  @override
  String get reliabilityBody => 'Ein paar Einstellungen fehlen noch.';

  @override
  String get permNotifications => 'Benachrichtigungen';

  @override
  String get permNotificationsHint => 'Für Erinnerungen und den Timer';

  @override
  String get permExact => 'Exakte Erinnerungen';

  @override
  String get permExactHint =>
      'Sonst kann die Erinnerung ein paar Minuten zu spät kommen';

  @override
  String get permBattery => 'Akku: Keine Einschränkungen';

  @override
  String get permBatteryHint =>
      'Damit Erinnerungen und die Knöpfe in den Benachrichtigungen sofort reagieren';

  @override
  String get permAutostart => 'Autostart erlauben';

  @override
  String get permAutostartHint =>
      'Damit Erinnerungen auch nach einem Neustart wieder eingeplant werden';

  @override
  String get sectionCalendar => 'Kalender';

  @override
  String get calendar => 'Kalender';

  @override
  String get calendarNone => 'Kein Kalender';

  @override
  String get calendarNoneHint =>
      'Schichten werden nicht in einen Kalender übertragen.';

  @override
  String get calendarPermissionMissing => 'Kalenderzugriff fehlt';

  @override
  String get eventTitle => 'Termin-Titel';

  @override
  String get eventColor => 'Termin-Farbe';

  @override
  String get eventColorHint =>
      'Gilt für alle Schichten im Kalender. Wer den Kalender mit dir teilt, sieht diese Farbe auch.';

  @override
  String get colorOfCalendar => 'Kalenderfarbe';

  @override
  String colorWithKey(String key) {
    return 'Farbe $key';
  }

  @override
  String get previewInCalendar => 'Vorschau im Kalender';

  @override
  String get apply => 'Übernehmen';

  @override
  String get sectionDefaultTimes => 'Standard-Schichtzeiten';

  @override
  String get lunchBeforeEvening => 'Mittag vor Abendschicht';

  @override
  String get sectionReminders => 'Erinnerungen';

  @override
  String get reminderBefore => 'Vor Schichtbeginn';

  @override
  String minutesBefore(int minutes) {
    return '$minutes Minuten vorher';
  }

  @override
  String get overrunAsk => 'Nachfragen, wenn nicht beendet';

  @override
  String minutesAfterEnd(int minutes) {
    return '$minutes Minuten nach geplantem Ende';
  }

  @override
  String get sectionRecording => 'Erfassung & Export';

  @override
  String get rounding => 'Rundung';

  @override
  String get roundingNearest => 'Auf nächste Viertelstunde';

  @override
  String get roundingInFavour => 'Beginn ab-, Ende aufrunden';

  @override
  String get roundingStrict => 'Beginn auf-, Ende abrunden';

  @override
  String get monthTotalsInExport => 'Monatssummen im Export';

  @override
  String get monthTotalsHint => 'Hängt die Monatsstunden an';

  @override
  String get sectionAppearance => 'Darstellung & Sprache';

  @override
  String get color => 'Farbe';

  @override
  String get colorSystem => 'Systemfarbe';

  @override
  String get colorAkai => 'AKAI-Rot';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorGreen => 'Grün';

  @override
  String get colorViolet => 'Violett';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Wie im System';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get welcomeTitle => 'Willkommen bei\nTimeTrack';

  @override
  String get welcomeBody =>
      'Schichten planen, Arbeitszeit mit einem Tipp erfassen und die Stunden der Woche als Text teilen.';

  @override
  String get letsGo => 'Los geht’s';

  @override
  String get remindersTitle => 'Pünktlich erinnert';

  @override
  String get remindersBody =>
      'Vor jeder Schicht kommt eine Erinnerung, mit der du die Erfassung direkt startest.';

  @override
  String get calendarTitle => 'Welcher Kalender?';

  @override
  String get calendarBody =>
      'Deine Schichten erscheinen dort als Termine. Andere Termine im Kalender bleiben unberührt.';

  @override
  String get calendarTip =>
      'Neue Google-Kalender lassen sich nur im Browser anlegen und teilen.';

  @override
  String get openGoogleCalendar => 'calendar.google.com öffnen';

  @override
  String get continueWithoutCalendar => 'Ohne Kalender fortfahren';

  @override
  String get calendarAccessNeeded =>
      'Für die Kalenderauswahl braucht die App Zugriff auf deine Kalender.';

  @override
  String get noCalendars =>
      'Keine beschreibbaren Kalender gefunden. Ist ein Google-Konto auf dem Handy eingerichtet?';

  @override
  String get xiaomiTitle => 'Noch zwei Handgriffe';

  @override
  String get xiaomiBody =>
      'Xiaomi-Handys beenden Apps im Hintergrund sehr gründlich. Ohne diese Einstellungen können Erinnerungen ausbleiben.';

  @override
  String get xiaomiNote =>
      'Wird nur auf Xiaomi-, Redmi- und POCO-Handys angezeigt. Später auch in den Einstellungen.';

  @override
  String get timesTitle => 'Deine Schichtzeiten';

  @override
  String get timesBody =>
      'Passen die Standardzeiten? Du kannst sie jederzeit in den Einstellungen ändern.';

  @override
  String get finish => 'Fertig';

  @override
  String stepOf(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get channelReminders => 'Erinnerungen';

  @override
  String get channelRecording => 'Laufende Erfassung';

  @override
  String get channelOverrun => 'Nachfragen';

  @override
  String notifStartTitle(int minutes) {
    return 'Schicht beginnt in $minutes min';
  }

  @override
  String notifShiftBody(String type, String from, String to) {
    return '$type · $from – $to';
  }

  @override
  String notifRunningBody(String type, String since, String until) {
    return '$type · seit $since · geplant bis $until';
  }

  @override
  String get notifOverrunTitle => 'Noch bei der Arbeit?';

  @override
  String notifOverrunBody(String time) {
    return 'Geplantes Ende war $time. Die Erfassung läuft noch.';
  }

  @override
  String get actionStart => 'Erfassung starten';

  @override
  String get actionLater => 'Später';

  @override
  String get actionStop => 'Beenden';

  @override
  String actionEndAt(String time) {
    return 'Ende $time';
  }

  @override
  String get actionStopNow => 'Jetzt beenden';

  @override
  String get actionKeepGoing => 'Weiter';

  @override
  String calPlanned(String times) {
    return 'Geplant: $times';
  }

  @override
  String calRecorded(String times, String hours) {
    return 'Erfasst: $times ($hours h)';
  }

  @override
  String get calManaged =>
      'Wird von TimeTrack verwaltet – bitte in der App ändern.';

  @override
  String get gcolLavender => 'Lavendel';

  @override
  String get gcolSage => 'Salbei';

  @override
  String get gcolGrape => 'Weintraube';

  @override
  String get gcolFlamingo => 'Flamingo';

  @override
  String get gcolBanana => 'Banane';

  @override
  String get gcolTangerine => 'Mandarine';

  @override
  String get gcolPeacock => 'Pfau';

  @override
  String get gcolGraphite => 'Graphit';

  @override
  String get gcolBlueberry => 'Heidelbeere';

  @override
  String get gcolBasil => 'Basilikum';

  @override
  String get gcolTomato => 'Tomate';
}
