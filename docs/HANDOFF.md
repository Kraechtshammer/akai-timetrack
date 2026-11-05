# Handoff: TimeTrack v1 implementation

State as of 2026-11-04 (evening); the version is now 1.0.1 (`1.0.1+2`). Read this together with [01-research.md](01-research.md), [02-design.md](02-design.md) (its §16 lists what changed during implementation) and [03-dev-setup.md](03-dev-setup.md).

## Where things stand

The v1 app is implemented and runs on the emulator (Android 16.0 / SDK 36.0, virtual Pixel 7 Pro, dark mode). Checked by hand there:

- **Onboarding:** language, notification and exact-alarm permissions, calendar choice, event colour, default times.
- **Heute:**
  - next-shift card, start button, running card with live timer and rounded preview;
  - month card with the Expressive wavy progress bar;
  - week strip with sun/moon icons (or bars, see Settings).
- **Plan:** Mittag/Abend toggles, lunch automatically 12:00–15:30 when there is an evening shift, shift sheet.
- **Export:** a monthly text grouped by week (weeks cut at the month's edges), always opens on the current month (also when switching back to the tab).
- **"Schicht gelöscht" snack bar** closes on its own again. Snack bars with an action (here "Rückgängig") default to `persist: true` in the current `material_ui`, so they stayed until tapped. `persist: false` is now set there and in `context.showSnack`. Keep it on any new snack bar with an action.
- **Calendar sync** into a local test calendar:
  - events titled "Kellnern" in the chosen colour (Tomate = key 11), without a calendar reminder;
  - events are updated when a shift changes and deleted when it's removed;
  - picker: "Aktualisieren" finds a newly added calendar; choosing a not-yet-synced calendar turns its sync on and moves all events there;
  - Settings › Kalender › "Jetzt synchronisieren" shows "Alles aktuell · zuletzt 20:41" or the number of pending changes.
- **Reminders:** scheduled as exact alarms (checked with `dumpsys alarm`).
- **Running notification:** chronometer, "Beenden" button, progress bar. On the Android 16 emulator it uses `ProgressStyle` with the red bar. The 5-minute progress alarm is scheduled (`dumpsys alarm`).

Automated checks:
- `flutter analyze`: no issues.
- `flutter test`: 40 tests pass (rounding, ISO weeks, export text DE/EN, month summary, reminder planning, planning rules against an in-memory database, new settings keys, notification progress maths, calendar sync with a fake bridge).
- Debug and release APKs build. The first release APK of this round hung on the splash screen: the resource shrinker had removed `ic_notification`, which flutter_local_notifications looks up by name, so `main()` threw before `runApp`. Fixed with `android/app/src/main/res/raw/keep.xml`; `main()` now also starts the app if notification setup fails. Any other resource looked up by name must be added to `keep.xml`.

## Done in the second session (2026-11-04, from the user's feedback)

1. **Calendar list:** lists not-yet-synced calendars (with a hint; choosing one turns sync on), plus "Aktualisieren" (asks Android to sync all accounts, then reads the list again now and after 6 s) and a hint about Google needing a few minutes.
2. **Sync status:** "Jetzt synchronisieren" tile in Settings › Kalender with the status as subtitle. The button runs the sync and asks Android for an expedited upload to Google. Not added on Plan (the user's "maybe"); easy to add there with the same providers if wanted.
3. **Event text language:** changing the language marks all events for an update.
4. **Week strip:** the user saw three prototypes (icons, two bars, dots). Kept icons (default) and bars, selectable in Settings › Darstellung › Wochenübersicht; the dots were dropped. The user noted bars scale better to a possible third shift, and icons could get a "rising sun" for a morning shift.
5. **App icon:** three variants, because the launcher decides the mask shape and apps can't find out which. They are switched in Settings › Darstellung › App-Symbol.
   - **Rund:** a red ring around a dark-red disc with centred letters, made for circular masks (Pixel). This is the default.
   - **Squircle:** exactly `branding/app-icon.svg` (n=4 panel, letters as in the SVG), mapped onto the 72 dp visible area, for squircle masks. It's the default on Xiaomi/Redmi/POCO, set once on the first start. Until 2026-11-05 its panel was a rounder compromise shape (exponent 2.5) with smaller letters; the user wanted the SVG as is.
   - **Squircle klein:** the whole squircle scaled down on a transparent background. The Pixel launcher fills the rest of its circle with black; the user likes this one too.
   - How it works: one `activity-alias` per variant in `AndroidManifest.xml`, of which exactly one is enabled (`MainActivity.kt`, channel `de.garten.akaitimetrack/app_icon`; Dart: `lib/platform/app_icon.dart`).
   - MainActivity's own MAIN/LAUNCHER filter stays in the source manifest, because the Flutter tool only looks for `<activity>`. It's marked `tools:node="remove"`, so the built app has only the aliases. Check: `adb shell cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER de.gartenpa.timetrack`.
   - Switching closes the app (Android finishes a task whose launcher alias is disabled), so the app asks first. The home-screen shortcut may have to be added again.
   - Checked on the emulator: Rund and Squircle klein in the app drawer, and switching from Settings.
   - A non-adaptive squircle icon was tried; Pixel wraps it in a white circle.
6. **Colours:** new AKAI-Rot `#C62828` (default, `DynamicSchemeVariant.vibrant`), the old brown-red is now "Terrakotta". The `fidelity` variant was tried first, but in dark mode it made glaring red containers and a blue tertiary.
7. **Material 3 Expressive:** the `material_3_expressive` ^1.2.0 package is added (user decision).
   - All buttons are `M3EButton` / `M3EIconButton`.
   - The wavy bar is `M3EProgressIndicator.linearWavy`.
   - The app is wrapped in `M3ETheme(data: M3EThemeData.fromMaterial(Theme.of(context)))`.
   - UI files import `lib/ui/material.dart`, which exports both `material_ui` and the package (with the name clash handled). Never import `package:material_ui` directly in UI code.
   - Segmented buttons, chips, sheets and dialogs are still the Material ones.
8. **Notification progress** (user decision: Live Update on Android 16, pre-scheduled updates elsewhere). It is a new local plugin, `packages/running_progress`:
   - Flutter posts the notification (with the button and the current progress).
   - The plugin re-posts it every 5 min from an exact alarm, rebuilt with `recoverBuilder`, until the planned end.
   - On SDK ≥ 36 it uses `ProgressStyle` and the `android.requestPromotedOngoing` extra (`setRequestPromotedOngoing` isn't in the API 36 SDK, so the extra is set directly), plus the `POST_PROMOTED_NOTIFICATIONS` permission.
   - **On the emulator (SDK 36.0) the notification is not promoted** (no `PROMOTED_ONGOING` flag), although the extra and permission are present. Live Updates were rolled out with Android 16 QPR1 (36.1), so this needs checking on the Pixel. If it isn't promoted there either, look at the promotion requirements (channel importance, `hasPromotableCharacteristics()`, the per-app "Live notifications" switch).
   - Pre-scheduling separate notifications (the other option discussed) doesn't work with flutter_local_notifications: scheduled notifications are keyed by id, so they can't all replace notification 1. That's why the native plugin approach is used for every Android version.

## Open points (in rough priority)

1. **Check on the Pixel 7 Pro:** Live Update promotion, launcher icon shape, release APK.
2. **Not tested yet:**
   - notification buttons "Erfassung starten" and "Ende 23:00" with the app killed. "Beenden" works with the app killed: checked on the emulator, where Android starts the process for the button, the shift is recorded and the event updated;
   - the "Noch bei der Arbeit?" overrun question;
   - "Später" snooze;
   - Settings: event title change and language switch (both should update all events);
   - light mode with the new AKAI-Rot, the Systemfarbe;
   - reboot (rescheduling; the progress alarm is not restored after a reboot until the app re-posts the notification on start);
   - the progress tick firing with the app killed (it fired on its own while the app was in the background: progress 24 → 59, next alarm set).
3. **Before handover (M6):**
   - Done: release signing key created, final package name `de.gartenpa.timetrack`, app name "TimeTrack" kept (see `02-design.md` §12).
   - Still to do by the user: back up `android/timetrack-release.jks` and its password, and set the three GitHub secrets (`03-dev-setup.md` section 9).
   - Pending: the first tagged release `v1.0.0`.
   - Open: test on her Xiaomi (checklist in `02-design.md` §11).
   - The package changed, so the old test install (`de.garten.akaitimetrack`) must be uninstalled; the new one starts with empty data.

## Code map

```
lib/
  main.dart                 start: services, notifications, ProviderScope
  app/  services.dart       AppServices (one per isolate), syncAll/syncNow, background notification entry point
        providers.dart      Riverpod providers (settings, shifts by day range, running shift, clock, sync status)
        app.dart, theme.dart (M3ETheme wrapper, seed colours)
  core/ time.dart, format.dart        dates, ISO weeks, minutes, HH:mm, decimal hours
  data/ database.dart (+ .g.dart)     drift tables Shifts, Settings
        shift_repository.dart, settings_repository.dart (also lastCalendarSync), app_settings.dart
  domain/ planning.dart, recording.dart, rounding.dart, month_summary.dart,
          export_text.dart, reminder_planner.dart, shift_info.dart   (pure logic, tested)
  platform/ notification_service.dart, calendar_sync.dart, device_setup.dart
  l10n/ app_de.arb (source), app_en.arb, labels.dart (+ generated app_localizations*.dart)
  ui/   material.dart (the one UI import), home_shell, common (header, Panel, WavyProgress, WeekSwitcher, pickers),
        today/, plan/, shift_sheet.dart, export/, settings/, onboarding/
packages/calendar_bridge/   Kotlin CalendarContract plugin (calendars incl. sync flag, event colours, events, enableSync, requestSync)
packages/running_progress/  Kotlin plugin: moves the running notification's progress bar (Live Update on Android 16)
test/                       unit tests (helpers.dart builds test shifts)
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
- **Emulator:** the task *Emulator: Start*. It has no Google account, so there are no calendars. `scripts/emulator-test-calendar.sh` creates a local test calendar with two event colours. The user also tries the app in the emulator window, so don't drive the UI blindly.
- **Releases:** bump `version:` in `pubspec.yaml`, push, then tag `v<version>`; GitHub Actions builds the APK (`03-dev-setup.md` section 9). Release builds use `android/key.properties` if present, otherwise the debug key.
- **Commits:** use the repo-local GitHub noreply identity; never the global work address. Subjects start with a type prefix (`Feature:`, `Bugfix:`, `Improvement:`, `Docs:`, `Dev:`, `Release:`); the release notes are built from them (03-dev-setup.md section 9).
