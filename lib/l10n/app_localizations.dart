import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'TimeTrack'**
  String get appTitle;

  /// No description provided for @tabToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get tabToday;

  /// No description provided for @tabPlan.
  ///
  /// In de, this message translates to:
  /// **'Plan'**
  String get tabPlan;

  /// No description provided for @tabExport.
  ///
  /// In de, this message translates to:
  /// **'Export'**
  String get tabExport;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @back.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @next.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get skip;

  /// No description provided for @later.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get later;

  /// No description provided for @done.
  ///
  /// In de, this message translates to:
  /// **'Erledigt'**
  String get done;

  /// No description provided for @open.
  ///
  /// In de, this message translates to:
  /// **'Öffnen'**
  String get open;

  /// No description provided for @allow.
  ///
  /// In de, this message translates to:
  /// **'Erlauben'**
  String get allow;

  /// No description provided for @allowed.
  ///
  /// In de, this message translates to:
  /// **'Erlaubt'**
  String get allowed;

  /// No description provided for @undo.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig'**
  String get undo;

  /// No description provided for @today.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get today;

  /// No description provided for @shiftLunch.
  ///
  /// In de, this message translates to:
  /// **'Mittag'**
  String get shiftLunch;

  /// No description provided for @shiftEvening.
  ///
  /// In de, this message translates to:
  /// **'Abend'**
  String get shiftEvening;

  /// No description provided for @shiftCustom.
  ///
  /// In de, this message translates to:
  /// **'Individuell'**
  String get shiftCustom;

  /// No description provided for @statusPlanned.
  ///
  /// In de, this message translates to:
  /// **'geplant'**
  String get statusPlanned;

  /// No description provided for @statusRecorded.
  ///
  /// In de, this message translates to:
  /// **'erfasst'**
  String get statusRecorded;

  /// No description provided for @statusMissed.
  ///
  /// In de, this message translates to:
  /// **'nicht erfasst'**
  String get statusMissed;

  /// No description provided for @statusRunning.
  ///
  /// In de, this message translates to:
  /// **'läuft'**
  String get statusRunning;

  /// No description provided for @hours.
  ///
  /// In de, this message translates to:
  /// **'{hours} h'**
  String hours(String hours);

  /// No description provided for @minutesShort.
  ///
  /// In de, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @nextShift.
  ///
  /// In de, this message translates to:
  /// **'Nächste Schicht'**
  String get nextShift;

  /// No description provided for @startsInMinutes.
  ///
  /// In de, this message translates to:
  /// **'in {minutes} min'**
  String startsInMinutes(int minutes);

  /// No description provided for @startsAt.
  ///
  /// In de, this message translates to:
  /// **'um {time}'**
  String startsAt(String time);

  /// No description provided for @runningNow.
  ///
  /// In de, this message translates to:
  /// **'läuft gerade'**
  String get runningNow;

  /// No description provided for @reminderAt.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung um {time}'**
  String reminderAt(String time);

  /// No description provided for @noShiftPlanned.
  ///
  /// In de, this message translates to:
  /// **'Keine Schicht geplant'**
  String get noShiftPlanned;

  /// No description provided for @noShiftPlannedHint.
  ///
  /// In de, this message translates to:
  /// **'Plane Schichten im Tab „Plan“ oder starte die Erfassung trotzdem.'**
  String get noShiftPlannedHint;

  /// No description provided for @startAnyway.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem starten'**
  String get startAnyway;

  /// No description provided for @startRecording.
  ///
  /// In de, this message translates to:
  /// **'Erfassung starten'**
  String get startRecording;

  /// No description provided for @stopRecording.
  ///
  /// In de, this message translates to:
  /// **'Erfassung beenden'**
  String get stopRecording;

  /// No description provided for @recordingRunning.
  ///
  /// In de, this message translates to:
  /// **'Erfassung läuft'**
  String get recordingRunning;

  /// No description provided for @recordingStarted.
  ///
  /// In de, this message translates to:
  /// **'Gestartet {start} · gerechnet ab {rounded}'**
  String recordingStarted(String start, String rounded);

  /// No description provided for @plannedEndAt.
  ///
  /// In de, this message translates to:
  /// **'Geplantes Ende {time}'**
  String plannedEndAt(String time);

  /// No description provided for @changeStart.
  ///
  /// In de, this message translates to:
  /// **'Startzeit ändern'**
  String get changeStart;

  /// No description provided for @ifStoppedNow.
  ///
  /// In de, this message translates to:
  /// **'Wenn du jetzt beendest'**
  String get ifStoppedNow;

  /// No description provided for @roundedHint.
  ///
  /// In de, this message translates to:
  /// **'auf Viertelstunden gerundet'**
  String get roundedHint;

  /// No description provided for @monthAsOfToday.
  ///
  /// In de, this message translates to:
  /// **'Stand heute'**
  String get monthAsOfToday;

  /// No description provided for @monthRecorded.
  ///
  /// In de, this message translates to:
  /// **'Erfasst'**
  String get monthRecorded;

  /// No description provided for @monthExpected.
  ///
  /// In de, this message translates to:
  /// **'Geplant (inkl. erfasst)'**
  String get monthExpected;

  /// No description provided for @monthProgress.
  ///
  /// In de, this message translates to:
  /// **'{percent} % erfasst · noch {hours} h in {count, plural, =1{1 geplanten Schicht} other{{count} geplanten Schichten}}'**
  String monthProgress(int percent, String hours, int count);

  /// No description provided for @monthRunningHint.
  ///
  /// In de, this message translates to:
  /// **'Die laufende Schicht zählt nach dem Beenden.'**
  String get monthRunningHint;

  /// No description provided for @missedShifts.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Schicht nicht erfasst} other{{count} Schichten nicht erfasst}}'**
  String missedShifts(int count);

  /// No description provided for @thisWeek.
  ///
  /// In de, this message translates to:
  /// **'Diese Woche · KW {week}'**
  String thisWeek(int week);

  /// No description provided for @toPlan.
  ///
  /// In de, this message translates to:
  /// **'Zum Plan'**
  String get toPlan;

  /// No description provided for @dayOff.
  ///
  /// In de, this message translates to:
  /// **'frei'**
  String get dayOff;

  /// No description provided for @planSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Tippe Mittag oder Abend zum Planen'**
  String get planSubtitle;

  /// No description provided for @weekLabel.
  ///
  /// In de, this message translates to:
  /// **'KW {week}'**
  String weekLabel(int week);

  /// No description provided for @weekRecorded.
  ///
  /// In de, this message translates to:
  /// **'{hours} h erfasst'**
  String weekRecorded(String hours);

  /// No description provided for @weekTotal.
  ///
  /// In de, this message translates to:
  /// **'Woche: {hours} h'**
  String weekTotal(String hours);

  /// No description provided for @previousWeek.
  ///
  /// In de, this message translates to:
  /// **'Vorherige Woche'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In de, this message translates to:
  /// **'Nächste Woche'**
  String get nextWeek;

  /// No description provided for @previousMonth.
  ///
  /// In de, this message translates to:
  /// **'Vorheriger Monat'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In de, this message translates to:
  /// **'Nächster Monat'**
  String get nextMonth;

  /// No description provided for @currentWeek.
  ///
  /// In de, this message translates to:
  /// **'Zur aktuellen Woche'**
  String get currentWeek;

  /// No description provided for @noShift.
  ///
  /// In de, this message translates to:
  /// **'Keine Schicht'**
  String get noShift;

  /// No description provided for @addCustomShift.
  ///
  /// In de, this message translates to:
  /// **'Individuelle Schicht hinzufügen'**
  String get addCustomShift;

  /// No description provided for @recordedNotRemovable.
  ///
  /// In de, this message translates to:
  /// **'Diese Schicht ist erfasst. Zum Löschen bitte öffnen.'**
  String get recordedNotRemovable;

  /// No description provided for @shiftDeleted.
  ///
  /// In de, this message translates to:
  /// **'Schicht gelöscht'**
  String get shiftDeleted;

  /// No description provided for @newShift.
  ///
  /// In de, this message translates to:
  /// **'Neue Schicht'**
  String get newShift;

  /// No description provided for @planned.
  ///
  /// In de, this message translates to:
  /// **'Geplant'**
  String get planned;

  /// No description provided for @actual.
  ///
  /// In de, this message translates to:
  /// **'Tatsächlich'**
  String get actual;

  /// No description provided for @start.
  ///
  /// In de, this message translates to:
  /// **'Beginn'**
  String get start;

  /// No description provided for @end.
  ///
  /// In de, this message translates to:
  /// **'Ende'**
  String get end;

  /// No description provided for @pause.
  ///
  /// In de, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @pauseNone.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get pauseNone;

  /// No description provided for @pauseOther.
  ///
  /// In de, this message translates to:
  /// **'Andere'**
  String get pauseOther;

  /// No description provided for @pauseOtherTitle.
  ///
  /// In de, this message translates to:
  /// **'Pause in Minuten'**
  String get pauseOtherTitle;

  /// No description provided for @recordedRaw.
  ///
  /// In de, this message translates to:
  /// **'Aufgezeichnet {from} – {to}, auf Viertelstunden gerundet'**
  String recordedRaw(String from, String to);

  /// No description provided for @takePlanned.
  ///
  /// In de, this message translates to:
  /// **'Wie geplant übernehmen'**
  String get takePlanned;

  /// No description provided for @removeActual.
  ///
  /// In de, this message translates to:
  /// **'Erfassung entfernen'**
  String get removeActual;

  /// No description provided for @workingTime.
  ///
  /// In de, this message translates to:
  /// **'Arbeitszeit'**
  String get workingTime;

  /// No description provided for @notRecordedYet.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht erfasst'**
  String get notRecordedYet;

  /// No description provided for @endsNextDay.
  ///
  /// In de, this message translates to:
  /// **'Endet am nächsten Tag'**
  String get endsNextDay;

  /// No description provided for @calendarInfo.
  ///
  /// In de, this message translates to:
  /// **'Kalender „{calendar}“ · „{title}“'**
  String calendarInfo(String calendar, String title);

  /// No description provided for @deleteRecordedTitle.
  ///
  /// In de, this message translates to:
  /// **'Erfasste Schicht löschen?'**
  String get deleteRecordedTitle;

  /// No description provided for @deleteRecordedBody.
  ///
  /// In de, this message translates to:
  /// **'Die erfasste Arbeitszeit geht dabei verloren.'**
  String get deleteRecordedBody;

  /// No description provided for @startMustBeBeforeEnd.
  ///
  /// In de, this message translates to:
  /// **'Das Ende muss nach dem Beginn liegen.'**
  String get startMustBeBeforeEnd;

  /// No description provided for @exportSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Arbeitszeiten des Monats als Text'**
  String get exportSubtitle;

  /// No description provided for @monthTotalLabel.
  ///
  /// In de, this message translates to:
  /// **'Monat gesamt'**
  String get monthTotalLabel;

  /// No description provided for @shiftsCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Schicht} other{{count} Schichten}}'**
  String shiftsCount(int count);

  /// No description provided for @daysCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{an 1 Tag} other{an {count} Tagen}}'**
  String daysCount(int count);

  /// No description provided for @preview.
  ///
  /// In de, this message translates to:
  /// **'Vorschau'**
  String get preview;

  /// No description provided for @copy.
  ///
  /// In de, this message translates to:
  /// **'Kopieren'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In de, this message translates to:
  /// **'Kopiert'**
  String get copied;

  /// No description provided for @share.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get share;

  /// No description provided for @missedNotExported.
  ///
  /// In de, this message translates to:
  /// **'Nicht erfasste Schichten fehlen im Text.'**
  String get missedNotExported;

  /// No description provided for @exportHeader.
  ///
  /// In de, this message translates to:
  /// **'Arbeitszeiten {month}'**
  String exportHeader(String month);

  /// No description provided for @exportWeekHeader.
  ///
  /// In de, this message translates to:
  /// **'KW {week} ({from}–{to})'**
  String exportWeekHeader(int week, String from, String to);

  /// No description provided for @exportDayPattern.
  ///
  /// In de, this message translates to:
  /// **'dd.MM.'**
  String get exportDayPattern;

  /// No description provided for @exportBreak.
  ///
  /// In de, this message translates to:
  /// **'{minutes} min Pause'**
  String exportBreak(int minutes);

  /// No description provided for @exportWeekTotal.
  ///
  /// In de, this message translates to:
  /// **'Woche gesamt: {hours} h'**
  String exportWeekTotal(String hours);

  /// No description provided for @exportMonthTotal.
  ///
  /// In de, this message translates to:
  /// **'{month} gesamt: {hours} h'**
  String exportMonthTotal(String month, String hours);

  /// No description provided for @exportMonthSoFar.
  ///
  /// In de, this message translates to:
  /// **'{month} bisher: {hours} h'**
  String exportMonthSoFar(String month, String hours);

  /// No description provided for @reliabilityTitle.
  ///
  /// In de, this message translates to:
  /// **'Damit Erinnerungen zuverlässig kommen'**
  String get reliabilityTitle;

  /// No description provided for @reliabilityBody.
  ///
  /// In de, this message translates to:
  /// **'Ein paar Einstellungen fehlen noch.'**
  String get reliabilityBody;

  /// No description provided for @permNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get permNotifications;

  /// No description provided for @permNotificationsHint.
  ///
  /// In de, this message translates to:
  /// **'Für Erinnerungen und den Timer'**
  String get permNotificationsHint;

  /// No description provided for @permExact.
  ///
  /// In de, this message translates to:
  /// **'Exakte Erinnerungen'**
  String get permExact;

  /// No description provided for @permExactHint.
  ///
  /// In de, this message translates to:
  /// **'Sonst kann die Erinnerung ein paar Minuten zu spät kommen'**
  String get permExactHint;

  /// No description provided for @permBattery.
  ///
  /// In de, this message translates to:
  /// **'Akku: Keine Einschränkungen'**
  String get permBattery;

  /// No description provided for @permBatteryHint.
  ///
  /// In de, this message translates to:
  /// **'Damit Erinnerungen und die Knöpfe in den Benachrichtigungen sofort reagieren'**
  String get permBatteryHint;

  /// No description provided for @permAutostart.
  ///
  /// In de, this message translates to:
  /// **'Autostart erlauben'**
  String get permAutostart;

  /// No description provided for @permAutostartHint.
  ///
  /// In de, this message translates to:
  /// **'Damit Erinnerungen auch nach einem Neustart wieder eingeplant werden'**
  String get permAutostartHint;

  /// No description provided for @sectionCalendar.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get sectionCalendar;

  /// No description provided for @calendar.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get calendar;

  /// No description provided for @calendarNone.
  ///
  /// In de, this message translates to:
  /// **'Kein Kalender'**
  String get calendarNone;

  /// No description provided for @calendarNoneHint.
  ///
  /// In de, this message translates to:
  /// **'Schichten werden nicht in einen Kalender übertragen.'**
  String get calendarNoneHint;

  /// No description provided for @calendarPermissionMissing.
  ///
  /// In de, this message translates to:
  /// **'Kalenderzugriff fehlt'**
  String get calendarPermissionMissing;

  /// No description provided for @eventTitle.
  ///
  /// In de, this message translates to:
  /// **'Termin-Titel'**
  String get eventTitle;

  /// No description provided for @eventColor.
  ///
  /// In de, this message translates to:
  /// **'Termin-Farbe'**
  String get eventColor;

  /// No description provided for @eventColorHint.
  ///
  /// In de, this message translates to:
  /// **'Gilt für alle Schichten im Kalender. Wer den Kalender mit dir teilt, sieht diese Farbe auch.'**
  String get eventColorHint;

  /// No description provided for @colorOfCalendar.
  ///
  /// In de, this message translates to:
  /// **'Kalenderfarbe'**
  String get colorOfCalendar;

  /// No description provided for @colorWithKey.
  ///
  /// In de, this message translates to:
  /// **'Farbe {key}'**
  String colorWithKey(String key);

  /// No description provided for @previewInCalendar.
  ///
  /// In de, this message translates to:
  /// **'Vorschau im Kalender'**
  String get previewInCalendar;

  /// No description provided for @apply.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get apply;

  /// No description provided for @sectionDefaultTimes.
  ///
  /// In de, this message translates to:
  /// **'Standard-Schichtzeiten'**
  String get sectionDefaultTimes;

  /// No description provided for @lunchBeforeEvening.
  ///
  /// In de, this message translates to:
  /// **'Mittag vor Abendschicht'**
  String get lunchBeforeEvening;

  /// No description provided for @sectionReminders.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen'**
  String get sectionReminders;

  /// No description provided for @reminderBefore.
  ///
  /// In de, this message translates to:
  /// **'Vor Schichtbeginn'**
  String get reminderBefore;

  /// No description provided for @minutesBefore.
  ///
  /// In de, this message translates to:
  /// **'{minutes} Minuten vorher'**
  String minutesBefore(int minutes);

  /// No description provided for @overrunAsk.
  ///
  /// In de, this message translates to:
  /// **'Nachfragen, wenn nicht beendet'**
  String get overrunAsk;

  /// No description provided for @minutesAfterEnd.
  ///
  /// In de, this message translates to:
  /// **'{minutes} Minuten nach geplantem Ende'**
  String minutesAfterEnd(int minutes);

  /// No description provided for @sectionRecording.
  ///
  /// In de, this message translates to:
  /// **'Erfassung & Export'**
  String get sectionRecording;

  /// No description provided for @rounding.
  ///
  /// In de, this message translates to:
  /// **'Rundung'**
  String get rounding;

  /// No description provided for @roundingNearest.
  ///
  /// In de, this message translates to:
  /// **'Auf nächste Viertelstunde'**
  String get roundingNearest;

  /// No description provided for @roundingInFavour.
  ///
  /// In de, this message translates to:
  /// **'Beginn ab-, Ende aufrunden'**
  String get roundingInFavour;

  /// No description provided for @roundingStrict.
  ///
  /// In de, this message translates to:
  /// **'Beginn auf-, Ende abrunden'**
  String get roundingStrict;

  /// No description provided for @sectionAppearance.
  ///
  /// In de, this message translates to:
  /// **'Darstellung & Sprache'**
  String get sectionAppearance;

  /// No description provided for @color.
  ///
  /// In de, this message translates to:
  /// **'Farbe'**
  String get color;

  /// No description provided for @colorSystem.
  ///
  /// In de, this message translates to:
  /// **'Systemfarbe'**
  String get colorSystem;

  /// No description provided for @colorAkai.
  ///
  /// In de, this message translates to:
  /// **'AKAI-Rot'**
  String get colorAkai;

  /// No description provided for @colorBlue.
  ///
  /// In de, this message translates to:
  /// **'Blau'**
  String get colorBlue;

  /// No description provided for @colorGreen.
  ///
  /// In de, this message translates to:
  /// **'Grün'**
  String get colorGreen;

  /// No description provided for @colorViolet.
  ///
  /// In de, this message translates to:
  /// **'Violett'**
  String get colorViolet;

  /// No description provided for @darkMode.
  ///
  /// In de, this message translates to:
  /// **'Dunkelmodus'**
  String get darkMode;

  /// No description provided for @themeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In de, this message translates to:
  /// **'Wie im System'**
  String get languageSystem;

  /// No description provided for @languageGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @welcomeTitle.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei\nTimeTrack'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In de, this message translates to:
  /// **'Schichten planen, Arbeitszeit mit einem Tipp erfassen und die Stunden des Monats als Text teilen.'**
  String get welcomeBody;

  /// No description provided for @letsGo.
  ///
  /// In de, this message translates to:
  /// **'Los geht’s'**
  String get letsGo;

  /// No description provided for @remindersTitle.
  ///
  /// In de, this message translates to:
  /// **'Pünktlich erinnert'**
  String get remindersTitle;

  /// No description provided for @remindersBody.
  ///
  /// In de, this message translates to:
  /// **'Vor jeder Schicht kommt eine Erinnerung, mit der du die Erfassung direkt startest.'**
  String get remindersBody;

  /// No description provided for @calendarTitle.
  ///
  /// In de, this message translates to:
  /// **'Welcher Kalender?'**
  String get calendarTitle;

  /// No description provided for @calendarBody.
  ///
  /// In de, this message translates to:
  /// **'Deine Schichten erscheinen dort als Termine. Andere Termine im Kalender bleiben unberührt.'**
  String get calendarBody;

  /// No description provided for @calendarTip.
  ///
  /// In de, this message translates to:
  /// **'Neue Google-Kalender lassen sich nur im Browser anlegen und teilen.'**
  String get calendarTip;

  /// No description provided for @openGoogleCalendar.
  ///
  /// In de, this message translates to:
  /// **'calendar.google.com öffnen'**
  String get openGoogleCalendar;

  /// No description provided for @continueWithoutCalendar.
  ///
  /// In de, this message translates to:
  /// **'Ohne Kalender fortfahren'**
  String get continueWithoutCalendar;

  /// No description provided for @calendarAccessNeeded.
  ///
  /// In de, this message translates to:
  /// **'Für die Kalenderauswahl braucht die App Zugriff auf deine Kalender.'**
  String get calendarAccessNeeded;

  /// No description provided for @noCalendars.
  ///
  /// In de, this message translates to:
  /// **'Keine beschreibbaren Kalender gefunden. Ist ein Google-Konto auf dem Handy eingerichtet?'**
  String get noCalendars;

  /// No description provided for @xiaomiTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch zwei Handgriffe'**
  String get xiaomiTitle;

  /// No description provided for @xiaomiBody.
  ///
  /// In de, this message translates to:
  /// **'Xiaomi-Handys beenden Apps im Hintergrund sehr gründlich. Ohne diese Einstellungen können Erinnerungen ausbleiben.'**
  String get xiaomiBody;

  /// No description provided for @xiaomiNote.
  ///
  /// In de, this message translates to:
  /// **'Wird nur auf Xiaomi-, Redmi- und POCO-Handys angezeigt. Später auch in den Einstellungen.'**
  String get xiaomiNote;

  /// No description provided for @timesTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Schichtzeiten'**
  String get timesTitle;

  /// No description provided for @timesBody.
  ///
  /// In de, this message translates to:
  /// **'Passen die Standardzeiten? Du kannst sie jederzeit in den Einstellungen ändern.'**
  String get timesBody;

  /// No description provided for @finish.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get finish;

  /// No description provided for @stepOf.
  ///
  /// In de, this message translates to:
  /// **'Schritt {step} von {total}'**
  String stepOf(int step, int total);

  /// No description provided for @channelReminders.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen'**
  String get channelReminders;

  /// No description provided for @channelRecording.
  ///
  /// In de, this message translates to:
  /// **'Laufende Erfassung'**
  String get channelRecording;

  /// No description provided for @channelOverrun.
  ///
  /// In de, this message translates to:
  /// **'Nachfragen'**
  String get channelOverrun;

  /// No description provided for @notifStartTitle.
  ///
  /// In de, this message translates to:
  /// **'Schicht beginnt in {minutes} min'**
  String notifStartTitle(int minutes);

  /// No description provided for @notifShiftBody.
  ///
  /// In de, this message translates to:
  /// **'{type} · {from} – {to}'**
  String notifShiftBody(String type, String from, String to);

  /// No description provided for @notifRunningBody.
  ///
  /// In de, this message translates to:
  /// **'{type} · seit {since} · geplant bis {until}'**
  String notifRunningBody(String type, String since, String until);

  /// No description provided for @notifOverrunTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch bei der Arbeit?'**
  String get notifOverrunTitle;

  /// No description provided for @notifOverrunBody.
  ///
  /// In de, this message translates to:
  /// **'Geplantes Ende war {time}. Die Erfassung läuft noch.'**
  String notifOverrunBody(String time);

  /// No description provided for @actionStart.
  ///
  /// In de, this message translates to:
  /// **'Erfassung starten'**
  String get actionStart;

  /// No description provided for @actionLater.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get actionLater;

  /// No description provided for @actionStop.
  ///
  /// In de, this message translates to:
  /// **'Beenden'**
  String get actionStop;

  /// No description provided for @actionEndAt.
  ///
  /// In de, this message translates to:
  /// **'Ende {time}'**
  String actionEndAt(String time);

  /// No description provided for @actionStopNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt beenden'**
  String get actionStopNow;

  /// No description provided for @actionKeepGoing.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get actionKeepGoing;

  /// No description provided for @calPlanned.
  ///
  /// In de, this message translates to:
  /// **'Geplant: {times}'**
  String calPlanned(String times);

  /// No description provided for @calRecorded.
  ///
  /// In de, this message translates to:
  /// **'Erfasst: {times} ({hours} h)'**
  String calRecorded(String times, String hours);

  /// No description provided for @calManaged.
  ///
  /// In de, this message translates to:
  /// **'Wird von TimeTrack verwaltet – bitte in der App ändern.'**
  String get calManaged;

  /// No description provided for @gcolLavender.
  ///
  /// In de, this message translates to:
  /// **'Lavendel'**
  String get gcolLavender;

  /// No description provided for @gcolSage.
  ///
  /// In de, this message translates to:
  /// **'Salbei'**
  String get gcolSage;

  /// No description provided for @gcolGrape.
  ///
  /// In de, this message translates to:
  /// **'Weintraube'**
  String get gcolGrape;

  /// No description provided for @gcolFlamingo.
  ///
  /// In de, this message translates to:
  /// **'Flamingo'**
  String get gcolFlamingo;

  /// No description provided for @gcolBanana.
  ///
  /// In de, this message translates to:
  /// **'Banane'**
  String get gcolBanana;

  /// No description provided for @gcolTangerine.
  ///
  /// In de, this message translates to:
  /// **'Mandarine'**
  String get gcolTangerine;

  /// No description provided for @gcolPeacock.
  ///
  /// In de, this message translates to:
  /// **'Pfau'**
  String get gcolPeacock;

  /// No description provided for @gcolGraphite.
  ///
  /// In de, this message translates to:
  /// **'Graphit'**
  String get gcolGraphite;

  /// No description provided for @gcolBlueberry.
  ///
  /// In de, this message translates to:
  /// **'Heidelbeere'**
  String get gcolBlueberry;

  /// No description provided for @gcolBasil.
  ///
  /// In de, this message translates to:
  /// **'Basilikum'**
  String get gcolBasil;

  /// No description provided for @gcolTomato.
  ///
  /// In de, this message translates to:
  /// **'Tomate'**
  String get gcolTomato;

  /// No description provided for @colorTerracotta.
  ///
  /// In de, this message translates to:
  /// **'Terrakotta'**
  String get colorTerracotta;

  /// No description provided for @calendarRefresh.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get calendarRefresh;

  /// No description provided for @calendarMissingHint.
  ///
  /// In de, this message translates to:
  /// **'Ein neuer Kalender fehlt? Google braucht dafür manchmal ein paar Minuten. Tippe dann auf „Aktualisieren“.'**
  String get calendarMissingHint;

  /// No description provided for @calendarNotSynced.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht auf diesem Handy synchronisiert. Die App schaltet das beim Auswählen ein.'**
  String get calendarNotSynced;

  /// No description provided for @syncNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt synchronisieren'**
  String get syncNow;

  /// No description provided for @syncPending.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Änderung noch nicht im Kalender} other{{count} Änderungen noch nicht im Kalender}}'**
  String syncPending(int count);

  /// No description provided for @syncUpToDate.
  ///
  /// In de, this message translates to:
  /// **'Alles aktuell · zuletzt {time}'**
  String syncUpToDate(String time);

  /// No description provided for @syncNever.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht synchronisiert'**
  String get syncNever;

  /// No description provided for @syncDone.
  ///
  /// In de, this message translates to:
  /// **'Kalender ist aktuell. Google überträgt die Änderungen gleich.'**
  String get syncDone;

  /// No description provided for @syncFailed.
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht geklappt. Die App versucht es später noch einmal.'**
  String get syncFailed;

  /// No description provided for @weekLegendRecorded.
  ///
  /// In de, this message translates to:
  /// **'farbig = erfasst'**
  String get weekLegendRecorded;

  /// No description provided for @weekLegendBars.
  ///
  /// In de, this message translates to:
  /// **'links Mittag · rechts Abend · farbig = erfasst'**
  String get weekLegendBars;

  /// No description provided for @weekMarks.
  ///
  /// In de, this message translates to:
  /// **'Wochenübersicht'**
  String get weekMarks;

  /// No description provided for @weekMarksIcons.
  ///
  /// In de, this message translates to:
  /// **'Symbole'**
  String get weekMarksIcons;

  /// No description provided for @weekMarksBars.
  ///
  /// In de, this message translates to:
  /// **'Balken'**
  String get weekMarksBars;

  /// No description provided for @appIcon.
  ///
  /// In de, this message translates to:
  /// **'App-Symbol'**
  String get appIcon;

  /// No description provided for @appIconRound.
  ///
  /// In de, this message translates to:
  /// **'Rund'**
  String get appIconRound;

  /// No description provided for @appIconSquircle.
  ///
  /// In de, this message translates to:
  /// **'Squircle'**
  String get appIconSquircle;

  /// No description provided for @appIconSmall.
  ///
  /// In de, this message translates to:
  /// **'Squircle klein'**
  String get appIconSmall;

  /// No description provided for @appIconHint.
  ///
  /// In de, this message translates to:
  /// **'Die App schließt sich dabei kurz. Das neue Symbol erscheint nach ein paar Sekunden; auf dem Startbildschirm musst du es eventuell neu ablegen.'**
  String get appIconHint;

  /// No description provided for @appIconApply.
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get appIconApply;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
