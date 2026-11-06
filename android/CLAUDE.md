# Android project notes

Guidance for work in `android/`. The general workflow is in the root `CLAUDE.md`.

## Identity and SDK levels (`app/build.gradle.kts`)
- `applicationId` is `de.gartenpa.timetrack`. It is final since 1.0.0. Changing it makes a different app: no update path, empty data.
- Kotlin `namespace` stays `de.garten.akaitimetrack`. `MainActivity` lives in that package. The two names are independent.
- `compileSdk` 37 (needed by `permission_handler`). `gradle.properties` has `android.suppressUnsupportedCompileSdk=37` because the Android Gradle plugin predates it.
- `minSdk` 29 (Android 10). Adaptive icons therefore work everywhere.
- Core library desugaring is on (`desugar_jdk_libs`). `flutter_local_notifications` needs it for scheduled notifications.
- `versionCode` and `versionName` come from `version:` in the root `pubspec.yaml`. Do not set them here.

## Signing
- Release builds use `android/key.properties` and `android/timetrack-release.jks` if `key.properties` exists. Otherwise they use the debug key.
- Both files are git-ignored. Never commit, open or print them, or the passwords. Do not paste their content into docs or logs.
- A debug-signed APK cannot update a release-signed install (and the other way round). Uninstall first when testing.
- GitHub Actions (`.github/workflows/release.yml`, on tags `v*`) writes the key from three repository secrets. Setup is in `docs/03-dev-setup.md` section 9.
- If the key is lost, installed apps can never be updated. The developer must keep a backup of the `.jks` and its password.

## Launcher icons
- 12 adaptive icons in `res/mipmap-anydpi-v26/`: `ic_launcher_<design>_<shape>.xml`, designs `cloche`, `akai`, `penguin_black`, `penguin_navy`, shapes `round` (circle masks, Pixel), `squircle` (squircle masks, Xiaomi), `small` (the whole squircle icon scaled down on a transparent background).
- **Cloche and penguins are generated:** `node branding/icons/generate.js` writes their mipmaps and drawables (`ic_launcher_panel_*`, `ic_launcher_cloche_*`, `ic_launcher_penguin_*`) from the same geometry as the SVG masters. Never edit those files by hand; change `generate.js` and run it again.
  - Vector drawables have no masks, so the cloche's cut-out spoon and fork are painted with the panel gradient.
  - Holes in the monochrome layers are group clip-paths drawn the other way round.
- **AKAI sign** (`ic_launcher_akai_*`): made by hand earlier. `akai_squircle` is exactly `branding/app-icon.svg`, its 100-unit box mapped onto the 72 dp visible area (scale 0.72, offset 18); `akai_round` has a dark-red disc on the red background colour.
- The application icon (`android:icon` on `<application>`) is the round cloche.
- Each mipmap is the icon of an `activity-alias` in `AndroidManifest.xml`. Exactly one is enabled. `.IconRound` (the round cloche) is enabled in the manifest.
  - The cloche uses `.IconRound`, `.IconSquircle` and `.IconSmall`, the names the AKAI sign had until 1.4.0, so existing installs moved to the cloche in their shape. The sign now has `.IconAkai*`, the penguins `.IconPenguinBlack*` and `.IconPenguinNavy*`.
  - Never rename an alias: an installed app's enabled alias is stored by name, and a missing one falls back to the manifest default.
- `MainActivity.kt` switches them through the channel `de.garten.akaitimetrack/app_icon` (`current`, `set`). Icons are keyed `design.shape` (e.g. `penguinNavy.small`) in `ICONS`. `set` enables the new alias before it disables the others. Dart side: `lib/platform/app_icon.dart` and `lib/domain/app_icons.dart`.
- Component names are built from `MainActivity`'s Java package, not from the `applicationId`. Keep that when editing.
- Switching makes Android close the app (the task's launcher alias is disabled). The Dart UI asks first.
- On the first start on Xiaomi/Redmi/POCO the app switches to the squircle cloche.
- `MainActivity` keeps a MAIN/LAUNCHER intent filter marked `tools:node="remove"`. It exists only so `flutter run` finds a launch activity (the Flutter tool ignores aliases). The built app has only the aliases. Do not delete it, do not drop the `remove`.
- Check the launcher entries (the manifest only; alias names must match):
  `adb shell cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER de.gartenpa.timetrack`
- Start the app by hand: `adb shell am start -n de.gartenpa.timetrack/de.garten.akaitimetrack.MainActivity`
- The launcher decides the mask. Apps cannot find out which. On Pixel, transparent icon backgrounds are filled black and non-adaptive icons get a white circle. Both were tried.
- The AKAI squircle vector paths come from `branding/app-icon.svg` (superellipse n=4; half-size 29.5 fits a circle mask). Regenerate them with a script; do not edit the path data by hand.
- Shell heredocs mangle backslashes in regexes. Put such scripts in files.
- A new design needs: its mipmaps (one per shape), three manifest aliases, three entries in `ICONS` in `MainActivity.kt`, and the Dart enum value and label.

## `res/raw/keep.xml`
- Resources used only by name are removed by the release resource shrinker. `keep.xml` lists them with `tools:keep`.
- Today: `@drawable/ic_notification` (`AndroidInitializationSettings('ic_notification')` in `lib/platform/notification_service.dart`).
- Without it the release app hung on the splash screen (`main()` threw before `runApp`).
- Add every new by-name resource here. Always test a release build, not only debug.

## Manifest
- Permissions:
  - `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `VIBRATE`: reminders, running timer, "still working?".
  - `RECEIVE_BOOT_COMPLETED`: reschedule reminders after a reboot.
  - `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`: the user may exempt the app (reliable reminders).
  - `READ_CALENDAR`, `WRITE_CALENDAR`: mirror shifts into a calendar (`packages/calendar_bridge`).
  - `INTERNET`: the in-app update (GitHub releases). Flutter adds it only to debug/profile builds, so it must stay in the main manifest or release builds can't check.
  - `REQUEST_INSTALL_PACKAGES`: install the downloaded update.
- **In-app update installer** (`MainActivity.kt`, channel `de.garten.akaitimetrack/updater`): `installedVersion`, `canInstall`, `openInstallPermission`, `install(path)` (PackageInstaller session; abandons the app's old sessions first). A dynamically registered, not exported receiver gets the session status: it starts the confirmation dialog, every other status goes to Dart as `installResult {status, message}`.
- The plugins add their own entries (`POST_PROMOTED_NOTIFICATIONS`, `ProgressTickReceiver`). See `packages/CLAUDE.md`.
- Three receivers belong to `flutter_local_notifications`: `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver` (boot, package replaced, quickboot), `ActionBroadcastReceiver` (notification buttons). Keep all three or reminders and buttons stop working.
- `android:label` is "TimeTrack".
