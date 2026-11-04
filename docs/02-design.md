# AKAI Timetrack – Design

Status: design step. As of 2026-11-04.
Inputs: [01-research.md](01-research.md) (features F1–F9, decisions Q1–Q10) and the approved concept screens in [concepts/](concepts/) ([canvas](https://claude.ai/artifact/7grRC9FNyoFRhYCEw6QmzV)).

## 1. Scope of v1

In scope:
- **Plan:** plan shifts, with Mittag/Abend quick toggles and custom shifts.
- **Recording:** record time from the app or from notifications.
- **Editing:** correct shift times by hand, including breaks.
- **Calendar sync:** one-way sync to a chosen Google calendar, with a selectable event colour.
- **Export:** weekly text with optional month totals.
- **Overview:** month figures in the app.
- **Appearance:** language DE/EN, selectable colour including system colour, light/dark/system.
- **Onboarding:** permissions, calendar choice, Xiaomi hints.
- **Platform:** Android only, minSdk 29 (Android 10), targeting the latest SDK.

Out of scope for v1:
- iOS.
- Two-way calendar sync.
- Pause button in the live notification.
- Backend or accounts.
- Play Store release.
- Lock-screen "Live Updates" (Android 16).

## 2. Architecture

```
┌──────────────── UI (Flutter widgets) ────────────────┐
│ Heute · Plan · Schicht-Sheet · Export · Einstellungen │
│ Onboarding                                            │
└───────────────┬──────────────────────────────────────┘
                │ Riverpod providers (watch DB streams)
┌───────────────▼──────────────────────────────────────┐
│ Domain services (pure Dart, unit-tested)              │
│  PlanningService   RecordingService   ExportService   │
│  MonthSummary      ReminderPlanner    Rounding        │
└───────┬───────────────────┬──────────────────┬───────┘
        │                   │                  │
┌───────▼──────┐  ┌─────────▼────────┐  ┌──────▼─────────────┐
│ Drift/SQLite │  │ NotificationSvc  │  │ CalendarSync       │
│ (source of   │  │ flutter_local_   │  │ → CalendarGateway  │
│  truth)      │  │ notifications    │  │   (own Kotlin      │
└──────────────┘  └──────────────────┘  │   bridge, Pigeon)  │
                                        └────────────────────┘
```

Principles:
- **The local database is the only source of truth.** The calendar and the notifications are derived from it and can be rebuilt from it at any time ("reconcile").
- **Each write marks the shift as needing an update.** A shift change only writes to the database and flags the shift for a calendar update. A reconcile step then brings the calendar and notifications in line. If a step fails (no permission, background isolate, app killed), nothing is lost; it catches up on the next run.
- **Domain logic is pure Dart and has no Flutter dependency.** Rounding, export text, month totals and "which notifications should exist" are plain functions, so they are easy to unit-test.

### Packages

| Concern | Package | Note |
|---|---|---|
| Database | `drift` + `sqlite3_flutter_libs` | Type-safe SQL with reactive streams. WAL mode so the background isolate can write. |
| State | `flutter_riverpod` | Providers wrap drift streams. |
| Navigation | `go_router` | 3 tabs (StatefulShellRoute), settings, onboarding, and deep links from notification taps. |
| Notifications | `flutter_local_notifications` + `timezone` + `flutter_timezone` | Exact scheduling, action buttons with a background handler, chronometer. Re-schedules after reboot by itself. |
| Calendar | **own Kotlin bridge via `pigeon`** | See §5. |
| Colour | `dynamic_color` | System colour (Android 12+). |
| i18n | `flutter_localizations`, `intl`, gen-l10n (ARB) | `app_de.arb` (template), `app_en.arb`. |
| Sharing | `share_plus` | Android share sheet. Copying uses `Clipboard` from `services`. |
| Device info | `device_info_plus` | Detect Xiaomi/Redmi/POCO to show the extra hints. |
| Settings intents | `android_intent_plus` | Open the Autostart, battery and exact-alarm settings pages. |

## 3. Data model

### Table `shifts`

| Column | Type | Meaning |
|---|---|---|
| `id` | text PK (UUID v4) | Random, globally unique ID instead of an auto-increment number. A backup can then be restored or merged into an existing database without ID clashes (§14). Notification IDs use a separate small int column, `notifId`. |
| `notifId` | int, unique, auto-increment | Only for notification IDs, which Android requires to be ints. Never leaves the device. |
| `day` | text `yyyy-MM-dd` | Local date the shift belongs to (its start date). Used for week and month grouping. |
| `type` | enum `lunch` / `evening` / `custom` | |
| `plannedStart`, `plannedEnd` | DateTime (stored as UTC epoch ms) | |
| `plannedCustomized` | bool | True once she edits the planned times by hand. Stops automatic default-time adjustments (§4.1). |
| `rawStart`, `rawEnd` | DateTime? | Exact recorded timestamps. `rawStart != null && rawEnd == null` means **recording is running**. |
| `actualStart`, `actualEnd` | DateTime? | Rounded times (after Stop) or times entered by hand. These are what counts. |
| `breakMinutes` | int, default 0 | |
| `calendarEventId` | text? | Event ID in the Calendar Provider. |
| `calendarId` | text? | The calendar the event lives in. Needed when the calendar setting changes. |
| `syncState` | enum `synced` / `dirty` / `pendingDelete` | Tells the calendar sync what to do. |
| `createdAt`, `updatedAt` | DateTime | |

Rules:
- **At most one running shift.** Enforced in `RecordingService`.
- **Deleting a shift** sets `pendingDelete`. The row is removed once the calendar event is deleted, or right away if it never had an event.
- **Derived status:**
  - `planned`: no actuals, start in the future.
  - `missed`: no actuals, planned end in the past. Shown as "nicht erfasst".
  - `running`: recording started, not stopped.
  - `recorded`: `actualStart` and `actualEnd` are both set.
- **Hours** = `actualEnd − actualStart − breakMinutes` for recorded shifts, and `plannedEnd − plannedStart` for planned ones.

### Conventions that keep the schema extendable

These apply from v1 so that backup, tips and salary (§14) can be added later without reworking existing data:

- **Schema versioning from day one.** Drift's `schemaVersion` starts at 1. Each change is a numbered migration that only adds things (new tables, new nullable columns) and never renames or reuses a column. Drift's schema snapshots are committed to the repo (`drift_schemas/`), and each migration gets a test that upgrades a snapshot of every older version.
- **Stable IDs:** UUIDs for every record that may end up in a backup (shifts now; tips and wage rates later).
- **Every record carries `createdAt` / `updatedAt`.** A restore or merge can then decide which copy is newer.
- **Units:**
  - money as **integer cents** (never floating point)
  - instants as **UTC epoch ms**
  - dates as **`yyyy-MM-dd`** text
  - durations as **minutes**
- **Device-specific data stays separate from user data.** Calendar event IDs, notification IDs and the chosen calendar ID only make sense on one phone. They are clearly marked and left out of backups (§14.1).

### Table `settings` (key-value)

Settings live in the database so the notification background isolate can read them without a second storage mechanism.

| Key | Default |
|---|---|
| `defaultLunch` | 12:00–16:00 |
| `defaultLunchBeforeEvening` | 12:00–15:30 |
| `defaultEvening` | 17:30–23:00 |
| `reminderLeadMinutes` | 15 |
| `overrunReminderMinutes` | 30 |
| `roundingMode` | `nearestQuarter` (alternatives: `inFavour`, `strict`) |
| `calendarId` | null, meaning sync is off |
| `eventTitle` | "Kellnern" |
| `eventColorKey` | null, meaning the calendar's own colour |
| `exportMonthTotals` | true |
| `themeSeed` | `akaiRed` / `system` / `blue` / `green` / `violet` |
| `themeMode` | `system` / `light` / `dark` |
| `locale` | `system` / `de` / `en` |
| `onboardingDone` | false |

## 4. Domain logic

### 4.1 Planning (Plan tab)

- **Tapping Mittag/Abend toggles** a shift of that type on that day.
  - Turning it on creates the shift with the default times.
  - Turning it off deletes it. Only shifts with no recording can be removed this way; recorded shifts need a long-press or the edit sheet.
- **Lunch default depends on the evening shift.**
  - Adding an evening shift on a day with a lunch shift moves the lunch end to 15:30, but only if the lunch shift still has default times (`plannedCustomized == false`) and isn't recorded yet.
  - Removing the evening shift moves it back to 16:00.
- **"+"** opens the sheet with type *Individuell* and empty times, defaulting to 18:00–22:00 so the pickers start somewhere sensible.
- **Past weeks** are fully editable. Recorded shifts are never changed automatically.

### 4.2 Recording (`RecordingService`)

The same code runs from the UI and from the notification background isolate.

**`start(shiftId?, at = now)`**
- If `shiftId` is given (from a notification or a shift row), that shift gets `rawStart = at`.
- Otherwise, from the Heute card: the shift is today's next planned shift if its start is less than 2 h away or it is in progress.
- If there is no such shift, a new shift of type Mittag (before 15:00) or Abend is created, with default planned times.
- Then: show the ongoing "Erfassung läuft" notification and schedule the overrun reminder.

**`stop(at = now)`**
- `rawEnd = at`, `actualStart = round(rawStart)`, `actualEnd = round(rawEnd)`. If both round to the same quarter, the end becomes start + 15 min.
- Cancel the ongoing notification and the overrun reminder, mark the shift `dirty`, and run the calendar sync.

**`stopAt(plannedEnd)`** is the same as `stop`, with `rawEnd = plannedEnd`. It's used by the "Ende 23:00" notification action.

**`changeStart(t)`** (while running) sets `rawStart = t` and refreshes the notification.

### 4.3 Rounding

```
nearestQuarter: round to the nearest :00/:15/:30/:45; exactly 7:30 past rounds up
inFavour:       start rounded down, end rounded up
strict:         start rounded up, end rounded down
```

- Applied only on Stop. Times entered by hand are kept as entered; the pickers step in 5 minutes.
- The raw times stay stored and show as "Aufgezeichnet 17:32 – 22:41" in the sheet.

### 4.4 Month summary (F8)

For the month of the selected or current date:
- **Erfasst** = sum of hours of `recorded` shifts.
- **Geplant (inkl. erfasst)** = Erfasst + hours of all `planned`, `running` and `missed` shifts in that month.
  - A `running` shift counts with its planned hours.
  - `missed` shifts are included but also shown as a warning ("1 Schicht nicht erfasst"), tappable to fix.
- A shift belongs to the month of its `day`.

### 4.5 Export text (F6)

Pure function `buildExport(week, shifts, settings, locale)`:

```
Arbeitszeiten KW 44 (26.10.–01.11.2026)
Mo 26.10.: 12:00–16:00 (4,0 h)
Fr 30.10.: 12:00–15:30 (3,5 h), 17:30–23:00, 30 min Pause (5,0 h)
Woche gesamt: 29,0 h
Oktober gesamt: 86,25 h
November bisher: 5,5 h
```

- **Week:** ISO week (Mon–Sun), with its ISO week number (KW).
- **What's listed:** only `recorded` shifts, in time order. Days without recorded shifts are left out.
- **Per shift:** `start–end`, then `, N min Pause` if there is a break, then `(net h)`.
- **Hour format:** at most 2 decimals, always at least one (`4,0`), with a locale decimal separator (`,` in DE, `.` in EN).
- **Month lines** (if `exportMonthTotals` is on): one line for each month the week overlaps, summing recorded hours in that month up to the week's end. The label is "<Monat> gesamt" if the month ends within the week, otherwise "<Monat> bisher".
- **Warning:** if the week has `missed` or `running` shifts, the Export screen shows "1 Schicht nicht erfasst" above the preview. They are not included in the text.
- **English version:** "Working hours CW 44…", "Week total", "October total", "November so far".

### 4.6 Reminder planning (`ReminderPlanner`)

Pure function `desiredNotifications(shifts, settings, now) → Set<ScheduledNotification>`. `NotificationService` compares that set with what is scheduled and cancels or adds the difference.

**Pre-shift reminder**
- For every `planned` shift whose `plannedStart − lead` is in the future, within the next 14 days (this stays far below Android's limit of 500 alarms).
- Fires at `plannedStart − lead`.
- ID `notifId * 10 + 1`.

**Overrun reminder**
- For the running shift.
- Fires at `plannedEnd + overrun`.
- ID `notifId * 10 + 2`.

**Running notification**
- ID `1`.
- Shown while a shift is running, and re-posted on app start (in case it was swiped away or lost).

**When reconcile runs:**
- app start and resume
- after any shift or settings change
- after start/stop

## 5. Calendar sync

### 5.1 Why our own bridge

No Flutter calendar plugin documents support for **per-event colours**: on Android that's `EVENT_COLOR_KEY` from `CalendarContract.Colors`, which is the only colour value Google sync carries to Google Calendar. We also need two other things:
- read the `DELETED` flag (events deleted in Google Calendar stay in the provider, flagged, until synced);
- calls that work reliably from the notification background isolate.

So the design is a **small Kotlin bridge** of about 200 lines, with a type-safe interface generated by `pigeon`:

```dart
abstract class CalendarGateway {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<List<CalendarInfo>> writableCalendars();          // id, name, account, colour
  Future<List<EventColor>> eventColors(String calendarId); // key, ARGB (the account's palette)
  Future<String> insertEvent(String calendarId, EventData e);
  Future<void> updateEvent(String eventId, EventData e);
  Future<void> deleteEvent(String eventId);
  Future<EventState> eventState(String eventId);           // exists | deleted | missing
}
```

`EventData` holds title, start, end, description, colour key or null, and time zone (Europe/Berlin).

This bridge is also the part that has to be rewritten for iOS later (EventKit). Note: **iOS has no per-event colours**, only the calendar's colour, so the colour setting would be hidden on iOS.

### 5.2 Calendar selection

- The list shows only calendars with access level ≥ `CAL_ACCESS_CONTRIBUTOR`, grouped by account (the Google address) and marked with their colour.
- Above the list is a hint: "Lege bei Bedarf einmalig einen eigenen Kalender auf calendar.google.com an und teile ihn". A link opens the browser.
- Any calendar works, including the shared one or her main one. The app only touches events whose IDs it has stored. Other events in the calendar (yours, or hers made by hand) are never read as shifts, changed or deleted.
- **Changing the calendar later:** asks "Bestehende Termine in den neuen Kalender verschieben?" — on Yes, the app deletes the events from the old calendar and creates them in the new one; on No, it removes the old ones only.
- **"Kein Kalender"** turns sync off. Existing events stay where they are; the app then forgets their IDs.

### 5.3 Event colour (new)

- Settings › Kalender › **Termin-Farbe** opens a grid of the account's event colours, read from `CalendarContract.Colors` (`COLOR_TYPE_EVENT`). For Google accounts these are the 11 Google Calendar colours (Tomate, Flamingo, Mandarine, Banane, Salbei, Basilikum, Pfau, Heidelbeere, Lavendel, Weintraube, Graphit).
- The first option is **"Kalenderfarbe"** (no override). It's the default.
- One colour applies to all app events. Changing it marks all managed events `dirty`; the sync updates them in the background.
- If the selected calendar's account provides no colour palette (e.g. a local calendar), the setting is hidden.

### 5.4 What an event looks like

- **Title:** the `eventTitle` setting ("Kellnern").
- **Time:** actual times if recorded, otherwise planned times.
- **Colour:** the `eventColorKey` setting.
- **Reminders:** none (`HAS_ALARM = 0`). The app does the reminding, and you shouldn't get her reminders through the shared calendar.
- **Availability:** busy.
- **Description:**
  ```
  Geplant: 17:30–23:00
  Erfasst: 17:30–22:45 (5,25 h)
  Wird von AKAI Timetrack verwaltet – bitte in der App ändern.
  Ref: 3f9c2a1b
  ```
  The `Ref:` line is the first 8 characters of the shift's UUID. It's used to find the event again after a backup restore (§14.1).
  The "Erfasst" line appears only once the shift is recorded.

### 5.5 Sync algorithm (`CalendarSync.reconcile`)

Runs at app start and resume, after each change, and best-effort in the background handler after Stop. If any step throws, the shift stays `dirty` and is retried next time.

```
if no calendarId or no permission: stop (shifts stay dirty)
for shift in shifts where syncState in (dirty, pendingDelete):
    pendingDelete → deleteEvent if id exists → delete row
    dirty, no eventId → insertEvent → store id → synced
    dirty, has eventId → updateEvent → synced
for shift in synced shifts from the current week onward:
    eventState(id) is deleted/missing → insertEvent again (deleted in Google Calendar → re-created)
```

The last loop is limited to the current week onward, so old shifts she deliberately cleaned up in the past aren't recreated on every start.

**Edits made in Google Calendar** to app events are overwritten the next time that shift changes in the app (one-way, as decided). The event description warns about this.

## 6. Notifications in detail

### Channels

| Channel | Importance | Use |
|---|---|---|
| `reminders` ("Erinnerungen") | high, sound | pre-shift reminder |
| `recording` ("Laufende Erfassung") | low, silent, ongoing | running timer |
| `overrun` ("Nachfragen") | high, sound | "Noch bei der Arbeit?" |

### Notifications

| Notification | Content | Actions (background, no UI) | Tap |
|---|---|---|---|
| Pre-shift reminder | "Schicht beginnt in 15 min" · "Abend · 17:30 – 23:00" | **Erfassung starten** → `start(shiftId)`; **Später** → re-schedule in 10 min (once) | Opens Heute |
| Running | "Erfassung läuft" · "Abend · seit 17:30 · geplant bis 23:00". `usesChronometer` + `when = rawStart` (the system draws the timer). Progress bar from planned start to planned end. | **Beenden** → `stop()` | Opens Heute |
| Overrun | "Noch bei der Arbeit?" · "Geplantes Ende war 23:00." | **Ende 23:00** → `stopAt(plannedEnd)`; **Jetzt beenden** → `stop()`; **Weiter** → overrun again in 30 min | Opens Heute |

**Background handler.** This is a top-level `@pragma('vm:entry-point')` function. It initialises bindings, opens the database (drift, WAL), runs the `RecordingService` command, reconciles notifications, and tries the calendar sync.

**When the app is open at the same time:**
- The main isolate's drift streams don't see writes from the other isolate. So the app calls `notifyUpdates` for all tables on `AppLifecycleState.resumed`.
- The foreground notification handler refreshes too.

## 7. Screens

All screens follow the concept canvas. Behaviour that isn't visible in the mockups:

### Heute
- **Next-shift card** shows the next `planned` shift today or later. It turns into the running card while recording.
- **When there's no plan:** "Keine Schicht geplant" with a "Trotzdem starten" button.
- **Missed shifts:** if a past shift wasn't recorded, a chip "1 Schicht nicht erfasst" opens it.
- **Month card:** wavy progress bar, recorded vs expected. Uses Flutter's indicator if it ships a wavy variant, otherwise a `CustomPainter`.
- **Week strip:** tap a day → Plan tab at that week.

### Plan
- **Week navigation:** arrows, swipe, and a "today" button.
- **Header chips:** recorded and total hours for the week.
- **Shift rows:**
  - Icon shows the status (clock = planned, filled check = recorded, warning = missed).
  - Tap opens the edit sheet.
  - Long-press offers "Löschen" with an undo snackbar.

### Schicht bearbeiten (bottom sheet)
- **Type selector:** Mittag / Abend / Individuell. Switching type resets the planned times to that type's defaults, but only if they haven't been edited by hand.
- **Planned and actual times** use the Material time picker in 24 h format.
- **Actual times** start empty for unrecorded shifts, with a button "Wie geplant übernehmen".
- **Pause chips:** none / 15 / 30 / 45 / Andere (number input).
- **Validation:** end must be after start. A shift may cross midnight; if the end is before the start, it moves to the next day (a hint is shown).
- **Delete:** asks for confirmation only if the shift is recorded.

### Export
- **Week picker:** defaults to the **last completed week** if today is Mon–Wed, otherwise the current week.
- **Copy** puts the text on the clipboard. **Share** opens the share sheet (WhatsApp etc.).
- **The month switch here** only applies to this export; the default comes from settings.

### Einstellungen
- **Sections:**
  - Kalender: calendar, Termin-Titel, **Termin-Farbe**
  - Standard-Schichtzeiten
  - Erinnerungen
  - Erfassung & Export
  - Darstellung & Sprache
  - Über
- **Reliability card** appears at the top only while something is missing:
  - notification permission
  - exact alarms
  - battery optimisation
  - Autostart, on Xiaomi only; it can't be read, so it's checked off by hand: "Erledigt"

### Onboarding (first start, all skippable except the first page)
1. **Welcome + language:** "AKAI Timetrack" with a short explanation.
2. **Notifications:** `POST_NOTIFICATIONS`.
3. **Exact reminders:** on Android 14+, the "Alarms & reminders" settings page.
4. **Calendar:** the hint about a separate calendar, the permission, the selection list, then the event colour.
5. **Xiaomi only:** Autostart and battery set to "Keine Einschränkungen", with buttons that open the right settings pages.
6. **Default times:** confirm or adjust.

## 8. Theming (F9)

- `ColorScheme.fromSeed(seed, brightness)` builds the light and dark schemes.
- **Presets:** AKAI-Rot `#8F4C38`, Blau `#415F91`, Grün `#4C662B`, Violett `#65558F`.
- **"Systemfarbe"** uses the `dynamic_color` palette. It's hidden on Android < 12.
- **Dark mode** follows `ThemeMode` from the setting.
- **Fonts:** Roboto Flex is bundled as an asset rather than fetched at runtime (offline, no Google Fonts call). Icons are Material Symbols Rounded, also bundled.
- **Large numbers** (timer, hours) use tabular figures.

## 9. Localization

- German is the template ARB. English is a full translation.
- Dates, weekdays, month names and decimals come from `intl` with the active locale.
- The export text is also localized, and follows the app language.

## 10. Project structure

```
akai_timetrack/
  lib/
    main.dart                     # bootstrap, timezone init, notification init
    app.dart                      # MaterialApp.router, themes, locale
    l10n/app_de.arb, app_en.arb
    core/                         # clock, rounding, number/date formatting
    data/
      db/                         # drift database, tables, migrations
      repositories/               # ShiftRepository, SettingsRepository
    domain/                       # models + PlanningService, RecordingService,
                                  # MonthSummary, ExportService, ReminderPlanner
    platform/
      calendar/                   # CalendarGateway (pigeon), CalendarSync
      notifications/              # NotificationService, background_handler.dart
      device/                     # permissions, OEM settings intents
    features/
      today/ plan/ shift_edit/ export/ settings/ onboarding/
    theme/
  pigeons/calendar_api.dart       # pigeon definition
  android/app/src/main/kotlin/…/CalendarApiImpl.kt
  test/                           # unit + widget tests
```

## 11. Testing

- **Unit tests:**
  - rounding (all modes, edge :07:30)
  - lunch/evening default logic
  - month summary (month boundaries, missed shifts)
  - export text (DE/EN, breaks, weeks spanning two months, empty week)
  - ReminderPlanner (lead time, 14-day window, running shift)
  - sync state transitions (gateway faked)
- **Widget tests:** Plan toggles, edit sheet validation, export preview.
- **Test devices:** development and testing happen on a **Google Pixel 7 Pro** (latest Android) plus the emulator. Her Xiaomi isn't available before handover, because the app is a surprise. The Xiaomi-specific behaviour (Autostart, battery saver) is therefore built from documentation, and the checklist below runs on her phone during the field test (M6). The emulator can at least check minSdk 29 (an Android 10 image).
- **Manual checklist (Pixel first, then again on her Xiaomi):**
  - reminder after a reboot
  - reminder with the app swiped away
  - Start/Stop from the notification with the app killed
  - event appears on your phone, with the right colour
  - deleting the event in Google Calendar → recreated
  - dark mode and system colour

## 12. Release and signing

- Builds are installed by USB (`flutter install`) or as an APK file.
- **Create the release signing key once and back it up safely** (password manager plus an offline copy). Every update must be signed with the same key. If the key is lost, she has to uninstall the app, which deletes its data unless it's backed up.
- When global developer verification arrives (2027), register the free limited-distribution account and register the app's package name. Proposed package name: `de.<yourname>.akaitimetrack`, to be fixed before the first install.

## 13. Implementation plan (milestones)

| # | Milestone | Done when |
|---|---|---|
| M0 | Setup and spikes | Flutter project builds and runs on the **Pixel 7 Pro** (test device). Spikes confirm (a) a notification action writes to the DB with the app killed, (b) the chronometer notification shows, (c) the Kotlin bridge inserts a coloured event that appears with that colour in Google Calendar on the web. |
| M1 | Data and Plan | Plan tab with toggles, custom shifts, edit sheet and breaks, persisted in drift, with unit tests for the planning logic. |
| M2 | Recording | Heute screen, start/stop/change start, rounding, running notification, pre-shift and overrun reminders, background actions. |
| M3 | Calendar sync | Calendar selection, event colour, reconcile with recreate-on-delete. |
| M4 | Export and overview | Export screen (copy/share), month card, missed-shift warnings. |
| M5 | Settings, theming, i18n, onboarding | All settings working, EN translation, dark mode and system colour, onboarding incl. Xiaomi hints. |
| M6 | Handover and field test | Release key created and backed up. Install on her Xiaomi and set it up together (onboarding incl. Autostart and battery). Run the Xiaomi checklist, then one real week of use, then fixes. |

## 14. Prepared for later (not in v1)

### 14.1 Backup and restore

**What v1 already has, with no work:** Android Auto Backup stores the database in her Google account's device backup. It's restored when she sets up a new phone or reinstalls the app. There's no manual "restore now" and no control over timing, but it covers a lost or replaced phone.

**What a later backup feature would be built on:**

- **Backup format:** a single versioned JSON file, e.g.
  ```json
  {
    "format": "akai-timetrack-backup",
    "formatVersion": 1,
    "schemaVersion": 3,
    "createdAt": "2027-03-01T20:15:00Z",
    "settings": { "...": "only portable settings" },
    "shifts": [ { "id": "uuid", "...": "..." } ],
    "tips": [ ],
    "wageRates": [ ]
  }
  ```
  - Excluded: calendar event IDs, notification IDs and the chosen calendar ID (device-specific).
  - The domain layer gets an `exportSnapshot()` / `importSnapshot()` pair so the format is independent of where the file is stored.
- **Restore:**
  - **Into an empty app:** import everything.
  - **Into an app that already has data:** merge by UUID, where the newer `updatedAt` wins.
  - **After a restore:** every shift is marked `dirty`, and she picks the calendar again.
  - **Avoiding duplicate events:** so the app doesn't create duplicates of events that still exist, each app-created event carries a short reference line in its description (`Ref: <first 8 chars of the UUID>`). After a restore, the app first looks for events with matching references in the chosen calendar and reconnects to them. This line is written from v1 on, so old events can be found later.
- **Where the file goes**, to be decided when the feature is built:
  - **No account setup:** Android's system file picker (Storage Access Framework). She picks a folder once, e.g. in Google Drive. The app keeps write access to it and saves a backup automatically, say weekly. No Google Cloud project, no OAuth.
  - **Invisible app storage on Google Drive:** Google Drive's hidden "app data" folder via the Drive API. Needs a Google Cloud project and Google sign-in in the app.
  - **iOS:** the app's iCloud Drive container. Needs the Apple Developer Program.
  - Recommendation for later: the system file picker on Android first, because it needs no accounts.

### 14.2 Tips and salary

**Tips** go in a new table rather than as a column on the shift, because there may be more than one entry per shift (cash, card share, pooled tips) and maybe tips without a shift:

| Table `tips` | Type | Meaning |
|---|---|---|
| `id` | text UUID | |
| `shiftId` | text?, FK → shifts | null = not tied to a shift (e.g. a monthly pool payout) |
| `day` | text `yyyy-MM-dd` | for month grouping |
| `amountCents` | int | |
| `kind` | enum `cash` / `card` / `pool` / `other` | |
| `note` | text? | |
| `createdAt`, `updatedAt` | DateTime | |

**Wage rates** are valid from a date, so a raise doesn't change past months:

| Table `wage_rates` | Type | Meaning |
|---|---|---|
| `id` | text UUID | |
| `validFrom` | text `yyyy-MM-dd` | |
| `hourlyCents` | int | gross hourly wage |
| `createdAt`, `updatedAt` | DateTime | |

Possible later extension: a `surcharge_rules` table for Sunday, holiday and night surcharges, which are common in restaurants. Each rule would have a weekday or holiday flag, a time window and a percentage.

**Salary calculation:** a pure domain function `salaryFor(month, shifts, wageRates, tips)` returning hours × the rate valid on each shift's day, tips, and the totals with and without tips. It's shown in a later "Lohn" tab, and could optionally go into the export text.

**UI hooks:** the shift edit sheet gets a "Trinkgeld" field below "Pause", and the month card on Heute can gain a third figure. The concept layouts leave room for both.

Nothing in v1 needs changing for this beyond the conventions in §3.

## 15. Open points (small, can be decided while building)

- App icon and the app name on the home screen ("AKAI Zeit"? "Schichten"?).
- Exact text of the event description in English.
- Whether "Später" on the pre-shift reminder needs a configurable delay (currently a fixed 10 min).
