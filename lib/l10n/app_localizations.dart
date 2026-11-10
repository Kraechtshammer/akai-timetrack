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

  /// No description provided for @tabHome.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get tabHome;

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

  /// No description provided for @tabPay.
  ///
  /// In de, this message translates to:
  /// **'Lohn'**
  String get tabPay;

  /// No description provided for @paySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Monatslohn und Trinkgeld'**
  String get paySubtitle;

  /// No description provided for @tips.
  ///
  /// In de, this message translates to:
  /// **'Trinkgeld'**
  String get tips;

  /// No description provided for @tipsMonthWeeks.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{noch nichts ausgezahlt} =1{aus 1 Woche} other{aus {count} Wochen}}'**
  String tipsMonthWeeks(int count);

  /// No description provided for @tipPayout.
  ///
  /// In de, this message translates to:
  /// **'Ausgezahlt'**
  String get tipPayout;

  /// No description provided for @tipPayoutHint.
  ///
  /// In de, this message translates to:
  /// **'Was du für diese Woche bar bekommen hast'**
  String get tipPayoutHint;

  /// No description provided for @tipPayoutTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgezahlt · KW {week}'**
  String tipPayoutTitle(int week);

  /// No description provided for @tipPool.
  ///
  /// In de, this message translates to:
  /// **'Tagestopf'**
  String get tipPool;

  /// No description provided for @tipPoolHint.
  ///
  /// In de, this message translates to:
  /// **'Trinkgeld aller zusammen an diesem Tag'**
  String get tipPoolHint;

  /// No description provided for @tipPoolTitle.
  ///
  /// In de, this message translates to:
  /// **'Tagestopf · {day}'**
  String tipPoolTitle(String day);

  /// No description provided for @tipPoolSum.
  ///
  /// In de, this message translates to:
  /// **'Zusammen'**
  String get tipPoolSum;

  /// No description provided for @tipNoWorkdays.
  ///
  /// In de, this message translates to:
  /// **'Diese Woche keine Schichten.'**
  String get tipNoWorkdays;

  /// No description provided for @tipEnter.
  ///
  /// In de, this message translates to:
  /// **'Eintragen'**
  String get tipEnter;

  /// No description provided for @tipInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen Betrag wie 42,50 eingeben.'**
  String get tipInvalid;

  /// No description provided for @tipDeleted.
  ///
  /// In de, this message translates to:
  /// **'Betrag gelöscht'**
  String get tipDeleted;

  /// No description provided for @tipPromptTitle.
  ///
  /// In de, this message translates to:
  /// **'Trinkgeld eintragen'**
  String get tipPromptTitle;

  /// No description provided for @tipPromptToday.
  ///
  /// In de, this message translates to:
  /// **'Wie viel Trinkgeld kam heute insgesamt zusammen?'**
  String get tipPromptToday;

  /// No description provided for @tipPromptYesterday.
  ///
  /// In de, this message translates to:
  /// **'Wie viel Trinkgeld kam gestern insgesamt zusammen?'**
  String get tipPromptYesterday;

  /// No description provided for @tipNotNow.
  ///
  /// In de, this message translates to:
  /// **'Nicht jetzt'**
  String get tipNotNow;

  /// No description provided for @paySalary.
  ///
  /// In de, this message translates to:
  /// **'Lohn'**
  String get paySalary;

  /// No description provided for @payExpectedSalary.
  ///
  /// In de, this message translates to:
  /// **'Erwarteter Lohn'**
  String get payExpectedSalary;

  /// No description provided for @payTotal.
  ///
  /// In de, this message translates to:
  /// **'Gesamt'**
  String get payTotal;

  /// No description provided for @payWithTips.
  ///
  /// In de, this message translates to:
  /// **'mit Trinkgeld'**
  String get payWithTips;

  /// No description provided for @payEarned.
  ///
  /// In de, this message translates to:
  /// **'Verdient'**
  String get payEarned;

  /// No description provided for @payExpected.
  ///
  /// In de, this message translates to:
  /// **'Erwartet'**
  String get payExpected;

  /// No description provided for @payEarnedSoFar.
  ///
  /// In de, this message translates to:
  /// **'{amount} verdient · {recorded} von {expected} h'**
  String payEarnedSoFar(String amount, String recorded, String expected);

  /// No description provided for @payForHours.
  ///
  /// In de, this message translates to:
  /// **'für {hours} h'**
  String payForHours(String hours);

  /// No description provided for @payOfExpected.
  ///
  /// In de, this message translates to:
  /// **'von {amount}'**
  String payOfExpected(String amount);

  /// No description provided for @wageRate.
  ///
  /// In de, this message translates to:
  /// **'Stundenlohn'**
  String get wageRate;

  /// No description provided for @wageAdd.
  ///
  /// In de, this message translates to:
  /// **'Stundenlohn eintragen'**
  String get wageAdd;

  /// No description provided for @wageMissing.
  ///
  /// In de, this message translates to:
  /// **'Trag deinen Stundenlohn ein, dann siehst du hier, was du im Monat verdienst.'**
  String get wageMissing;

  /// No description provided for @wageSheetHint.
  ///
  /// In de, this message translates to:
  /// **'Pro Stunde, ohne Trinkgeld.'**
  String get wageSheetHint;

  /// No description provided for @wageFirstHint.
  ///
  /// In de, this message translates to:
  /// **'Gilt auch für frühere Monate.'**
  String get wageFirstHint;

  /// No description provided for @wageValidFrom.
  ///
  /// In de, this message translates to:
  /// **'Gilt ab'**
  String get wageValidFrom;

  /// No description provided for @wageSince.
  ///
  /// In de, this message translates to:
  /// **'ab {date}'**
  String wageSince(String date);

  /// No description provided for @wageAll.
  ///
  /// In de, this message translates to:
  /// **'Alle Stundenlöhne'**
  String get wageAll;

  /// No description provided for @wageDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Stundenlohn ab {date} löschen?'**
  String wageDeleteTitle(String date);

  /// No description provided for @wageInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen Betrag wie 14,50 eingeben.'**
  String get wageInvalid;

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

  /// No description provided for @currentMonth.
  ///
  /// In de, this message translates to:
  /// **'Zum aktuellen Monat'**
  String get currentMonth;

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
  /// **'Darstellung'**
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

  /// No description provided for @weekLegendBars.
  ///
  /// In de, this message translates to:
  /// **'links Mittag · rechts Abend'**
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

  /// No description provided for @appIconShape.
  ///
  /// In de, this message translates to:
  /// **'Symbolform'**
  String get appIconShape;

  /// No description provided for @appIconCloche.
  ///
  /// In de, this message translates to:
  /// **'Servierglocke'**
  String get appIconCloche;

  /// No description provided for @appIconAkai.
  ///
  /// In de, this message translates to:
  /// **'AKAI-Schild'**
  String get appIconAkai;

  /// No description provided for @appIconPenguinBlack.
  ///
  /// In de, this message translates to:
  /// **'Pinguin, schwarz'**
  String get appIconPenguinBlack;

  /// No description provided for @appIconPenguinNavy.
  ///
  /// In de, this message translates to:
  /// **'Pinguin, dunkelblau'**
  String get appIconPenguinNavy;

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

  /// No description provided for @sectionUpdate.
  ///
  /// In de, this message translates to:
  /// **'App-Update'**
  String get sectionUpdate;

  /// No description provided for @updateCheck.
  ///
  /// In de, this message translates to:
  /// **'Nach Updates suchen'**
  String get updateCheck;

  /// No description provided for @updateStatusChecked.
  ///
  /// In de, this message translates to:
  /// **'Version {version} · aktuell, geprüft {time}'**
  String updateStatusChecked(String version, String time);

  /// No description provided for @updateStatusNotChecked.
  ///
  /// In de, this message translates to:
  /// **'Version {version} · noch nicht geprüft'**
  String updateStatusNotChecked(String version);

  /// No description provided for @updateChecking.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Updates …'**
  String get updateChecking;

  /// No description provided for @updateUpToDate.
  ///
  /// In de, this message translates to:
  /// **'TimeTrack ist auf dem neuesten Stand.'**
  String get updateUpToDate;

  /// No description provided for @updateAvailableTile.
  ///
  /// In de, this message translates to:
  /// **'Update auf Version {version}'**
  String updateAvailableTile(String version);

  /// No description provided for @updateAvailableHint.
  ///
  /// In de, this message translates to:
  /// **'Neuerungen ansehen und installieren'**
  String get updateAvailableHint;

  /// No description provided for @updateDownloading.
  ///
  /// In de, this message translates to:
  /// **'Wird heruntergeladen … {percent} %'**
  String updateDownloading(int percent);

  /// No description provided for @updateInstalling.
  ///
  /// In de, this message translates to:
  /// **'Bestätige die Installation im Android-Fenster. Die App schließt sich dabei; öffne sie danach einfach wieder.'**
  String get updateInstalling;

  /// No description provided for @updateCloseHint.
  ///
  /// In de, this message translates to:
  /// **'Die App schließt sich während des Updates. Öffne sie danach einfach wieder.'**
  String get updateCloseHint;

  /// No description provided for @updateRestart.
  ///
  /// In de, this message translates to:
  /// **'Update neu starten'**
  String get updateRestart;

  /// No description provided for @updateRestartHint.
  ///
  /// In de, this message translates to:
  /// **'Falls die Installation hängt oder nicht geklappt hat'**
  String get updateRestartHint;

  /// No description provided for @updateDeleteFile.
  ///
  /// In de, this message translates to:
  /// **'Update-Datei löschen'**
  String get updateDeleteFile;

  /// No description provided for @updateFileSize.
  ///
  /// In de, this message translates to:
  /// **'Belegt {size}'**
  String updateFileSize(String size);

  /// No description provided for @updateNoFile.
  ///
  /// In de, this message translates to:
  /// **'Keine Datei gespeichert'**
  String get updateNoFile;

  /// No description provided for @updateFileDeleted.
  ///
  /// In de, this message translates to:
  /// **'Update-Datei gelöscht'**
  String get updateFileDeleted;

  /// No description provided for @updateDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Update auf Version {version}'**
  String updateDialogTitle(String version);

  /// No description provided for @updateNotesEmpty.
  ///
  /// In de, this message translates to:
  /// **'Kleine Verbesserungen im Hintergrund.'**
  String get updateNotesEmpty;

  /// No description provided for @notesNew.
  ///
  /// In de, this message translates to:
  /// **'Neu'**
  String get notesNew;

  /// No description provided for @notesFixed.
  ///
  /// In de, this message translates to:
  /// **'Behoben'**
  String get notesFixed;

  /// No description provided for @notesImproved.
  ///
  /// In de, this message translates to:
  /// **'Verbessert'**
  String get notesImproved;

  /// No description provided for @updateInstall.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get updateInstall;

  /// No description provided for @updateClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get updateClose;

  /// No description provided for @updateCheckFailed.
  ///
  /// In de, this message translates to:
  /// **'GitHub ist gerade nicht erreichbar. Versuch es später noch einmal.'**
  String get updateCheckFailed;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In de, this message translates to:
  /// **'Der Download hat nicht geklappt. Versuch es noch einmal.'**
  String get updateDownloadFailed;

  /// No description provided for @updateNoPermission.
  ///
  /// In de, this message translates to:
  /// **'TimeTrack darf noch keine Apps installieren. Erlaube es in den Android-Einstellungen und tippe dann noch einmal auf „Aktualisieren“.'**
  String get updateNoPermission;

  /// No description provided for @updateAborted.
  ///
  /// In de, this message translates to:
  /// **'Update abgebrochen.'**
  String get updateAborted;

  /// No description provided for @updateFailed.
  ///
  /// In de, this message translates to:
  /// **'Android hat das Update abgelehnt.'**
  String get updateFailed;

  /// No description provided for @whatsNewTile.
  ///
  /// In de, this message translates to:
  /// **'Was ist neu?'**
  String get whatsNewTile;

  /// No description provided for @whatsNewTileHint.
  ///
  /// In de, this message translates to:
  /// **'Die Änderungen in Version {version}'**
  String whatsNewTileHint(String version);

  /// No description provided for @whatsNewTitle.
  ///
  /// In de, this message translates to:
  /// **'Neu in Version {version}'**
  String whatsNewTitle(String version);

  /// No description provided for @whatsNewFailed.
  ///
  /// In de, this message translates to:
  /// **'Die Neuerungen lassen sich gerade nicht laden. Versuch es später noch einmal.'**
  String get whatsNewFailed;

  /// No description provided for @whatsNewEarlier.
  ///
  /// In de, this message translates to:
  /// **'Frühere Versionen'**
  String get whatsNewEarlier;

  /// No description provided for @whatsNewVersion.
  ///
  /// In de, this message translates to:
  /// **'Version {version}'**
  String whatsNewVersion(String version);

  /// No description provided for @sectionShifts.
  ///
  /// In de, this message translates to:
  /// **'Schichten'**
  String get sectionShifts;

  /// No description provided for @sectionGeneral.
  ///
  /// In de, this message translates to:
  /// **'Allgemein'**
  String get sectionGeneral;

  /// No description provided for @sectionFeatures.
  ///
  /// In de, this message translates to:
  /// **'Funktionen'**
  String get sectionFeatures;

  /// No description provided for @featuresNone.
  ///
  /// In de, this message translates to:
  /// **'Keine eingeschaltet'**
  String get featuresNone;

  /// No description provided for @tipPoolSwitchSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Das Trinkgeld aller an jedem Arbeitstag notieren. Nach der Schicht fragt die App danach.'**
  String get tipPoolSwitchSubtitle;

  /// No description provided for @sectionPermissions.
  ///
  /// In de, this message translates to:
  /// **'Berechtigungen'**
  String get sectionPermissions;

  /// No description provided for @permissionsHint.
  ///
  /// In de, this message translates to:
  /// **'Damit Erinnerungen pünktlich kommen, auch wenn die App geschlossen ist.'**
  String get permissionsHint;

  /// No description provided for @settingsShiftsSummary.
  ///
  /// In de, this message translates to:
  /// **'Standardzeiten, geöffnete Schichten, Rundung'**
  String get settingsShiftsSummary;

  /// No description provided for @settingsTeamPeople.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Noch niemand angelegt} =1{1 Person} other{{count} Personen}}'**
  String settingsTeamPeople(int count);

  /// No description provided for @settingsUpdateSummary.
  ///
  /// In de, this message translates to:
  /// **'Version {version}'**
  String settingsUpdateSummary(String version);

  /// No description provided for @clearField.
  ///
  /// In de, this message translates to:
  /// **'Leeren'**
  String get clearField;

  /// No description provided for @restaurant.
  ///
  /// In de, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @restaurantHint.
  ///
  /// In de, this message translates to:
  /// **'Optional. Steht im Kalender, im Export und auf dem Dienstplan-Bild.'**
  String get restaurantHint;

  /// No description provided for @notSet.
  ///
  /// In de, this message translates to:
  /// **'Nicht festgelegt'**
  String get notSet;

  /// No description provided for @colorRed.
  ///
  /// In de, this message translates to:
  /// **'Rot'**
  String get colorRed;

  /// No description provided for @exportHeaderAt.
  ///
  /// In de, this message translates to:
  /// **'Arbeitszeiten {month} – {restaurant}'**
  String exportHeaderAt(String month, String restaurant);

  /// No description provided for @teamImageTitleAt.
  ///
  /// In de, this message translates to:
  /// **'Dienstplan {restaurant}'**
  String teamImageTitleAt(String restaurant);

  /// No description provided for @tabTeam.
  ///
  /// In de, this message translates to:
  /// **'Dienstplan'**
  String get tabTeam;

  /// No description provided for @teamTitle.
  ///
  /// In de, this message translates to:
  /// **'Dienstplan'**
  String get teamTitle;

  /// No description provided for @teamSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Schichten fürs Team planen'**
  String get teamSubtitle;

  /// No description provided for @teamAnswersCount.
  ///
  /// In de, this message translates to:
  /// **'Antworten: {answered} von {total}'**
  String teamAnswersCount(int answered, int total);

  /// No description provided for @teamEnterAnswers.
  ///
  /// In de, this message translates to:
  /// **'Antworten eintragen'**
  String get teamEnterAnswers;

  /// No description provided for @teamNoPeople.
  ///
  /// In de, this message translates to:
  /// **'Leg die Leute an, für die du planst.'**
  String get teamNoPeople;

  /// No description provided for @teamAddPeople.
  ///
  /// In de, this message translates to:
  /// **'Leute anlegen'**
  String get teamAddPeople;

  /// No description provided for @teamFill.
  ///
  /// In de, this message translates to:
  /// **'Auffüllen'**
  String get teamFill;

  /// No description provided for @teamClear.
  ///
  /// In de, this message translates to:
  /// **'Leeren'**
  String get teamClear;

  /// No description provided for @teamPeople.
  ///
  /// In de, this message translates to:
  /// **'Leute'**
  String get teamPeople;

  /// No description provided for @teamAddMyShifts.
  ///
  /// In de, this message translates to:
  /// **'Meine Schichten in den Plan'**
  String get teamAddMyShifts;

  /// No description provided for @teamAddedMyShifts.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Schicht in den Plan übernommen} other{{count} Schichten in den Plan übernommen}}'**
  String teamAddedMyShifts(int count);

  /// No description provided for @teamMyShiftsAlready.
  ///
  /// In de, this message translates to:
  /// **'Schon alle im Plan'**
  String get teamMyShiftsAlready;

  /// No description provided for @teamNoCore.
  ///
  /// In de, this message translates to:
  /// **'Keine Stammkraft'**
  String get teamNoCore;

  /// No description provided for @teamCore.
  ///
  /// In de, this message translates to:
  /// **'Stammkraft'**
  String get teamCore;

  /// No description provided for @teamCoreHint.
  ///
  /// In de, this message translates to:
  /// **'Erfahren; in jede Schicht kommt möglichst eine'**
  String get teamCoreHint;

  /// No description provided for @teamShiftsPerPerson.
  ///
  /// In de, this message translates to:
  /// **'Schichten pro Person'**
  String get teamShiftsPerPerson;

  /// No description provided for @teamShiftCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Schicht} other{{count} Schichten}}'**
  String teamShiftCount(int count);

  /// No description provided for @teamPossible.
  ///
  /// In de, this message translates to:
  /// **'{count} möglich'**
  String teamPossible(int count);

  /// No description provided for @teamNoAnswer.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Antwort'**
  String get teamNoAnswer;

  /// No description provided for @teamCanWork.
  ///
  /// In de, this message translates to:
  /// **'Hat Zeit'**
  String get teamCanWork;

  /// No description provided for @teamCantWork.
  ///
  /// In de, this message translates to:
  /// **'Hat keine Zeit'**
  String get teamCantWork;

  /// No description provided for @teamFilled.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Platz besetzt} other{{count} Plätze besetzt}}'**
  String teamFilled(int count);

  /// No description provided for @teamStillOpen.
  ///
  /// In de, this message translates to:
  /// **'{count} noch offen'**
  String teamStillOpen(int count);

  /// No description provided for @teamAllFilled.
  ///
  /// In de, this message translates to:
  /// **'Alle Plätze besetzt'**
  String get teamAllFilled;

  /// No description provided for @teamNobodyFits.
  ///
  /// In de, this message translates to:
  /// **'Für die offenen Plätze hat niemand Zeit'**
  String get teamNobodyFits;

  /// No description provided for @teamCleared.
  ///
  /// In de, this message translates to:
  /// **'Plan geleert'**
  String get teamCleared;

  /// No description provided for @teamStaffNeeded.
  ///
  /// In de, this message translates to:
  /// **'Benötigt'**
  String get teamStaffNeeded;

  /// No description provided for @teamClosed.
  ///
  /// In de, this message translates to:
  /// **'Geschlossen'**
  String get teamClosed;

  /// No description provided for @teamStartAt.
  ///
  /// In de, this message translates to:
  /// **'ab {time}'**
  String teamStartAt(String time);

  /// No description provided for @teamAnswersTitle.
  ///
  /// In de, this message translates to:
  /// **'Antworten · KW {week}'**
  String teamAnswersTitle(int week);

  /// No description provided for @teamProgress.
  ///
  /// In de, this message translates to:
  /// **'{index} von {total}'**
  String teamProgress(int index, int total);

  /// No description provided for @teamAvailable.
  ///
  /// In de, this message translates to:
  /// **'Hat Zeit: {list}'**
  String teamAvailable(String list);

  /// No description provided for @teamAvailableAll.
  ///
  /// In de, this message translates to:
  /// **'Hat Zeit: jede Schicht'**
  String get teamAvailableAll;

  /// No description provided for @teamAvailableNone.
  ///
  /// In de, this message translates to:
  /// **'Hat Zeit: keine Schicht'**
  String get teamAvailableNone;

  /// No description provided for @teamLunchShort.
  ///
  /// In de, this message translates to:
  /// **'Mittag'**
  String get teamLunchShort;

  /// No description provided for @teamEveningShort.
  ///
  /// In de, this message translates to:
  /// **'Abend'**
  String get teamEveningShort;

  /// No description provided for @teamChooseMode.
  ///
  /// In de, this message translates to:
  /// **'Wähl zuerst, ob die Antwort sagt, wann die Person Zeit hat oder wann nicht.'**
  String get teamChooseMode;

  /// No description provided for @teamAtMost.
  ///
  /// In de, this message translates to:
  /// **'Höchstens'**
  String get teamAtMost;

  /// No description provided for @teamNoLimit.
  ///
  /// In de, this message translates to:
  /// **'Keine Grenze'**
  String get teamNoLimit;

  /// No description provided for @teamRemoveAnswer.
  ///
  /// In de, this message translates to:
  /// **'Antwort entfernen'**
  String get teamRemoveAnswer;

  /// No description provided for @teamAddPerson.
  ///
  /// In de, this message translates to:
  /// **'Person hinzufügen'**
  String get teamAddPerson;

  /// No description provided for @teamName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get teamName;

  /// No description provided for @teamIsMe.
  ///
  /// In de, this message translates to:
  /// **'Das bin ich'**
  String get teamIsMe;

  /// No description provided for @teamDuplicateName.
  ///
  /// In de, this message translates to:
  /// **'Den Namen gibt es schon. Im Bild stünde er zweimal.'**
  String get teamDuplicateName;

  /// No description provided for @teamNobodyYet.
  ///
  /// In de, this message translates to:
  /// **'Noch niemand angelegt.'**
  String get teamNobodyYet;

  /// No description provided for @teamShareTitle.
  ///
  /// In de, this message translates to:
  /// **'Plan teilen'**
  String get teamShareTitle;

  /// No description provided for @teamShareHint.
  ///
  /// In de, this message translates to:
  /// **'Offene Plätze und Warnungen sind nicht im Bild.'**
  String get teamShareHint;

  /// No description provided for @teamImageTitle.
  ///
  /// In de, this message translates to:
  /// **'Dienstplan'**
  String get teamImageTitle;

  /// No description provided for @teamImageWeek.
  ///
  /// In de, this message translates to:
  /// **'KW {week} · {range}'**
  String teamImageWeek(int week, String range);

  /// No description provided for @teamBackToNextWeek.
  ///
  /// In de, this message translates to:
  /// **'Zur nächsten Woche'**
  String get teamBackToNextWeek;

  /// No description provided for @sectionTeam.
  ///
  /// In de, this message translates to:
  /// **'Dienstplan'**
  String get sectionTeam;

  /// No description provided for @teamPlannerSwitch.
  ///
  /// In de, this message translates to:
  /// **'Dienstplan'**
  String get teamPlannerSwitch;

  /// No description provided for @teamPlannerSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Schichten fürs Team planen und den Plan als Bild teilen'**
  String get teamPlannerSubtitle;

  /// No description provided for @teamShiftTimes.
  ///
  /// In de, this message translates to:
  /// **'Schichtzeiten'**
  String get teamShiftTimes;

  /// No description provided for @teamShiftTimesNote.
  ///
  /// In de, this message translates to:
  /// **'Dieselben Zeiten wie unter Einstellungen › Schichten. Sie gelten auch für deine eigenen Schichten, und mit ihnen werden die Stunden im Monat gezählt.'**
  String get teamShiftTimesNote;

  /// No description provided for @teamMaxHours.
  ///
  /// In de, this message translates to:
  /// **'Max. Stunden im Monat'**
  String get teamMaxHours;

  /// No description provided for @teamMaxHoursHelp.
  ///
  /// In de, this message translates to:
  /// **'Zum Beispiel bei einem Minijob. Leer lassen, wenn es keine Grenze gibt.'**
  String get teamMaxHoursHelp;

  /// No description provided for @teamMaxHoursInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine Zahl eingeben, z. B. 43 oder 43,5.'**
  String get teamMaxHoursInvalid;

  /// No description provided for @teamHoursTitle.
  ///
  /// In de, this message translates to:
  /// **'Stunden im Monat'**
  String get teamHoursTitle;

  /// No description provided for @teamHoursSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Geplant im Dienstplan'**
  String get teamHoursSubtitle;

  /// No description provided for @teamHoursOf.
  ///
  /// In de, this message translates to:
  /// **'{hours} von {max} h'**
  String teamHoursOf(String hours, String max);

  /// No description provided for @teamHoursOnly.
  ///
  /// In de, this message translates to:
  /// **'{hours} h'**
  String teamHoursOnly(String hours);

  /// No description provided for @teamHoursLeft.
  ///
  /// In de, this message translates to:
  /// **'noch {hours} h'**
  String teamHoursLeft(String hours);

  /// No description provided for @teamHoursOver.
  ///
  /// In de, this message translates to:
  /// **'{hours} h zu viel'**
  String teamHoursOver(String hours);

  /// No description provided for @teamOverLimit.
  ///
  /// In de, this message translates to:
  /// **'Über der Monatsgrenze'**
  String get teamOverLimit;

  /// No description provided for @teamAboveWeekShare.
  ///
  /// In de, this message translates to:
  /// **'Über dem Wochenanteil'**
  String get teamAboveWeekShare;

  /// No description provided for @teamHoursNoLimit.
  ///
  /// In de, this message translates to:
  /// **'Keine Grenze'**
  String get teamHoursNoLimit;

  /// No description provided for @teamHoursNote.
  ///
  /// In de, this message translates to:
  /// **'Gezählt werden die Schichten im Dienstplan, mit den Schichtzeiten aus den Einstellungen. Wochenanteil: was vor der Woche von der Monatsgrenze noch übrig ist, gleichmäßig auf die restlichen Tage des Monats verteilt.'**
  String get teamHoursNote;

  /// No description provided for @teamWarnWhy.
  ///
  /// In de, this message translates to:
  /// **'Warum?'**
  String get teamWarnWhy;

  /// No description provided for @teamWarnNoAnswer.
  ///
  /// In de, this message translates to:
  /// **'Für diese Woche gibt es noch keine Antwort.'**
  String get teamWarnNoAnswer;

  /// No description provided for @teamWarnCantWork.
  ///
  /// In de, this message translates to:
  /// **'Laut Antwort ist diese Schicht nicht möglich.'**
  String get teamWarnCantWork;

  /// No description provided for @teamWarnOverLimit.
  ///
  /// In de, this message translates to:
  /// **'Im {month} sind {planned} h geplant. Die Grenze ist {limit} h, also {over} h zu viel.'**
  String teamWarnOverLimit(
    String month,
    String planned,
    String limit,
    String over,
  );

  /// No description provided for @teamWarnAboveShare.
  ///
  /// In de, this message translates to:
  /// **'Vor dieser Woche sind von der Monatsgrenze noch {left} h übrig. Gleichmäßig auf den Rest des Monats verteilt, sind das etwa {share} h für diese Woche. Geplant sind {planned} h, also deutlich mehr.'**
  String teamWarnAboveShare(String left, String share, String planned);

  /// No description provided for @teamWarnFill.
  ///
  /// In de, this message translates to:
  /// **'„Auffüllen“ teilt niemanden darüber hinaus ein. Von Hand geht es trotzdem.'**
  String get teamWarnFill;

  /// No description provided for @teamSyncPlan.
  ///
  /// In de, this message translates to:
  /// **'Meine Schichten automatisch in den Plan'**
  String get teamSyncPlan;

  /// No description provided for @teamSyncPlanSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Schichten im Dienstplan kommen von selbst in den Plan, mit Kalender und Erinnerungen, und gehen wieder, wenn du herausgenommen wirst. Schichten mit erfassten Zeiten bleiben.'**
  String get teamSyncPlanSubtitle;

  /// No description provided for @teamSyncPlanNoMe.
  ///
  /// In de, this message translates to:
  /// **'Markiere dich dazu unter „Leute“ mit „Das bin ich“.'**
  String get teamSyncPlanNoMe;

  /// No description provided for @planLeftTeamShift.
  ///
  /// In de, this message translates to:
  /// **'Auch aus dem Dienstplan genommen'**
  String get planLeftTeamShift;

  /// No description provided for @planFromTeam.
  ///
  /// In de, this message translates to:
  /// **'Aus dem Dienstplan'**
  String get planFromTeam;

  /// No description provided for @teamAway.
  ///
  /// In de, this message translates to:
  /// **'Diese Woche nicht da'**
  String get teamAway;

  /// No description provided for @teamAwayShort.
  ///
  /// In de, this message translates to:
  /// **'Nicht da'**
  String get teamAwayShort;

  /// No description provided for @teamDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'{name} löschen?'**
  String teamDeleteTitle(String name);

  /// No description provided for @teamDeleteBody.
  ///
  /// In de, this message translates to:
  /// **'Die Antworten und Schichten dieser Person werden in allen Wochen mit gelöscht.'**
  String get teamDeleteBody;

  /// No description provided for @minutesUnit.
  ///
  /// In de, this message translates to:
  /// **'min'**
  String get minutesUnit;

  /// No description provided for @shiftChangedMeanwhile.
  ///
  /// In de, this message translates to:
  /// **'Die Schicht wurde inzwischen geändert, zum Beispiel über die Benachrichtigung. Bitte prüfe sie noch einmal.'**
  String get shiftChangedMeanwhile;

  /// No description provided for @openShifts.
  ///
  /// In de, this message translates to:
  /// **'Geöffnete Schichten'**
  String get openShifts;

  /// No description provided for @openShiftsHint.
  ///
  /// In de, this message translates to:
  /// **'Geschlossene Schichten erscheinen nicht im Plan.'**
  String get openShiftsHint;

  /// No description provided for @staffNeededHint.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Leute jede Schicht braucht. Bei 0 ist geschlossen, dann erscheint die Schicht nicht im Plan.'**
  String get staffNeededHint;

  /// No description provided for @openShiftsCount.
  ///
  /// In de, this message translates to:
  /// **'{count} von 14 Schichten'**
  String openShiftsCount(int count);

  /// No description provided for @openShiftsTitle.
  ///
  /// In de, this message translates to:
  /// **'Wann hat dein Restaurant geöffnet?'**
  String get openShiftsTitle;

  /// No description provided for @openShiftsBody.
  ///
  /// In de, this message translates to:
  /// **'Schalte die Schichten aus, in denen geschlossen ist. Sie erscheinen dann nicht im Plan. Du kannst das jederzeit in den Einstellungen ändern.'**
  String get openShiftsBody;

  /// No description provided for @extrasTitle.
  ///
  /// In de, this message translates to:
  /// **'Was die App noch kann'**
  String get extrasTitle;

  /// No description provided for @extrasBody.
  ///
  /// In de, this message translates to:
  /// **'Du kannst das alles später in den Einstellungen ändern.'**
  String get extrasBody;

  /// No description provided for @themeMode.
  ///
  /// In de, this message translates to:
  /// **'Modus'**
  String get themeMode;
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
