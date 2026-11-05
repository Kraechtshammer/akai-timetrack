# Handoff: TimeTrack v1 implementation

State as of 2026-11-05; the version is now 1.3.0 (`1.3.0+5`). Read this together with [01-research.md](01-research.md), [02-design.md](02-design.md) (its §16 lists what changed during implementation) and [03-dev-setup.md](03-dev-setup.md).

## Where things stand

The v1 app is implemented and runs on the emulator (Android 16.0 / SDK 36.0, virtual Pixel 7 Pro, dark mode). Checked by hand there:

- **Onboarding:** language, notification and exact-alarm permissions, calendar choice, event colour, default times.
- **Home tab:**
  - next-shift card, start button, running card with live timer and rounded preview;
  - month card with the Expressive wavy progress bar;
  - week strip with sun/moon icons (or bars, see Settings).
- **Plan:** Lunch/Evening toggles, lunch automatically 12:00–15:30 when there is an evening shift, shift sheet.
- **Export:** a monthly text grouped by week (weeks cut at the month's edges), always opens on the current month (also when switching back to the tab).
- **"Shift deleted" snack bar** closes on its own again. Snack bars with an action (here "Undo") default to `persist: true` in the current `material_ui`, so they stayed until tapped. `persist: false` is now set there and in `context.showSnack`. Keep it on any new snack bar with an action.
- **Calendar sync** into a local test calendar:
  - events titled with the default title `Kellnern` in the chosen colour (Tomato = key 11), without a calendar reminder;
  - events are updated when a shift changes and deleted when it's removed;
  - picker: "Refresh" finds a newly added calendar; choosing a not-yet-synced calendar turns its sync on and moves all events there;
  - Settings › Calendar › "Sync now" shows "Up to date · last synced 20:41" or the number of pending changes.
- **Reminders:** scheduled as exact alarms (checked with `dumpsys alarm`).
- **Running notification:** chronometer, "Stop" button, progress bar. On the Android 16 emulator it uses `ProgressStyle` with the red bar. The 5-minute progress alarm is scheduled (`dumpsys alarm`).

Automated checks:
- `flutter analyze`: no issues.
- `flutter test`: 40 tests pass (rounding, ISO weeks, export text DE/EN, month summary, reminder planning, planning rules against an in-memory database, new settings keys, notification progress maths, calendar sync with a fake bridge).
- Debug and release APKs build. The first release APK of this round hung on the splash screen: the resource shrinker had removed `ic_notification`, which flutter_local_notifications looks up by name, so `main()` threw before `runApp`. Fixed with `android/app/src/main/res/raw/keep.xml`; `main()` now also starts the app if notification setup fails. Any other resource looked up by name must be added to `keep.xml`.

## Done in the second session (2026-11-04, from the developer's feedback)

1. **Calendar list:** lists not-yet-synced calendars (with a hint; choosing one turns sync on), plus "Refresh" (asks Android to sync all accounts, then reads the list again now and after 6 s) and a hint about Google needing a few minutes.
2. **Sync status:** "Sync now" tile in Settings › Calendar with the status as subtitle. The button runs the sync and asks Android for an expedited upload to Google. Not added on Plan (the developer's "maybe"); easy to add there with the same providers if wanted.
3. **Event text language:** changing the language marks all events for an update.
4. **Week strip:** the developer saw three prototypes (icons, two bars, dots). Kept icons (default) and bars, selectable in Settings › Appearance & language › Week overview; the dots were dropped. The developer noted bars scale better to a possible third shift, and icons could get a "rising sun" for a morning shift.
5. **App icon:** three variants, because the launcher decides the mask shape and apps can't find out which. They are switched in Settings › Appearance & language › App icon.
   - **Round:** a red ring around a dark-red disc with centred letters, made for circular masks (Pixel). This is the default.
   - **Squircle:** exactly `branding/app-icon.svg` (n=4 panel, letters as in the SVG), mapped onto the 72 dp visible area, for squircle masks. It's the default on Xiaomi/Redmi/POCO, set once on the first start. Until 2026-11-05 its panel was a rounder compromise shape (exponent 2.5) with smaller letters; the developer wanted the SVG as is.
   - **Small squircle:** the whole squircle scaled down on a transparent background. The Pixel launcher fills the rest of its circle with black; the developer likes this one too.
   - How it works: one `activity-alias` per variant in `AndroidManifest.xml`, of which exactly one is enabled (`MainActivity.kt`, channel `de.garten.akaitimetrack/app_icon`; Dart: `lib/platform/app_icon.dart`).
   - MainActivity's own MAIN/LAUNCHER filter stays in the source manifest, because the Flutter tool only looks for `<activity>`. It's marked `tools:node="remove"`, so the built app has only the aliases. Check: `adb shell cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER de.gartenpa.timetrack`.
   - Switching closes the app (Android finishes a task whose launcher alias is disabled), so the app asks first. The home-screen shortcut may have to be added again.
   - Checked on the emulator: Round and Small squircle in the app drawer, and switching from Settings.
   - A non-adaptive squircle icon was tried; Pixel wraps it in a white circle.
6. **Colours:** new "AKAI red" `#C62828` (default, `DynamicSchemeVariant.vibrant`), the old brown-red is now "Terracotta". The `fidelity` variant was tried first, but in dark mode it made glaring red containers and a blue tertiary.
7. **Material 3 Expressive:** the `material_3_expressive` ^1.2.0 package is added (developer decision).
   - All buttons are `M3EButton` / `M3EIconButton`.
   - The wavy bar is `M3EProgressIndicator.linearWavy`.
   - The app is wrapped in `M3ETheme(data: M3EThemeData.fromMaterial(Theme.of(context)))`.
   - UI files import `lib/ui/material.dart`, which exports both `material_ui` and the package (with the name clash handled). Never import `package:material_ui` directly in UI code.
   - Segmented buttons, chips, sheets and dialogs are still the Material ones.
8. **Notification progress** (developer decision: Live Update on Android 16, pre-scheduled updates elsewhere). It is a new local plugin, `packages/running_progress`:
   - Flutter posts the notification (with the button and the current progress).
   - The plugin re-posts it every 5 min from an exact alarm, rebuilt with `recoverBuilder`, until the planned end.
   - On SDK ≥ 36 it uses `ProgressStyle` and the `android.requestPromotedOngoing` extra (`setRequestPromotedOngoing` isn't in the API 36 SDK, so the extra is set directly), plus the `POST_PROMOTED_NOTIFICATIONS` permission.
   - **On the emulator (SDK 36.0) the notification is not promoted** (no `PROMOTED_ONGOING` flag), although the extra and permission are present. Live Updates were rolled out with Android 16 QPR1 (36.1), so this needs checking on the Pixel. If it isn't promoted there either, look at the promotion requirements (channel importance, `hasPromotableCharacteristics()`, the per-app "Live notifications" switch).
   - Pre-scheduling separate notifications (the other option discussed) doesn't work with flutter_local_notifications: scheduled notifications are keyed by id, so they can't all replace notification 1. That's why the native plugin approach is used for every Android version.

## Done in the third session (2026-11-05): in-app update

- The app looks for a newer GitHub release on start and on resume (at most every 6 hours), shows a popup once per version with the "New / Fixed / Improved" notes, downloads the APK and starts Android's installer (PackageInstaller session). Settings › App update: check now, the found update, "Restart update", "Delete update file". The APK is deleted on the first start of the new version. Design: `02-design.md` §12.
- Code: `domain/app_update.dart` (versions, release JSON, notes, clean-up rules; tested), `platform/app_update.dart` (HTTP, files, channel), `app/update_controller.dart` (Riverpod state), `ui/settings/update_tiles.dart` (tiles and popup), `MainActivity.kt` (channel `de.garten.akaitimetrack/updater`). The manifest now has `INTERNET` and `REQUEST_INSTALL_PACKAGES`.
- Testing on the emulator with a fake release: `scripts/update_test_server.dart`, see `03-dev-setup.md` §9.
- Checked by the developer on the emulator (debug builds 1.0.0 → 1.0.1 from the fake server): popup with notes, "install unknown apps" switch and automatic continue, download progress, cancelling Android's prompt ("Update cancelled.") and retrying without a second download, the update itself, the APK deleted on the next start, deleting the file by hand.
- Developer decisions: session installer (not the system installer intent), popup once per version, check on start/resume every 6 h (no background job), only the sections of the notes that matter to the user.

## Done in the fourth session (2026-11-05): tips (F10)

- Research in `01-research.md` §9, design in `02-design.md` §3 (tables), §4.7 (rules), §7 (screens).
- **New tab "Pay"**, between Plan and Export. It opens on the current week. It shows the month's tips, the week's "Paid out" (cash payout) and a "Daily pool" list: one row per workday with the day's pool total, the tips of everyone combined. Both amounts are only for the user's records; they don't go into the export.
- **Home tab:** an "Add the tips" card once the day's shifts are recorded (today or yesterday; "Not now" hides it for that day), and a "Tips" row on the month card. A third column was prototyped too; the developer chose the row, because salary rows will go there later.
- A payout counts for the month of its week's Thursday (ISO rule; developer decision).
- **Database schema version 2:** tables `tip_days` and `tip_payouts`. First drift schema snapshots (`drift_schemas/`, `build.yaml`) and generated migration tests (`test/drift/`). Opening the database file moved to `data/database_connection.dart`, so drift's schema export can run `database.dart` without Flutter.
- Checked by the developer on the emulator (installed over 1.1.0 data, so the migration ran on a real database): prompt and sheet, amounts with and without cents, payout and month total, delete with "Undo", both month-card layouts. 66 tests pass (14 of them for tips, 2 for the migration).
- Not checked: light mode for the new screens; on a phone.
- Trap: the dev container's Python has no `json` module. ARB edits were done with a Dart script.

## Done in the fifth session (2026-11-05): salary

- Design in `02-design.md` §3 (table `wage_rates`), §4.8 (rules), §7 (screens).
- **Hourly wage:** set on the Pay tab. A rate is valid from a day on (default: the 1st of the month on screen), so a raise doesn't change past months. The first rate also counts for earlier months. The wage sheet lists all rates; each can be deleted.
- **Pay tab month card:** the expected gross pay for the calendar month as the big number, with the amount earned so far (recorded shifts) and a wavy bar; "Expected" adds planned, running and missed shifts. Then "Tips", then "Total · with tips" as "Earned" and "Expected". Past months show what was earned, future months what is expected. The hourly wage is a chip in the header. The developer picked this layout from three prototypes.
- **Home tab:** the "Today" tab is now "Home" (icon `home`), and the month card has a "Pay" row above "Tips": "€412 of €980", or "Add hourly wage".
- No tax or deductions (developer decision). Tips have no forecast: "Expected" totals add the tips paid out so far.
- **Database schema version 3:** table `wage_rates`, with a migration test from v2.
- Developer decisions: rates with a valid-from day (not a single setting), set on the Pay tab (not in Settings), the tab renamed to "Home".
- Checked: 90 tests pass (15 for salary rules, 6 for the wage repository, 3 more for migrations to v3). The debug APK was installed on the emulator over 1.2.0 data; the app starts, the migration ran (old tips still shown), and the Home tab shows "Add hourly wage". Not checked yet: entering and changing rates in the app, a rate change within a month, dark mode, a phone.
- Docs: from this session on, docs, code comments and release notes are English only and say "the user" for the person using the app (`docs/CLAUDE.md`).

## Open points (in rough priority)

0. **In-app update on real phones:** 1.1.0 is the first version with the updater, so it is installed by hand; the first real in-app update is 1.2.0 (tips). Until then the path with the release key and GitHub is only checked with debug builds and the fake server on the emulator. On the Xiaomi: some MIUI versions had trouble with session installs from third-party apps; if it fails there, fall back to the system installer intent (FileProvider + ACTION_VIEW).

1. **Check on the Pixel 7 Pro:** Live Update promotion, launcher icon shape, release APK.
2. **Not tested yet:**
   - notification buttons "Start recording" and "End 23:00" with the app killed. "Stop" works with the app killed: checked on the emulator, where Android starts the process for the button, the shift is recorded and the event updated;
   - the "Still at work?" overrun question;
   - "Later" snooze;
   - Settings: event title change and language switch (both should update all events);
   - light mode with the new AKAI red, the System color;
   - reboot (rescheduling; the progress alarm is not restored after a reboot until the app re-posts the notification on start);
   - the progress tick firing with the app killed (it fired on its own while the app was in the background: progress 24 → 59, next alarm set).
3. **Before handover (M6):**
   - Done: release signing key created, final package name `de.gartenpa.timetrack`, app name "TimeTrack" kept (see `02-design.md` §12).
   - Still to do by the developer: back up `android/timetrack-release.jks` and its password, and set the three GitHub secrets (`03-dev-setup.md` section 9).
   - Pending: the first tagged release `v1.0.0`.
   - Open: test on the user's Xiaomi (checklist in `02-design.md` §11).
   - The package changed, so the old test install (`de.garten.akaitimetrack`) must be uninstalled; the new one starts with empty data.

## Code map

```
lib/
  main.dart                 start: services, notifications, ProviderScope
  app/  services.dart       AppServices (one per isolate), syncAll/syncNow, background notification entry point
        providers.dart      Riverpod providers (settings, shifts by day range, running shift, clock, sync status)
        app.dart, theme.dart (M3ETheme wrapper, seed colours)
  core/ time.dart, format.dart        dates, ISO weeks, minutes, HH:mm, decimal hours
  data/ database.dart (+ .g.dart, .steps.dart)  drift tables Shifts, Settings, TipDays, TipPayouts, WageRates; migrations
        database_connection.dart     opens the database file (kept out of database.dart for drift's schema export)
        shift_repository.dart, tip_repository.dart, wage_repository.dart,
        settings_repository.dart (also status keys: lastCalendarSync, tipPromptDismissedDay), app_settings.dart
  domain/ planning.dart, recording.dart, rounding.dart, month_summary.dart,
          export_text.dart, reminder_planner.dart, shift_info.dart,
          tips.dart (money parsing, tip weeks and months, Home prompt),
          salary.dart (rate of a day, month pay)   (pure logic, tested)
  platform/ notification_service.dart, calendar_sync.dart, device_setup.dart
  l10n/ app_de.arb (source), app_en.arb, labels.dart (+ generated app_localizations*.dart)
  ui/   material.dart (the one UI import), home_shell, common (header, Panel, Figure, WavyProgress, WeekSwitcher, pickers),
        today/ (Home tab), plan/, shift_sheet.dart, pay/ (Pay tab, money sheet, wage sheet), export/, settings/, onboarding/
packages/calendar_bridge/   Kotlin CalendarContract plugin (calendars incl. sync flag, event colours, events, enableSync, requestSync)
packages/running_progress/  Kotlin plugin: moves the running notification's progress bar (Live Update on Android 16)
test/                       unit tests (helpers.dart builds test shifts); test/drift/ generated migration tests
drift_schemas/              drift schema snapshots per version (build.yaml configures make-migrations)
.github/workflows/ci.yml       analyze + test on push to main and on pull requests
.github/workflows/release.yml  on tag v*: signed release APK + GitHub release (needs the three secrets)
scripts/release-notes.sh       release notes from the commit subjects' type prefixes
.githooks/commit-msg           rejects commit subjects without a type prefix
android/key.properties, android/timetrack-release.jks, android/timetrack-release.jks.base64
                            release signing key files; git-ignored, never commit or print them
```

Key ideas:
- The database is the source of truth. Every change marks the shift `dirty`.
- `AppServices.syncAll()` reconciles reminders and the calendar. It runs after each change, on app start and on resume, one sync at a time.
- Notification buttons run `AppServices.handleNotificationAction`, in the app or in a background isolate. drift's `shareAcrossIsolates` keeps the screens up to date.

## Working in this repo

- Build and test inside the dev container (see 03-dev-setup.md). From Windows, the running container is reached through WSL: `wsl.exe -e docker exec <container> bash -lc '…'` (`wsl.exe -e docker ps` shows the name).
- The repo lives in WSL (`/home/paga/Projects/akai-timetrack`) since 2026-11-05, with a link at `C:\Users\paga\Projects\akai-timetrack`. Open it in VS Code through WSL, then in the container. `flutter analyze` takes 20–30 s there (5–7 min on `C:`); see 03-dev-setup.md §8.
- The dev image installs Android platforms 35, 36 and 37.0 (`.devcontainer/Dockerfile`). A platform missing there makes the first build in a fresh container fail with "Failed to find target"; it worked before only because the old container had downloaded it.
- After changing ARB files run `flutter gen-l10n`; after changing tables run `dart run build_runner build -d`.
- **Emulator:** the task *Emulator: Start*. It has no Google account, so there are no calendars. `scripts/emulator-test-calendar.sh` creates a local test calendar with two event colours. The developer also tries the app in the emulator window, so don't drive the UI blindly.
- **Releases:** bump `version:` in `pubspec.yaml`, push, then tag `v<version>`; GitHub Actions builds the APK (`03-dev-setup.md` section 9). Release builds use `android/key.properties` if present, otherwise the debug key.
- **Commits:** use the repo-local GitHub noreply identity; never the global work address. Subjects start with a type prefix (`Feature:`, `Bugfix:`, `Improvement:`, `Docs:`, `Dev:`, `Release:`); the release notes are built from them (03-dev-setup.md section 9).
