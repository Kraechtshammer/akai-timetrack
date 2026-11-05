# AKAI Timetrack – Research

Status: research step (before design and implementation). As of 2026-11-04; §9 and §10 added on 2026-11-05.

## 1. Problem and current workflow

- The user works as a server at AKAI. There are two shift types:
  - **Lunch:** ~12:00–16:00, or ~12:00–15:30 when an evening shift follows.
  - **Evening:** ~17:30–23:00.
- What the user does today, in Google Calendar:
  1. When the week's plan comes out, the user creates one event per shift with the approximate times.
  2. After each shift, the user corrects the event to the actual times.
  3. At the end of the week, the user types up the hours by hand and texts them to the boss.
- Pain points: duplicate manual entry, easy to forget the correction, and the weekly summary is assembled by hand.

## 2. Target features (as requested)

| # | Feature | Notes |
|---|---------|-------|
| F1 | **Shift planning** tab | Week view. Tap Lunch or Evening per day to add a planned shift with default times. Edit start/end; delete. |
| F2 | **Google Calendar sync** | Planned shifts (and later the actual times) appear in the user's Google Calendar, which the developer can see too. |
| F3 | **Pre-shift reminder** | Notification X minutes before the planned start (default 15, configurable) with a "Start" button. |
| F4 | **Live recording notification** | While recording, the notification shows elapsed time plus a "Stop" button. On stop, the times are rounded to the quarter hour and written to the shift. |
| F5 | **Manual correction** | Edit actual start/end by hand (for when the user forgot to start or stop). |
| F6 | **Weekly export** | Build a text from the week's actual times, then copy it or share it into WhatsApp/Signal/SMS. |
| F7 | **Localization** | German by default, English optional. |

## 3. Technical findings per feature

### 3.1 Calendar sync (F2): use the on-device calendar, not the Google Calendar API

There are two ways to get events into Google Calendar.

**A) Android Calendar Provider (`CalendarContract`). Recommended.**
- The app writes events into a calendar that already exists on the phone and belongs to the user's Google account. Android's own Google sync then uploads them to Google Calendar.
- No Google Cloud project, no OAuth, no API keys, no Google app verification. The only thing needed is the `READ_CALENDAR` / `WRITE_CALENDAR` runtime permission.
- Works offline; sync happens whenever the phone syncs.
- iOS has an equivalent, EventKit, which works if the user's Google account is added in iOS Settings. Cross-platform plugins wrap both (e.g. Flutter `device_calendar_plus`, `expo-calendar`).
- Limitation: apps **cannot create a new Google-synced calendar** through the provider; only local, unsynced calendars can be created that way. Suggested setup:
  1. The user creates a calendar called **"AKAI Shifts"** once in Google Calendar on the web.
  2. The user shares it with the developer (read access).
  3. The app lets the user pick that calendar once in its settings.
  - Side benefit: work shifts stay separate from private events, and the developer can see only the shifts.
- The app keeps its own database as the **source of truth** and stores each shift's calendar event ID. The calendar is a **mirror**.
- Recommendation for v1: **one-way sync (app → calendar).** If the user edits the event directly in Google Calendar, the app overwrites it on the next change. Two-way sync is possible later but adds conflict handling.

**B) Google Calendar REST API with OAuth.** Not recommended.
- Needs a Google Cloud project and an OAuth consent screen.
- Calendar scopes are "sensitive", so Google verification is needed once there are more than 100 users. That matters if colleagues use the app.
- More code: token handling and network errors.
- Only worth it if the app ever needs a backend or web version.

### 3.2 Pre-shift reminder (F3)

- A notification is scheduled for each planned shift at `start − lead time`. It is rescheduled whenever a shift is edited or deleted, and after a reboot (Android clears alarms on reboot, so the app needs a `BOOT_COMPLETED` receiver).
- **Exact timing:** since Android 14, `SCHEDULE_EXACT_ALARM` is no longer granted by default. The app has to send the user once to the "Alarms & reminders" settings page to allow it.
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
- On stop: the actual start and end are rounded to the quarter hour, the shift is saved, the calendar event is updated (title, and possibly the description, changes from "planned" to actual), and the notification is dismissed.
- **The rounding rule needs a decision** (open question Q1). Options:
  - nearest quarter hour;
  - in the user's favour: start rounded down, end rounded up;
  - strict: start rounded up, end rounded down.
  - The restaurant's rule may be fixed already. The rule should be a setting with a sensible default.

### 3.4 Manual correction (F5)

- Planned times and actual times are stored as separate fields, so the plan is never lost and the export uses actual times when they exist.
- Edit sheet with time pickers in 5-minute or 15-minute steps. A "Start now" action is also available inside the app (and is the fallback whenever the notification flow isn't used).
- "I forgot to start" case: open the shift, choose "Start recording with the planned time", or simply edit the time afterwards.

### 3.5 Weekly export (F6)

- The text is generated from a template, then copied to the clipboard or sent through Android's share sheet straight into WhatsApp or another messenger.
- Example (format to be agreed; the user should show us the current message):
  ```
  Working hours CW 45 (03/11–09/11)
  Mon 03/11  12:00–15:30, 17:30–23:00  (9.0 h)
  Tue 04/11  17:30–22:45               (5.25 h)
  ...
  Total: 27.75 h
  ```
- Open: Is the week Mon–Sun? Hours as decimals or h:mm? Are breaks deducted? See Q2–Q4.

### 3.6 Localization (F7)

- Both Flutter and native Android support this through standard resource files (ARB files in Flutter, `strings.xml` natively).
- German is the default, with English added as a second file. Date and number formats come from the locale (`03/11` or `03.11.`, `9.5 h` or `9,5 h`).

### 3.7 Data and backup

- Local SQLite database only. No server and no account inside the app.
- Android Auto Backup stores the database in the user's Google Drive backup automatically, which covers a phone change. Since the calendar holds a copy of every shift, the risk of losing data is small anyway.
- Privacy: no data leaves the phone except through Google Calendar sync and the export the user triggers. That keeps a possible Play Store data-safety declaration trivial.

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

If the developer is sure iOS will never matter and doesn't mind Android Studio, native Kotlin/Compose would be equally good, and slightly better for Android-only details.

### What "iOS later" really costs (for any framework)

- **A Mac is required** to build and sign iOS apps. The alternative is a cloud build service (Codemagic, GitHub Actions macOS runners, Expo EAS), but you still need a Mac or a device to test on.
- **The live timer on iOS** requires a **Live Activity** (ActivityKit). That is a small widget extension written in Swift, whatever framework the app uses; regular iOS notifications can't show a running timer.
  - Action buttons ("Start"/"Stop") in regular iOS notifications do work.
- iOS has no exact-alarm restriction for local notifications, which is simpler than Android.

## 5. Tooling on Windows (Flutter path)

1. **Flutter SDK.** Download the zip, or let the VS Code Flutter extension install it. Add it to `PATH`.
2. **Android SDK and emulator.** The easiest route is installing **Android Studio** once, only to get the SDK, platform tools, the emulator and a JDK; afterwards it can stay closed. (The command-line tools work too but are fiddlier.)
3. **VS Code** with the **Flutter** extension (it pulls in Dart).
4. **A real phone.** Enable Developer options and USB debugging (or wireless debugging), then run `flutter run` straight onto the user's phone or the developer's.
5. `flutter doctor` checks the setup.
6. Optional: Git with a private GitHub repo, for backup and later CI builds.

## 6. Accounts and registrations

| What | Needed for | Cost / effort |
|------|-----------|---------------|
| Nothing | Developing, running on the emulator, installing on your own phones via USB/`adb` | Free |
| **Android developer verification**: "limited distribution" (hobbyist) account | Installing the APK on certified Android devices **by normal sideloading** once enforcement reaches Germany. Enforcement started 2026-09-30 in BR/ID/SG/TH; **global rollout is planned for 2027**. | Free, no government ID, up to **20 devices**. Enough for the user and some colleagues. `adb` install from a computer stays possible without it. |
| **Google Play Console** | Play Store release (for colleagues at scale) | US$25 one-time and ID verification. New personal accounts must run a **closed test with ≥12 testers for 14 consecutive days per app** before going public. |
| Google Cloud project and OAuth consent | Only if we used the Calendar REST API | **Avoided** by using the on-device calendar |
| Expo account | Only on the React Native/Expo path (EAS cloud builds) | Free tier available |
| Apple ID (free) | Installing on the developer's own iPhone from Xcode | Free; the app expires after **7 days** |
| Apple Developer Program | TestFlight / App Store | US$99 per year, plus a Mac |

**Practical path:**
1. Develop and test via USB. No accounts needed.
2. Once global verification enforcement nears (2027), register a free limited-distribution account so the user, and maybe colleagues, can keep installing and updating normally.
3. Only consider Play Store or iOS if colleagues show real interest.

## 7. Decisions (answers to the open questions, 2026-11-04)

| # | Topic | Decision |
|---|-------|----------|
| Q1 | Rounding | **Nearest quarter hour** for both start and end (12:07 → 12:00, 12:08 → 12:15; exactly x:07:30 rounds up). Kept as a setting so another rule can be chosen later. |
| Q2 | Breaks | **Optional break per shift**, in minutes. It is subtracted from the shift's hours and shown in the export. |
| Q3 | Export format | **Decimal hours, plus start and end times.** No example of the user's current message was available, so the format below is a proposal. |
| Q4 | Period | **Weekly export (Mon–Sun) plus a month total.** |
| Q5 | Default times | Lunch 12:00–16:00 (12:00–15:30 when an evening shift follows the same day), evening 17:30–23:00. **Editable in settings.** |
| Q6 | Calendar events | Title `Kellnern` (the default value in the code), editable in settings. The shift type is not needed in the title: the app finds its events by the stored event ID, so the title is free text. Planned and actual times and hours go in the event description. |
| Q7 | Sync direction | **One-way (app → calendar)** for v1. |
| Q8 | Forgotten stop | **Reminder at planned end + 30 min** ("Still working?"). Actions: "Stop at planned end" / "Stop now" / ignore. |
| Q9 | Phone | Probably a **Xiaomi** (MIUI/HyperOS), at most ~5 years old and kept updated. **minSdk 29 (Android 10)**, targeting the latest SDK. See the Xiaomi notes below. |
| Q10 | Shift types | Quick buttons for **Lunch** and **Evening**, plus a **custom shift** with free times. |

### Proposed export format (Q3/Q4)

Messengers use proportional fonts, so the format uses one line per day rather than column alignment:

```
Working hours CW 45 (03/11–09/11/2026)
Mon 03/11: 12:00–15:30 (3.5 h), 17:30–23:00 (5.5 h)
Tue 04/11: 17:30–22:45 (5.25 h)
Fri 07/11: 12:00–16:00, 30 min break (3.5 h)
Week total: 17.75 h
November so far: 42.75 h
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
- Test on the user's actual phone early, since the emulator won't show Xiaomi's quirks.

### Further decisions

- **Framework: Flutter.** Develop in VS Code; Android first, iOS kept possible.
- **Month total in the export: kept.** A setting can turn it off if the boss doesn't want it.
- **Breaks: entered afterwards** by editing the shift. There is no pause button in the live notification for v1.
- **New feature F8, month overview in the app:**
  - **Recorded:** hours actually worked so far this month.
  - **Planned:** recorded hours plus all still-upcoming planned shifts this month, i.e. the expected month total.
  - Shown prominently, e.g. as a header on the planning tab or as a small dashboard. The exact placement is a design-step decision.
  - Useful for keeping an eye on an hours cap (e.g. Minijob).
- **New feature F9, appearance:**
  - **Colour is selectable.** The default is "AKAI red" (seed `#8F4C38`); a few preset colours are offered; and there is a **"System color" option that follows the phone's wallpaper accent** (Android 12+ dynamic colour).
    - In Flutter, `dynamic_color` reads the system palette, and `ColorScheme.fromSeed` builds the full scheme from any preset colour.
    - On Android below 12, the system-colour option is hidden.
  - **Dark mode: Light / Dark / System**, with System as the default. Flutter covers this with `ThemeMode` plus a light and a dark `ColorScheme` built from the same seed.
  - Both live in Settings › "Appearance & language", next to the language.

- **Calendar is shared and co-used:** the chosen calendar is shared between the user and the developer and also holds other joint events. The app only touches events it created (tracked by stored event ID).
- **Event colour is selectable** (Settings › Calendar › Event color), using the Google account's event colours. The default is the calendar's own colour.
- **Edits made directly in Google Calendar** are overwritten by the app on the next change; the event description says so.
- **App events deleted in Google Calendar** are recreated by the app.
- The design is continued in [02-design.md](02-design.md).

## 8. Concept screens

- Interactive design canvas (private): https://claude.ai/artifact/7grRC9FNyoFRhYCEw6QmzV
- Source files are saved in [docs/concepts/](concepts/). They are `.dc.html` design-canvas files, which render only inside the canvas, not as standalone HTML.
- Screens:
  - Home (idle; the concepts call this tab "Today")
  - Home (recording running)
  - Plan (week, with interactive toggles)
  - Edit shift (bottom sheet)
  - Export (with the month-total switch)
  - Settings
  - Notifications (reminder, running timer, "Still at work?")
- Style: Material 3 Expressive, Roboto Flex, Material Symbols Rounded, light scheme from the AKAI-Rot seed.
- Added later:
  - First-run setup: Welcome + language, Reminders (notifications + exact alarms), Choose a calendar, Xiaomi (autostart + battery)
  - Event color picker
  - Home and Plan in dark mode
- Not drawn: the default-times onboarding step (it looks like the Settings section), and dark variants of the remaining screens (they use the same dark colour roles).

## 9. Tips (F10), 2026-11-05

Added after 1.1.0. Salary comes later and will go on the same tab.

### How tips work at AKAI

- All tips go into one pool. Each day's pool total is known.
- Kitchen and servers each get a share per workday. The user's share depends on how many people worked that day, so it isn't a fixed rule.
- The user is paid the tips **weekly, in cash**. The tip week runs Monday to Sunday, the same as the app's weeks. The restaurant is closed on Sundays.

### What the user wants to record

| # | Feature | Notes |
|---|---------|-------|
| F10a | **Daily pool total ("Daily pool")** | One number per day: the total tips of everyone combined, **not the user's share**. Optional. Only for days the user worked, because those are the days that count. |
| F10b | **Weekly payout ("Paid out")** | The cash the user actually received for the week. |

- Both numbers are **only for the user's own records**. They don't go into the export text.
- Amounts are euros with cents. Cents are shown only when they aren't zero ("€40", "€42.50" in English).

### Decisions (the developer, 2026-11-05)

- **A new tab, "Pay"**, rather than putting money on the Export screen. Export is a monthly task; money is recorded weekly. "Earnings" was proposed first; the developer chose "Pay", which also fits once salary is added.
- **A prompt on the Home tab** asks for the day's pool total after the user has worked.
- **The Home tab's month card** gets a third figure: tips this month.
- **No share estimate for now.** The app doesn't calculate what the user should have got. That needs the number of people per day and is kept as a possible later feature.
- **No new dependencies.** `intl` formats euros.
- The tips model planned in `02-design.md` §14.2 (one entry per shift, kinds cash/card/pool) doesn't match this and is replaced in the design.

## 10. Team shift planner (F11), 2026-11-05

Research only. Nothing is decided yet; the open questions are at the end.

### The situation

- The boss is away in November 2026. The user stands in for some of the boss's tasks, among them the weekly shift plan for the service staff (kitchen is out of scope for now).
- Today's workflow without the app:
  1. Each server tells the user when they can work next week. Some say when they **can** ("Mon and Thu evening"), others when they **can't** ("not Friday").
  2. The user builds the plan from these answers: who works which lunch and evening shift.
  3. The user posts the plan as a picture in the team chat.
- Step 2 is the hard part: keeping everyone's answers in mind, filling every shift, and spreading the shifts fairly.

### What the developer asked for

| # | Feature | Notes |
|---|---------|-------|
| F11a | **People** | A list of colleagues by name, kept across weeks. Service staff only for now. |
| F11b | **Availability per week** | One page per person. A switch at the top picks whether the user enters the times the person **can** or **can't** work. Whole days or single shifts can be marked. The user goes through all people in turn and ends on the board. |
| F11c | **Board** | A week plan where the user sorts people into the shifts. |
| F11d | **Staff needed per shift** | Default numbers per shift, which can be changed for a week on the board. |
| F11e | **Fill** (if cheap) | Fills the empty places from the available people, spreading shifts evenly. Places filled by hand stay. |
| F11f | **Clear** | Empties the board. |
| F11g | **Share as image** | A widescreen PNG of the whole week, laid out like a timetable, shared into the chat. |
| F11h | **Special start time** (extra) | Per person and shift, e.g. someone starts the evening at 18:30. Shown as a small note next to the name in the image. |

### Is it feasible?

Yes. Every part can be built with what the app already has, with **no new dependencies**:

| Part | How | Risk |
|---|---|---|
| People, availability, board | New drift tables (additive migration, schema version 4) and repositories, like tips and wage rates. | Low. The migration pattern and its tests exist. |
| Moving people into shifts | Tap a shift, pick people from a sheet. Flutter's built-in `LongPressDraggable` / `DragTarget` would allow drag and drop too. | Low for tap-to-pick. Drag and drop on a portrait phone is fiddly (see below). |
| Fill | A small greedy algorithm in pure Dart (`domain/`), unit-tested. | Low. A plan for ~8 people and 12 shifts is tiny. |
| PNG | Lay the image out as a normal widget at a fixed size (e.g. 1600 × 900 logical pixels), wrap it in a `RepaintBoundary` and call `toImage(pixelRatio: …)` from `dart:ui`. Then `toByteData(format: png)` into a temp file (`path_provider`, already used). | Low. Shown on a preview screen inside a `FittedBox`, the image still renders at full size, because `toImage` uses the boundary's own layout size, not the scaled size on screen. Rendering without showing it is also possible (an own `PipelineOwner`/`BuildOwner`, as `flutter_widget_to_image` does), but a preview is wanted anyway. |
| Sharing | `share_plus` (already used for the export text) with `ShareParams(files: [XFile(path)])`. | Low. |

**Image size and the chat.** WhatsApp sends photos in "Standard" quality by default and scales them down to about 1600 px on the long edge; "HD" keeps more, and sending as a document keeps the original. So the image is designed to be readable at **1600 × 900** (16:9): names at least ~26 px high there. Rendered at 1920 × 1080 it still looks sharp on phones that show the HD version.

**Size of the job.** Bigger than tips and salary together: 4–5 tables, a domain file with the fill rules, about five screens (people, availability, board, slot sheet, image preview), and roughly 60–80 new strings in two languages. Two to three sessions. A useful first version (everything except drag and drop and the extras marked below) fits in one long session if the decisions are made up front.

### In this app or a separate app?

| | In TimeTrack | Separate app |
|---|---|---|
| Setup | None. Database, theming, l10n, `WeekSwitcher`, ISO weeks, update and release pipeline are all there. | New package name, launcher icon, onboarding, CI and release workflow, own update channel (a second GitHub repo or a tag scheme). About a session before the first useful screen. |
| For the user | Comes with the next in-app update. Nothing new to install. | A second sideloaded app, with "install unknown apps" again. |
| Own shifts | The user is often on the plan too. Their shifts can go straight onto the Plan tab, and from there into the calendar. | Not possible without an app-to-app link. |
| Scope | The app grows from "my hours" to "the team's plan". Colleagues who get TimeTrack later would see a feature they don't need. | Clean split. Could later go to whoever plans after the boss is back. |
| Risk | A migration in the app that holds the user's hours and pay. Low: migrations only add tables and are tested. | None for the existing app. |

**Recommendation: build it into TimeTrack, as a module that is off by default.**
- A switch in Settings ("Team planner") shows the feature; without it, nothing changes. Colleagues who get the app later won't see it.
- When on, a fifth tab "Team" (German "Dienstplan") appears. Five tabs is the maximum Material allows; an entry in the Plan tab's header is the alternative if five feels crowded.
- Its code stays in its own files (`domain/roster.dart`, `data/roster_repository.dart`, `ui/roster/`), its own tables, and no ties into calendar sync or reminders. It could be moved into a separate app later.

### Behaviour, part by part

**People (F11a)**
- A name is all that's needed. The list is sorted by name.
- A person can be **set inactive** (on leave, left the restaurant). Inactive people don't appear in new weeks but stay in old plans. Deleting is only offered for people with no plan entries. *(Dropped on 2026-11-05, see decision 12.)*
- A person can be marked as a **core worker** (the developer's idea, 2026-11-05). Core workers are the experienced staff; usually each shift has one. The mark is kept per person, not per week.
- One person can be marked as **"This is me"**, for the link to the Plan tab (see "Own shifts").
- Kitchen staff later: a `role` column on the table now keeps that possible, but the UI ignores it.

**The week and its shifts**
- A plan belongs to an ISO week, Monday to Sunday, like the rest of the app. The planner opens on **next week**, because that's what the user plans.
- Shifts are Lunch and Evening per day. A shift with **0 staff needed** counts as closed: it is hidden on the board and in the image. That covers the closed Sunday (and any closed lunch) without an extra "open days" setting.
- Defaults: a staff count per weekday and shift (e.g. Mon–Thu 2/3, Fri–Sat 3/5, Sun 0/0) and a start time per shift for the image (Lunch 12:00, Evening 17:30). The board can change a count for one week.

**Availability (F11b)**
- One page per person. At the top the switch **"Can work" / "Can't work"**. Below, the week as rows of days, each with a Lunch and an Evening toggle; tapping the day name toggles both.
- What a mark means depends on the switch. In "Can work" mode, unmarked shifts are unavailable; in "Can't work" mode, unmarked shifts are available. A line under the grid spells out the result ("Available: Mon evening, Thu, Sat lunch"), so a wrong switch is easy to spot.
- Flipping the switch after marking: keep the marks and change their meaning (the user most likely picked the wrong mode before typing the answer in). The summary line shows the effect at once.
- **"No answer yet"** is a separate state: a person whose page hasn't been filled in. Fill doesn't use them, and the board shows them with a hint, so a missing answer isn't mistaken for "can't work".
- Optional per person and week: **"At most N shifts"**, because people often say "max three shifts". Fill respects it.
- **Walk-through:** "Next" and "Back" with "3 of 7" at the top, ending on the board. Each page can also be opened on its own from the board later.
- Maybe: "Same as last week" to copy a person's answer, for people with fixed patterns.

**Board (F11c, F11d)**
- Portrait phone: one card per open day, listed down the page. Each card has a Lunch and an Evening row with the assigned names as chips and a count like "2/3". The count turns into a warning when short and a different colour when over.
- **Tap a row** → a sheet with the people:
  - available people first, sorted by how few shifts they have this week, each with their count ("2 shifts");
  - **core workers on top while the shift has none yet:** if no core worker is in the shift, the available core workers come first, whatever their shift count. Among themselves they are sorted the same way (fewest shifts first). Once a core worker is in the shift, the list goes back to the normal order. Core workers carry a small mark in the sheet and on the board;
  - people without an answer, then people who can't work, collapsed and dimmed. They can still be picked, with a warning, because the user may know better than the form.
  - a "Staff needed" stepper (− 3 +) for this shift and week.
- **Tap a chip** → set a special start time or remove the person.
- A strip or list "Shifts per person" shows how many shifts each person has and could have had, so the spread is visible at a glance.
- **Drag and drop** (maybe later): dragging chips between rows works with Flutter's built-in widgets, but on a portrait screen the target rows are often off-screen and the list must scroll while dragging. A landscape grid (days as columns) would suit drag and drop better. Tap-to-pick first.

**Fill (F11e)**
- Keeps everything placed by hand. Only fills empty places.
- Rule: repeatedly take the open place with the **fewest possible people** (hardest to fill first), and give it to the available person with the **fewest shifts so far** this week. Ties go to the person with fewer remaining options, then by name.
- Core workers, by the same rule as the sheet: a shift without a core worker gets an available core worker first, then the rest is filled normally. Probably in two passes: first one core worker per shift (hardest shifts first), then the remaining places. A shift where no core worker is available is flagged on the board ("No core worker").
- It respects availability and "At most N shifts", never puts someone twice in one shift, and avoids lunch plus evening on the same day while anyone else is free.
- "Evenly" means equal **number of shifts**. Equal **hours** (evening shifts are longer) is an alternative.
- Afterwards a snack bar: "Filled 9 places · 2 still open" with "Undo".
- Deterministic: the same input gives the same plan. A "Shuffle" that breaks ties randomly could offer alternatives; probably not needed.

**Clear (F11f)**
- Removes all people from the week's shifts. The availability stays. A snack bar with "Undo" (with `persist: false`).

**Image (F11g, F11h)**
- 16:9, white background and dark text, with AKAI red as the accent, whatever the app's theme, so it reads the same in every chat.
- Top: "Shift plan · Week 46 · 9–14 Nov".
- Columns: the open days, with weekday and date. Rows: Lunch and Evening, each with its start time. Cells: the names, one per line. A special start time is a small note after the name ("from 18:30").
- Many names in one cell: the font shrinks to fit, down to a minimum.
- Language: the app language (German for the AKAI chat).
- Open places are not shown in the image, only on the board.
- Flow: "Share" on the board → preview screen with the image → "Share" opens the share sheet. The PNG is written to the app's cache and replaced on the next share.

**Own shifts (maybe)**
- If a person is marked "This is me", the board offers "Add my shifts to Plan". It creates planned Lunch/Evening shifts for that week on the Plan tab (with the special start time, if any), which then sync to the calendar as usual. Shifts already on the Plan tab are not duplicated.

**Privacy**
- The colleagues' names stay in the app's database on the phone. They are in Android's device backup like all app data, but never in the calendar, the export text or the docs.

### Open questions for the developer

1. **Where:** in TimeTrack, behind a switch in Settings (recommended), or a separate app?
2. **Entry point:** a fifth tab when the switch is on (recommended), or a button in the Plan tab's header?
3. **Is the user on the plan too?** If yes, "This is me" and "Add my shifts to Plan" are worth building.
4. **Opening hours:** which days are lunch and evening served? Sunday closed is known from the tips research. Typical staff counts per shift, for the defaults?
5. **Scope of the first version:** the recommendation is everything in F11a–F11h with tap-to-pick, and to leave drag and drop, "Same as last week" and "Shuffle" for later. When is the first plan needed?
6. **"Evenly":** equal number of shifts (recommended) or equal hours?
7. **Not-yet-answered people:** keep them out of Fill (recommended), or treat them as available?
8. **Image:** show open places ("1 open") in the shared image or not (recommended: not)? White image (recommended) or following the app's dark/light theme?
9. **Names in the UI:** "Team" / "Dienstplan" for the tab, "Fill" / "Auffüllen" and "Clear" / "Leeren" for the buttons. Other preferences?
10. **Core workers:** should Fill also put one in each shift first (proposed above), and should a shift without one get a warning on the board? Should the image mark them (proposed: no)?

### Decisions (the developer, 2026-11-05)

1. **In TimeTrack**, behind a switch in Settings. No separate app.
2. **A fifth tab** while the switch is on. The name is open: the developer decides on the built screen.
3. **The user is on the plan**, under their own name, like everyone else. "This is me" and "Add my shifts to Plan" are in.
4. **Lunch and evening on every day except Sunday.** Defaults: 2 people at lunch, 3 in the evening; the real numbers come later. Staff counts and closed days are set in Settings, in a section of their own.
5. **First version:** F11a–F11h with tap-to-pick. Drag and drop, "Same as last week" and "Shuffle" wait.
6. **"Evenly" = the same number of shifts**, except that each shift gets a core worker first.
7. **People without an answer stay out of Fill.**
8. **Image:** open places are not shown; always light, whatever the app's theme.
9. **Names:** "Fill" / "Auffüllen", "Clear" / "Leeren".
10. **Core workers:** a shift without one gets a "No core worker" warning on the board. The image doesn't mark core workers.
11. **Core workers cost more** (added while testing, 2026-11-05). After a shift has its core worker, Fill and the shift sheet prefer people who aren't core workers.
12. **Vacation** is an answer: the answer page gets an "Away this week" button. **No "inactive" state:** it was built first and then dropped as confusing. People who leave for longer are deleted (with their answers and shifts) and added again later.

## Sources

- [Android developer verification rolling out (Android Developers Blog, 2026-03)](https://android-developers.googleblog.com/2026/03/android-developer-verification-rolling-out-to-all-developers.html)
- [Android developer verification 2026 explained (Doply)](https://www.doply.io/en/blog/android-developer-verification-explained)
- [Android sideloading changes 2026 (techzoom)](https://techzoom.org/android-sideloading-changes-2026/)
- [Play Console testing requirements for new personal accounts (Google support)](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB)
- [Google Play 12-testers rule (testerscommunity)](https://www.testerscommunity.com/guides/how-many-testers-do-you-need-google-play)
- [device_calendar_plus (pub.dev)](https://pub.dev/packages/device_calendar_plus)
- [WhatsApp image sizes and the Standard/HD split (Chatarmin)](https://chatarmin.com/en/blog/whats-app-image-size-guide)
- [WhatsApp HD photos (GSMArena, 2023)](https://www.gsmarena.com/newscomm-59587.php)
- [OffscreenWidgetTree: rendering a widget to an image without showing it (flutter_widget_to_image, pub.dev)](https://pub.dev/documentation/flutter_widget_to_image/latest/flutter_widget_to_image/OffscreenWidgetTree-class.html)
