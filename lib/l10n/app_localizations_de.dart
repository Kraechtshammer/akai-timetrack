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
  String get tabHome => 'Start';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabExport => 'Export';

  @override
  String get tabPay => 'Lohn';

  @override
  String get paySubtitle => 'Monatslohn und Trinkgeld';

  @override
  String get tips => 'Trinkgeld';

  @override
  String tipsMonthWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'aus $count Wochen',
      one: 'aus 1 Woche',
      zero: 'noch nichts ausgezahlt',
    );
    return '$_temp0';
  }

  @override
  String get tipPayout => 'Ausgezahlt';

  @override
  String get tipPayoutHint => 'Was du für diese Woche bar bekommen hast';

  @override
  String tipPayoutTitle(int week) {
    return 'Ausgezahlt · KW $week';
  }

  @override
  String get tipPool => 'Tagestopf';

  @override
  String get tipPoolHint => 'Trinkgeld aller zusammen an diesem Tag';

  @override
  String tipPoolTitle(String day) {
    return 'Tagestopf · $day';
  }

  @override
  String get tipPoolSum => 'Zusammen';

  @override
  String get tipNoWorkdays => 'Diese Woche keine Schichten.';

  @override
  String get tipEnter => 'Eintragen';

  @override
  String get tipInvalid => 'Bitte einen Betrag wie 42,50 eingeben.';

  @override
  String get tipDeleted => 'Betrag gelöscht';

  @override
  String get tipPromptTitle => 'Trinkgeld eintragen';

  @override
  String get tipPromptToday =>
      'Wie viel Trinkgeld kam heute insgesamt zusammen?';

  @override
  String get tipPromptYesterday =>
      'Wie viel Trinkgeld kam gestern insgesamt zusammen?';

  @override
  String get tipNotNow => 'Nicht jetzt';

  @override
  String get paySalary => 'Lohn';

  @override
  String get payExpectedSalary => 'Erwarteter Lohn';

  @override
  String get payTotal => 'Gesamt';

  @override
  String get payWithTips => 'mit Trinkgeld';

  @override
  String get payEarned => 'Verdient';

  @override
  String get payExpected => 'Erwartet';

  @override
  String payEarnedSoFar(String amount, String recorded, String expected) {
    return '$amount verdient · $recorded von $expected h';
  }

  @override
  String payForHours(String hours) {
    return 'für $hours h';
  }

  @override
  String payOfExpected(String amount) {
    return 'von $amount';
  }

  @override
  String get wageRate => 'Stundenlohn';

  @override
  String get wageAdd => 'Stundenlohn eintragen';

  @override
  String get wageMissing =>
      'Trag deinen Stundenlohn ein, dann siehst du hier, was du im Monat verdienst.';

  @override
  String get wageSheetHint => 'Pro Stunde, ohne Trinkgeld.';

  @override
  String get wageFirstHint => 'Gilt auch für frühere Monate.';

  @override
  String get wageValidFrom => 'Gilt ab';

  @override
  String wageSince(String date) {
    return 'ab $date';
  }

  @override
  String get wageAll => 'Alle Stundenlöhne';

  @override
  String wageDeleteTitle(String date) {
    return 'Stundenlohn ab $date löschen?';
  }

  @override
  String get wageInvalid => 'Bitte einen Betrag wie 14,50 eingeben.';

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
  String get previousMonth => 'Vorheriger Monat';

  @override
  String get nextMonth => 'Nächster Monat';

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
  String get exportSubtitle => 'Arbeitszeiten des Monats als Text';

  @override
  String get monthTotalLabel => 'Monat gesamt';

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
  String get copy => 'Kopieren';

  @override
  String get copied => 'Kopiert';

  @override
  String get share => 'Teilen';

  @override
  String get missedNotExported => 'Nicht erfasste Schichten fehlen im Text.';

  @override
  String exportHeader(String month) {
    return 'Arbeitszeiten $month';
  }

  @override
  String exportWeekHeader(int week, String from, String to) {
    return 'KW $week ($from–$to)';
  }

  @override
  String get exportDayPattern => 'dd.MM.';

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
  String get sectionAppearance => 'Darstellung';

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
      'Schichten planen, Arbeitszeit mit einem Tipp erfassen und die Stunden des Monats als Text teilen.';

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

  @override
  String get colorTerracotta => 'Terrakotta';

  @override
  String get calendarRefresh => 'Aktualisieren';

  @override
  String get calendarMissingHint =>
      'Ein neuer Kalender fehlt? Google braucht dafür manchmal ein paar Minuten. Tippe dann auf „Aktualisieren“.';

  @override
  String get calendarNotSynced =>
      'Noch nicht auf diesem Handy synchronisiert. Die App schaltet das beim Auswählen ein.';

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Änderungen noch nicht im Kalender',
      one: '1 Änderung noch nicht im Kalender',
    );
    return '$_temp0';
  }

  @override
  String syncUpToDate(String time) {
    return 'Alles aktuell · zuletzt $time';
  }

  @override
  String get syncNever => 'Noch nicht synchronisiert';

  @override
  String get syncDone =>
      'Kalender ist aktuell. Google überträgt die Änderungen gleich.';

  @override
  String get syncFailed =>
      'Das hat nicht geklappt. Die App versucht es später noch einmal.';

  @override
  String get weekLegendBars => 'links Mittag · rechts Abend';

  @override
  String get weekMarks => 'Wochenübersicht';

  @override
  String get weekMarksIcons => 'Symbole';

  @override
  String get weekMarksBars => 'Balken';

  @override
  String get appIcon => 'App-Symbol';

  @override
  String get appIconRound => 'Rund';

  @override
  String get appIconSquircle => 'Squircle';

  @override
  String get appIconSmall => 'Squircle klein';

  @override
  String get appIconShape => 'Symbolform';

  @override
  String get appIconCloche => 'Servierglocke';

  @override
  String get appIconAkai => 'AKAI-Schild';

  @override
  String get appIconPenguinBlack => 'Pinguin, schwarz';

  @override
  String get appIconPenguinNavy => 'Pinguin, dunkelblau';

  @override
  String get appIconHint =>
      'Die App schließt sich dabei kurz. Das neue Symbol erscheint nach ein paar Sekunden; auf dem Startbildschirm musst du es eventuell neu ablegen.';

  @override
  String get appIconApply => 'Ändern';

  @override
  String get sectionUpdate => 'App-Update';

  @override
  String get updateCheck => 'Nach Updates suchen';

  @override
  String updateStatusChecked(String version, String time) {
    return 'Version $version · aktuell, geprüft $time';
  }

  @override
  String updateStatusNotChecked(String version) {
    return 'Version $version · noch nicht geprüft';
  }

  @override
  String get updateChecking => 'Suche nach Updates …';

  @override
  String get updateUpToDate => 'TimeTrack ist auf dem neuesten Stand.';

  @override
  String updateAvailableTile(String version) {
    return 'Update auf Version $version';
  }

  @override
  String get updateAvailableHint => 'Neuerungen ansehen und installieren';

  @override
  String updateDownloading(int percent) {
    return 'Wird heruntergeladen … $percent %';
  }

  @override
  String get updateInstalling =>
      'Bestätige die Installation im Android-Fenster. Die App schließt sich dabei; öffne sie danach einfach wieder.';

  @override
  String get updateCloseHint =>
      'Die App schließt sich während des Updates. Öffne sie danach einfach wieder.';

  @override
  String get updateRestart => 'Update neu starten';

  @override
  String get updateRestartHint =>
      'Falls die Installation hängt oder nicht geklappt hat';

  @override
  String get updateDeleteFile => 'Update-Datei löschen';

  @override
  String updateFileSize(String size) {
    return 'Belegt $size';
  }

  @override
  String get updateNoFile => 'Keine Datei gespeichert';

  @override
  String get updateFileDeleted => 'Update-Datei gelöscht';

  @override
  String updateDialogTitle(String version) {
    return 'Update auf Version $version';
  }

  @override
  String get updateNotesEmpty => 'Kleine Verbesserungen im Hintergrund.';

  @override
  String get notesNew => 'Neu';

  @override
  String get notesFixed => 'Behoben';

  @override
  String get notesImproved => 'Verbessert';

  @override
  String get updateInstall => 'Aktualisieren';

  @override
  String get updateClose => 'Schließen';

  @override
  String get updateCheckFailed =>
      'GitHub ist gerade nicht erreichbar. Versuch es später noch einmal.';

  @override
  String get updateDownloadFailed =>
      'Der Download hat nicht geklappt. Versuch es noch einmal.';

  @override
  String get updateNoPermission =>
      'TimeTrack darf noch keine Apps installieren. Erlaube es in den Android-Einstellungen und tippe dann noch einmal auf „Aktualisieren“.';

  @override
  String get updateAborted => 'Update abgebrochen.';

  @override
  String get updateFailed => 'Android hat das Update abgelehnt.';

  @override
  String get whatsNewTile => 'Was ist neu?';

  @override
  String whatsNewTileHint(String version) {
    return 'Die Änderungen in Version $version';
  }

  @override
  String whatsNewTitle(String version) {
    return 'Neu in Version $version';
  }

  @override
  String get whatsNewFailed =>
      'Die Neuerungen lassen sich gerade nicht laden. Versuch es später noch einmal.';

  @override
  String get whatsNewEarlier => 'Frühere Versionen';

  @override
  String whatsNewVersion(String version) {
    return 'Version $version';
  }

  @override
  String get sectionShifts => 'Schichten';

  @override
  String get sectionGeneral => 'Allgemein';

  @override
  String get sectionFeatures => 'Funktionen';

  @override
  String get featuresNone => 'Keine eingeschaltet';

  @override
  String get tipPoolSwitchSubtitle =>
      'Das Trinkgeld aller an jedem Arbeitstag notieren. Nach der Schicht fragt die App danach.';

  @override
  String get sectionPermissions => 'Berechtigungen';

  @override
  String get permissionsHint =>
      'Damit Erinnerungen pünktlich kommen, auch wenn die App geschlossen ist.';

  @override
  String get settingsShiftsSummary =>
      'Standardzeiten, geöffnete Schichten, Rundung';

  @override
  String settingsTeamPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
      zero: 'Noch niemand angelegt',
    );
    return '$_temp0';
  }

  @override
  String settingsUpdateSummary(String version) {
    return 'Version $version';
  }

  @override
  String get clearField => 'Leeren';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get restaurantHint =>
      'Optional. Steht im Kalender, im Export und auf dem Dienstplan-Bild.';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get colorRed => 'Rot';

  @override
  String exportHeaderAt(String month, String restaurant) {
    return 'Arbeitszeiten $month – $restaurant';
  }

  @override
  String teamImageTitleAt(String restaurant) {
    return 'Dienstplan $restaurant';
  }

  @override
  String get tabTeam => 'Dienstplan';

  @override
  String get teamTitle => 'Dienstplan';

  @override
  String get teamSubtitle => 'Schichten fürs Team planen';

  @override
  String teamAnswersCount(int answered, int total) {
    return 'Antworten: $answered von $total';
  }

  @override
  String get teamEnterAnswers => 'Antworten eintragen';

  @override
  String get teamNoPeople => 'Leg die Leute an, für die du planst.';

  @override
  String get teamAddPeople => 'Leute anlegen';

  @override
  String get teamFill => 'Auffüllen';

  @override
  String get teamClear => 'Leeren';

  @override
  String get teamPeople => 'Leute';

  @override
  String get teamAddMyShifts => 'Meine Schichten in den Plan';

  @override
  String teamAddedMyShifts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schichten in den Plan übernommen',
      one: '1 Schicht in den Plan übernommen',
    );
    return '$_temp0';
  }

  @override
  String get teamMyShiftsAlready => 'Schon alle im Plan';

  @override
  String get teamNoCore => 'Keine Stammkraft';

  @override
  String get teamCore => 'Stammkraft';

  @override
  String get teamCoreHint => 'Erfahren; in jede Schicht kommt möglichst eine';

  @override
  String get teamShiftsPerPerson => 'Schichten pro Person';

  @override
  String teamShiftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schichten',
      one: '1 Schicht',
    );
    return '$_temp0';
  }

  @override
  String teamPossible(int count) {
    return '$count möglich';
  }

  @override
  String get teamNoAnswer => 'Noch keine Antwort';

  @override
  String get teamCanWork => 'Hat Zeit';

  @override
  String get teamCantWork => 'Hat keine Zeit';

  @override
  String teamFilled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Plätze besetzt',
      one: '1 Platz besetzt',
    );
    return '$_temp0';
  }

  @override
  String teamStillOpen(int count) {
    return '$count noch offen';
  }

  @override
  String get teamAllFilled => 'Alle Plätze besetzt';

  @override
  String get teamNobodyFits => 'Für die offenen Plätze hat niemand Zeit';

  @override
  String get teamCleared => 'Plan geleert';

  @override
  String get teamStaffNeeded => 'Benötigt';

  @override
  String get teamClosed => 'Geschlossen';

  @override
  String teamStartAt(String time) {
    return 'ab $time';
  }

  @override
  String teamAnswersTitle(int week) {
    return 'Antworten · KW $week';
  }

  @override
  String teamProgress(int index, int total) {
    return '$index von $total';
  }

  @override
  String teamAvailable(String list) {
    return 'Hat Zeit: $list';
  }

  @override
  String get teamAvailableAll => 'Hat Zeit: jede Schicht';

  @override
  String get teamAvailableNone => 'Hat Zeit: keine Schicht';

  @override
  String get teamLunchShort => 'Mittag';

  @override
  String get teamEveningShort => 'Abend';

  @override
  String get teamChooseMode =>
      'Wähl zuerst, ob die Antwort sagt, wann die Person Zeit hat oder wann nicht.';

  @override
  String get teamAtMost => 'Höchstens';

  @override
  String get teamNoLimit => 'Keine Grenze';

  @override
  String get teamRemoveAnswer => 'Antwort entfernen';

  @override
  String get teamAddPerson => 'Person hinzufügen';

  @override
  String get teamName => 'Name';

  @override
  String get teamIsMe => 'Das bin ich';

  @override
  String get teamDuplicateName =>
      'Den Namen gibt es schon. Im Bild stünde er zweimal.';

  @override
  String get teamNobodyYet => 'Noch niemand angelegt.';

  @override
  String get teamShareTitle => 'Plan teilen';

  @override
  String get teamShareHint => 'Offene Plätze und Warnungen sind nicht im Bild.';

  @override
  String get teamImageTitle => 'Dienstplan';

  @override
  String teamImageWeek(int week, String range) {
    return 'KW $week · $range';
  }

  @override
  String get teamNextWeek => 'Nächste Woche';

  @override
  String get sectionTeam => 'Dienstplan';

  @override
  String get teamPlannerSwitch => 'Dienstplan';

  @override
  String get teamPlannerSubtitle =>
      'Schichten fürs Team planen und den Plan als Bild teilen';

  @override
  String get teamStartTimes => 'Startzeiten';

  @override
  String get teamAway => 'Diese Woche nicht da';

  @override
  String get teamAwayShort => 'Nicht da';

  @override
  String teamDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get teamDeleteBody =>
      'Die Antworten und Schichten dieser Person werden in allen Wochen mit gelöscht.';

  @override
  String get minutesUnit => 'min';

  @override
  String get shiftChangedMeanwhile =>
      'Die Schicht wurde inzwischen geändert, zum Beispiel über die Benachrichtigung. Bitte prüfe sie noch einmal.';

  @override
  String get openShifts => 'Geöffnete Schichten';

  @override
  String get openShiftsHint =>
      'Geschlossene Schichten erscheinen nicht im Plan.';

  @override
  String get staffNeededHint =>
      'Wie viele Leute jede Schicht braucht. Bei 0 ist geschlossen, dann erscheint die Schicht nicht im Plan.';

  @override
  String openShiftsCount(int count) {
    return '$count von 14 Schichten';
  }

  @override
  String get openShiftsTitle => 'Wann hat dein Restaurant geöffnet?';

  @override
  String get openShiftsBody =>
      'Schalte die Schichten aus, in denen geschlossen ist. Sie erscheinen dann nicht im Plan. Du kannst das jederzeit in den Einstellungen ändern.';

  @override
  String get extrasTitle => 'Was die App noch kann';

  @override
  String get extrasBody =>
      'Du kannst das alles später in den Einstellungen ändern.';

  @override
  String get themeMode => 'Modus';
}
