# AKAI Timetrack – Research

Status: research step (before design and implementation). As of 2026-11-04.

## 1. Problem and current workflow

- She works as a server at AKAI. There are two shift types:
  - **Lunch (Mittag):** ~12:00–16:00, or ~12:00–15:30 when an evening shift follows.
  - **Evening (Abend):** ~17:30–23:00.
- What she does today, in Google Calendar:
  1. When the week's plan comes out, she creates one event per shift with the approximate times.
  2. After each shift, she corrects the event to the actual times.
  3. At the end of the week, she types up her hours by hand and texts them to her boss.
- Pain points: duplicate manual entry, easy to forget the correction, and the weekly summary is assembled by hand.

## 2. Target features (as requested)

| # | Feature | Notes |
|---|---------|-------|
| F1 | **Shift planning** tab | Week view. Tap Mittag/Abend per day to add a planned shift with default times. Edit start/end; delete. |
| F2 | **Google Calendar sync** | Planned shifts (and later the actual times) appear in her Google Calendar, which you can see too. |
| F3 | **Pre-shift reminder** | Notification X minutes before the planned start (default 15, configurable) with a "Start" button. |
| F4 | **Live recording notification** | While recording, the notification shows elapsed time plus a "Stop" button. On stop, the times are rounded to the quarter hour and written to the shift. |
| F5 | **Manual correction** | Edit actual start/end by hand (for when she forgot to start or stop). |
| F6 | **Weekly export** | Build a text from the week's actual times, then copy it or share it into WhatsApp/Signal/SMS. |
| F7 | **Localization** | German by default, English optional. |

## 3. Technical findings per feature

### 3.1 Calendar sync (F2): use the on-device calendar, not the Google Calendar API

There are two ways to get events into Google Calendar.

**A) Android Calendar Provider (`CalendarContract`). Recommended.**
- The app writes events into a calendar that already exists on the phone and belongs to her Google account. Android's own Google sync then uploads them to Google Calendar.
- No Google Cloud project, no OAuth, no API keys, no Google app verification. The only thing needed is the `READ_CALENDAR` / `WRITE_CALENDAR` runtime permission.
- Works offline; sync happens whenever the phone syncs.
- iOS has an equivalent, EventKit, which works if her Google account is added in iOS Settings. Cross-platform plugins wrap both (e.g. Flutter `device_calendar_plus`, `expo-calendar`).
- Limitation: apps **cannot create a new Google-synced calendar** through the provider; only local, unsynced calendars can be created that way. Suggested setup:
  1. She creates a calendar called **"AKAI Schichten"** once in Google Calendar on the web.
  2. She shares it with you (read access).
  3. The app lets her pick that calendar once in its settings.
  - Side benefit: work shifts stay separate from her private events, and you can see only the shifts.
- The app keeps its own database as the **source of truth** and stores each shift's calendar event ID. The calendar is a **mirror**.
- Recommendation for v1: **one-way sync (app → calendar).** If she edits the event directly in Google Calendar, the app overwrites it on the next change. Two-way sync is possible later but adds conflict handling.

**B) Google Calendar REST API with OAuth.** Not recommended.
- Needs a Google Cloud project and an OAuth consent screen.
- Calendar scopes are "sensitive", so Google verification is needed once there are more than 100 users. That matters if colleagues use the app.
- More code: token handling and network errors.
- Only worth it if the app ever needs a backend or web version.

### 3.2 Pre-shift reminder (F3)

- A notification is scheduled for each planned shift at `start − lead time`. It is rescheduled whenever a shift is edited or deleted, and after a reboot (Android clears alarms on reboot, so the app needs a `BOOT_COMPLETED` receiver).
- **Exact timing:** since Android 14, `SCHEDULE_EXACT_ALARM` is no longer granted by default. The app has to send her once to the "Alarms & reminders" settings page to allow it.
  - Without that permission, Android may deliver the reminder a few minutes late. For a 15-minute heads-up that is probably acceptable, but exact timing is the cleaner option.
  - `USE_EXACT_ALARM` (granted automatically) is allowed by Play policy only for alarm-clock and calendar apps, so we should not rely on it.
- `POST_NOTIFICATIONS` is a runtime permission on Android 13 and later and is requested at first launch.
- Tapping the notification's "Start" button records the start time without opening the app (handled by a BroadcastReceiver).

### 3.3 Live recording notification (F4)

- Android notifications have a built-in **chronometer** (`setUsesChronometer` + `setWhen(startTime)`). The system draws the running timer itself, so **no foreground service is needed**.
  - The app only stores the start timestamp. Battery cost is zero, and recording survives the app being killed.
- The notification is set to ongoing and has a "Stop" action.
  - Caveat: since Android 14, users can swipe ongoing notifications away. That does not stop the recording, because the timestamp is saved. The app shows the running recording on its main screen and can re-post the notification.
- Android 16 adds "Live Updates" (promoted ongoing notifications, shown more prominently on the lock screen and status bar). This is a nice-to-have, not needed for v1.
- On stop: the actual start and end are rounded to the quarter hour, the shift is saved, the calendar event is updated (title, and possibly the description, changes from "geplant" to actual), and the notification is dismissed.
- **The rounding rule needs a decision** (open question Q1). Options:
  - nearest quarter hour;
  - in her favour: start rounded down, end rounded up;
  - strict: start rounded up, end rounded down.
  - The restaurant's rule may be fixed already. The rule should be a setting with a sensible default.

### 3.4 Manual correction (F5)

- Planned times and actual times are stored as separate fields, so the plan is never lost and the export uses actual times when they exist.
- Edit sheet with time pickers in 5-minute or 15-minute steps. A "Start now" action is also available inside the app (and is the fallback whenever the notification flow isn't used).
- "I forgot to start" case: open the shift, choose "Start recording with the planned time", or simply edit the time afterwards.

### 3.5 Weekly export (F6)

- The text is generated from a template, then copied to the clipboard or sent through Android's share sheet straight into WhatsApp or another messenger.
- Example (format to be agreed; she should show us her current message):
  ```
  Arbeitszeiten KW 45 (03.11.–09.11.)
  Mo 03.11.  12:00–15:30, 17:30–23:00  (9,0 h)
  Di 04.11.  17:30–22:45               (5,25 h)
  ...
  Gesamt: 27,75 h
  ```
- Open: Is the week Mon–Sun? Hours as decimals or h:mm? Are breaks deducted? See Q2–Q4.

### 3.6 Localization (F7)

- Both Flutter and native Android support this through standard resource files (ARB files in Flutter, `strings.xml` natively).
- German is the default, with English added as a second file. Date and number formats come from the locale (`03.11.`, `9,5 h`).

### 3.7 Data and backup

- Local SQLite database only. No server and no account inside the app.
- Android Auto Backup stores the database in her Google Drive backup automatically, which covers a phone change. Since the calendar holds a copy of every shift, the risk of losing data is small anyway.
- Privacy: no data leaves the phone except through Google Calendar sync and the export she triggers herself. That keeps a possible Play Store data-safety declaration trivial.

## 4. Framework options

All the hard parts of this app are platform features (notifications with actions, alarms, the calendar provider). The UI itself is simple. So the deciding question is how well each option reaches those native APIs.

| Option | Language | Can do iOS later? | VS Code? | Fit for this app |
|--------|----------|-------------------|----------|------------------|
| **Native Android** (Jetpack Compose) | Kotlin | No, iOS would be a rewrite (Swift) | Poor. Android Studio is effectively required. | Best possible API access, but closes the door on iOS. |
| **Kotlin Multiplatform + Compose Multiplatform** | Kotlin | Yes. Shared UI and logic; platform code per OS. iOS UI has been stable since 2025. | Weak. JetBrains' Kotlin LSP for VS Code is still early; in practice you use Android Studio or IntelliJ. | Very good on Android, since it is native Kotlin. iOS still needs Swift for the platform bits. |
| **Flutter** | Dart | Yes. One codebase; iOS mostly "just builds". | **First-class** (official Dart and Flutter extensions: debugging, hot reload) | Very good. Mature plugins: `flutter_local_notifications` (actions, scheduling, chronometer), `device_calendar_plus` (Calendar Provider and EventKit, actively maintained). Kotlin can be dropped in for anything missing. |
| **React Native + Expo** | TypeScript | Yes | First-class | Good. `expo-calendar` is solid, but `expo-notifications` has no chronometer, so it needs Notifee or a custom native module. Expo's cloud builds (EAS) need an Expo account. |
| .NET MAUI | C# | Yes | Possible, but VS Code support is second-class | Workable, smaller ecosystem. Not recommended here. |

### Recommendation: Flutter

- It matches the VS Code preference best.
- It needs no account for development.
- It has proven plugins for exactly the three platform features we need.
- It keeps iOS open at little extra cost.
- Dart is easy to pick up for anyone who knows Java, C#, Kotlin or TypeScript.

If you're sure iOS will never matter and you don't mind Android Studio, native Kotlin/Compose would be equally good, and slightly better for Android-only details.

### What "iOS later" really costs (for any framework)

- **A Mac is required** to build and sign iOS apps. The alternative is a cloud build service (Codemagic, GitHub Actions macOS runners, Expo EAS), but you still need a Mac or a device to test on.
- **The live timer on iOS** requires a **Live Activity** (ActivityKit). That is a small widget extension written in Swift, whatever framework the app uses; regular iOS notifications can't show a running timer.
  - Action buttons ("Start"/"Stop") in regular iOS notifications do work.
- iOS has no exact-alarm restriction for local notifications, which is simpler than Android.

## 5. Tooling on Windows (Flutter path)

1. **Flutter SDK.** Download the zip, or let the VS Code Flutter extension install it. Add it to `PATH`.
2. **Android SDK and emulator.** The easiest route is installing **Android Studio** once, only to get the SDK, platform tools, the emulator and a JDK; afterwards it can stay closed. (The command-line tools work too but are fiddlier.)
3. **VS Code** with the **Flutter** extension (it pulls in Dart).
4. **A real phone.** Enable Developer options and USB debugging (or wireless debugging), then run `flutter run` straight onto her phone or yours.
5. `flutter doctor` checks the setup.
6. Optional: Git with a private GitHub repo, for backup and later CI builds.

## 6. Accounts and registrations

| What | Needed for | Cost / effort |
|------|-----------|---------------|
| Nothing | Developing, running on the emulator, installing on your own phones via USB/`adb` | Free |
| **Android developer verification**: "limited distribution" (hobbyist) account | Installing the APK on certified Android devices **by normal sideloading** once enforcement reaches Germany. Enforcement started 2026-09-30 in BR/ID/SG/TH; **global rollout is planned for 2027**. | Free, no government ID, up to **20 devices**. Enough for her and some colleagues. `adb` install from a computer stays possible without it. |
| **Google Play Console** | Play Store release (for colleagues at scale) | US$25 one-time and ID verification. New personal accounts must run a **closed test with ≥12 testers for 14 consecutive days per app** before going public. |
| Google Cloud project and OAuth consent | Only if we used the Calendar REST API | **Avoided** by using the on-device calendar |
| Expo account | Only on the React Native/Expo path (EAS cloud builds) | Free tier available |
| Apple ID (free) | Installing on your own iPhone from Xcode | Free; the app expires after **7 days** |
| Apple Developer Program | TestFlight / App Store | US$99 per year, plus a Mac |

**Practical path:**
1. Develop and test via USB. No accounts needed.
2. Once global verification enforcement nears (2027), register a free limited-distribution account so she, and maybe colleagues, can keep installing and updating normally.
3. Only consider Play Store or iOS if colleagues show real interest.

## 7. Decisions (answers to the open questions, 2026-11-04)

| # | Topic | Decision |
|---|-------|----------|
| Q1 | Rounding | **Nearest quarter hour** for both start and end (12:07 → 12:00, 12:08 → 12:15; exactly x:07:30 rounds up). Kept as a setting so another rule can be chosen later. |
| Q2 | Breaks | **Optional break per shift**, in minutes. It is subtracted from the shift's hours and shown in the export. |
| Q3 | Export format | **Decimal hours, plus start and end times.** No example of her current message was available, so the format below is a proposal. |
| Q4 | Period | **Weekly export (Mon–Sun) plus a month total.** |
| Q5 | Default times | Lunch 12:00–16:00 (12:00–15:30 when an evening shift follows the same day), evening 17:30–23:00. **Editable in settings.** |
| Q6 | Calendar events | Title **"Kellnern"**, editable in settings. The shift type is not needed in the title: the app finds its events by the stored event ID, so the title is free text. Planned and actual times and hours go in the event description. |
| Q7 | Sync direction | **One-way (app → calendar)** for v1. |
| Q8 | Forgotten stop | **Reminder at planned end + 30 min** ("Still working?"). Actions: "Stop at planned end" / "Stop now" / ignore. |
| Q9 | Phone | Probably a **Xiaomi** (MIUI/HyperOS), at most ~5 years old and kept updated. **minSdk 29 (Android 10)**, targeting the latest SDK. See the Xiaomi notes below. |
| Q10 | Shift types | Quick buttons for **Mittag** and **Abend**, plus a **custom shift** with free times. |

### Proposed export format (Q3/Q4)

Messengers use proportional fonts, so the format uses one line per day rather than column alignment:

```
Arbeitszeiten KW 45 (03.11.–09.11.2026)
Mo 03.11.: 12:00–15:30 (3,5 h), 17:30–23:00 (5,5 h)
Di 04.11.: 17:30–22:45 (5,25 h)
Fr 07.11.: 12:00–16:00, 30 min Pause (3,5 h)
Woche gesamt: 17,75 h
November bisher: 42,75 h
```

- Shift hours are net (after the break).
- The month line is the total of all recorded shifts in the calendar month up to the end of the exported week. It can be switched off in settings.
- When a week spans two months, the month line refers to the month of the week's last day. Whether a second line for the earlier month is wanted is a design-step detail.
- Days without shifts are left out.

### Xiaomi (MIUI / HyperOS) notes (Q9)

Xiaomi is one of the most aggressive vendors at killing background apps (see dontkillmyapp.com). What this means for us:
- **Autostart** is off by default for sideloaded apps. Without it, the `BOOT_COMPLETED` receiver doesn't run after a reboot, and reminders aren't rescheduled. Mitigations:
  - The app re-syncs all alarms every time it is opened.
  - Onboarding shows a hint with a deep link to the Autostart settings.
- **Battery saver** should be set to "No restrictions" for the app, otherwise alarms and notification actions may be delayed. This also goes into the onboarding hint.
- The **exact alarm** permission ("Alarms & reminders") still has to be granted on Android 14+, just as on other phones.
- The live-timer design is robust here: it relies only on a stored start timestamp and the system chronometer, and needs no running process. Even if the notification is lost, the recording isn't.
- About minSdk: Android 10 vs 11+ makes no practical difference for our features (notification actions, chronometer and exact alarms all exist since earlier versions). 29 keeps colleagues' older phones supported. All we actually rely on is a phone from 2021 or later being on Android 11–15.
- Test on her actual phone early, since the emulator won't show Xiaomi's quirks.

### Further decisions

- **Framework: Flutter.** Develop in VS Code; Android first, iOS kept possible.
- **Month total in the export: kept.** A setting ("Monatssumme im Export") can turn it off if the boss doesn't want it.
- **Breaks: entered afterwards** by editing the shift. There is no pause button in the live notification for v1.
- **New feature F8, month overview in the app:**
  - **Recorded:** hours actually worked so far this month.
  - **Planned:** recorded hours plus all still-upcoming planned shifts this month, i.e. the expected month total.
  - Shown prominently, e.g. as a header on the planning tab or as a small dashboard. The exact placement is a design-step decision.
  - Useful for keeping an eye on an hours cap (e.g. Minijob).
- **New feature F9, appearance (Darstellung):**
  - **Colour is selectable.** The default is "AKAI-Rot" (seed `#8F4C38`); a few preset colours are offered; and there is a **"Systemfarbe" option that follows the phone's wallpaper accent** (Android 12+ dynamic colour).
    - In Flutter, `dynamic_color` reads the system palette, and `ColorScheme.fromSeed` builds the full scheme from any preset colour.
    - On Android below 12, the system-colour option is hidden.
  - **Dark mode: Hell / Dunkel / System**, with System as the default. Flutter covers this with `ThemeMode` plus a light and a dark `ColorScheme` built from the same seed.
  - Both live in Settings › "Darstellung & Sprache", next to the language.

- **Calendar is shared and co-used:** the chosen calendar is shared between the two of you and also holds other joint events. The app only touches events it created (tracked by stored event ID).
- **Event colour is selectable** (Settings › Kalender › Termin-Farbe), using the Google account's event colours. The default is the calendar's own colour.
- **Edits made directly in Google Calendar** are overwritten by the app on the next change; the event description says so.
- **App events deleted in Google Calendar** are recreated by the app.
- The design is continued in [02-design.md](02-design.md).

## 8. Concept screens

- Interactive design canvas (private): https://claude.ai/artifact/7grRC9FNyoFRhYCEw6QmzV
- Source files are saved in [docs/concepts/](concepts/). They are `.dc.html` design-canvas files, which render only inside the canvas, not as standalone HTML.
- Screens:
  - Heute (idle)
  - Heute (recording running)
  - Plan (week, with interactive toggles)
  - Schicht bearbeiten (bottom sheet)
  - Export (with the month-total switch)
  - Einstellungen
  - Benachrichtigungen (reminder, running timer, "Noch bei der Arbeit?")
- Style: Material 3 Expressive, Roboto Flex, Material Symbols Rounded, light scheme from the AKAI-Rot seed.
- Added later:
  - Ersteinrichtung: Willkommen + Sprache, Erinnerungen (notifications + exact alarms), Kalender wählen, Xiaomi (Autostart + battery)
  - Termin-Farbe picker
  - Heute and Plan in dark mode
- Not drawn: the default-times onboarding step (it looks like the Settings section), and dark variants of the remaining screens (they use the same dark colour roles).

## 9. Tips (F10), 2026-11-05

Added after 1.1.0. Salary comes later and will go on the same tab.

### How tips work at AKAI

- All tips go into one pool. Each day's pool total is known.
- Kitchen and servers each get a share per workday. Her share depends on how many people worked that day, so it isn't a fixed rule.
- She is paid her tips **weekly, in cash**. The tip week runs Monday to Sunday, the same as the app's weeks. The restaurant is closed on Sundays.

### What she wants to record

| # | Feature | Notes |
|---|---------|-------|
| F10a | **Daily pool total ("Tagestopf")** | One number per day: the total tips of everyone combined, **not her share**. Optional. Only for days she worked, because those are the days that count for her. |
| F10b | **Weekly payout ("Ausgezahlt")** | The cash she actually received for the week. |

- Both numbers are **only for her own records**. They don't go into the export text.
- Amounts are euros with cents. Cents are shown only when they aren't zero ("40 €", "42,50 €").

### Decisions (the user, 2026-11-05)

- **A new tab, "Lohn"** (English "Pay"), rather than putting money on the Export screen. Export is a monthly task; money is recorded weekly. "Verdienst" was proposed first; the user chose "Lohn", which also fits once salary is added.
- **A prompt on "Heute"** asks for the day's pool total after she has worked.
- **Heute's month card** gets a third figure: tips this month.
- **No share estimate for now.** The app doesn't calculate what she should have got. That needs the number of people per day and is kept as a possible later feature.
- **No new dependencies.** `intl` formats euros.
- The tips model planned in `02-design.md` §14.2 (one entry per shift, kinds cash/card/pool) doesn't match this and is replaced in the design.

## Sources

- [Android developer verification rolling out (Android Developers Blog, 2026-03)](https://android-developers.googleblog.com/2026/03/android-developer-verification-rolling-out-to-all-developers.html)
- [Android developer verification 2026 explained (Doply)](https://www.doply.io/en/blog/android-developer-verification-explained)
- [Android sideloading changes 2026 (techzoom)](https://techzoom.org/android-sideloading-changes-2026/)
- [Play Console testing requirements for new personal accounts (Google support)](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB)
- [Google Play 12-testers rule (testerscommunity)](https://www.testerscommunity.com/guides/how-many-testers-do-you-need-google-play)
- [device_calendar_plus (pub.dev)](https://pub.dev/packages/device_calendar_plus)
