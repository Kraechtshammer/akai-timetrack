# Development setup

Everything needed to build the app (Flutter, Android SDK, Java, Claude Code) lives in a **dev container**. On Windows you only need the things in step 1.

```
Windows                                   Dev container (Linux)
──────────────────────────────            ───────────────────────────────────
VS Code (+ Dev Containers ext.)  ◄──────► Flutter, Android SDK, JDK 17,
Docker (Engine in WSL 2,                  Dart/Flutter + Claude Code extensions
        or Docker Desktop)
adb server  (start-adb-server.cmd) ◄───── adb client (wrapper picks the server)
  ├─ phone via USB
  ├─ phone via wireless debugging
  └─ emulator (optional, Android Studio)
```

Why adb runs on Windows: Docker can't pass USB devices into the container, and the Android emulator can't run inside it either (no hardware virtualization). Instead, the adb **client** in the container talks to an adb **server** on Windows, which sees every phone and emulator on the PC.

How the container finds Windows: `adb` in the container is a small wrapper (`.devcontainer/adb-wrapper.sh`). Each call checks whether the Windows adb server is reachable:
- **Docker Engine in WSL 2:** at the WSL VM's default gateway. The container runs with host networking for this, and the address is looked up each time because it can change after a reboot.
- **Docker Desktop:** at `host.docker.internal`.

If the Windows server isn't running, adb uses its own server inside the container instead (port 5039). Wireless debugging still works that way, but USB phones and emulators aren't visible.

## 1. One-time setup on Windows

All of these are already installed on this PC:
- **Docker:** on this PC, the Docker Engine inside the WSL 2 Ubuntu, with VS Code's Dev Containers using it. Docker Desktop with the WSL 2 backend works too.
- **VS Code** with the **Dev Containers** extension (`ms-vscode-remote.remote-containers`). No other extensions are needed on Windows; the Flutter and Claude Code extensions are installed inside the container.
- **Android platform-tools** (`adb`), installed under `C:\Program Files\android-platform-tools`. On another PC: `winget install Google.PlatformTools`.

## 2. Open the project in the container

1. Open the folder in VS Code → **"Reopen in Container"** (or Ctrl+Shift+P → *Dev Containers: Reopen in Container*).
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

The `dist/` folder is visible in Windows Explorer, so an APK can also be copied to a phone by hand. Opening it on the phone asks to allow installs from that source. Until there is a release signing key (milestone M6), release APKs are signed with the debug key; that's fine for testing.

## 6. Emulator (optional)

**Windows Subsystem for Android no longer exists**; Microsoft discontinued it in March 2025. The Android Emulator on Windows still works next to Docker and WSL 2:

1. Install Android Studio on Windows: `winget install Google.AndroidStudio`. It's only needed for the emulator.
2. Android Studio → Settings → Build, Execution, Deployment → Debugger → **Adb Server Lifecycle Management: "Use existing manually managed server"**, port 5037. Otherwise Android Studio may restart adb in a mode the container can't reach.
3. Start `start-adb-server.cmd` first, then in Android Studio: *Device Manager* → create a device (e.g. Pixel 9, latest API, with Google Play so the Google Calendar app is available) → start it.
4. The emulator shows up in the container as `emulator-5554` (task *Device: List devices*) and in VS Code's device picker.

If the emulator complains about virtualization, enable the Windows feature **"Windows Hypervisor Platform"** and restart.

## Troubleshooting

- **Phone or emulator not listed** although it's connected on Windows:
  - Check that `start-adb-server.cmd` is running.
  - In the container (Docker in WSL), `ip route | grep default` shows the address the wrapper tries. On Windows, `netstat -ano | findstr :5037` should show `0.0.0.0:5037 LISTENING`.
  - If the Windows firewall blocks adb for the WSL network, allow `adb.exe` (Windows Security → Firewall → Allow an app) for the network type it asks about.
- **Force a server:** set `ADB_SERVER_SOCKET=tcp:<host>:5037` yourself, or `ADB_MODE=local` to never use Windows.
- **"adb server version (…) doesn't match this client"**: Windows and container adb versions differ too much. Update platform-tools on Windows (`winget upgrade Google.PlatformTools`).
- **Phone shows "unauthorized"**: unlock the phone and accept the debugging prompt.
- **Changing Flutter or Android SDK versions**: edit the `ARG`s at the top of `.devcontainer/Dockerfile`, then *Dev Containers: Rebuild Container*.
