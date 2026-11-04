# Handoff: TimeTrack v1 implementation

State as of 2026-11-04. Read this together with [01-research.md](01-research.md), [02-design.md](02-design.md) and [03-dev-setup.md](03-dev-setup.md).

## Where things stand

The v1 app is implemented and runs on the emulator. Checked by hand on the emulator (Android 16, virtual Pixel 7 Pro):

- **Onboarding:** language, notification and exact-alarm permissions, calendar choice, event colour, default times.
- **Heute:** next-shift card, start button, running card with live timer and rounded preview, month card, week strip.
- **Plan:** Mittag/Abend toggles, lunch automatically 12:00–15:30 when there is an evening shift, shift sheet.
- **Export:** defaults to last week on Mon–Wed, month-total switch.
- **Calendar sync** into a local test calendar:
  - events titled "Kellnern" in the chosen colour (Tomate = key 11), without a calendar reminder;
  - events are updated when a shift changes and deleted when it's removed.
- **Reminders:** scheduled as exact alarms (checked with `dumpsys alarm`).

Automated checks:
- `flutter analyze`: no issues.
- `flutter test`: 21 tests pass (rounding, ISO weeks, export text DE/EN, month summary, reminder planning, planning rules against an in-memory database).
- Debug and release APK builds succeed. The release build uses R8 and is 64.5 MB.

## Open points (in rough priority)

1. **Progress bar in the running notification** (user request). It currently only shows Android's built-in chronometer. Two ways to add it:
   - re-post the notification periodically with `showProgress`/`progress` (would need a recurring alarm or WorkManager);
   - Android 16 "Live Updates" (promoted ongoing notification with a progress style).
   Decide with the user.
2. **Wavy progress bar on Heute.** It's drawn by hand (`WavyProgress` in `lib/ui/common.dart`). An alternative is the pub package `material_3_expressive` ^1.2.0:
   - `M3EProgressIndicator.linearWavy(value:)`; also offers Expressive buttons and shapes;
   - MIT licence, built on `material_ui`, one maintainer;
   - in files importing both packages: `import 'package:material_ui/material_ui.dart' hide CornerRounding, RoundedPolygon;`.
   Ask the user before adding it.
3. **Not tested yet:**
   - notification buttons (Start/Stop/"Ende 23:00") with the app killed (background isolate);
   - the "Noch bei der Arbeit?" overrun question;
   - "Später" snooze;
   - the Settings screen (calendar switch, colour/title change → events updated, language switch);
   - dark mode and system colour;
   - reboot (rescheduling);
   - the release APK on a device.
4. **Docs:** update `02-design.md` with what changed during implementation (next section) and the README status line.
5. **Before handover (M6):** release signing key, final app name and package name, test on her Xiaomi (checklist in `02-design.md` §11).

## Changes from the design (to record in 02-design.md)

- **UI library:** `package:material_ui` (Flutter's Material library, now a separate package) instead of `package:flutter/material.dart`. `dynamic_color` already requires it. Never import both in the same file. Material 3 Expressive is enabled for icon buttons (`IconButtonThemeData(variant: StyleVariant.material3Expressive)`).
- **Navigation:** no go_router. Three tabs in an `IndexedStack` (`lib/ui/home_shell.dart`), Settings pushed with `Navigator`. A tap on a notification just opens the app.
- **Calendar bridge:** a plain `MethodChannel` local plugin (`packages/calendar_bridge`) instead of Pigeon. It has to be a plugin package (not code in MainActivity) so it's also available in the notification background isolate.
- **compileSdk 37:** required by `permission_handler`. Set in `android/app/build.gradle.kts`, with the warning suppressed in `gradle.properties`. minSdk stays 29. The dev container image only has platform 36; Gradle downloads 37 on the first build.
- **"Kein Kalender":** choosing it deletes the app's events from the old calendar. Switching calendars moves all events.
- **Systemfarbe:** not hidden on Android < 12; it falls back to AKAI-Rot.
- **Fonts and icons:** Roboto and Material Icons ship with Flutter, so nothing extra is bundled.
- **Export texts:** neutral, with no mention of the boss (user request).
- **Database:** no drift schema snapshots yet (`drift_schemas/`). Create one before the first schema change: `dart run drift_dev make-migrations`.

## Code map

```
lib/
  main.dart                 start: services, notifications, ProviderScope
  app/  services.dart       AppServices (one per isolate) + background notification entry point
        providers.dart      Riverpod providers (settings, shifts by day range, running shift, clock)
        app.dart, theme.dart
  core/ time.dart, format.dart        dates, ISO weeks, minutes, HH:mm, decimal hours
  data/ database.dart (+ .g.dart)     drift tables Shifts, Settings
        shift_repository.dart, settings_repository.dart, app_settings.dart
  domain/ planning.dart, recording.dart, rounding.dart, month_summary.dart,
          export_text.dart, reminder_planner.dart, shift_info.dart   (pure logic, tested)
  platform/ notification_service.dart, calendar_sync.dart, device_setup.dart
  l10n/ app_de.arb (source), app_en.arb, labels.dart (+ generated app_localizations*.dart)
  ui/   home_shell, common (header, Panel, WavyProgress, WeekSwitcher, pickers),
        today/, plan/, shift_sheet.dart, export/, settings/, onboarding/
packages/calendar_bridge/   Kotlin CalendarContract plugin (calendars, event colours, events)
test/                       unit tests (helpers.dart builds test shifts)
```

Key ideas:
- The database is the source of truth. Every change marks the shift `dirty`.
- `AppServices.syncAll()` reconciles reminders and the calendar. It runs after each change, on app start and on resume, one sync at a time.
- Notification buttons run `AppServices.handleNotificationAction`, in the app or in a background isolate. drift's `shareAcrossIsolates` keeps the screens up to date.

## Working in this repo

- Build and test inside the dev container (see 03-dev-setup.md). From outside, the running container can be driven with `docker exec`.
- After changing ARB files run `flutter gen-l10n`; after changing tables run `dart run build_runner build -d`.
- **Emulator:** the task *Emulator: Start*. It has no Google account, so there are no calendars. `scripts/emulator-test-calendar.sh` creates a local test calendar with two event colours. The user also tries the app in the emulator window, so don't drive the UI blindly.
- **Commits:** use the repo-local GitHub noreply identity; never the global work address.
