# AKAI Timetrack – Design

Status: v1 implemented. As of 2026-11-04. Where the implementation differs from the original design, §16 says how; the sections above are updated where noted.
Inputs: [01-research.md](01-research.md) (features F1–F9, decisions Q1–Q10) and the approved concept screens in [concepts/](concepts/) ([canvas](https://claude.ai/artifact/7grRC9FNyoFRhYCEw6QmzV)).

## 1. Scope of v1

In scope:
- **Plan:** plan shifts, with Lunch/Evening quick toggles and custom shifts.
- **Recording:** record time from the app or from notifications.
- **Editing:** correct shift times by hand, including breaks.
- **Calendar sync:** one-way sync to a chosen Google calendar, with a selectable event colour.
- **Export:** monthly text, grouped by week (was: weekly text with optional month totals; see §16).
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

## 2. Architecture

```
┌──────────────── UI (Flutter widgets) ────────────────┐
│ Home · Plan · Shift sheet · Export · Settings         │
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
| Navigation | none (plain `Navigator`) | 3 tabs in an `IndexedStack`, settings pushed. See §16. |
| Notifications | `flutter_local_notifications` + `timezone` + `flutter_timezone` | Exact scheduling, action buttons with a background handler, chronometer. Re-schedules after reboot by itself. |
| Calendar | **own Kotlin plugin** (`packages/calendar_bridge`, MethodChannel) | See §5 and §16. |
| Notification progress | **own Kotlin plugin** (`packages/running_progress`) | Moves the running notification's progress bar; Live Update on Android 16. See §6. |
| UI library | `material_ui` | Flutter's Material library as a separate package. See §16. |
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
| `plannedCustomized` | bool | True once the user edits the planned times by hand. Stops automatic default-time adjustments (§4.1). |
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
  - `missed`: no actuals, planned end in the past. Shown as "not recorded".
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
| `eventTitle` | `Kellnern` (a literal default in the code) |
| `eventColorKey` | null, meaning the calendar's own colour |
| `themeSeed` | `akaiRed` / `terracotta` / `system` / `blue` / `green` / `violet` |
| `weekMarks` | `icons` / `bars` (week strip on the Home tab) |
| `themeMode` | `system` / `light` / `dark` |
| `locale` | `system` / `de` / `en` |
| `onboardingDone` | false |
| `restaurant` | `''` (not set). Installs from 1.4.1 and earlier, which have no stored value but finished the setup, read `AKAI`. See §4.10. |
| `tipPromptDismissedDay` | null; the `yyyy-MM-dd` day whose "Add the tips" prompt on the Home tab the user closed (§4.7). Device status like `lastCalendarSync`: `SettingsRepository.watch()` leaves it out, so closing the prompt doesn't rebuild the app. |

### Tables `tip_days` and `tip_payouts` (F10, schema version 2)

Tips are kept apart from shifts. The pool total belongs to a day, not to a shift, and the payout belongs to a week. Neither is device-specific, so both go into a later backup (§14.1).

| Table `tip_days` | Type | Meaning |
|---|---|---|
| `id` | text PK (UUID v4) | |
| `day` | text `yyyy-MM-dd`, unique | the workday |
| `poolCents` | int | **"Daily pool"**: the day's tips of everyone combined, not the user's share |
| `createdAt`, `updatedAt` | DateTime | |

| Table `tip_payouts` | Type | Meaning |
|---|---|---|
| `id` | text PK (UUID v4) | |
| `weekStart` | text `yyyy-MM-dd`, unique | the Monday of the tip week (Monday to Sunday) |
| `amountCents` | int | **"Paid out"**: the cash the user received for that week |
| `createdAt`, `updatedAt` | DateTime | |

- One row per day or week at most. Saving again updates the row; clearing the amount deletes it.
- Zero is a valid amount (stored), an empty field is not (no row).
- A note column is left out for now. It can be added later as a nullable column.

### Table `wage_rates` (salary, schema version 3)

The user's hourly wage. Each rate is valid from a day on, so a raise (for example the minimum wage step on 2027-01-01) doesn't change past months. It goes into a later backup (§14.1).

| Table `wage_rates` | Type | Meaning |
|---|---|---|
| `id` | text PK (UUID v4) | |
| `validFrom` | text `yyyy-MM-dd`, unique | the first day the rate applies to |
| `hourlyCents` | int | hourly wage in cents |
| `createdAt`, `updatedAt` | DateTime | |

- One row per start day at most. Saving a rate for a day that already has one updates it.
- Zero is not a valid rate.

### Team planner tables (F11, schema version 4)

The team planner (§4.9) has its own tables and no link to `shifts`, calendar sync or reminders. Research and decisions: `01-research.md` §10. Shift kinds are stored as `TeamShift` (`lunch` = 0, `evening` = 1), not as `ShiftType`, because the planner has no custom shifts.

| Table `team_members` | Type | Meaning |
|---|---|---|
| `id` | text PK (UUID v4) | |
| `name` | text | as shown on the board and in the image |
| `core` | bool, default false | **core worker**: experienced; each shift should have one |
| `isMe` | bool, default false | this person is the user. At most one row; setting it clears it on the others |
| `active` | bool, default true | **unused** since 2026-11-05 (always true). The developer dropped "inactive" as confusing: people who leave are deleted and added again later. The column stays because migrations only add. |
| `createdAt`, `updatedAt` | DateTime | |

| Table `team_answers` | Type | Meaning |
|---|---|---|
| `id` | text PK (UUID v4) | |
| `weekStart` | text `yyyy-MM-dd` | the Monday of the planned week |
| `memberId` | text | `team_members.id` |
| `mode` | enum `canWork` / `cantWork` | what the marks mean |
| `marks` | int, default 0 | bit `(weekday − 1) × 2 + shift` is set for each marked shift (Monday lunch = bit 0, Sunday evening = bit 13) |
| `maxShifts` | int? | "At most N shifts"; null = no limit |
| `createdAt`, `updatedAt` | DateTime | |

- Unique on (`weekStart`, `memberId`). **No row = "No answer yet".** "Remove answer" deletes the row.

| Table `team_assignments` | Type | Meaning |
|---|---|---|
| `id` | text PK (UUID v4) | |
| `day` | text `yyyy-MM-dd` | |
| `shift` | enum `TeamShift` | |
| `memberId` | text | `team_members.id` |
| `startMinutes` | int? | special start time (minutes after midnight); null = the shift's normal start |
| `createdAt`, `updatedAt` | DateTime | |

- Unique on (`day`, `shift`, `memberId`): a person is in a shift at most once.
- A special start equal to the normal start is stored as null.

| Table `team_needs` | Type | Meaning |
|---|---|---|
| `id` | text PK (UUID v4) | |
| `day` | text `yyyy-MM-dd` | |
| `shift` | enum `TeamShift` | |
| `needed` | int | staff needed in this shift, for this one week |

- Only changes made on the board are stored here (unique on `day`, `shift`). Everything else comes from the setting `teamStaffNeeded`, so the defaults can still be set after a week has been planned. Setting a count back to the default deletes the row.

**Settings keys** (in the `settings` table, §3):

| Key | Default | Meaning |
|---|---|---|
| `teamPlanner` | false | shows the fifth tab |
| `teamStaffNeeded` | `2,3;2,3;2,3;2,3;2,3;2,3;0,0` | staff needed per weekday (Monday first), lunch then evening. 0 = closed |
| `teamStarts` | `12:00,17:30` | the normal start of lunch and evening, shown on the board and in the image |

The team start times are separate from the user's "Default shift times", because those are the user's own times (lunch may end at 15:30, the evening may start later), and changing them shouldn't change the team plan.

## 4. Domain logic

### 4.1 Planning (Plan tab)

- **Tapping Lunch or Evening toggles** a shift of that type on that day.
  - Turning it on creates the shift with the default times.
  - Turning it off deletes it. Only shifts with no recording can be removed this way; recorded shifts need a long-press or the edit sheet.
- **Lunch default depends on the evening shift.**
  - Adding an evening shift on a day with a lunch shift moves the lunch end to 15:30, but only if the lunch shift still has default times (`plannedCustomized == false`) and isn't recorded yet.
  - Removing the evening shift moves it back to 16:00.
- **"+"** opens the sheet with type *Custom* and empty times, defaulting to 18:00–22:00 so the pickers start somewhere sensible.
- **Past weeks** are fully editable. Recorded shifts are never changed automatically.

### 4.2 Recording (`RecordingService`)

The same code runs from the UI and from the notification background isolate.

**`start(shiftId?, at = now)`**
- If `shiftId` is given (from a notification or a shift row), that shift gets `rawStart = at`.
- Otherwise, from the Home tab's card: the shift is today's next planned shift if its start is less than 2 h away or it is in progress.
- If there is no such shift, a new shift of type lunch (before 15:00) or evening is created, with default planned times.
- Then: show the ongoing "Recording" notification and schedule the overrun reminder.

**`stop(at = now)`**
- `rawEnd = at`, `actualStart = round(rawStart)`, `actualEnd = round(rawEnd)`. If both round to the same quarter, the end becomes start + 15 min.
- Cancel the ongoing notification and the overrun reminder, mark the shift `dirty`, and run the calendar sync.

**`stopAt(plannedEnd)`** is the same as `stop`, with `rawEnd = plannedEnd`. It's used by the "End 23:00" notification action.

**`changeStart(t)`** (while running) sets `rawStart = t` and refreshes the notification.

### 4.3 Rounding

```
nearestQuarter: round to the nearest :00/:15/:30/:45; exactly 7:30 past rounds up
inFavour:       start rounded down, end rounded up
strict:         start rounded up, end rounded down
```

- Applied only on Stop. Times entered by hand are kept as entered; the pickers step in 5 minutes.
- The raw times stay stored and show as "Recorded 17:32 – 22:41, rounded to quarter hours" in the sheet.

### 4.4 Month summary (F8)

For the month of the selected or current date:
- **Recorded** = sum of hours of `recorded` shifts.
- **Planned (incl. recorded)** = Recorded + hours of all `planned`, `running` and `missed` shifts in that month.
  - A `running` shift counts with its planned hours.
  - `missed` shifts are included but also shown as a warning ("1 shift not recorded"), tappable to fix.
- A shift belongs to the month of its `day`.

### 4.5 Export text (F6)

Pure function `buildExportText(month, shifts, now, l10n)` in `lib/domain/export_text.dart`. The user sends the hours once a month, so the text covers a whole month, grouped by week (developer decision 2026-11-04; it was a weekly text before):

```
Working hours October 2026

CW 40 (01/10–04/10)
Thu 01/10: 12:00–16:00 (4.0 h)
Week total: 4.0 h

CW 44 (26/10–31/10)
Mon 26/10: 12:00–16:00 (4.0 h)
Fri 30/10: 12:00–15:30 (3.5 h), 17:30–23:00, 30 min break (5.0 h)
Week total: 12.5 h

October total: 16.5 h
```

- **Month:** calendar month. Planning stays weekly; only the export is monthly.
- **Weeks:** ISO weeks (Mon–Sun) with their week number (CW). A week that crosses the month's start or end is cut to the days inside the month; its other days are in the neighbouring month's export. Weeks without recorded shifts are left out.
- **What's listed:** only `recorded` shifts, in time order. Days without recorded shifts are left out.
- **Per shift:** `start–end`, then `, N min break` if there is a break, then `(net h)`.
- **Hour format:** at most 2 decimals, always at least one (`4,0`), with a locale decimal separator (`,` in DE, `.` in EN).
- **Last line:** "<Month> total" once the month is over, "<Month> so far" while it is still running.
- **Warning:** if the month has `missed` or `running` shifts, the Export screen shows "1 shift not recorded" above the preview. They are not included in the text.
- **Language:** the text follows the app language. The German version has the same layout, with German labels and dates like `01.10.`.

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

### 4.7 Tips (F10, `domain/tips.dart`)

**Workdays** of a week are the days up to today that have at least one shift (recorded, running or not recorded). A day with a stored pool total is also listed, even if its shift was deleted later, so no entry disappears.

**Money:**
- Stored as integer cents.
- Shown with cents only when they aren't zero: "40 €", "42,50 €" in German; "€40", "€42.50" in English (`NumberFormat.currency` with 0 or 2 decimals).
- Input accepts "40", "40,5", "40,50" and "40.50": `,` and `.` both work as the decimal mark when one or two digits follow, because phone keyboards differ. Thousands may only be grouped with the app language's mark ("1.234,50" in German, "1,234.50" in English), so "40,505" is rejected as a typo rather than read as 40 505 euros. More than two decimals or anything else is rejected with a hint.

**Which month a payout counts for:** the month of the week's Thursday, the same rule ISO week numbers use. A week spanning two months goes to the month with more of its days (the restaurant is open Monday to Saturday, so at least 3 of 6 workdays). Example: Mon 2026-11-30 to Sun 2026-12-06 counts for December.

**Month figure ("Tips" on the Home and Pay tabs):** the sum of the payouts of the weeks that count for the month. Pool totals are not added in, because they are everyone's tips.

**Prompt on the Home tab ("Add the tips"):** shown for the newest day D that meets all of these:
- D is today or yesterday (so the user can still enter it the next morning, and an evening shift ending after midnight still counts for D);
- D has at least one recorded shift, and none of D's shifts is running or still planned for later;
- D has no pool total;
- `tipPromptDismissedDay` is not D.

"Add" opens the pool-total sheet for D. "Not now" stores D in `tipPromptDismissedDay`. Later days can still be entered on the Pay tab.

**Not in this version:** an estimate of the user's share. It would need the number of people working each day (§14.2).

### 4.8 Salary (`domain/salary.dart`)

The hours times the hourly wage, nothing else: no tax, no deductions, no tips. The app doesn't say whether the wage is gross or net; the pay is whichever the user entered. Salary is paid per calendar month, so a shift's pay counts for the month of its `day` (unlike tips, which use the Thursday rule).

**Rate of a day:** the newest rate whose `validFrom` is on or before the day. Days before the first rate use the first rate, so the first rate entered also counts for earlier months. Without any rate there is no pay figure.

**Month figures**, from the same shifts as the month summary (§4.4):
- **"Earned"** = recorded hours × rate.
- **"Expected"** = "Earned" plus the planned hours of all planned, running and missed shifts × rate. It matches "Planned (incl. recorded)" for the hours, so missed shifts count until they are recorded or deleted.
- Each shift is paid at the rate of its day. Minutes are summed per rate and rounded to cents once per rate, not per shift.

### 4.9 Team planner (F11, `domain/roster.dart`)

Pure functions over people, answers, assignments and staff counts; the repository is `data/roster_repository.dart`. Research and the developer's decisions: `01-research.md` §10.

**Week and shifts.** A plan covers an ISO week, Monday to Sunday. Each day has a Lunch and an Evening shift. The staff needed comes from `team_needs`, else from `teamStaffNeeded`. A shift with 0 needed is **closed**. A day is **open** if one of its shifts is open or has people in it; the board and the image show open days only, and a closed shift only while people are in it.

**Answers.** For a person, a week and a shift:
- no `team_answers` row → **no answer**;
- `canWork` → available if the shift is marked;
- `cantWork` → available if the shift is not marked.

Closed shifts are never available. Switching the mode keeps the marks and flips their meaning. The summary line lists the available open shifts grouped by day: a day with both shifts is named once ("Thu"), otherwise with the shift ("Mon evening"). All of them: "Every shift"; none: "No shift".

**Counts per person** (for sorting and the "Shifts per person" list):
- **shifts**: the person's assignments in the week;
- **possible**: the open shifts the person is available for.

**Order in the shift sheet** (who to pick for shift S):
1. **Available** people, sorted by fewest shifts this week, then by name (case-insensitive). If S has no core worker yet, the available core workers come first. Once S has one, the people who aren't core workers come first, because core workers cost more. Each part is sorted the same way.
2. **No answer yet**, by name.
3. **Can't work**, by name.

People already in S are listed in their group, ticked.

**Fill** (`fillWeek`). Adds people to open places and never removes or moves anyone. Person P is **eligible** for shift S if:
- P has an answer that makes P available for S;
- P isn't in S yet;
- P has fewer shifts than their "At most N" (if set).

It runs in two passes, each a loop that adds one person at a time:
1. **Core pass:** over the open shifts with a free place and no core worker. Take the shift with the fewest eligible core workers (at least one); ties go to the earlier day, then lunch. Add the best eligible core worker.
2. **Normal pass:** over the open shifts with a free place. Take the shift with the fewest eligible people (at least one), with the same ties. Add the best eligible person, but prefer people who **aren't core workers** over everything else, because core workers cost more (developer decision, 2026-11-05). Core workers only get a place here when nobody else is eligible.

"Best" means, in this order (after the core rule of the normal pass):
- fewest shifts this week;
- not already working the other shift that day;
- fewest other open places they are eligible for, because people with many options can still fill a place later;
- name.

The rules are deterministic: the same input gives the same plan. Fill returns the added assignments, the number of places still open and the shifts without a core worker. The board's snack bar reads "Filled 9 places · 2 still open" ("All places filled" when none are open), with "Undo".

**Away:** a person who has answered, is available for no shift and isn't in the plan (`isAway`). The answer page's "Away this week" button saves exactly that ("Can work" with nothing marked). The summary line and the "Shifts per person" list show "Away this week" / "Away" instead of "0 shifts · 0 possible".

**Warnings on the board:**
- the count "2/3" in the error colour when short;
- in the tertiary colour when over;
- "No core worker" when an open shift has nobody marked core, but only if at least one person is a core worker at all.

**Clear** removes all assignments of the week. Answers and staff counts stay. Undo puts the old assignments back (with their ids and start times).

**Add my shifts to Plan.** For each assignment of the person marked `isMe` in the week:
- if the user already has a Lunch or Evening shift of that kind on that day, skip it;
- otherwise create it through `PlanningService` with the user's default times, so the lunch-before-evening rule applies (§4.1);
- with a special start time, the planned start is moved to it, the end stays, and the shift counts as edited by hand (`plannedCustomized`).

The new shifts sync to the calendar as usual. Snack bar: "Added 3 shifts to Plan" or "Already on Plan". Nothing on the Plan tab is ever removed by the planner.

**Image** (`ui/roster/plan_image.dart`). A widget at a fixed 1600 × 900 logical pixels, rendered with `RepaintBoundary.toImage(pixelRatio: 1.2)` to a 1920 × 1080 PNG.
- **Colours:** always light (white background, dark text, AKAI red `#C62828` for the headers), whatever the app's theme.
- **Title:** "Shift plan" and "Week 46 · 9–14 Nov", in the app's language.
- **Grid:** one column per open day (weekday and date); one row for Lunch and one for Evening, each labelled with its start time from `teamStarts`. Each cell lists the names, one per line. A special start time follows the name in a smaller grey font ("from 18:30"). A closed cell is light grey.
- **Fitting:** one font size for all names. It shrinks from 30 px until the fullest cell fits, but not below 18 px. Below that the cell is cut off, which a plan of 6–8 people never reaches.
- **Left out:** open places, core worker marks, warnings.
- The file is written to the app's cache as `team-plan-<weekStart>.png`, replacing an earlier one, and shared with `share_plus`.

### 4.10 Restaurant name (2026-11-06)

- The `restaurant` setting: in the setup's first page and in Settings › General › "Restaurant". Empty means not set; nothing shows then.
- **Where it shows:** the calendar events' location (§5.4), the export header ("Working hours November 2026 – AKAI"), and the title of the shared team plan picture ("AKAI shift plan"). Not in the app's own screens: the developer chose these three, so the name costs no screen space.
- **AKAI only:** when the name is `AKAI` (trimmed, any case; `isAkaiRestaurant` in `domain/app_icons.dart`), the "AKAI sign" icon design is offered, and the default colour is called "AKAI red". Otherwise the picker leaves the sign out (unless it's the current icon) and the colour is called "Red". The colour itself is the same, so nothing changes for installs at other restaurants.
- Installs from 1.4.1 and earlier read `AKAI` when no value is stored, because all of them were set up at AKAI.

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

- The list shows calendars with access level ≥ `CAL_ACCESS_CONTRIBUTOR`, grouped by account (the Google address) and marked with their colour.
- **Calendars not synced to the phone** (`SYNC_EVENTS = 0`; Google adds newly created calendars switched off) are listed too, with a hint. Choosing one turns its sync on (`SYNC_EVENTS = 1`, `VISIBLE = 1`) and asks Android to sync the account.
- **"Refresh"** asks Android to sync all calendar accounts (so a calendar just created on calendar.google.com shows up) and reads the list again, once right away and once after a few seconds.
- Above the list is a hint: "New Google calendars can only be created and shared in the browser." A link ("Open calendar.google.com") opens the browser.
- Any calendar works, including the shared one or the user's main one. The app only touches events whose IDs it has stored. Other events in the calendar (the developer's, or the user's own made by hand) are never read as shifts, changed or deleted.
- **Changing the calendar later:** asks whether to move the existing events to the new calendar. On yes, the app deletes the events from the old calendar and creates them in the new one; on no, it removes the old ones only.
- **"No calendar"** turns sync off and deletes the app's events from the old calendar (as implemented; see §16).

### 5.3 Event colour (new)

- Settings › Calendar › **Event color** opens a grid of the account's event colours, read from `CalendarContract.Colors` (`COLOR_TYPE_EVENT`). For Google accounts these are the 11 Google Calendar colours (Tomato, Flamingo, Tangerine, Banana, Sage, Basil, Peacock, Blueberry, Lavender, Grape, Graphite).
- The first option is **"Calendar color"** (no override). It's the default.
- One colour applies to all app events. Changing it marks all managed events `dirty`; the sync updates them in the background.
- If the selected calendar's account provides no colour palette (e.g. a local calendar), the setting is hidden.

### 5.4 What an event looks like

- **Title:** the `eventTitle` setting (default `Kellnern`).
- **Time:** actual times if recorded, otherwise planned times.
- **Colour:** the `eventColorKey` setting.
- **Location:** the `restaurant` setting, or none when it's empty. Changing it marks all events `dirty`.
- **Reminders:** none (`HAS_ALARM = 0`). The app does the reminding, and the developer shouldn't get the user's reminders through the shared calendar.
- **Availability:** busy.
- **Description:**
  ```
  Planned: 17:30–23:00
  Recorded: 17:30–22:45 (5.25 h)
  Managed by TimeTrack – please change it in the app.
  ```
  The "Recorded" line appears only once the shift is recorded.

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

The last loop is limited to the current week onward, so old shifts the user deliberately cleaned up in the past aren't recreated on every start.

**Sync status and "Sync now".** Settings › Calendar shows the status: "N changes not in the calendar yet" while shifts are marked, otherwise "Up to date · last synced 17:04" (the time of the last run without errors, stored as `lastCalendarSync` in the settings table but kept out of `AppSettings`). The button runs the sync and then asks Android to upload the account's changes to Google right away (`ContentResolver.requestSync`, expedited). Automatic sync is unchanged.

**Language.** The event description is written in the app's language; changing the language marks all events for an update, like a title or colour change.

**Edits made in Google Calendar** to app events are overwritten the next time that shift changes in the app (one-way, as decided). The event description warns about this.

## 6. Notifications in detail

### Channels

| Channel | Importance | Use |
|---|---|---|
| `reminders` ("Reminders") | high, sound | pre-shift reminder |
| `recording` ("Running recording") | low, silent, ongoing | running timer |
| `overrun` ("Follow-up questions") | high, sound | "Still at work?" |

### Notifications

| Notification | Content | Actions (background, no UI) | Tap |
|---|---|---|---|
| Pre-shift reminder | "Shift starts in 15 min" · "Evening · 17:30 – 23:00" | **Start recording** → `start(shiftId)`; **Later** → re-schedule in 10 min (once) | Opens the Home tab |
| Running | "Recording" · "Evening · since 17:30 · planned until 23:00". `usesChronometer` + `when = rawStart` (the system draws the timer). Progress bar from the recorded start to the planned end (see below). | **Stop** → `stop()` | Opens the Home tab |
| Overrun | "Still at work?" · "The planned end was 23:00. Recording is still running." | **End 23:00** → `stopAt(plannedEnd)`; **Stop now** → `stop()`; **Keep going** → overrun again in 30 min | Opens the Home tab |

**Progress bar of the running notification.** flutter_local_notifications posts the notification (with its button and the progress at that moment). The local plugin `running_progress` then keeps the bar moving without Flutter: an exact alarm every 5 minutes wakes a `BroadcastReceiver`, which rebuilds the shown notification with `Notification.Builder.recoverBuilder` (so the buttons stay), sets the new progress and re-posts it, until the planned end. If the notification is gone (stopped), it stops. On **Android 16** the rebuilt notification uses `Notification.ProgressStyle` and `setRequestPromotedOngoing(true)` (permission `POST_PROMOTED_NOTIFICATIONS`), so it shows as a **Live Update** (status-bar chip, prominent on the lock screen); before Android 16 it uses the classic `setProgress`. Each re-post through the app (reconcile) restarts the plugin.

**Background handler.** This is a top-level `@pragma('vm:entry-point')` function. It initialises bindings, opens the database (drift, WAL), runs the `RecordingService` command, reconciles notifications, and tries the calendar sync.

**When the app is open at the same time:**
- The main isolate's drift streams don't see writes from the other isolate. So the app calls `notifyUpdates` for all tables on `AppLifecycleState.resumed`.
- The foreground notification handler refreshes too.

## 7. Screens

All screens follow the concept canvas. Behaviour that isn't visible in the mockups:

### Home

The first tab, "Home" (it was "Today" until 2026-11-05). Icon: `home`. It was renamed when pay was added, because most of the page is now a month overview, not today.

- **Next-shift card** shows the next `planned` shift today or later. It turns into the running card while recording.
- **When there's no plan:** "No shift planned" with a "Start anyway" button.
- **Missed shifts:** if a past shift wasn't recorded, a chip "1 shift not recorded" opens it.
- **Month card:** wavy progress bar, recorded vs expected. Uses Flutter's indicator if it ships a wavy variant, otherwise a `CustomPainter`. Below the bar, two rows:
  - **"Pay"**: "Earned" of "Expected" for the current month (§4.8), e.g. "€412 of €980". Without a rate, an "Add hourly wage" button opens the wage sheet.
  - **"Tips"**: the month's payouts (§4.7); "€0" until the first payout. The developer saw both prototypes (2026-11-05). A third column next to the hours looked good too, but rows leave room for the pay row.
- **Tip prompt:** a small card "Add the tips" below the next-shift card, by the rule in §4.7, with "Add" and "Not now".
- **Week strip:** tap a day → Plan tab at that week. Under each day, lunch and evening shifts are marked either with icons (sun, moon, clock for custom; the default) or with two bars (left lunch, right evening; custom shifts by start time). Grey = planned, coloured = recorded. Chosen in Settings › Appearance › Week overview.

### Plan
- **Week navigation:** arrows, swipe, and a "today" button.
- **Header chips:** recorded and total hours for the week.
- **Shift rows:**
  - Icon shows the status (clock = planned, filled check = recorded, warning = missed).
  - Tap opens the edit sheet.
  - Long-press offers "Delete" with an undo snackbar.

### Edit shift (bottom sheet)
- **Type selector:** Lunch / Evening / Custom. Switching type resets the planned times to that type's defaults, but only if they haven't been edited by hand.
- **Planned and actual times** use the Material time picker in 24 h format.
- **Actual times** start empty for unrecorded shifts, with a button "Use planned times".
- **Break chips:** none / 15 / 30 / 45 / Other (number input).
- **Validation:** end must be after start. A shift may cross midnight; if the end is before the start, it moves to the next day (a hint is shown).
- **Delete:** asks for confirmation only if the shift is recorded.

### Pay (F10)

The third tab, between Plan and Export: Home, Plan, Pay, Export. Icon: `payments`. It opens on the current week on each visit, like Export opens on the current month.

- **Month card:** the month of the shown week (by the Thursday rule). Chosen by the developer on 2026-11-05 from three prototypes (a two-column receipt, a big total on top, the old card plus a total). The receipt was dropped because tips have no forecast, so its "Expected" column only repeated them.
  - **Header:** the month, and a chip with the hourly wage ("€14.50/h", the rate at the end of the month). Tap opens the wage sheet. Without a rate the chip reads "Hourly wage" with a plus.
  - **Pay** (§4.8), the biggest number, because it is what reaches the bank account at the end of the month. The current month shows "Expected pay" with the expected amount, "€412 earned · 28.5 of 67.5 h" below it, and the wavy bar. A past month shows "Pay" with the amount earned, unless shifts were missed; a future month shows the expected amount and "for 67.5 h". Without a rate: a hint and an "Add hourly wage" button.
  - **"Tips"** with the number of weeks with a payout ("from 3 weeks").
  - **"Total · with tips":** "Earned" and "Expected" side by side, in the style of the hours on the Home tab; one of them for past and future months, by the same rule as the pay. Hidden without a rate.
- **Week switcher:** the same as on Plan (arrows, swipe, "today" button).
- **"Paid out" card:** the week's payout, or an "Add" button if there is none. Tap opens the money sheet.
- **"Daily pool" list:** one row per workday (§4.7): weekday and date, the shift types worked (sun/moon icons as on the Home tab), and the pool total or "–". Tap opens the money sheet for that day. Below the list: "Total" with the sum of the week's pool totals.
- **A week without workdays:** "No shifts this week." The payout can still be entered.
- **Money sheet** (bottom sheet, the same for day and week):
  - title "Daily pool · Mon, Nov 2" or "Paid out · week 45";
  - a hint: "Everyone's tips combined that day" or "The cash you got for this week";
  - one text field with the decimal keyboard and a "€" suffix, focused when the sheet opens;
  - "Save", plus "Delete" if there is a value. Delete doesn't ask; a snack bar offers "Undo" (with `persist: false`).
- **Wage sheet** (bottom sheet, `ui/pay/wage_sheet.dart`):
  - title "Hourly wage" and the hint "Per hour, without tips."; for the very first rate also "Also counts for earlier months.";
  - one money field with a "€/h" suffix, filled with the rate of the month on screen;
  - "Valid from" with a date chip, set to the 1st of the month on screen; shown only once a rate exists, because the first rate counts for every month anyway;
  - "Save" stores the rate for that day (or updates the rate already starting that day);
  - "All hourly wages": every rate, newest first, each with a delete button that asks first. Not a snack bar with "Undo", because the sheet would cover it.

### Export
- **Month picker:** always opens on the **current month**, also when coming back to the tab (developer decision 2026-11-04). Earlier months are one tap back.
- **Summary card:** "Month total" with the hours, shifts and days of the month.
- **Copy** puts the text on the clipboard. **Share** opens the share sheet (WhatsApp etc.).

### Team (F11)

The fifth tab, last in the bar, shown only while Settings › Team planner is on. Turning the switch off hides the tab and keeps the data. The label is provisional: "Team" in English, "Dienstplan" in German, icon `groups`. The developer decides on the name once the screen is built. Last in the bar, so the other tabs keep their places when it is switched on or off. Rules: §4.9.

**Board** (`ui/roster/team_screen.dart`). It opens on **next week** on each visit to the tab, like Pay opens on the current week.
- **Header:** `PageHeader` and the `WeekSwitcher` (arrows, swipe, a button back to next week). A menu (⋮) has "People" and, if a person is marked "This is me" and has shifts this week, "Add my shifts to Plan".
- **Answers card:** "Answers: 5 of 7" and the button "Enter answers". It starts the walk-through at the first person without an answer, or at the first person if everyone has answered. Without any people, the card reads "Add the people you plan for" with an "Add people" button instead.
- **Action row:** "Fill" (tonal), "Clear" (text) and "Share" (filled). "Clear" is disabled on an empty board. "Share" opens the preview.
- **Day cards:** one per open day, in the style of the Plan tab's cards.
  - Each card has a row for Lunch and one for Evening: the shift name and normal start, the people as chips, and the count "2/3".
  - A chip shows the name, a small star for a core worker, and a special start time ("18:30"). A person who can't work or hasn't answered gets a warning icon on the chip.
  - Under the chips, "No core worker" when it applies.
  - Tap a row → the shift sheet.
- **"Shifts per person"** card: one row per person. Each row has the name with the core star and "3 shifts · 5 possible", "Away", or "No answer yet" in the error colour. Tap → that person's answer page alone.

**Shift sheet** (bottom sheet, `ui/roster/shift_sheet.dart`):
- Title: "Fri, Nov 13 · Evening".
- "Staff needed" with − and + buttons and the number; 0 shows "Closed". Changes are saved at once (`team_needs`).
- The people in the order of §4.9, each as a row with a check box: name, core star, "2 shifts". Ticking adds the person at once, unticking removes them.
- A ticked row also shows a time button with the start ("17:30", or the special time in bold). It opens the 24 h time picker. Picking the normal start clears the special time.
- "No answer yet" and "Can't work" are collapsed sections, closed by default. Their rows are dimmed but can be ticked.
- No "Save" button; the sheet closes with a swipe or tap outside.

**Answer page** (pushed, `ui/roster/answer_screen.dart`):
- App bar: "Answers · Week 46". During the walk-through, a line "3 of 7" and a thin progress bar.
- The person's name, big, with the core star.
- A segmented button **"Can work" / "Can't work"** with no selection while there is no answer. Choosing one saves the answer.
- **"Away this week"** (outlined button): one tap for vacation. It saves "Can work" with nothing marked and no limit. Disabled while the person is already away.
- **The grid:** one row per day (Monday to Sunday) with a Lunch and an Evening toggle (sun and moon icons as on the Home tab). Tapping the day name toggles both. Closed shifts are disabled. Tapping a shift while there is no answer first chooses "Can work".
- **Summary line:** "Available: Mon evening, Thu, Sat lunch", "Available: every shift", "Away this week" or "No answer yet". "Available: no shift" remains for someone who is in the plan by hand although no shift fits.
- **"At most"** tile: "No limit", or 1–12 shifts, chosen with `pickOption`.
- A menu (⋮) with "Remove answer" (back to no answer).
- **Bottom:** "Back" and "Next" ("Done" on the last person, which returns to the board). Opened from "Shifts per person", only "Done". The order is everyone by name.

**People** (pushed from the board's menu and from Settings, `ui/roster/people_screen.dart`):
- Everyone by name.
- Each row has the name, a core star and "This is me" as a subtitle.
- "Add person" opens the person sheet.
- **Person sheet:** a name field (focused), switches "Core worker" and "This is me", then "Save" and, for an existing person, "Delete". Deleting someone with answers or shifts asks first ("Delete Anna?"), because their answers and shifts in all weeks go too; otherwise a week would count a person the board can't show.
- Names must not be empty. Two people with the same name are allowed, but the sheet warns, because the image would show the name twice.

**Share preview** (pushed, `ui/roster/share_screen.dart`): the image (§4.9) scaled to the screen width inside a `FittedBox`. Below it "Share", which writes the PNG and opens the share sheet. A hint below the image: "Open places and warnings are not in the picture."

### Settings
An overview with one row per category (icon, title, a short summary, a chevron). Each row opens the category on its own page (`ui/settings/settings_pages.dart`). Before 2026-11-06 everything was on one long page.

| Category | Summary on the overview | Page |
|---|---|---|
| Shifts | "Default times, rounding" | "Default shift times" (Lunch, Lunch before evening, Evening); "Recording & export" ("Rounding") |
| Reminders | the lead time, "15 minutes before" | "Before a shift starts", "Ask if not stopped"; "Permissions" with every reliability check and its status |
| Calendar | the calendar's name or "No calendar" | calendar, "Event title", **"Event color"**, "Sync now" |
| Team planner | "Off", or "On · 7 people" | the switch "Team planner" (subtitle "Plan the team's shifts and share the plan as a picture"). While it is on, also "Staff needed" (a sheet with − / + per weekday for Lunch and Evening; 0 shows "Closed"), "Start times" (`teamStarts`) and "People" |
| Appearance | colour and dark mode, "Red · Dark" | "Color", "Dark mode", "App icon", "Icon shape", "Week overview" |
| General | restaurant and language, "Not set · Same as the phone" | "Restaurant" (optional; the dialog has a clear button), "Language" |
| App update | "Version 1.4.1", or "Update to version 1.5.0" with a dot | "Check for updates", "What's new", the found update, "Restart update", "Delete update file" (§12) |

- **Reliability card:** at the top of the overview, only while something is missing: notification permission, exact alarms, battery optimisation, and Autostart on Xiaomi only (it can't be read, so it's ticked off by hand). It checks again when a category page closes.
- **In two places:** only the reliability checks (the developer's choice, 2026-11-06). The overview warns about the missing ones; Reminders › "Permissions" lists them all, so they can be looked at any time.

### Onboarding (first start, all skippable except the first page)
1. **Welcome + language:** "AKAI Timetrack" with a short explanation, and the "Restaurant" field (optional, saved as it's typed).
2. **Notifications:** `POST_NOTIFICATIONS`.
3. **Exact reminders:** on Android 14+, the "Alarms & reminders" settings page.
4. **Calendar:** the hint about a separate calendar, the permission, the selection list, then the event colour.
5. **Xiaomi only:** Autostart and battery set to "No restrictions", with buttons that open the right settings pages.
6. **Default times:** confirm or adjust.

## 8. Theming (F9)

- `ColorScheme.fromSeed(seed, brightness)` builds the light and dark schemes.
- **Presets:** "AKAI red" `#C62828` (default; built with the `vibrant` scheme variant so it stays a clear red), "Terracotta" `#8F4C38` (the former AKAI red), "Blue" `#415F91`, "Green" `#4C662B`, "Violet" `#65558F`.
- **"System color"** uses the `dynamic_color` palette. On Android < 12 it's still shown and falls back to AKAI red.
- **Dark mode** follows `ThemeMode` from the setting.
- **Fonts:** Roboto and Material Icons, which ship with Flutter; nothing extra is bundled, and nothing is fetched at runtime.
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
  - export text (DE/EN, breaks, weeks cut at the month's edges, empty month, "total"/"so far")
  - ReminderPlanner (lead time, 14-day window, running shift)
  - sync state transitions (gateway faked)
  - tips (F10): money parsing and formatting DE/EN, the Thursday month rule, workdays of a week, the Home prompt rule, repository save/clear
  - migration from schema 1 to 2 against the committed snapshot
- **Widget tests:** Plan toggles, edit sheet validation, export preview.
- **Test devices:** development and testing happen on a **Google Pixel 7 Pro** (latest Android) plus the emulator. The user's Xiaomi isn't available before handover, because the app is a surprise. The Xiaomi-specific behaviour (Autostart, battery saver) is therefore built from documentation, and the checklist below runs on the user's phone during the field test (M6). The emulator can at least check minSdk 29 (an Android 10 image).
- **Manual checklist (Pixel first, then again on the user's Xiaomi):**
  - reminder after a reboot
  - reminder with the app swiped away
  - Start/Stop from the notification with the app killed
  - event appears on the developer's phone, with the right colour
  - deleting the event in Google Calendar → recreated
  - dark mode and system colour

## 12. Release and signing

- **Version:** 1.1.0 (`version: 1.1.0+3` in `pubspec.yaml`). The part after `+` is Android's versionCode. It must go up with every release, or the phone refuses the update.
- **Package name (final):** `de.gartenpa.timetrack`, set in one place, `android/app/build.gradle.kts` (`applicationId`). Android treats a new package name as a different app (no updates, separate data), so it must not change again. The Kotlin namespace and the `MainActivity` package stay `de.garten.akaitimetrack`; they are internal only.
- **App name (final):** **TimeTrack** on the home screen, set in `android/app/src/main/AndroidManifest.xml` (`android:label`) and in the ARB files.
- **Release signing key:** created on 2026-11-04 in the dev container.
  - PKCS12 keystore `android/timetrack-release.jks`, alias `timetrack`, RSA 4096, valid 10000 days, CN=TimeTrack. Store and key password are the same.
  - Its settings are in `android/key.properties` (`storeFile`, `storePassword`, `keyPassword`, `keyAlias`).
  - `android/timetrack-release.jks.base64` is a base64 copy for pasting into GitHub. It can be deleted once the secret is set.
  - All three files are git-ignored.
  - SHA-256 certificate fingerprint: `A0:BF:16:21:D7:60:52:69:B2:D6:2D:3C:CD:A2:AF:8E:41:1A:A9:C8:76:8A:4B:7A:2F:66:15:70:62:1C:2C:91`
- **Signing in the build:** `android/app/build.gradle.kts` uses the release key for release builds when `android/key.properties` exists, otherwise the debug key. That is fine for local tests, but a debug-signed APK cannot update an install signed with the release key.
- **Back up the key.** Every update must be signed with the same key. Keep `android/timetrack-release.jks` and its password in a password manager plus an offline copy. If the key is lost, the app on the user's phone can only be replaced by uninstalling it, which deletes its data. The GitHub secret is not a backup, because secrets can't be read back.
- **Releases come from GitHub Actions** (public repo `github.com/Kraechtshammer/akai-timetrack`; the in-app update needs it public):
  - `.github/workflows/ci.yml`: on every push to main and on pull requests, runs `flutter analyze` and `flutter test` (Flutter 3.47.9, same as the dev container).
  - `.github/workflows/release.yml`: on pushing a tag `v*` (or started by hand in the Actions tab), it checks that the tag matches the `pubspec.yaml` version, runs analyze and tests, writes the keystore from the repository secrets, builds the release APK, checks that it isn't debug-signed, and creates a GitHub release "TimeTrack <version>" with `timetrack-<version>.apk` attached and generated release notes. It fails if the secrets are missing.
  - Steps are in [03-dev-setup.md](03-dev-setup.md), section 9.
- **Versioning rule:** to release, raise the version name and the build number in `pubspec.yaml` (e.g. `1.0.1+2`), commit, then tag `v1.0.1`.
- **In-app update** (since 2026-11-05):
  - **Check:** `GET api.github.com/repos/Kraechtshammer/akai-timetrack/releases/latest`, no token (public repo). Drafts and pre-releases don't count; the release needs an `.apk` asset. Newer means a higher `vX.Y.Z` tag than the installed versionName.
  - **When:** on app start and when the app comes back to the foreground, at most every 6 hours (`lastUpdateCheck` status key), plus by hand in Settings. No background work: Android keeps the process alive for days, so "on start" alone wasn't enough, and a background job would need the workmanager package.
  - **Popup:** once per new version (`updatePopupShown` status key), with the release notes: only the "New", "Fixed" and "Improved" sections, headings translated, Markdown links and bold stripped. A release text without headings is shown as it is. "Later" leaves the update in Settings › App update.
  - **Install:** the APK goes to `<app support>/updates/timetrack-<version>.apk` (`.part` while downloading, size checked against the asset), then into a PackageInstaller session (`MainActivity.kt`, channel `de.garten.akaitimetrack/updater`). Android asks the user to confirm; on success it stops and replaces the app. If "install unknown apps" is off for TimeTrack, the app opens that switch and continues the update when the user comes back.
  - **Restart:** "Restart update" (popup while installing, and Settings while an APK is stored) abandons the app's unfinished installer sessions and starts again, reusing the downloaded APK.
  - **What's new** (2026-11-06): on the first start of a newer version, a popup shows the changes since the version that ran before (`lastRunVersion` status key). The notes come from `GET …/releases?per_page=20`: all releases after the last-run version up to the installed one, merged into one "New / Fixed / Improved" list, newest first. An install updated from 1.4.1 or earlier has no `lastRunVersion` yet; if its setup is done, it shows the installed version's notes. A fresh install records its version when the setup ends and shows nothing. If GitHub can't be reached, the next start or resume tries again. Nothing shows when the releases have no user-facing sections. Settings › App update › "What's new" opens the same popup at any time, from the stored notes (`whatsNew` status key, JSON) or GitHub.
  - **Clean-up:** on the first check after start the app deletes APKs of the installed version or older and unfinished downloads. "Delete update file" deletes all of them by hand.
  - Only an APK signed with the same key can replace the app; Android's refusal is shown in the popup.
- **Installing:** USB (`flutter install`) or the APK from the release page. Because the package name changed to the final one, the first install is a new app; the earlier test install (`de.garten.akaitimetrack`) must be uninstalled, and its data is not carried over.
- When global developer verification arrives (2027), register the free limited-distribution account and register the app's package name `de.gartenpa.timetrack`.

## 13. Implementation plan (milestones)

| # | Milestone | Done when |
|---|---|---|
| M0 | Setup and spikes | Flutter project builds and runs on the **Pixel 7 Pro** (test device). Spikes confirm (a) a notification action writes to the DB with the app killed, (b) the chronometer notification shows, (c) the Kotlin bridge inserts a coloured event that appears with that colour in Google Calendar on the web. |
| M1 | Data and Plan | Plan tab with toggles, custom shifts, edit sheet and breaks, persisted in drift, with unit tests for the planning logic. |
| M2 | Recording | Home tab, start/stop/change start, rounding, running notification, pre-shift and overrun reminders, background actions. |
| M3 | Calendar sync | Calendar selection, event colour, reconcile with recreate-on-delete. |
| M4 | Export and overview | Export screen (copy/share), month card, missed-shift warnings. |
| M5 | Settings, theming, i18n, onboarding | All settings working, EN translation, dark mode and system colour, onboarding incl. Xiaomi hints. |
| M6 | Handover and field test | Release key created and backed up. Install on the user's Xiaomi and set it up together (onboarding incl. Autostart and battery). Run the Xiaomi checklist, then one real week of use, then fixes. |

## 14. Prepared for later (not in v1)

### 14.1 Backup and restore

**What v1 already has, with no work:** Android Auto Backup stores the database in the user's Google account's device backup. It's restored when the user sets up a new phone or reinstalls the app. There's no manual "restore now" and no control over timing, but it covers a lost or replaced phone.

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
  - **After a restore:** every shift is marked `dirty`, and the user picks the calendar again.
  - **Avoiding duplicate events:** after a restore, before creating any events, the app looks in the chosen calendar for an existing event **on the same day, with the same start and end time and the event title from settings**. If one matches, the app reconnects the shift to it instead of creating a duplicate. Times are compared using the recorded times if the shift has them, otherwise the planned times.
    - If several events match (e.g. two events with the default title at the same time), the app takes one and leaves the others alone.
    - An event edited by hand in Google Calendar, or created before the title setting was changed, won't match. The app then creates a new event, and the old one has to be deleted by hand.
    - Nothing extra is written into the events for this, so they stay clean.
- **Where the file goes**, to be decided when the feature is built:
  - **No account setup:** Android's system file picker (Storage Access Framework). The user picks a folder once, e.g. in Google Drive. The app keeps write access to it and saves a backup automatically, say weekly. No Google Cloud project, no OAuth.
  - **Invisible app storage on Google Drive:** Google Drive's hidden "app data" folder via the Drive API. Needs a Google Cloud project and Google sign-in in the app.
  - **iOS:** the app's iCloud Drive container. Needs the Apple Developer Program.
  - Recommendation for later: the system file picker on Android first, because it needs no accounts.

### 14.2 Salary (and a tip-share estimate)

Tips are built (F10, §3 and §4.7). The model planned here first (one tip entry per shift, kinds cash/card/pool) was dropped because AKAI pools tips per day and pays weekly.

Salary is built too (2026-11-05): the `wage_rates` table (§3), the rules in §4.8, and the screens in §7.

Possible later extensions:
- tax and deductions, for example a Minijob limit or a net estimate;
- a `surcharge_rules` table for Sunday, holiday and night surcharges, which are common in restaurants. Each rule would have a weekday or holiday flag, a time window and a percentage.

**Tip-share estimate (maybe):** the user's expected share of a day's pool needs the kitchen/service split and the number of servers that day. Both change, so it would be a per-day input next to "Daily pool" (a nullable column on `tip_days`).

## 15. Open points (small, can be decided while building)

- App name "TimeTrack" and package name `de.gartenpa.timetrack` are final (see §12).
- Exact text of the event description in English.
- Whether "Later" on the pre-shift reminder needs a configurable delay (currently a fixed 10 min).

## 16. Changes made during implementation

- **UI library:** `package:material_ui` (Flutter's Material library, now a separate package) instead of `package:flutter/material.dart`; `dynamic_color` already requires it. Never import both in the same file.
- **Navigation:** no go_router. Three tabs in an `IndexedStack` (`lib/ui/home_shell.dart`), Settings pushed with `Navigator`. A tap on a notification just opens the app.
- **Calendar bridge:** a plain `MethodChannel` local plugin (`packages/calendar_bridge`) instead of Pigeon. It has to be a plugin package (not code in MainActivity) so it's also available in the notification background isolate. The same goes for `packages/running_progress`.
- **compileSdk 37:** required by `permission_handler`. minSdk stays 29.
- **"No calendar":** choosing it deletes the app's events from the old calendar. Switching calendars always moves all events (no question).
- **Export texts:** neutral, with no mention of the boss.
- **Monthly export** (2026-11-04): the user sends the hours monthly, so the export covers a month, grouped by week (§4.5). The `exportMonthTotals` setting, its switch in Settings and the switch on the Export screen were removed, because the month total is now always the last line. An old stored `exportMonthTotals` value is ignored.
- **App icon:** adaptive icons in a design and a shape, chosen in Settings › Appearance › "App icon" and "Icon shape". Two settings, because the launcher decides the mask shape and apps can't find it out.
  - Designs (2026-11-06): "Cloche" (a serving dome whose clock hands are a spoon and a fork; the default), "AKAI sign" (the restaurant's sign, `branding/app-icon.svg`, the only design until 1.4.0), and two secret penguin designs, "Penguin, black" and "Penguin, dark blue". Masters in `branding/icons/`.
  - Shapes: "Round" for circular masks (the default), "Squircle" for squircle masks (the default on Xiaomi), "Small squircle" (the whole squircle icon scaled down; the launcher fills the rest).
  - The penguin designs show in the "App icon" list only when the person marked "This is me" in the team planner's "People" has a certain name (`lib/domain/app_icons.dart`), or when a penguin is already the current icon. The release notes only mention "secret icons".
  - Each design and shape is an `activity-alias` (12 in all); the app enables exactly one. Switching closes the app once. The cloche took over the alias names of the sign, so installs from 1.4.0 and earlier move to the cloche in their shape without the app closing. Each design has its own monochrome layer for themed icons; the shapes share it.
- **Package name:** changed to `de.gartenpa.timetrack` at 1.0.0 (was the provisional `de.garten.akaitimetrack`). The Kotlin namespace and `MainActivity` package stay `de.garten.akaitimetrack`.
- **In-app update** (2026-11-05, §12): not in the original design. No new Flutter packages: dart:io for HTTP, the installer in `MainActivity.kt`. Needs the `INTERNET` permission in the main manifest (Flutter only adds it to debug builds) and `REQUEST_INSTALL_PACKAGES`.
- **Database:** schema snapshots in `drift_schemas/` since schema version 2 (2026-11-05), configured in `build.yaml`. Migration steps come from the generated `lib/data/database.steps.dart`; tests are in `test/drift/`. Opening the database file moved to `lib/data/database_connection.dart`, because drift's schema export runs `database.dart` without Flutter.
- **Tips** (2026-11-05, F10): the per-shift `tips` table planned in §14.2 was replaced by `tip_days` (the day's pool total) and `tip_payouts` (the weekly cash payout), because AKAI pools tips per day and pays weekly. A fourth tab, "Pay", was added between Plan and Export. Schema version 2.
- **Salary** (2026-11-05): built with the `wage_rates` table planned in §14.2 (schema version 3). The planned `salaryFor(month, shifts, wageRates, payouts)` became `payForMonth(shifts, rates, now)` in `domain/salary.dart`; tips stay separate (`TipMonth`), because they are counted by week, not by calendar month.
- **Home tab:** the "Today" tab was renamed to "Home", with a `home` icon, when the pay row was added (developer decision, 2026-11-05).
- **Team planner** (F11, planned 2026-11-05): not in the original scope. The user stands in for the boss's weekly service shift plan. Built into the app behind a Settings switch rather than as a separate app (`01-research.md` §10). Tables in §3, rules in §4.9, screens in §7. Schema version 4.
- **Restaurant name** (2026-11-06, §4.10): not in the original design. The app was made for one restaurant and may be shared with colleagues, so the name became a setting. It goes into the event location, the export header and the team plan picture; the AKAI sign icon is offered only when the name is AKAI, and the default red is called "AKAI red" only then.
- **What's new** (2026-11-06, §12): a popup after an update with the changes since the last version that ran, and the same popup from Settings › App update.
- **No "gross"** (2026-11-06, §4.8): the Pay tab and the wage sheet no longer call the wage or the pay gross.
- **Settings categories** (2026-11-06, §7): the one long Settings page became an overview with seven categories, each on its own page, because the page needed a lot of scrolling. The developer picked seven categories over five, and to show the reliability checks in two places but nothing else.
