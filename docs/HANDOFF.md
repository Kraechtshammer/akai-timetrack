# Handoff: TimeTrack v1 implementation

State as of 2026-11-12; the version is now 1.8.2. Read this together with [01-research.md](01-research.md), [02-design.md](02-design.md) (its §16 lists what changed during implementation) and [03-dev-setup.md](03-dev-setup.md).

## Where things stand

The app was handed over (milestone M6) and has been in daily use on the user's Xiaomi since 2026-11-04; the developer checks new features on the Pixel 7 Pro. The v1 app was first checked on the emulator (Android 16.0 / SDK 36.0, virtual Pixel 7 Pro, dark mode). Checked by hand there:

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
4. **Week strip:** the developer saw three prototypes (icons, two bars, dots). Kept icons (default) and bars, selectable in Settings › Appearance › Week overview; the dots were dropped. The developer noted bars scale better to a possible third shift, and icons could get a "rising sun" for a morning shift.
5. **App icon:** three variants, because the launcher decides the mask shape and apps can't find out which. They are switched in Settings › Appearance › App icon.
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

- The app looks for a newer GitHub release on start and on resume (at most every 30 minutes; 6 hours until 1.8.0), shows a popup once per version with the "New / Fixed / Improved" notes, downloads the APK and starts Android's installer (PackageInstaller session). Settings › App update: check now, the found update, "Restart update", "Delete update file". The APK is deleted on the first start of the new version. Design: `02-design.md` §12.
- Code: `domain/app_update.dart` (versions, release JSON, notes, clean-up rules; tested), `platform/app_update.dart` (HTTP, files, channel), `app/update_controller.dart` (Riverpod state), `ui/settings/update_tiles.dart` (tiles and popup), `MainActivity.kt` (channel `de.garten.akaitimetrack/updater`). The manifest now has `INTERNET` and `REQUEST_INSTALL_PACKAGES`.
- Testing on the emulator with a fake release: `scripts/update_test_server.dart`, see `03-dev-setup.md` §9.
- Checked by the developer on the emulator (debug builds 1.0.0 → 1.0.1 from the fake server): popup with notes, "install unknown apps" switch and automatic continue, download progress, cancelling Android's prompt ("Update cancelled.") and retrying without a second download, the update itself, the APK deleted on the next start, deleting the file by hand.
- Developer decisions: session installer (not the system installer intent), popup once per version, check on start/resume every 6 h (no background job; 30 minutes since 1.8.1, see below), only the sections of the notes that matter to the user.

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
- **Pay tab month card:** the expected pay for the calendar month as the big number, with the amount earned so far (recorded shifts) and a wavy bar; "Expected" adds planned, running and missed shifts. Then "Tips", then "Total · with tips" as "Earned" and "Expected". Past months show what was earned, future months what is expected. The hourly wage is a chip in the header. The developer picked this layout from three prototypes.
- **Home tab:** the "Today" tab is now "Home" (icon `home`), and the month card has a "Pay" row above "Tips": "€412 of €980", or "Add hourly wage".
- No tax or deductions (developer decision). Tips have no forecast: "Expected" totals add the tips paid out so far.
- **Database schema version 3:** table `wage_rates`, with a migration test from v2.
- Developer decisions: rates with a valid-from day (not a single setting), set on the Pay tab (not in Settings), the tab renamed to "Home".
- Checked: 90 tests pass (15 for salary rules, 6 for the wage repository, 3 more for migrations to v3). The debug APK was installed on the emulator over 1.2.0 data; the app starts, the migration ran (old tips still shown), and the Home tab shows "Add hourly wage". Not checked yet: entering and changing rates in the app, a rate change within a month, dark mode, a phone.
- Docs: from this session on, docs, code comments and release notes are English only and say "the user" for the person using the app (`docs/CLAUDE.md`).

## Done in the sixth session (2026-11-05): team planner (F11), first version

- Research in `01-research.md` §10 (feasibility, in-app vs. separate app, decisions 1–12), design in `02-design.md` §3 (tables), §4.9 (rules), §7 (screens).
- **Why:** while the boss is away in November 2026, the user plans the weekly shifts of the service staff. The planner collects who can work, helps fill the shifts and shares the plan as a picture in the team chat.
- **Off by default:** Settings › Team planner turns on a fifth tab, "Team" (German "Dienstplan"), last in the bar. The same section has "Staff needed" (per weekday and shift, 0 = closed; default 2 at lunch, 3 in the evening, Sunday closed), "Start times" (12:00, 17:30) and "People". The real staff counts are still to be set by the user.
- **Flow:** People (name, "Core worker", "This is me") → "Enter answers" walks through everyone ("Can work" / "Can't work", whole days or single shifts, "At most N shifts", "Away this week") → the board (one card per open day, "2/3" counts, "No core worker" warning) → tap a shift for the sheet (staff needed, people with check boxes, special start times) → "Fill" / "Clear" with "Undo" → "Share" (preview, 1920 × 1080 PNG, always light) → ⋮ "Add my shifts to Plan".
- **Fill:** hardest shift first (fewest possible people); one core worker per shift first; then people who aren't core workers, fewest shifts first. People without an answer are never used.
- Developer decisions while testing: core workers cost more, so after a shift has one the others come first; vacation is the "Away this week" answer; no "inactive" state (people who leave are deleted with their answers and shifts and added again later; the `team_members.active` column stays unused).
- **Database schema version 4:** tables `team_members`, `team_answers`, `team_assignments`, `team_needs`, with a migration test from v3. Settings keys `teamPlanner`, `teamStaffNeeded`, `teamStarts`.
- Built with four Sonnet subagents in parallel (settings and people, answer page, board and shift sheet, image and share), on top of the data, rules and strings written first; reviewed afterwards. Fixes in review: the shift sheet keeps its order while open (rows jumped when the first core worker was ticked), the image ignores the phone's font size.
- **Checked:** 121 tests pass (23 for the planner rules and repository, 3 for the image layout, 1 more migration test); `flutter analyze` clean. The developer went through the test steps on the emulator (settings, people, answers, Fill, shift sheet, Share, "Add my shifts to Plan", "Away this week", deleting) and found it working. Installed over 1.3.1 data, so the migration ran on a real database.
- **Not checked:** the shared PNG at full size and in a real chat; light mode for the new screens; a phone.

## Done in the seventh session (2026-11-05): README

- The README is now the repo's landing page: icon, badges, four screenshots, the features per tab, install, build and the stack.
- Screenshots are in `docs/screenshots/`: English UI, dark mode, demo data with made-up names, taken on the emulator.
- How they were made: the emulator's database (`app_flutter/timetrack.sqlite`, read with `adb exec-out run-as de.gartenpa.timetrack cat …`) was backed up, replaced with a demo database built with `sqlite3`, and restored afterwards. The full screenshots were cropped to 1440 × 2920 from y = 120 (no status bar or gesture handle), scaled to 540 px wide, with rounded corners. The seed and crop scripts were not kept in the repo.
- Found while doing it: on the Pay tab in English, the weekday in the "Daily pool" list wraps ("Mo" / "n"), because the cell is 28 px wide (`ui/pay/pay_screen.dart`). German "Mo" fits. Not fixed yet. The Pay screenshot is cropped above that list.

## Done in the eighth session (2026-11-06): new app icons

The developer designed new app icons, to move away from the restaurant's sign over time. They are built into the app.

**In the app:**
- **Two settings** in Settings › Appearance:
  - "App icon" picks the design: "Cloche" (the default), "AKAI sign", "Penguin, black", "Penguin, dark blue".
  - "Icon shape" keeps the earlier choice: "Round", "Squircle", "Small squircle".
  - Every design comes in every shape (developer decision), so there are 12 `activity-alias`es. Both settings ask first, because switching closes the app.
- **Secret penguin icons:**
  - The two penguin designs are offered only when the person marked "This is me" in the team planner's "People" has a certain name. The check is trimmed and ignores case (`secretIconsUnlocked` in `lib/domain/app_icons.dart`).
  - The people list is read from the database, so it works with the team planner switched off.
  - A penguin that is already the current icon stays in the list, even if the name changes later.
  - The release notes only say "secret icons" (developer decision). Keep the unlock rule out of commit subjects and the README.
- **Cloche is the default without switching:** the cloche took over the alias names the sign had until 1.4.0 (`.IconRound`, `.IconSquircle`, `.IconSmall`). An install updated from 1.4.0 shows the cloche in the shape it had, and the app doesn't close for it. The sign moved to `.IconAkai*`. Never rename aliases; Android stores the enabled one by name.
- **Code:** `lib/domain/app_icons.dart` (`IconDesign`, `IconShape`, `AppIcon` with the channel key `design.shape`, the unlock rule; tested in `test/app_icons_test.dart`), `lib/platform/app_icon.dart` (channel), two tiles in `ui/settings/settings_screen.dart`, the `ICONS` map in `MainActivity.kt`. `set` now enables the new alias before it disables the old ones.
- Built with one Sonnet subagent for the Dart side while the drawables were made. Fixed in review: the design list read the people with `ref.read(...).value`, which is empty while nothing watches that provider, so the penguins could be missing; it now awaits `teamMembersProvider.future`.

**Files** in `branding/icons/`. Each is a 108 × 108 adaptive-icon canvas; launchers show the central 72 × 72.
- `node branding/icons/generate.js` writes all the SVGs **and** the app's vector drawables for the cloche and the penguins (`android/app/src/main/res`, see `android/CLAUDE.md`). It has no dependencies. Change shapes, colours or positions there and run it again; never edit the generated XML.
- `preview.png` shows the SVGs under their masks.

| File | What |
|---|---|
| `cloche.svg`, `cloche-round.svg` | **Default icon.** A cream serving dome on the sign's dark-red panel inside the red frame. The clock hands are a spoon (long) and a fork (short), cut out of the dome. `cloche` is for squircle masks (Xiaomi), `cloche-round` for round masks (Pixel). |
| `cloche-icon.svg` | The default icon as a squircle launcher shows it: the visible 72 × 72 clipped to the mask. For the README; the canvases above would show the red frame as a full square. |
| `cloche-mono.svg` | Monochrome layer of the cloche for themed icons. |
| `penguin-navy.svg`, `penguin-navy-round.svg` | **Secret icon "Penguin, dark blue".** A baby penguin with a round belly lifts the dome with one flipper. Navy body with a dark outline. Was "option 1" in the design round. |
| `penguin-black.svg`, `penguin-black-round.svg` | **Secret icon "Penguin, black".** The same penguin, the whole body in the dark colour without the extra edge, so slightly slimmer. Was "option 2". |

**Design notes:**
- **The frame is the same width all round.** The squircle panel is the n = 4 launcher squircle moved 4 units inwards along its normals, not scaled down. A scaled panel, as in the AKAI sign's Squircle variant, gives a frame that is thinner on the sides than in the corners. The round versions use a disc of r = 32.
- **Depth:** in the penguin icons, the plate's ends and the free flipper reach about 1–1.5 units past the panel onto the red ring. The developer likes that sense of depth; keep it, and keep it slight. A faint shadow sits under the plate where it overhangs.
- **Per-mask layout:** the plate width, the penguin's position and the dome's tilt differ between the squircle and round files, because the panel shapes differ. The values are in `generate.js`.
- **Small squircle** versions are the squircle icon cut to the launcher squircle and scaled to a half-size of 29.5, like the sign's.
- **Earlier concepts:** all drafts are on the developer's private design canvas (claude.ai artifact "TimeTrack logo concepts"). The drafts include TT, Clock, Lunch & evening, Day & night, Wavy T, a knife-and-fork cloche and plush penguins. Only the files above went into the repo.

**How the SVGs became vector drawables** (all in `generate.js`):
- Every shape (rects, circles, ellipses, arcs, quadratic curves) becomes one absolute path of lines and cubics, with the SVG transforms applied to its points. No group transforms, so the gradient coordinates stay absolute.
- **Layers:** the background is the red frame plus the panel (`ic_launcher_panel_round`, `ic_launcher_panel_squircle`, shared by cloche and penguins); the foreground holds the dome, plate and penguin.
- **Hands:** vector drawables have no masks, so the spoon and fork are painted with the panel's gradient.
- **Penguin clip:** the clip above the plate is a group `clip-path`. The shadow's opacity is `fillAlpha`; the navy outline is a stroke under the fill.
- **Monochrome:** one layer for the cloche, one shared by both penguins (silhouette, face cut out, eyes and beak filled). Holes are cut with a group clip-path whose hole runs the other way round, which works under both fill rules. Two overlapping holes in one even-odd path would fill their overlap again (the spoon and fork overlap).

**Checked:**
- The refactored `generate.js` writes byte-identical SVGs to the ones the developer approved.
- The generated drawables were drawn with a throwaway Flutter test (not kept) that read the XML: all 9 cloche and penguin icons under a circle and a squircle mask, plus the monochrome layers. They match `preview.png`.
- `flutter analyze` is clean, and 125 tests pass. The debug and release APKs build.
- The debug build was installed over 1.3.1 with the round sign on the emulator: exactly one launcher entry, the round cloche. The developer then checked it on the emulator and found it working: designs, shapes and the penguin unlock.
- Later checked by the developer on the Pixel and the user's Xiaomi: themed icons, the squircle mask, the release APK.

## Done in the ninth session (2026-11-06): "What's new" and the restaurant name

**"What's new" after an update** (`02-design.md` §12):
- On the first start of a newer version, a popup lists the changes since the version that ran before, merged from all releases in between ("New / Fixed / Improved"). Settings › App update › "What's new" opens it again.
- Code: `whatsNewDue`, `releasesBetween`, `mergedNotes` and `ReleaseNotes` in `domain/app_update.dart` (tested); `fetchReleases` in `platform/app_update.dart` (GitHub's release list, overridable with `--dart-define=UPDATE_RELEASES_URL=...`); `whatsNewOnStart`, `whatsNew`, `markVersionSeen` in `app/update_controller.dart`; the dialog in `ui/settings/update_tiles.dart`; `HomeShell` shows it before looking for a newer update. Status keys `lastRunVersion` and `whatsNew`.
- Installs updated from 1.4.1 or earlier have no `lastRunVersion`; they show the installed version's notes once. The setup's last step records the version, so a fresh install shows nothing.
- `scripts/update_test_server.dart` also serves `/releases.json`.

**Restaurant name** (`02-design.md` §4.10):
- New setting `restaurant`, in the setup's first page ("Restaurant" field under the language) and in Settings › General › "Restaurant". Installs from 1.4.1 and earlier read `AKAI` when nothing is stored.
- Used in three places, the developer's choice: the calendar events' location (`CalendarEvent.location`, `EVENT_LOCATION` in `calendar_bridge`), the export header and the team plan picture's title. Not on the app's own screens.
- `isAkaiRestaurant` (`domain/app_icons.dart`): only for AKAI does the icon picker offer the "AKAI sign" (the current icon always shows) and is the default colour called "AKAI red"; otherwise it's "Red". The developer chose renaming over hiding the colour.
- Changing the name marks all calendar events for an update.

**Checked:** `flutter analyze` clean, 133 tests pass (new: what's-new rules, the restaurant default and round trip, `isAkaiRestaurant` and the icon list, event location, export header). Checked by the developer on the emulator (1.4.1 debug installed over 1.4.0 data): the "What's new in version 1.4.1" popup once on start and again from Settings, "Restaurant" read as AKAI, the icon list and the "Red" label with another name, the export header. The calendar location was checked with a local test calendar (`scripts/emulator-test-calendar.sh`): all events had `eventLocation=AKAI` (`adb shell content query --uri content://com.android.calendar/events`). Not checked on a phone; the team plan picture's title only if the developer opened the share preview.

## Done in the tenth session (2026-11-06): Settings categories

- **Settings overview** (`02-design.md` §7): seven rows (Shifts, Reminders, Calendar, Team planner, Appearance, General, App update), each with a summary, each opening its own page. The developer chose seven over five categories.
- Only the reliability checks are in two places: the warning on the overview while something is missing, and all of them with their status on Reminders › "Permissions".
- **Code:** `ui/settings/settings_screen.dart` has the overview and the shared tiles (`SettingsSection`, `SettingsTile`, `DefaultTimesTiles`); `ui/settings/settings_pages.dart` has `SettingsCategory` and the pages. "Appearance & language" is now "Appearance"; "Language" moved to General with "Restaurant".
- **Restaurant can stay empty:** it always could (storage, setup, export, calendar, picture and icons all handle it). The hint now starts with "Optional.", and the Settings dialog has a clear button.
- **"App icon" only with a choice:** Settings › Appearance hides "App icon" when `iconDesignsOffered` returns just the cloche (not AKAI, secret icons locked, current icon the cloche). "Icon shape" stays.
- **README:** shows `branding/icons/cloche-icon.svg`, the icon clipped to the squircle (the full canvas showed the red as a square).
- **README without AKAI:** the restaurant is no longer named there, nor the AKAI sign icon or "AKAI red", because they are meant as a surprise. Only the repo URLs still contain it.

**Checked:** `flutter analyze` clean, 133 tests pass. The developer checked the debug build on the emulator: the overview and its summaries, the Permissions list, clearing the restaurant. Not checked on a phone.

## Done in the eleventh session (2026-11-06): optional features

- **Settings › Features** (`02-design.md` §7): a new category between Calendar and Team planner, with a switch per optional feature. Turning one off hides it and keeps its data.
  - **"Daily pool"** (`tipPool`, §4.7): hides the pool list on the Pay tab and the "Add the tips" prompt on the Home tab. "Paid out" and the "Tips" figures stay. Off on a fresh install; installs from 1.5.0 and earlier read it as on, because they have no stored value but finished the setup (the same trick as `restaurant`). The setup's last step saves every key, so a fresh install stores `false` before `onboardingDone` turns true.
  - **"Team planner"**: the switch moved here. The "Team planner" row on the overview shows only while it is on, with the number of people as its summary.
- Developer decisions: a new category rather than switches in "General"; only these two switches for now; the pool default above.
- **Checked:** `flutter analyze` clean, 134 tests pass (new: the `tipPool` default for fresh and older installs). The developer checked the debug build on the emulator, installed over 1.5.0 data: the pool read as on, both switches hide and bring back their parts, the data stays. Not checked on a phone.

## Done in the eleventh session (2026-11-06): earlier versions in "What's new"

- The "What's new" popup, after an update and from Settings, lists up to 9 older versions below the new changes, under "Earlier versions". Each is a collapsed row that opens its notes (`02-design.md` §12). The developer asked for it in both places; the update-available popup stays as it was.
- Settings › "What's new" now loads the notes from GitHub each time (the installed version open), and falls back to the stored notes offline. Before, it showed the stored notes first.
- Code: `earlierReleases` in `domain/app_update.dart` (tested), `WhatsNew.earlier` in `app/update_controller.dart` (the `whatsNew` status key also stores them; older stored notes without them still read), `_EarlierVersion` in `ui/settings/update_tiles.dart`.
- **Testing the popup without a release:** stop the app, copy `app_flutter/timetrack.sqlite` out with `adb exec-out run-as de.gartenpa.timetrack cat …`, set the `lastRunVersion` row to an older version with the container's `sqlite3`, and write it back with `run-as … sh -c 'cat … > app_flutter/timetrack.sqlite'` (through `/data/local/tmp`). The emulator has no root and no `sqlite3`.
- **Checked:** `flutter analyze` clean, 135 tests pass. The developer checked the debug build on the emulator: the popup after a simulated update from 1.4.0, and Settings › "What's new". Not checked on a phone.

## Done in the twelfth session (2026-11-06): shift colours

- **Colour by meaning** (`02-design.md` §6, §8): sage for recorded, honey for not recorded, grey for planned, apricot for lunch and periwinkle for evening, on the Home week strip (circles, bars or icons, and a colour legend), the "1 shift not recorded" chip, the month card ("Recorded" hours and the wave), and the Plan tab (status icons, type labels, the Lunch/Evening toggles, the "recorded" chip). The pay amount on Home is plain text now.
- **Other themes:** each colour moves to a neighbour when it would look like the theme colour (`ShiftColors.forScheme` in `app/shift_colors.dart`, OKLCH hues, no new package). Tested for all five presets in light and dark (`test/shift_colors_test.dart`).
- **Today border:** AKAI red in dark mode uses the real red `#C62828` (`todayColorFor` in `app/theme.dart`); the team planner's day cards use it too.
- The developer chose these on an artboard (week strip options A–C, the five themes, three new themes). Not taken: new themes (Graphite, Sand, Night blue), because they put the AKAI red on the next-shift card for people who did not choose it.
- `isLunchSlot` moved from the week strip to `domain/shift_info.dart`, because the Plan labels use it too.
- **Released as 1.6.0** (tag `v1.6.0`; the release workflow passed). The Plan row fix below went out as 1.6.1.
- **After 1.6.0:**
  - Plan rows: next to the long status "not recorded" (English), the times wrapped onto two lines. They now shrink a little instead (`FittedBox` in `_ShiftRow`).
  - README: new screenshots `home.png`, `plan.png` and `home-month.png`, and a "Colours" section with `themes.png` (month card and week strip in the five themes, dark over light). Made like the seventh session's: a demo database built with `sqlite3` from a copy of the emulator's, loaded with `run-as`, the original restored afterwards. Trap: the emulator's clock is UTC, so store the demo times as UTC, not Berlin time. Remove `calendarId` from the demo settings, or the demo shifts go into the test calendar. The theme is switched through the `themeSeed` and `themeMode` settings rows, and the Home tab scrolled to its end, so all crops line up. Cropped with a scratch Dart script (`package:image`, outside the repo). `export.png`, `pay-month.png`, `team.png` and `team-share.png` are unchanged.
- **Checked:** `flutter analyze` clean, 149 tests pass. On the emulator (debug build): the Home tab in light mode with AKAI red and bars (sage circles and bars, red today ring, grey planned days, legend, plain pay). Not yet looked at in the app: dark mode, the Plan tab, a missed shift, the icon style, the other themes and System color. Not checked on a phone.

## Done on 2026-11-10: open shifts (released as 1.7.0)

- **Plan hides closed shifts:** a Lunch or Evening shift that is closed has no toggle on the Plan tab, and a day with nothing open is hidden. A shift the user already has there keeps its toggle and its day, so it can be removed. While the team planner is on, the week's own staff counts from the board count too. `02-design.md` §4.1.
- **"Open shifts"** in Settings › Shifts (and as "Staff needed" on the team planner's page): one sheet, `ui/settings/open_shifts.dart`. With the team planner off it shows a switch per shift, with it on the − / + counters. Both edit the one setting `teamStaffNeeded` (0 = closed; switching on writes 2 at lunch, 3 in the evening). The developer chose this over a second setting, so the two views can't disagree. Lunch and Evening are a header row now, which also fixed the weekday names breaking letter by letter on the emulator (about 411 dp wide).
- **First-start setup** got a last step, "When is your restaurant open?", with the switches.
- **Setup step "What else the app can do"** (the last one): the feature switches with their descriptions, the theme colours and Light / Dark / System. The controls are shared with Settings › Features and › Appearance (`ui/settings/look_and_features.dart`).
- **Test calendar:** `scripts/emulator-test-calendar.sh` adds all 11 Google event colours now (the emulator had two) and can run again.
- **New default:** closed on Monday, open for lunch and evening on the other days (a typical small restaurant). Existing installs keep their saved week, since every settings save writes all keys. AKAI is Monday to Saturday with Saturday evening only.
- Code: `WeekNeeds` (`domain/roster.dart`) holds a week's staff counts for the board and the Plan tab; `planToggles`, `planDayShown` and `openShiftsSummary` are in `domain/display_rules.dart`; `StaffNeeds.withOpen` and `openDefault` in `data/app_settings.dart`. The roster tests pin the old Monday-to-Saturday week (`monToSat`), which they were written for.

## Done on 2026-11-10: monthly hours limits in the team planner (released as 1.8.0)

- **Why:** many of the service staff are mini-jobbers with a monthly limit. The developer asked to see each person's planned hours against a limit and to keep it in mind while planning.
- **People:** optional "Max. hours per month" in the person sheet (`team_members.maxMonthMinutes`, schema version 5, a migration that only adds the column, tested from v4).
- **"Hours per month"** (hourglass in the Team tab's header, `ui/roster/hours_screen.dart`): everyone's planned hours of a month, with a bar against the limit; tap a row to set the limit.
- **While planning:** the shift sheet shows the hours left in the month and warns "Over the monthly limit" (orange) or "Above the week's share" (gold), for people in the shift (unticked people showed it "as if ticked" at first, which confused the developer; changed the same day). The board's "Shifts per person" card shows the same, chips only "over". Tapping a warning (the icon in the shift sheet, the line in "Shifts per person") explains it with the numbers, also "No answer yet" and "Can't work". Fill goes neither over a limit nor above the week's share; by hand both are allowed. Rules in `02-design.md` §4.9 (`domain/team_hours.dart`).
- **Developer decisions:** the limit is in hours (no wages needed); planned team shifts are counted with the end times of the "Default shift times"; the week's share is what is left of the limit, spread evenly over the rest of the month, plus one long shift (5.5 h by default), first built as +25 % and changed the same day at the developer's request. From "make it make sense" for the shift times: the team planner's own "Start times" were dropped, and Settings › Team planner shows the "Default shift times" as "Shift times". Until 1.7.0 the two were kept apart on purpose (`02-design.md` §3); an old `teamStarts` value is ignored. **Confirm this with the developer**: a user whose own times differ from the restaurant's would now see them on the board.
- Built with two Sonnet subagents (people sheet and hours page; shift sheet and board), on top of the data, rules, providers and strings written first; reviewed afterwards (the hours page's month switcher got month tooltips and its subtitle).
- Trap: drift's schema export fell back to static analysis and wrote a broken steps file when the new migration step was written before `make-migrations` (`03-dev-setup.md`).
- **Checked:** `flutter analyze` clean, 201 tests pass (16 new in `test/team_hours_test.dart`, one new migration test). Debug build installed on the emulator over 1.7.0 data. Not yet checked in the app by the developer; not on a phone.

## Done on 2026-11-10: "Sync my shifts with Plan" (released as 1.8.0)

- **What:** a switch in Settings › Team planner (`teamSyncPlan`, off by default). While on, the team shifts of "This is me" go onto Plan by themselves from today on, follow special start changes, and leave again when the user is taken out, unless recorded or running. Shifts added by hand are never touched. Turning a copy off or deleting it on Plan takes the user out of the team shift too ("Also taken out of the team plan"); "Undo" after a delete puts them back. Copies have a small team icon on Plan. "Add my shifts to Plan" is hidden while the switch is on. Rules: `02-design.md` §4.9.
- **Developer decisions:** link copies (new column `shifts.teamStart`, schema version 6) rather than match by day; removing on Plan also leaves the team shift, with a message and an icon on copies; starts follow the board unless edited by hand; behind a setting.
- **Code:** `domain/team_sync.dart` (`teamSyncActions`, pure), `PlanningService.syncTeamShifts` applies it; `AppServices.startTeamSync()` listens to the team tables (`RosterRepository.watchChanges`) and the settings, UI isolate only (started in `main`).
- **Checked:** `flutter analyze` clean, 218 tests pass (11 in `test/team_sync_test.dart`, a migration test v5 → v6, the setting's round trip). The developer tried it on the emulator (copies on Plan, the explanation dialog); after that the toggles of copies got the team icon (not looked at again). Not on a phone.

## Small improvements on 2026-11-10 (released as 1.8.0)

- The "Above the week's share" explanation no longer states the exact extra that is fine; the share is in whole hours (developer's wish).
- The shift sheet shows the hours warnings only for people in the shift (developer's wish).
- Since 2026-11-12 every planner warning has its own icon and colour (`teamWarningStyle`, `02-design.md` §7), and the shift sheet lists the people without an answer under a small heading instead of a collapsed section (developer's wish; "No answer yet" is blue with a question mark, no longer a red warning). Released as 1.8.2; checked by the developer on the emulator only, not on a phone.
- **Week switcher jumps back:** on any week other than the home one (this week on Plan and Pay, next week on Team, this month on Export), a small tonal double-arrow button sits next to the centred week, on the side the home week lies. Replaces the calendar icon in the Plan and Pay headers and the Team tab's "Next week" text button. A label under the dates was tried first and dropped. `WeekSwitcher.onHome` / `homeIsBefore` in `ui/common.dart`. Checked: analyze clean, tests pass, installed on the emulator; the developer checked it on the emulator.

## Small improvements on 2026-11-10 (released as 1.8.1)

- The app looks for a new release on start and on resume at most every 30 minutes instead of every 6 hours (`updateCheckInterval` in `domain/app_update.dart`), so a release shows up soon after the app is next opened. Checked: analyze and tests; not checked with the fake release server or on a phone.

## README refreshed on 2026-11-10 (after 1.8.1)

- All screenshots retaken with 1.8.1 on the emulator: `home.png`, `plan.png`, `export.png`, `team.png` (full screens), `home-month.png`, `pay-month.png`, `themes.png`, and `team-share.png`, which is now the PNG the app shares (copied from `cache/team-plan-<week>.png` with `run-as`), not a screenshot of the preview. New: `team-hours.png` ("Hours per month").
- README text: "Open shifts" on Plan, "Staff needed" and the first-start setup for the team planner, and the 30-minute update check. Everything else still matched the app.
- Made like the seventh and twelfth sessions' (demo database through `run-as`, original restored afterwards). Demo "today" is Tue 2026-11-10 with an evening shift being recorded; the team answers are for next week (2026-11-16), the Team tab's home week, and the board was filled with "Fill". Set `restaurant` to '' in the demo data, or "AKAI" shows in the Export text and the picture's title (the README doesn't name it). Add a pool for yesterday, or Home shows "Add the tips" instead of the month card. The seed and crop scripts were again kept outside the repo.

## Open points (in rough priority)

Done and removed on 2026-11-06, as the developer confirmed: the new icons and the release build checked on the Pixel and the Xiaomi; the Live Update and icon checks on the Pixel 7 Pro; the handover (M6) with the release key backed up, the GitHub secrets set, the old test install removed, and the app in daily use on the user's Xiaomi since 2026-11-04.

0. **Review findings** (2026-11-06): fixed on 2026-11-07 (time-zone bugs, stale writes, notification error handling, column widths). What is left is in `04-architecture.md` §10.

0. **Team planner in real use:** the developer is asking how the shared picture looks in WhatsApp (Standard quality shrinks it to about 1600 px; expected to be fine). Set the real staff counts. Maybe later: drag and drop, "Same as last week", kitchen staff (`01-research.md` §10).

1. **In-app update on the Xiaomi:** the path with the release key and GitHub is checked with debug builds and the fake server on the emulator, but no confirmed in-app update on the user's phone yet. Some MIUI versions had trouble with session installs from third-party apps; if it fails there, fall back to the system installer intent (FileProvider + ACTION_VIEW).

2. **Not tested yet** (may already be covered by real use; confirm with the developer):
   - notification buttons "Start recording" and "End 23:00" with the app killed. "Stop" works with the app killed: checked on the emulator, where Android starts the process for the button, the shift is recorded and the event updated;
   - the "Still at work?" overrun question;
   - "Later" snooze;
   - Settings: event title change and language switch (both should update all events);
   - the System color theme;
   - reboot (rescheduling; the progress alarm is not restored after a reboot until the app re-posts the notification on start);
   - the progress tick firing with the app killed (it fired on its own while the app was in the background: progress 24 → 59, next alarm set).

## Code map

```
lib/
  main.dart                 start: services, notifications, ProviderScope
  app/  services.dart       AppServices (one per isolate), syncAll/syncNow, background notification entry point
        providers.dart      Riverpod providers (settings, shifts by day range, running shift, clock, sync status)
        app.dart, theme.dart (M3ETheme wrapper, seed colours), shift_colors.dart (status, lunch/evening and today colours)
  core/ time.dart, format.dart        dates, ISO weeks, minutes, HH:mm, decimal hours
  data/ database.dart (+ .g.dart, .steps.dart)  drift tables Shifts, Settings, TipDays, TipPayouts, WageRates; migrations
        database_connection.dart     opens the database file (kept out of database.dart for drift's schema export)
        shift_repository.dart, tip_repository.dart, wage_repository.dart,
        roster_repository.dart (team planner tables),
        settings_repository.dart (also status keys: lastCalendarSync, tipPromptDismissedDay), app_settings.dart
  domain/ planning.dart, recording.dart, rounding.dart, month_summary.dart,
          export_text.dart, reminder_planner.dart, shift_info.dart,
          tips.dart (money parsing, tip weeks and months, Home prompt),
          salary.dart (rate of a day, month pay),
          roster.dart (team planner: availability, sheet order, Fill),
          team_hours.dart (team planner: hours of planned shifts, monthly limits),
          team_sync.dart ("Sync my shifts with Plan": team shifts of "me" onto Plan),
          app_icons.dart (launcher icon designs and shapes, secret designs, isAkaiRestaurant)   (pure logic, tested)
  platform/ notification_service.dart, calendar_sync.dart, device_setup.dart, app_icon.dart, app_update.dart
  l10n/ app_de.arb (source), app_en.arb, labels.dart (+ generated app_localizations*.dart)
  ui/   material.dart (the one UI import), home_shell, common (header, Panel, Figure, WavyProgress, WeekSwitcher, pickers),
        today/ (Home tab), plan/, shift_sheet.dart, pay/ (Pay tab, money sheet, wage sheet), export/, settings/ (overview, category pages, update tiles, reliability checks), onboarding/,
        roster/ (Team tab: board, shift sheet, answers, people, hours per month, plan image, share preview, Settings tiles)
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
- **Emulator:** the task *Emulator: Start*. It has no Google account, so there are no calendars. `scripts/emulator-test-calendar.sh` creates a local test calendar with Google's 11 event colours (safe to run again). The developer also tries the app in the emulator window, so don't drive the UI blindly.
- **Releases:** bump `version:` in `pubspec.yaml`, push, then tag `v<version>`; GitHub Actions builds the APK (`03-dev-setup.md` section 9). Release builds use `android/key.properties` if present, otherwise the debug key.
- **Commits:** use the repo-local GitHub noreply identity; never the global work address. Subjects start with a type prefix (`Feature:`, `Bugfix:`, `Improvement:`, `Docs:`, `Dev:`, `Release:`); the release notes are built from them (03-dev-setup.md section 9).
