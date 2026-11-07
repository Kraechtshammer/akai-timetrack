# lib/ and test/

Guidance for work on the Dart code. The root `CLAUDE.md` covers the dev container, running flutter/adb, commits, docs style and developer preferences. Design background: `docs/02-design.md`; state and code map: `docs/HANDOFF.md`.

## Layers

- `core/`: pure helpers. Time (`time.dart`: day keys, ISO weeks, minutes), `format.dart` (HH:mm, `formatHours`, `formatEuros`).
- `data/`: drift database `database.dart` (+ generated `database.g.dart` and `database.steps.dart`), `database_connection.dart` (opens the file), `shift_repository.dart`, `tip_repository.dart`, `wage_repository.dart`, `roster_repository.dart` (team planner), `settings_repository.dart`, `app_settings.dart`.
- `domain/`: pure Dart logic (planning, recording, rounding, month summary, export text, reminder planner, tips, salary, team planner `roster.dart`, launcher icon designs and shapes `app_icons.dart`). No Flutter imports, except `export_text.dart`, which takes `AppLocalizations`. Unit-tested. The drift row classes (`Shift`, `TipDay`, …) are the domain models, so `domain/` imports `data/`.
- `platform/`: Android integration. `notification_service.dart`, `calendar_sync.dart`, `device_setup.dart`, `app_icon.dart`, `app_update.dart`.
- `app/`: `AppServices` (`services.dart`, one per isolate), Riverpod `providers.dart`, `app.dart`, `theme.dart`, `shift_colors.dart`, `update_controller.dart` (in-app update state).
- `ui/`: screens. `material.dart` is the one UI import. `common.dart` has shared widgets. `ui/roster/` is the team planner (F11): board, shift sheet, answers, people, image and share preview, Settings tiles; shared bits in `roster_common.dart`.
- `l10n/`: ARB files, generated `app_localizations*.dart` (committed), `labels.dart`.
- Native code is in `packages/calendar_bridge` and `packages/running_progress` (Kotlin plugins).
- The structure, the reasons behind it, the known weaknesses and the diagrams are in `docs/04-architecture.md`. Two imports go against the layer order today: `data/roster_repository.dart` and `data/app_settings.dart` import from `domain/`. Don't add more.

## Data flow

- The database is the source of truth. Every shift write marks the row `dirty` (`SyncState`).
- `AppServices.syncAll()` reconciles notifications and the calendar. It runs after each change, on start and on resume, one at a time (chained on `_lastSync`). It swallows errors with `debugPrint`, so look at the logs when something silently doesn't sync.
- `PlanningService` and `RecordingService` get `syncAll` as a callback. Change shifts through them or `ShiftRepository`, never write tables from the UI.
- Notification buttons call `AppServices.handleNotificationAction`, in the app or in a background isolate (`onNotificationActionInBackground`, which builds its own `AppServices`). Code on these paths must work without UI and Riverpod, and may only use plugins, not the MainActivity channels.
- The database uses drift `shareAcrossIsolates`, so screens update when the background isolate writes.
- Time zone: `tz.local` must be set before using `tz`. `AppServices.create` does it. Tests must do it too.

## Common changes

### Add a setting
1. In `data/app_settings.dart`: field and default in the constructor, `fromMap`, `toMap`, `copyWith`.
2. `fromMap`: unknown or broken values fall back to the default. Enums use `pick(values, key, fallback)`.
3. `copyWith`: nullable values are `T? Function()?` closures, e.g. `calendarId: () => null`.
4. Add a round-trip test in `test/settings_and_notification_test.dart`.
5. Settings live in the `settings` key-value table so the background isolate can read them. No new table or column is needed.
- `lastCalendarSync` (and `tipPromptDismissedDay`) is device status, not a setting. `SettingsRepository.watch()` filters it out so it doesn't rebuild the app. Do the same for other status keys.

### Add or change a string
- `l10n/app_de.arb` is the template. `app_en.arb` must get every key.
- Run `flutter gen-l10n` and commit the generated files.
- Enum-to-text mapping goes in `l10n/labels.dart`.
- Notification and calendar texts use `AppServices.l10n()` (the app language setting), not a widget context. Changing the language marks all events dirty.
- Hours are formatted with `formatHours` (locale decimal separator, at least one decimal). Time pickers are 24 h (`pickTime`).

### Add a UI screen or widget
- Always `import '../material.dart';` (path relative to the file). It re-exports `material_ui` and `material_3_expressive` and hides the `RoundedPolygon`/`CornerRounding` clash.
- Never import `package:flutter/material.dart`. In `ui/` never import `package:material_ui` directly.
- Buttons: `M3EButton` (styles filled, tonal, outlined, text; `M3EButton.icon`). Big buttons: `size: M3EButtonSize.md` plus `decoration: M3EButtonDecoration.styleFrom(minimumSize: ...)`. Icon buttons: `M3EIconButton(variant: ...)`.
- The wavy bar is `WavyProgress` (wraps `M3EProgressIndicator.linearWavy`).
- Segmented buttons, chips, sheets and dialogs are still plain Material.
- `app.dart` wraps the app in `M3ETheme(data: M3EThemeData.fromMaterial(Theme.of(context)))`.
- Use the helpers in `ui/common.dart`: `PageHeader`, `Panel`, `Figure`, `WeekSwitcher`, `TimeField`, `pickTime`, `pickOption`, and `context.l10n/colors/text/locale/showSnack`.
- Columns of aligned one-line texts get their width from `textColumnWidth` (`common.dart`), not a fixed number, so English labels and large fonts don't wrap.
- Check the screen in dark and in light mode.

### Change colours
- Seeds are in `app/theme.dart`. "AKAI red" `#C62828` uses `DynamicSchemeVariant.vibrant`; `fidelity` was rejected (glaring dark-mode containers, blue tertiary). The other seeds use `tonalSpot`. "System color" comes from `dynamic_color`.
- Shift status and shift type colours are `context.shiftColors` (`app/shift_colors.dart`): `recorded`, `missed`, `lunch`, `evening` (with containers / on-colours) and `today` for the today border. Use them instead of `primary`/`error` for these meanings. Planned is `outline`, running is `primary`. Adding a candidate or changing a seed: update the expected picks in `test/shift_colors_test.dart`.

### Change the database
- Tables are in `data/database.dart`. After editing run `dart run build_runner build -d`.
- Then run `dart run drift_dev make-migrations`. It snapshots the schema into `drift_schemas/`, regenerates `database.steps.dart` and the tests in `test/drift/` (config in `build.yaml`).
- Raise `schemaVersion` and add the step in `AppDatabase.migration`. Migrations only add. Never rename or reuse a column. Fill the generated data-integrity test with a row per old table.
- `database.dart` must not import Flutter (drift's schema export runs it in plain Dart); the file is opened in `database_connection.dart`.
- Money is integer cents. Show it with `formatEuros`; parse input with `parseEuroCents` (`domain/tips.dart`).

### Team planner (F11)
- Its own tables (`team_members`, `team_answers`, `team_assignments`, `team_needs`) and no link to `shifts`, calendar sync or reminders. The only bridge is `PlanningService.addFromTeamPlan` ("Add my shifts to Plan").
- All rules are on `RosterWeek` in `domain/roster.dart` (availability, staff counts, sheet order, `fill()`); screens read it through `rosterWeekProvider(weekStart)`. Tests: `test/roster_test.dart`, `test/plan_image_test.dart`.
- Answer marks are a bit mask: bit `(weekday - 1) * 2 + shift.index`. Use `withMark`/`isMarked`.
- The shared PNG is `TeamPlanImage` (1600 × 900 logical, pixel ratio 1.2), always light, whatever the app theme.

### Change domain logic
- Keep it in `domain/` as pure functions or small classes taking repositories/settings. Every domain change gets a test.

## Platform notes

- `platform/app_icon.dart` uses the MainActivity channel `de.garten.akaitimetrack/app_icon`. It works in the UI isolate only. An icon is a design and a shape (`domain/app_icons.dart`), sent as the key `design.shape`. The secret designs are offered by `iconDesignsOffered`, from the team planner's "This is me" person; keep that rule out of the release notes.
- `platform/app_update.dart` (in-app update) uses the MainActivity channel `de.garten.akaitimetrack/updater`, also UI isolate only. State lives in `app/update_controller.dart` (`updateProvider`); `HomeShell` triggers the check on start and resume. Its status keys (`lastUpdateCheck`, `updatePopupShown`) are filtered out of `SettingsRepository.watch()`. The release URL can be overridden with `--dart-define=UPDATE_RELEASE_URL=...` for tests.
- Notification ids: `notificationId(shift, kind)` in `domain/reminder_planner.dart` = `shift.notifId * 10 + kind.code`. The running notification is `runningNotificationId` = 1.
- The running notification's progress bar is moved by the `running_progress` package (exact alarm every 5 min).
- Calendar access goes through `CalendarSync` and the `calendar_bridge` package. `CalendarSync` takes an optional bridge and an optional permission function, so tests can fake both.

## Tests

- `test/` mirrors the layers. Run `TZ=Europe/Berlin flutter test` (the task *Flutter: Test* and CI do): the container runs in UTC, which has no daylight saving change, so date bugs would pass unnoticed.
- Calendar arithmetic uses `addDays`, `daysBetween`, `weekStart` and `timesOn` from `core/time.dart`, never `Duration(days: …)` or `difference(…).inDays` on local times.
- `flutter analyze` must report no issues.
- Database tests use an in-memory `AppDatabase(NativeDatabase.memory())`. Build shifts with `testShift` from `test/helpers.dart`.
- Domain tests are pure.
- `calendar_sync_test.dart` uses `FakeBridge` and calls `tzdata.initializeTimeZones()` in `setUpAll`. Tests that format dates in a locale need `initializeDateFormatting` in `setUpAll` (see `export_text_test.dart`).

## Pitfalls

- The release build's resource shrinker removes resources that are only referenced by name. It once removed `ic_notification`, and the app hung on the splash screen. Add such resources to `android/app/src/main/res/raw/keep.xml`.
- `main()` must never let a failing setup step block `runApp`. Wrap new start-up work in try/catch like the notification setup.
- Don't add anything to the notification-action path that needs a `BuildContext`, a provider, or `MethodChannel`s from MainActivity.
- Generated files (`database.g.dart`, `app_localizations*.dart`) are committed. Regenerate, don't hand-edit.
- A `SnackBar` with an `action` defaults to `persist: true` and never closes on its own. Set `persist: false` (as `context.showSnack` does).
