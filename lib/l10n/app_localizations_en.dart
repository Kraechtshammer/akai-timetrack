// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TimeTrack';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabExport => 'Export';

  @override
  String get tabPay => 'Pay';

  @override
  String get paySubtitle => 'Monthly pay and tips';

  @override
  String get tips => 'Tips';

  @override
  String tipsMonthWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'from $count weeks',
      one: 'from 1 week',
      zero: 'nothing paid out yet',
    );
    return '$_temp0';
  }

  @override
  String get tipPayout => 'Paid out';

  @override
  String get tipPayoutHint => 'The cash you got for this week';

  @override
  String tipPayoutTitle(int week) {
    return 'Paid out · week $week';
  }

  @override
  String get tipPool => 'Daily pool';

  @override
  String get tipPoolHint => 'Everyone\'s tips combined that day';

  @override
  String tipPoolTitle(String day) {
    return 'Daily pool · $day';
  }

  @override
  String get tipPoolSum => 'Total';

  @override
  String get tipNoWorkdays => 'No shifts this week.';

  @override
  String get tipEnter => 'Add';

  @override
  String get tipInvalid => 'Enter an amount like 42.50.';

  @override
  String get tipDeleted => 'Amount deleted';

  @override
  String get tipPromptTitle => 'Add the tips';

  @override
  String get tipPromptToday =>
      'How much did everyone get in tips today, all combined?';

  @override
  String get tipPromptYesterday =>
      'How much did everyone get in tips yesterday, all combined?';

  @override
  String get tipNotNow => 'Not now';

  @override
  String get paySalary => 'Pay';

  @override
  String get payGross => 'gross';

  @override
  String get payExpectedSalary => 'Expected pay';

  @override
  String get payTotal => 'Total';

  @override
  String get payWithTips => 'with tips';

  @override
  String get payEarned => 'Earned';

  @override
  String get payExpected => 'Expected';

  @override
  String payEarnedSoFar(String amount, String recorded, String expected) {
    return '$amount earned · $recorded of $expected h';
  }

  @override
  String payForHours(String hours) {
    return 'for $hours h';
  }

  @override
  String payOfExpected(String amount) {
    return 'of $amount';
  }

  @override
  String get wageRate => 'Hourly wage';

  @override
  String get wageAdd => 'Add hourly wage';

  @override
  String get wageMissing =>
      'Add your hourly wage to see what you earn each month.';

  @override
  String get wageSheetHint => 'Gross per hour, without tips.';

  @override
  String get wageFirstHint => 'Also counts for earlier months.';

  @override
  String get wageValidFrom => 'Valid from';

  @override
  String wageSince(String date) {
    return 'from $date';
  }

  @override
  String get wageAll => 'All hourly wages';

  @override
  String wageDeleteTitle(String date) {
    return 'Delete the hourly wage from $date?';
  }

  @override
  String get wageInvalid => 'Enter an amount like 14.50.';

  @override
  String get settings => 'Settings';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get later => 'Later';

  @override
  String get done => 'Done';

  @override
  String get open => 'Open';

  @override
  String get allow => 'Allow';

  @override
  String get allowed => 'Allowed';

  @override
  String get undo => 'Undo';

  @override
  String get today => 'Today';

  @override
  String get shiftLunch => 'Lunch';

  @override
  String get shiftEvening => 'Evening';

  @override
  String get shiftCustom => 'Custom';

  @override
  String get statusPlanned => 'planned';

  @override
  String get statusRecorded => 'recorded';

  @override
  String get statusMissed => 'not recorded';

  @override
  String get statusRunning => 'running';

  @override
  String hours(String hours) {
    return '$hours h';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get nextShift => 'Next shift';

  @override
  String startsInMinutes(int minutes) {
    return 'in $minutes min';
  }

  @override
  String startsAt(String time) {
    return 'at $time';
  }

  @override
  String get runningNow => 'going on now';

  @override
  String reminderAt(String time) {
    return 'Reminder at $time';
  }

  @override
  String get noShiftPlanned => 'No shift planned';

  @override
  String get noShiftPlannedHint =>
      'Plan shifts in the Plan tab, or start recording anyway.';

  @override
  String get startAnyway => 'Start anyway';

  @override
  String get startRecording => 'Start recording';

  @override
  String get stopRecording => 'Stop recording';

  @override
  String get recordingRunning => 'Recording';

  @override
  String recordingStarted(String start, String rounded) {
    return 'Started $start · counted from $rounded';
  }

  @override
  String plannedEndAt(String time) {
    return 'Planned end $time';
  }

  @override
  String get changeStart => 'Change start time';

  @override
  String get ifStoppedNow => 'If you stop now';

  @override
  String get roundedHint => 'rounded to quarter hours';

  @override
  String get monthAsOfToday => 'As of today';

  @override
  String get monthRecorded => 'Recorded';

  @override
  String get monthExpected => 'Planned (incl. recorded)';

  @override
  String monthProgress(int percent, String hours, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planned shifts',
      one: '1 planned shift',
    );
    return '$percent % recorded · $hours h left in $_temp0';
  }

  @override
  String get monthRunningHint => 'The running shift counts once it\'s stopped.';

  @override
  String missedShifts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shifts not recorded',
      one: '1 shift not recorded',
    );
    return '$_temp0';
  }

  @override
  String thisWeek(int week) {
    return 'This week · CW $week';
  }

  @override
  String get toPlan => 'Open plan';

  @override
  String get dayOff => 'off';

  @override
  String get planSubtitle => 'Tap Lunch or Evening to plan';

  @override
  String weekLabel(int week) {
    return 'CW $week';
  }

  @override
  String weekRecorded(String hours) {
    return '$hours h recorded';
  }

  @override
  String weekTotal(String hours) {
    return 'Week: $hours h';
  }

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get currentWeek => 'Go to this week';

  @override
  String get noShift => 'No shift';

  @override
  String get addCustomShift => 'Add custom shift';

  @override
  String get recordedNotRemovable =>
      'This shift is recorded. Open it to delete it.';

  @override
  String get shiftDeleted => 'Shift deleted';

  @override
  String get newShift => 'New shift';

  @override
  String get planned => 'Planned';

  @override
  String get actual => 'Actual';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get pause => 'Break';

  @override
  String get pauseNone => 'None';

  @override
  String get pauseOther => 'Other';

  @override
  String get pauseOtherTitle => 'Break in minutes';

  @override
  String recordedRaw(String from, String to) {
    return 'Recorded $from – $to, rounded to quarter hours';
  }

  @override
  String get takePlanned => 'Use planned times';

  @override
  String get removeActual => 'Remove recording';

  @override
  String get workingTime => 'Working time';

  @override
  String get notRecordedYet => 'Not recorded yet';

  @override
  String get endsNextDay => 'Ends the next day';

  @override
  String calendarInfo(String calendar, String title) {
    return 'Calendar \"$calendar\" · \"$title\"';
  }

  @override
  String get deleteRecordedTitle => 'Delete recorded shift?';

  @override
  String get deleteRecordedBody => 'The recorded working time will be lost.';

  @override
  String get startMustBeBeforeEnd => 'The end must be after the start.';

  @override
  String get exportSubtitle => 'The month\'s working hours as text';

  @override
  String get monthTotalLabel => 'Month total';

  @override
  String shiftsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shifts',
      one: '1 shift',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'on $count days',
      one: 'on 1 day',
    );
    return '$_temp0';
  }

  @override
  String get preview => 'Preview';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get share => 'Share';

  @override
  String get missedNotExported =>
      'Shifts that weren\'t recorded are missing from the text.';

  @override
  String exportHeader(String month) {
    return 'Working hours $month';
  }

  @override
  String exportWeekHeader(int week, String from, String to) {
    return 'CW $week ($from–$to)';
  }

  @override
  String get exportDayPattern => 'dd/MM';

  @override
  String exportBreak(int minutes) {
    return '$minutes min break';
  }

  @override
  String exportWeekTotal(String hours) {
    return 'Week total: $hours h';
  }

  @override
  String exportMonthTotal(String month, String hours) {
    return '$month total: $hours h';
  }

  @override
  String exportMonthSoFar(String month, String hours) {
    return '$month so far: $hours h';
  }

  @override
  String get reliabilityTitle => 'So reminders arrive reliably';

  @override
  String get reliabilityBody => 'A few settings are still missing.';

  @override
  String get permNotifications => 'Notifications';

  @override
  String get permNotificationsHint => 'For reminders and the timer';

  @override
  String get permExact => 'Exact reminders';

  @override
  String get permExactHint =>
      'Otherwise a reminder may come a few minutes late';

  @override
  String get permBattery => 'Battery: unrestricted';

  @override
  String get permBatteryHint =>
      'So reminders and notification buttons react right away';

  @override
  String get permAutostart => 'Allow autostart';

  @override
  String get permAutostartHint =>
      'So reminders are set up again after a restart';

  @override
  String get sectionCalendar => 'Calendar';

  @override
  String get calendar => 'Calendar';

  @override
  String get calendarNone => 'No calendar';

  @override
  String get calendarNoneHint => 'Shifts are not copied to a calendar.';

  @override
  String get calendarPermissionMissing => 'Calendar access missing';

  @override
  String get eventTitle => 'Event title';

  @override
  String get eventColor => 'Event color';

  @override
  String get eventColorHint =>
      'Used for all shifts in the calendar. People you share the calendar with see this color too.';

  @override
  String get colorOfCalendar => 'Calendar color';

  @override
  String colorWithKey(String key) {
    return 'Color $key';
  }

  @override
  String get previewInCalendar => 'Preview in the calendar';

  @override
  String get apply => 'Apply';

  @override
  String get sectionDefaultTimes => 'Default shift times';

  @override
  String get lunchBeforeEvening => 'Lunch before an evening shift';

  @override
  String get sectionReminders => 'Reminders';

  @override
  String get reminderBefore => 'Before a shift starts';

  @override
  String minutesBefore(int minutes) {
    return '$minutes minutes before';
  }

  @override
  String get overrunAsk => 'Ask if not stopped';

  @override
  String minutesAfterEnd(int minutes) {
    return '$minutes minutes after the planned end';
  }

  @override
  String get sectionRecording => 'Recording & export';

  @override
  String get rounding => 'Rounding';

  @override
  String get roundingNearest => 'To the nearest quarter hour';

  @override
  String get roundingInFavour => 'Start down, end up';

  @override
  String get roundingStrict => 'Start up, end down';

  @override
  String get sectionAppearance => 'Appearance & language';

  @override
  String get color => 'Color';

  @override
  String get colorSystem => 'System color';

  @override
  String get colorAkai => 'AKAI red';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorViolet => 'Violet';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Same as the phone';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get welcomeTitle => 'Welcome to\nTimeTrack';

  @override
  String get welcomeBody =>
      'Plan your shifts, record your working time with one tap and share the month\'s hours as text.';

  @override
  String get letsGo => 'Let\'s go';

  @override
  String get remindersTitle => 'Reminded on time';

  @override
  String get remindersBody =>
      'Before every shift you get a reminder that starts the recording right away.';

  @override
  String get calendarTitle => 'Which calendar?';

  @override
  String get calendarBody =>
      'Your shifts appear there as events. Other events in the calendar stay untouched.';

  @override
  String get calendarTip =>
      'New Google calendars can only be created and shared in the browser.';

  @override
  String get openGoogleCalendar => 'Open calendar.google.com';

  @override
  String get continueWithoutCalendar => 'Continue without a calendar';

  @override
  String get calendarAccessNeeded =>
      'To choose a calendar, the app needs access to your calendars.';

  @override
  String get noCalendars =>
      'No writable calendars found. Is a Google account set up on the phone?';

  @override
  String get xiaomiTitle => 'Two more steps';

  @override
  String get xiaomiBody =>
      'Xiaomi phones stop background apps very strictly. Without these settings, reminders may not arrive.';

  @override
  String get xiaomiNote =>
      'Only shown on Xiaomi, Redmi and POCO phones. Also available later in Settings.';

  @override
  String get timesTitle => 'Your shift times';

  @override
  String get timesBody =>
      'Do the default times fit? You can change them any time in Settings.';

  @override
  String get finish => 'Done';

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get channelReminders => 'Reminders';

  @override
  String get channelRecording => 'Running recording';

  @override
  String get channelOverrun => 'Follow-up questions';

  @override
  String notifStartTitle(int minutes) {
    return 'Shift starts in $minutes min';
  }

  @override
  String notifShiftBody(String type, String from, String to) {
    return '$type · $from – $to';
  }

  @override
  String notifRunningBody(String type, String since, String until) {
    return '$type · since $since · planned until $until';
  }

  @override
  String get notifOverrunTitle => 'Still at work?';

  @override
  String notifOverrunBody(String time) {
    return 'The planned end was $time. Recording is still running.';
  }

  @override
  String get actionStart => 'Start recording';

  @override
  String get actionLater => 'Later';

  @override
  String get actionStop => 'Stop';

  @override
  String actionEndAt(String time) {
    return 'End $time';
  }

  @override
  String get actionStopNow => 'Stop now';

  @override
  String get actionKeepGoing => 'Keep going';

  @override
  String calPlanned(String times) {
    return 'Planned: $times';
  }

  @override
  String calRecorded(String times, String hours) {
    return 'Recorded: $times ($hours h)';
  }

  @override
  String get calManaged =>
      'Managed by TimeTrack – please change it in the app.';

  @override
  String get gcolLavender => 'Lavender';

  @override
  String get gcolSage => 'Sage';

  @override
  String get gcolGrape => 'Grape';

  @override
  String get gcolFlamingo => 'Flamingo';

  @override
  String get gcolBanana => 'Banana';

  @override
  String get gcolTangerine => 'Tangerine';

  @override
  String get gcolPeacock => 'Peacock';

  @override
  String get gcolGraphite => 'Graphite';

  @override
  String get gcolBlueberry => 'Blueberry';

  @override
  String get gcolBasil => 'Basil';

  @override
  String get gcolTomato => 'Tomato';

  @override
  String get colorTerracotta => 'Terracotta';

  @override
  String get calendarRefresh => 'Refresh';

  @override
  String get calendarMissingHint =>
      'A new calendar is missing? Google sometimes needs a few minutes. Then tap “Refresh”.';

  @override
  String get calendarNotSynced =>
      'Not synced to this phone yet. The app turns that on when you choose it.';

  @override
  String get syncNow => 'Sync now';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes not in the calendar yet',
      one: '1 change not in the calendar yet',
    );
    return '$_temp0';
  }

  @override
  String syncUpToDate(String time) {
    return 'Up to date · last synced $time';
  }

  @override
  String get syncNever => 'Not synced yet';

  @override
  String get syncDone =>
      'Calendar is up to date. Google uploads the changes shortly.';

  @override
  String get syncFailed => 'That didn’t work. The app will try again later.';

  @override
  String get weekLegendRecorded => 'coloured = recorded';

  @override
  String get weekLegendBars =>
      'left lunch · right evening · coloured = recorded';

  @override
  String get weekMarks => 'Week overview';

  @override
  String get weekMarksIcons => 'Icons';

  @override
  String get weekMarksBars => 'Bars';

  @override
  String get appIcon => 'App icon';

  @override
  String get appIconRound => 'Round';

  @override
  String get appIconSquircle => 'Squircle';

  @override
  String get appIconSmall => 'Small squircle';

  @override
  String get appIconHint =>
      'The app closes briefly. The new icon shows up after a few seconds; you may have to add it to the home screen again.';

  @override
  String get appIconApply => 'Change';

  @override
  String get sectionUpdate => 'App update';

  @override
  String get updateCheck => 'Check for updates';

  @override
  String updateStatusChecked(String version, String time) {
    return 'Version $version · up to date, checked $time';
  }

  @override
  String updateStatusNotChecked(String version) {
    return 'Version $version · not checked yet';
  }

  @override
  String get updateChecking => 'Checking for updates…';

  @override
  String get updateUpToDate => 'TimeTrack is up to date.';

  @override
  String updateAvailableTile(String version) {
    return 'Update to version $version';
  }

  @override
  String get updateAvailableHint => 'See what\'s new and install';

  @override
  String updateDownloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get updateInstalling =>
      'Confirm the installation in the Android window. The app closes meanwhile; just open it again afterwards.';

  @override
  String get updateCloseHint =>
      'The app closes during the update. Just open it again afterwards.';

  @override
  String get updateRestart => 'Restart update';

  @override
  String get updateRestartHint => 'If the installation got stuck or failed';

  @override
  String get updateDeleteFile => 'Delete update file';

  @override
  String updateFileSize(String size) {
    return 'Uses $size';
  }

  @override
  String get updateNoFile => 'No file stored';

  @override
  String get updateFileDeleted => 'Update file deleted';

  @override
  String updateDialogTitle(String version) {
    return 'Update to version $version';
  }

  @override
  String get updateNotesEmpty => 'Small improvements behind the scenes.';

  @override
  String get notesNew => 'New';

  @override
  String get notesFixed => 'Fixed';

  @override
  String get notesImproved => 'Improved';

  @override
  String get updateInstall => 'Update';

  @override
  String get updateClose => 'Close';

  @override
  String get updateCheckFailed =>
      'GitHub can\'t be reached right now. Try again later.';

  @override
  String get updateDownloadFailed =>
      'The download didn\'t work. Please try again.';

  @override
  String get updateNoPermission =>
      'TimeTrack isn\'t allowed to install apps yet. Allow it in Android\'s settings, then tap “Update” again.';

  @override
  String get updateAborted => 'Update cancelled.';

  @override
  String get updateFailed => 'Android refused the update.';
}
