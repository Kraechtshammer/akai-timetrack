# Architecture and code style

How the code is built and written, as of version 1.6.1 (2026-11-06). The behaviour lives in [02-design.md](02-design.md). Step-by-step recipes for common changes ("add a setting", "change the database") live in [lib/CLAUDE.md](../lib/CLAUDE.md). This file explains the structure and the reasons behind it, and §10 lists the known weaknesses found in the review on 2026-11-06.

**Diagrams:** the architecture canvas ([claude.ai artifact](https://claude.ai/artifact/Q7dPU5DCffUdpWGhiZHSDr), VS Code task *Docs: Show architecture*) has four boards: layers, the write-and-sync loop, isolates and native code, and the database. Their sources are in [architecture/](architecture/). §11 says how to keep them current.

## 1. Size

| Part | Lines | Notes |
|---|---|---|
| `lib/` Dart, without generated files | about 12,400 | 33 UI files; the largest is `ui/today/today_screen.dart` (861) |
| Kotlin | about 600 | two plugins in `packages/`, `MainActivity.kt` |
| `test/`, without generated schema files | about 3,100 | 172 tests |
| Texts | 372 keys | `app_de.arb` (template) and `app_en.arb` |

One developer, one user, one Android phone. Every decision below is measured against that size.

## 2. Layers

| Folder | Holds | May import |
|---|---|---|
| `core/` | Time helpers (day keys, ISO weeks, minutes of the day) and formatting (HH:mm, hours, euros) | nothing of ours |
| `data/` | The drift database (`database.dart`), repositories, `AppSettings` | `core` |
| `domain/` | The rules: planning, recording, rounding, month summary, export text, reminder planner, tips, salary, team roster, icon designs, update versions | `core`, `data` |
| `platform/` | Android integration: notifications, calendar sync, device setup, launcher icon, in-app update | `core`, `data`, `domain`, `l10n` |
| `app/` | `AppServices`, Riverpod providers, `TimeTrackApp`, theme, shift colours, update controller | everything below |
| `ui/` | Screens, sheets, shared widgets (`common.dart`), the `material.dart` re-export | everything below |
| `l10n/` | ARB files, the generated `AppLocalizations`, `labels.dart` (enum → text) | used by every layer above `core` |
| `packages/` | Kotlin plugins `calendar_bridge` and `running_progress` | called from `platform/` |

Imports that go against this order today:

- `data/roster_repository.dart` imports `domain/roster.dart` (`FillPick`, `TeamSlot`), and `data/app_settings.dart` imports `domain/rounding.dart` (the `RoundingMode` enum).
- `app/app.dart` imports `ui/` to build `HomeShell` and `OnboardingScreen`. This is normal for the app root.
- `domain/export_text.dart` imports `l10n/app_localizations.dart`, which imports Flutter. So `domain/` is Flutter-free except for this one file.
- `l10n/labels.dart` imports `platform/app_icon.dart` for the icon names.

**Domain models are the drift row classes.** `Shift`, `TipDay`, `WageRate` and `TeamMember` come from `database.g.dart`, and `domain/shift_info.dart` adds behaviour to `Shift` as an extension (`statusAt`, `workedMinutes`, `isRecorded`). A separate model layer would mean mapping every row twice for no gain at this size.

## 3. Runtime

### 3.1 Start-up

`main()` (`lib/main.dart`):
1. `AppServices.create()` sets the time zone (Europe/Berlin if the device's can't be read), opens the database and builds the repositories and services.
2. It sets up notifications inside a try/catch, so the app opens even without them.
3. It chooses the default launcher icon once and starts a first `syncAll()` (both unawaited).
4. It calls `runApp` with a `ProviderScope` that overrides `servicesProvider` with these services.

`TimeTrackApp` shows an empty `Scaffold` until the settings stream has its first value, then shows onboarding or `HomeShell`.

### 3.2 AppServices and Riverpod

- `AppServices` (`app/services.dart`) is a plain object holding the database, the five repositories, `NotificationService`, `CalendarSync`, `PlanningService` and `RecordingService`. Each isolate creates one.
- Riverpod is a thin view layer on top. Most providers are one-line `StreamProvider`s over a repository's `watch…` method. The only derived one is `rosterWeekProvider`. `nowProvider` ticks every 20 seconds.
- Screens reach the services through `ref.services` (a `read`), and the settings and the current time through `ref.settings` and `ref.now` (both `watch`es). All three are extensions on `WidgetRef` in `app/providers.dart`.

The background isolate cannot use Riverpod, which is why the services live in a plain object rather than in providers.

### 3.3 A change, from tap to calendar

1. The UI calls `PlanningService` or `RecordingService` (or `ShiftRepository` directly for small edits).
2. The repository writes the row with `syncState = dirty` and a new `updatedAt`.
3. The service calls its `onChanged` callback, which is `AppServices.syncAll()`.
4. `syncAll()` chains runs on `_lastSync`, so only one runs at a time in this isolate. A run:
   - `NotificationService.reconcile` gets the shifts from yesterday on. It plans the wanted reminders (`planReminders`), cancels pending start and overrun reminders that are no longer wanted and snoozes whose shift is gone or no longer planned (`staleSnoozeIds`), schedules the wanted ones, and shows or removes the running notification.
   - `CalendarSync.run` deletes events of `pendingDelete` shifts, inserts or updates each dirty shift's event, and re-creates events deleted in Google Calendar for shifts from this week on.
   - `ShiftRepository.setSynced` marks a row synced only if its `updatedAt` hasn't changed since the run read it, so a change made during the run is not lost.
5. drift's streams fire, providers emit, screens rebuild.

Errors are caught separately for the notifications and the calendar, so one failing doesn't skip the other, and only logged with `debugPrint`. Dirty shifts wait for the next run, which happens after the next change, on start and on resume.

### 3.4 Isolates

- **UI isolate:** everything above, plus the MainActivity channels (`…/app_icon`, `…/updater`), which exist only here.
- **Background isolate:** when a notification button is tapped while the app is closed, `flutter_local_notifications` starts `onNotificationActionInBackground`. It builds its own `AppServices` and calls `handleNotificationAction`, the same method the open app uses. No Riverpod, no `BuildContext`, no MainActivity channels.
- **Shared database:** `driftDatabase(…, shareAcrossIsolates: true)` runs one database server isolate, so writes from either side reach every stream.
- **Native, no Dart:** `ProgressTickReceiver` (`running_progress`) moves the running notification's progress bar from an exact alarm every 5 minutes. The notification plugin's boot receiver re-registers scheduled reminders after a reboot.

Each isolate has its own `_lastSync` chain, so the two isolates can sync at the same moment. That is rare, since the background isolate lives only for one button tap.

### 3.5 Native code

| Piece | Kind | Why this way |
|---|---|---|
| `calendar_bridge` | Own Kotlin plugin, MethodChannel | Event colour keys, switching on sync for a hidden Google calendar, and checking for deleted events are not covered by a package (02-design.md §5.1). Work runs on a single-thread executor; results go back on the main thread. |
| `running_progress` | Own Kotlin plugin | Must run from an alarm without Flutter. Uses `ProgressStyle` on Android 16 (Live Update). |
| `MainActivity.kt` | Two channels | The launcher icon (activity aliases) and the updater (`PackageInstaller` session) need the activity; one-off code does not justify a plugin. |

Channel names still start with the first package name `de.garten.…`. They are only strings; renaming them would gain nothing.

### 3.6 In-app update

`platform/app_update.dart` reads GitHub's `releases/latest`. It downloads the APK into app storage, checks its size against the release data, and installs it through `PackageInstaller` (`MainActivity.kt`). State and the "What's new" popup are in `app/update_controller.dart`. Android refuses an APK signed with a different key, which is the real protection against a tampered file.

## 4. Data

- **drift on SQLite**, schema version 4. Migrations are generated step by step from snapshots in `drift_schemas/`. They only add tables or nullable columns.
- **Conventions:**
  - UUID ids, so a later backup can merge by id.
  - Days as text `yyyy-MM-dd`, so a shift belongs to its local day whatever the time zone.
  - Money as integer cents.
  - `createdAt` and `updatedAt` on every table except `team_needs`.
- **No foreign keys.** Repositories keep related rows in step, for example `deleteMember` in one transaction.
- **Settings** are a key-value table read into one immutable `AppSettings` (23 settings). The background isolate can read them, and new settings need no migration. Device status values (`lastCalendarSync`, `whatsNew`, …) share the table. `SettingsRepository.watch()` filters them out so they don't rebuild the app.
- **Writes:**
  - `ShiftRepository.save` and `delete` replace the whole row with the object the caller passes. Services use them right after reading the shift.
  - The shift sheet holds a shift while it is open, so it saves with `saveEdited`. That writes only if the row's `updatedAt` is still the one the sheet read; otherwise the sheet closes with "This shift was changed in the meantime…". `updatedAt` is stored in whole seconds, so every write moves it forward by at least a second.
  - Read-then-write steps run in a transaction: creating a shift (with its notification id), `setSynced`, `SettingsRepository.update`, and the tip, wage, answer and roster upserts.

## 5. Domain

- **Pure functions** take their inputs and the current time as parameters: `roundShift`, `summarizeMonth(shifts, now)`, `planReminders(shifts, settings, now)`, `payForMonth`, `tipWeeksOf`, `buildExportText`.
- **Display rules** that screens share live in `domain/display_rules.dart`: sums over shifts (`recordedMinutes`, `missingCount`), `nextShift`, the week strip's `dayStatus` and `slotStatus`, `stopPreview` for the running card, and `payColumns`. Screens map the results to colours and texts. `RosterWeek` holds every team-planner rule, and `fill()` is deterministic.
- **Two services:** `PlanningService` and `RecordingService` take `ShiftRepository`, `SettingsRepository` and an `onChanged` callback. Their methods take an optional `at:` time for tests.
- **The callback** is the only link from the rules to platform code. It keeps notifications and the calendar out of `domain/`, and tests pass a stub.

## 6. UI

- **Navigation:** `HomeShell` holds the tab index and an `IndexedStack` of Home, Plan, Pay, Export and (when switched on) Team. A `ValueKey` that counts visits gives Pay, Export and Team a fresh state on each visit. Settings and the team sub-screens are pushed routes; sheets are modal bottom sheets. No router package.
- **Data:** screens are `ConsumerWidget`s, or `ConsumerStatefulWidget`s when they hold local state or a timer. They read streams as `ref.watch(provider).value ?? fallback`. There is no loading or error UI, because a local database answers in milliseconds.
- **Writes** go through `ref.services` (services or repositories), never to tables.
- **Shared pieces:**
  - `ui/common.dart`: `PageHeader`, `Panel`, `Figure`, `WeekSwitcher`, `TimeField`, `pickTime`, `pickOption`, the day card frame `DayCard` with `DividedRow`, `textColumnWidth` for aligned columns, and the `context.l10n`, `colors`, `text`, `locale` and `showSnack` helpers.
  - `context.shiftColors` (`app/shift_colors.dart`) for status and shift-type colours.
  - `l10n/labels.dart` for enum texts and `shiftTypeIcon`.
- **Material:** every UI file imports `ui/material.dart`, which re-exports `material_ui` and `material_3_expressive` and hides their name clash. Nothing imports `package:flutter/material.dart`.

## 7. Code style

- **Formatting:** `dart format`. Lints: `flutter_lints` plus `unawaited_futures`, `discarded_futures`, `cancel_subscriptions`, `close_sinks`, `avoid_dynamic_calls`, `prefer_final_locals` and a few more (`analysis_options.yaml`). A future that is meant to run on its own is wrapped in `unawaited(...)`. `flutter analyze` must be clean.
- **Files:** one screen per file, with its parts as private widget classes (`_RunningCard`, `_WeekStrip`) rather than methods returning widgets. Shared pieces move to `common.dart` or `roster_common.dart` once a second screen needs them.
- **Names:**
  - Dart names follow the language conventions.
  - Providers end in `Provider`.
  - Repositories have `watch…` for streams, `get…` or `load` for one-off reads, and `set…`, `save` or `delete` for writes.
  - Domain functions are verbs (`planReminders`, `summarizeMonth`).
- **Imports:** packages first, then `material.dart` in UI files, then relative imports of our own files.
- **Comments:** `///` on public classes, fields and non-obvious functions. They say what and why, in plain English, and point to the design doc (`docs/02-design.md §4.8`). Comments follow the docs style: English only, UI elements by their English label, and "the user".
- **Time:**
  - `DateTime` in local time.
  - `dateOnly`, `addDays`, `daysBetween`, `weekStart` and `timesOn` from `core/time.dart` for calendar arithmetic, never a `Duration` of days, which is an hour off across a clock change.
  - Day keys for storage.
  - `tz` only for scheduling notifications.
- **Money:** integer cents, `formatEuros` to show, `parseEuroCents` to read.
- **Errors:** caught at the edges (start-up, sync run, platform calls) and logged with `debugPrint`. Rules don't throw for expected cases; they return a result (`ToggleResult`, `CalendarSyncResult`).
- **Kotlin:** short KDoc that says why; channel errors become `PlatformException` codes; cursors use `use`; blocking work stays off the main thread.

## 8. Tests

`flutter test --coverage` on 2026-11-06, lines hit per folder:

| Folder | Coverage |
|---|---|
| `core/` | 97% |
| `domain/` | 92% |
| `data/` (hand-written) | 63% |
| `platform/` | 20% |
| `app/` | 17% |
| `ui/` | 9% |

- **Database tests** use an in-memory drift database; `testShift('17:30-23:00')` in `test/helpers.dart` builds shifts.
- **The calendar sync** is tested against `FakeBridge`.
- **Migrations** have generated tests in `test/drift/`.
- **Widget tests:** only the team plan image and the shift colours. There are none for the screens.
- **Not tested:** `syncAll`, `handleNotificationAction` and `NotificationService.reconcile`.
- **Time zone:** the dev container runs in UTC, which has no daylight saving change. CI and the VS Code test task run the tests with `TZ=Europe/Berlin`, and `test/time_and_rounding_test.dart` has cases across both clock changes.

## 9. Decisions, reviewed on 2026-11-06

| Decision | Verdict |
|---|---|
| Local database as the only source of truth; calendar and notifications derived by reconcile | Keep. It is why sync errors never lose data. |
| `AppServices` as a plain object, Riverpod only as a thin view layer | Keep. The background isolate needs the services without Riverpod. |
| drift row classes as domain models | Keep. A mapping layer would cost more than it saves. |
| Key-value settings with hand-written `fromMap`, `toMap` and `copyWith` | Keep the table. Each new setting touches five places in `app_settings.dart`, which is tolerable at 23 settings. |
| One `syncAll` chain per isolate, errors only logged | Keep. Notifications and calendar have separate try/catch blocks since 2026-11-07. |
| Own Kotlin calendar plugin; MainActivity channels for icon and updater | Keep. |
| Old channel names `de.garten.…` | Keep. Cosmetic. |
| No router, `IndexedStack` with visit counters | Keep. |
| No loading or error UI | Keep for a local database. |
| Lints | Stricter since 2026-11-07: fire-and-forget futures must be marked with `unawaited`. |
| Status and display rules inside widgets | Moved to `domain/display_rules.dart` with tests on 2026-11-07. Keep new ones there. |
| Whole-row writes in `ShiftRepository.save` | Keep for services; the shift sheet uses the checked `saveEdited`. |

## 10. Known weaknesses

The review on 2026-11-06 found two time-zone bugs, stale writes from the shift sheet, missing error handling on the notification paths, fixed-width columns, untested display rules in widgets, and comments against the docs style. All were fixed on 2026-11-07 (commits `1482f64` to the comment clean-up that followed `d835059`). What is left is small. Remove an item when it is fixed.

- Two imports still go against the layer order (§2): `data/` uses `FillPick`, `TeamSlot` and `RoundingMode` from `domain/`.
- The UI isolate and the background isolate each have their own sync chain, so two runs can overlap (§3.4). Rare; the steps are mostly idempotent.
- The background isolate never closes its database connection. It lives only for one button tap.
- There are no widget tests for the screens. The rules they show are tested in `domain/`.
- `deleteWithUndo` lives in `ui/plan/plan_screen.dart`, but `ui/shift_sheet.dart` uses it too.
- `ui/today/today_screen.dart` is still about 850 lines. It splits naturally into the shift cards and the week strip when it is next changed.

## 11. Keeping this current

- Change this file and the canvas in the same commit as a structural change: a new folder, layer, table, isolate path, plugin or channel.
- **The canvas:**
  - Its sources are `docs/architecture/canvas.json` and one `.dc.html` file per board.
  - Edit them, then publish the changed files to the artifact `https://claude.ai/artifact/Q7dPU5DCffUdpWGhiZHSDr`, with `root` `docs/architecture` and each file served at `project/<name>`. Send `canvas.json` only when boards are added, moved or resized.
  - The canvas is a claude.ai artifact of the Design type. It is private to the developer's account.
- Update the version and date in the canvas title note and at the top of this file when you do.
