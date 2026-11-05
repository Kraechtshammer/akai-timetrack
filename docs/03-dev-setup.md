# Development setup

Everything needed to build the app (Flutter, Android SDK, Java, Claude Code) lives in a **dev container**. On Windows you only need the things in step 1.

```
Windows                                   Dev container (Linux)
──────────────────────────────            ───────────────────────────────────
VS Code (+ Dev Containers ext.)  ◄──────► Flutter, Android SDK, JDK 17,
Docker (Engine in WSL 2,                  Dart/Flutter + Claude Code extensions
        or Docker Desktop)
adb server  (start-adb-server.cmd) ◄───── adb client (wrapper picks the server)
  ├─ phone via USB                        Android emulator (window via WSLg,
  └─ phone via wireless debugging           KVM via WSL 2)
```

Why adb runs on Windows: Docker can't pass USB devices into the container. Instead, the adb **client** in the container talks to an adb **server** on Windows, which sees every phone connected to the PC. The emulator runs inside the container (section 6).

How the container finds Windows: `adb` in the container is a small wrapper (`.devcontainer/adb-wrapper.sh`). Each call checks whether the Windows adb server is reachable:
- **Docker Engine in WSL 2:** at the WSL VM's default gateway. The container runs with host networking for this, and the address is looked up each time because it can change after a reboot.
- **Docker Desktop:** at `host.docker.internal`.

If the Windows server isn't running, adb uses its own server inside the container instead (port 5039). Wireless debugging still works that way, but USB phones and emulators aren't visible.

## 1. One-time setup on Windows

All of these are already installed on this PC:
- **Docker:** on this PC, the Docker Engine inside the WSL 2 Ubuntu, with VS Code's Dev Containers using it. Docker Desktop with the WSL 2 backend works too.
- **VS Code** with the **WSL** (`ms-vscode-remote.remote-wsl`) and **Dev Containers** (`ms-vscode-remote.remote-containers`) extensions. No other extensions are needed on Windows; the Flutter and Claude Code extensions are installed inside the container.
- **The repo inside WSL**, not on `C:` (see section 8 for why): `/home/paga/Projects/akai-timetrack` in the Ubuntu distribution. In Explorer it's under *Linux → Ubuntu*, or `\\wsl.localhost\Ubuntu\home\paga\Projects`. `C:\Users\paga\Projects\akai-timetrack` is a link to that folder, so it can still be found next to the other projects.
- **Android platform-tools** (`adb`), installed under `C:\Program Files\android-platform-tools`. On another PC: `winget install Google.PlatformTools`.

## 2. Open the project in the container

1. Open the folder through WSL, then in the container:
   - In an Ubuntu terminal: `cd ~/Projects/akai-timetrack && code .` (or in VS Code: Ctrl+Shift+P → *WSL: Open Folder in WSL…*).
   - Then **"Reopen in Container"** (or Ctrl+Shift+P → *Dev Containers: Reopen in Container*).

   Don't open it through the `C:\` link or the `\\wsl.localhost` path: the container would then be mounted over the slow 9p bridge again.
2. The first build takes a while (roughly 10–20 minutes): it downloads Flutter, the Android SDK and runs a warm-up build, so later builds are fast. Rebuilds after that reuse Docker's cache.
3. When it's done, open a terminal and run `flutter doctor`. Flutter and the Android toolchain should be ✓. Android Studio may show as missing; it isn't needed in the container.

## 3. Claude Code token

Each project can use its own Claude login (customer vs. private):

1. On the first container start, `.devcontainer/.env` is created from `.env.example`. This file is **git-ignored and never committed**.
2. Get a long-lived token for the login you want to use **for this project**: run `claude setup-token` (in the container or anywhere) and sign in with that account.
3. Put it in `.devcontainer/.env`:
   ```
   CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-...
   ```
4. Open a new terminal; `claude` now uses it. For the Claude Code **extension**, run *Developer: Reload Window*.

To check the token is not tracked: `git check-ignore -v .devcontainer/.env` should print the `.gitignore` rule.

## 4. Connect your phone (Pixel 7 Pro)

**On Windows:** double-click `scripts\windows\start-adb-server.cmd` and leave the window open while you work.
- It restarts adb so it accepts connections from the container.
- If Windows Firewall asks, allow access on **private networks only**. The server is reachable from your local network while it runs, so close it when you're done or on public Wi-Fi.

**Phone, one time:** Settings → About phone → tap *Build number* 7 times → Developer options → turn on **USB debugging** (and **Wireless debugging** if you want to work without a cable).

**Option A: USB.** Plug in the phone and accept the "Allow USB debugging?" dialog. Then run the task *Device: List devices* in VS Code; the Pixel should be listed.

**Option B: wireless debugging** (phone and PC on the same Wi-Fi):
1. Phone: Developer options → Wireless debugging → *Pair device with pairing code*.
2. VS Code task *Device: Pair wireless debugging*: enter the IP:port and the code shown on the phone.
3. VS Code task *Device: Connect wireless debugging*: enter the address under *IP address & Port* (a different port than for pairing).
4. Pairing is remembered; next time only step 3 is needed (the port changes each time wireless debugging is turned on).

## 5. Run, build, install

| What | How |
|---|---|
| Run with hot reload | F5 (*TimeTrack (debug)*). Pick the device in the status bar first. |
| Build a release APK | Ctrl+Shift+B (*Build: Release APK*) → `dist/timetrack-<version>-release.apk` |
| Build a debug APK | Task *Build: Debug APK* |
| Build and install on the phone | Task *Device: Build and install release APK* (updates the app, keeps its data) |
| Install the last built APK | Task *Device: Install latest release APK* |
| App logs | Task *Device: Show app logs* |
| Analyze / test | Tasks *Flutter: Analyze*, *Flutter: Test* |

The `dist/` folder is visible in Windows Explorer, so an APK can also be copied to a phone by hand. Opening it on the phone asks to allow installs from that source. Release APKs are signed with the release key when `android/key.properties` exists, otherwise with the debug key (see section 9). A debug-signed APK can't update an app installed with the release key.

**Changing the database.** Tables are in `lib/data/database.dart`. After a change:

```
dart run build_runner build -d          # regenerate database.g.dart
dart run drift_dev make-migrations      # new snapshot in drift_schemas/, steps, tests
```

Then raise `schemaVersion`, write the step in `AppDatabase.migration` (`from1To2`, …), and run `flutter test test/drift`. Run `make-migrations` once before the change too, if the current version has no snapshot yet. Migrations only add tables or nullable columns.

**App icon variants.** The launcher entry is one of three activity aliases (Round, Squircle, Small squircle), chosen in the app's Settings. `flutter run` / F5 still works: `MainActivity` keeps a MAIN/LAUNCHER intent filter in the source manifest, and the build removes it from the installed app (`tools:node="remove"`). To start the app by hand:

```
adb shell am start -n de.gartenpa.timetrack/de.garten.akaitimetrack.MainActivity
```

## 6. Emulator

The Android emulator runs **inside the dev container**. Its window appears on the Windows desktop through WSLg (WSL's built-in Linux GUI support), and it uses WSL 2's KVM for speed. No Android Studio is needed. (Windows Subsystem for Android, which you may have heard of, was discontinued by Microsoft in March 2025.)

| Task | What it does |
|---|---|
| *Emulator: Set up (one time, ~3 GB download)* | Downloads the emulator and an **Android 16 image with Google Play**, and creates a virtual **Pixel 7 Pro**. Takes about 10 minutes. |
| *Emulator: Start* | Opens the emulator window and waits until Android has booted: about 50 s the first time, about 25 s after that (quick-boot snapshot). Then pick it in VS Code's device picker and press F5, or use the install tasks. |
| *Emulator: Stop* | Shuts it down; the next start resumes from a snapshot. |
| *Emulator: Factory reset* | Deletes all apps, data and the Google sign-in, then starts it. |

Notes:
- **Storage:** the emulator, the Android image and the virtual phone's data live in the Docker volume `timetrack-emulator` (about 7 GB after setup, growing with use). They survive container rebuilds. To remove everything, delete the volume (in WSL: `docker volume rm timetrack-emulator`) while the container is stopped.
- **Google account:** the image has the Play Store, so you can sign in with a Google account and install Google Calendar there to test calendar sync. Use a test account if you prefer.
- **adb:** the emulator works with both adb servers. If `start-adb-server.cmd` is running, the start task connects the Windows server to the emulator (it appears as `127.0.0.1:5555`); otherwise it's `emulator-5554` on the container's own server.
- **Graphics** are rendered in software (SwiftShader). That's reliable and fast enough for this app; animations may be a little less smooth than on a real phone.
- **Requirements:** Docker Engine in WSL 2 (as on this PC). The container gets `/dev/kvm` and WSLg's display through `runArgs` in `devcontainer.json`. With **Docker Desktop** instead, the emulator isn't available: remove the `--device=/dev/kvm` line and the two `/mnt/wslg` mounts there, and use a phone.
- **Logs:** `~/.android-emu/emulator.log` in the container. If a start fails, the task prints the end of it.

After changing `devcontainer.json` or the `Dockerfile` (e.g. when pulling these changes), run *Dev Containers: Rebuild Container* once.

## 7. Using the container from Windows without VS Code

Useful for scripts and for Claude Code running on Windows. Docker Engine runs inside the WSL 2 Ubuntu, so call it through `wsl.exe`:

```
wsl.exe -e docker ps
wsl.exe -e docker exec <name> bash -lc 'cd /workspaces/akai-timetrack && flutter test'
```

`docker ps` shows the container name. Inside the container the repo is at `/workspaces/akai-timetrack`; in WSL it's at `~/Projects/akai-timetrack`, so git can run there too: `wsl.exe -e git -C /home/paga/Projects/akai-timetrack status`.

From Git Bash, set `MSYS_NO_PATHCONV=1` before `wsl.exe` calls that pass Linux paths. Otherwise Git Bash rewrites `/mnt/c/...` into `C:/Program Files/Git/mnt/c/...`.

To capture the emulator screen, run this in the container (`build/` is git-ignored):

```
adb exec-out screencap -p > build/shot.png
```

## 8. Build speed and where the repo lives

There is no CPU limit. Windows, the WSL VM and the container all see every core, and the container has no cgroup CPU quota (`cat /sys/fs/cgroup/cpu.max` shows `max`).

The limit was file access. Until 2026-11-05 the repo lived on `C:\` and was mounted into the container over 9p (`mount | grep workspaces` showed `type 9p ... aname=drvfs`), so every file read crossed the Windows/WSL boundary. Since 2026-11-05 it lives on WSL's own ext4 disk (`/home/paga/Projects/akai-timetrack`), and the mount shows `ext4`.

| | Repo on `C:` (9p) | Repo in WSL (ext4), measured 2026-11-05 |
|---|---|---|
| `flutter analyze` | 5–7 min | 20–30 s |
| `flutter test` | | 25 s |
| Debug APK, incremental | about 2 min | 23 s |
| Debug APK, clean | | about 3 min |
| Release APK | about 5 min | not measured yet |

What changed with the move:
- **Explorer:** `C:\Users\paga\Projects\akai-timetrack` is a link to `\\wsl.localhost\Ubuntu\home\paga\Projects\akai-timetrack`. Windows programs that read the repo through it (Explorer, Claude Code on Windows) now cross the boundary the other way, so they are the slow side. Build inside WSL or the container.
- **Git:** run git inside WSL or the container. Git for Windows on the link is slow and complains about "dubious ownership". Pushing from WSL needs a credential helper there; Git for Windows' credential manager can be used for it.
- **Backups:** the files are inside WSL's virtual disk (`ext4.vhdx`). OneDrive and File History don't see them, and `wsl --unregister Ubuntu` deletes them. Push to GitHub regularly. The git-ignored release key and `.env` need their own backup (see section 9).

Memory is the other limit. The WSL VM gets about 15 GB by default (half the PC's RAM). The emulator takes about 6.5 GB. Gradle's and the Kotlin daemon's JVMs may each grow to 8 GB (`org.gradle.jvmargs` in `android/gradle.properties`).

Further options:
- **Give WSL more memory** in `%UserProfile%\.wslconfig`:
  ```
  [wsl2]
  memory=24GB
  ```
  Optionally add `processors=`. Then run `wsl --shutdown`. This stops the container and the emulator.
- **Keep the emulator closed** while building when you don't need it.

## 9. Releases

Releases are built by GitHub Actions when a version tag is pushed. The repo is public: `github.com/Kraechtshammer/akai-timetrack`. Keep it public, or the in-app update can no longer see the releases. Version 1.0.0 uses the package name `de.gartenpa.timetrack`; it installs as a new app, so uninstall the old test install first (its data is not carried over).

**One-time setup: repository secrets.** The release workflow needs three secrets. Without them it fails.
1. On GitHub open the repo → Settings → Secrets and variables → Actions → *New repository secret*.
2. `ANDROID_KEYSTORE_BASE64`: paste the whole content of `android/timetrack-release.jks.base64`.
3. `ANDROID_KEYSTORE_PASSWORD`: the `storePassword` value from `android/key.properties`.
4. `ANDROID_KEY_ALIAS`: `timetrack`.
5. Delete `android/timetrack-release.jks.base64` afterwards.

**Make a release.**
1. In `pubspec.yaml` set `version:` to the new name and a higher build number, e.g. `1.0.1+2`. The build number is Android's versionCode and must increase, or updates are refused.
2. Commit (subject `Release: 1.0.1`) and push to main. The CI workflow (`.github/workflows/ci.yml`) runs analyze and tests.
3. Tag and push:
   ```
   git tag v1.0.1
   git push origin v1.0.1
   ```
4. The release workflow (`.github/workflows/release.yml`) checks that the tag matches the pubspec version, runs analyze and tests, builds the signed APK and creates the release "TimeTrack 1.0.1" with `timetrack-1.0.1.apk` attached and the release notes as its text. It can also be started by hand in the Actions tab.
5. On the phone the app finds the release by itself (on start or when opened again, at most every 6 hours; or Settings › App update › "Check for updates") and shows the popup with the notes. The APK can also still be downloaded from the release page and installed by hand.

**Release notes.** Since 2026-11-05 every commit subject starts with a type prefix. `scripts/release-notes.sh <tag>` collects the subjects since the tag before and sorts them into sections; the release workflow uses its output as the release text.

| Prefix | Section | Use for |
|---|---|---|
| `Feature:` | New | new things the user can do in the app |
| `Bugfix:` | Fixed | something that was broken works again |
| `Improvement:` | Improved | existing behaviour or looks got better |
| `Dev:`, `Docs:` | Behind the scenes | build, CI, tooling, tests, dev container; docs |
| `Release:` | left out | version bumps |

- Subjects without a prefix (all commits before 2026-11-05) go under "Other changes".
- Preview the next release's notes with `bash scripts/release-notes.sh` (no tag).
- `.githooks/commit-msg` rejects a subject without a prefix. Merges, reverts and `fixup!` commits pass. The dev container's post-create step enables it with `git config core.hooksPath .githooks`; in an older container or a plain WSL clone, run that once by hand.

**Key files** (all git-ignored, in `android/`): `timetrack-release.jks` (the keystore, alias `timetrack`), `key.properties` (its settings) and `timetrack-release.jks.base64` (copy for GitHub; delete after use). Never commit or share them.

**Back up the key.** Every update must be signed with the same key. Keep `timetrack-release.jks` and the password in a password manager plus an offline copy. If the key is lost, the app on the user's phone can only be replaced by uninstalling it, which deletes its data. The GitHub secret is not a backup: secrets can't be read back.

**Testing the in-app update.** The app on the emulator is debug-signed, so the real (release-signed) APK from GitHub can't replace it. Point a debug build at a fake release instead:
1. Build the "new" version and keep it: `flutter build apk --debug --dart-define=UPDATE_RELEASE_URL=http://127.0.0.1:8765/latest.json --build-name=1.0.1 --build-number=2`, copy `build/app/outputs/flutter-apk/app-debug.apk` aside.
2. Build an older one with the same `--dart-define` and `--build-name=1.0.0 --build-number=1`, and `adb install -r` it.
3. `dart run scripts/update_test_server.dart <new apk> 1.0.1` and `adb reverse tcp:8765 tcp:8765`.
4. Open the app: the popup appears. Debug APKs are about 200 MB, so the download takes a moment.
- The debug key belongs to the container (`~/.android/debug.keystore`). After a container rebuild it is new, and new debug builds can't update an older debug install ("signatures do not match"). Because the app is debuggable, its data can be kept: `adb exec-out run-as de.gartenpa.timetrack tar cf - . > appdata.tar`, uninstall, install, then copy `app_flutter/timetrack.sqlite` back with `adb push` to `/data/local/tmp` and `run-as … cp`.

**Local release builds.** `scripts/build-apk.sh release` and the task *Build: Release APK* also sign with the release key when `android/key.properties` is present, otherwise with the debug key.

## Troubleshooting

- **Builds or `flutter analyze` are very slow** although the CPU is idle: see section 8 (9p file access, memory).
- **Phone or emulator not listed** although it's connected on Windows:
  - Check that `start-adb-server.cmd` is running.
  - In the container (Docker in WSL), `ip route | grep default` shows the address the wrapper tries. On Windows, `netstat -ano | findstr :5037` should show `0.0.0.0:5037 LISTENING`.
  - If the Windows firewall blocks adb for the WSL network, allow `adb.exe` (Windows Security → Firewall → Allow an app) for the network type it asks about.
- **Force a server:** set `ADB_SERVER_SOCKET=tcp:<host>:5037` yourself, or `ADB_MODE=local` to never use Windows.
- **"adb server version (…) doesn't match this client"**: Windows and container adb versions differ too much. Update platform-tools on Windows (`winget upgrade Google.PlatformTools`).
- **Phone shows "unauthorized"**: unlock the phone and accept the debugging prompt.
- **Changing Flutter or Android SDK versions**: edit the `ARG`s at the top of `.devcontainer/Dockerfile`, then *Dev Containers: Rebuild Container*.
