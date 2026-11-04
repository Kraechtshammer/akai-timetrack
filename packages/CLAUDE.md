# Local plugin packages

Two Android-only Flutter plugins, referenced by path from the root `pubspec.yaml`. Both are `publish_to: 'none'`.

## Why plugins and not `MainActivity` code
- Plugins are registered in every Flutter engine, including the background isolate that handles notification buttons.
- Channels set up in `MainActivity` exist only in the UI engine and fail in the background isolate.
- Use a plugin for anything the background code may call. `MainActivity` is only for UI-only things (the app icon switch).

## `calendar_bridge`
- Files: `android/src/main/kotlin/de/garten/calendar_bridge/CalendarBridgePlugin.kt`, `lib/calendar_bridge.dart`.
- Why it exists: no Flutter calendar plugin supports `EVENT_COLOR_KEY`, which sets the colour per event.
- `MethodChannel` `de.garten.calendar_bridge`. Every call runs on one worker thread; results are posted back to the main thread.
- A `SecurityException` becomes the error code `NO_PERMISSION`. Dart turns it into `CalendarPermissionException`. Other failures: `CALENDAR_ERROR`. The permission itself is requested on the Dart side.
- Methods:
  - `writableCalendars`: calendars with access level >= contributor. Includes `synced` (from `SYNC_EVENTS`); Google adds new calendars switched off.
  - `eventColors(calendarId)`: the account's `TYPE_EVENT` colours (Google: the 11 colours; keys are strings).
  - `insertEvent`, `updateEvent`, `deleteEvent`, `eventExists` (false if gone or `DELETED` is set, e.g. removed in Google Calendar).
  - `enableSync`: sets `SYNC_EVENTS=1` and `VISIBLE=1`.
  - `requestSync(calendarId?)`: `ContentResolver.requestSync`, manual and expedited. Without an id: all accounts with calendars. Skips `ACCOUNT_TYPE_LOCAL` accounts.
- Event values: `HAS_ALARM` 0 (the app does its own reminders), busy, `EVENT_COLOR_KEY` or null. Null also clears `EVENT_COLOR`, so the calendar colour shows.
- The app only touches events whose ids it stored. Never query or change other events.
- iOS would need EventKit and has no per-event colours.
- `compileSdk` 36 here, `minSdk` 29.

## `running_progress`
- Files: `android/src/main/kotlin/de/garten/running_progress/RunningProgressPlugin.kt`, `lib/running_progress.dart`, `android/src/main/AndroidManifest.xml`.
- Purpose: move the progress bar of the "running shift" notification. `flutter_local_notifications` posts it (with its buttons); this plugin re-posts it.
- `MethodChannel` `de.garten.running_progress`: `start(notificationId, startMs, endMs, color)` and `stop`.
- `start` stores id, start, end and colour in `SharedPreferences` (`running_progress`), updates now, and sets an exact alarm 5 minutes ahead (never past the end).
- `ProgressTickReceiver` (needs no Flutter) rebuilds the shown notification with `Notification.Builder.recoverBuilder`. That keeps the buttons.
  - SDK >= 36: `ProgressStyle` plus the extra `android.requestPromotedOngoing` (Live Update).
  - Older: `setProgress`.
- `setRequestPromotedOngoing` is not in the API 36 SDK, so the extra is set directly. Hence `compileSdk` 36 here. Do not "fix" it to the method call without checking the SDK.
- It stops itself when the notification is gone or the end is reached.
- Each re-post by the app calls `start` again and restarts the alarm.
- After a reboot the alarm is not restored until the app posts the notification again.
- Without the exact-alarm permission it falls back to an inexact alarm.
- The manifest adds `POST_PROMOTED_NOTIFICATIONS` and the receiver.
- Live Update promotion is confirmed on the Pixel (Android 16 QPR). The emulator (Android 16.0) does not promote it. Do not treat that as a bug.
- Why not pre-schedule notifications: `flutter_local_notifications` keys scheduled ones by id, so they cannot all replace notification 1.

## Adding a method
- Kotlin: add a `when` branch in `onMethodCall`.
- Dart: add a wrapper that calls the same method name and argument keys.
- Return `null` for methods without a result. Flutter cannot send Kotlin's `Unit`.
- Keep Kotlin and Dart in sync (names, keys, types). Numbers arrive as `Number`; convert with `toLong()` or `toInt()`.
- Unit-test the Dart side with a fake where possible (calendar sync uses a fake bridge in `test/`).
- After changing plugin Kotlin, rebuild the app; hot reload does not pick it up.
