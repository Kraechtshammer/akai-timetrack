# TimeTrack (AKAI Timetrack)

Android app (Flutter) for one person: the user's partner, who waits tables at the restaurant AKAI. She plans lunch and evening shifts, the shifts appear in a shared Google calendar, she records her working time from a notification, and she sends the week's hours as text. The app is a surprise. It runs on her Xiaomi only after the handover (milestone M6). Until then, the user tests it on a Pixel 7 Pro and on the emulator.

Status: version 1.0.1 is released (tag `v1.0.1`). **Read [docs/HANDOFF.md](docs/HANDOFF.md) first.** It has the current state, the open points and the code map.

The UI is German first, English second. The user writes in German or English; answer in English unless they switch.

## Where things are

| Path | What | More |
|---|---|---|
| `lib/` | The app: data, domain logic, platform services, screens, texts | [lib/CLAUDE.md](lib/CLAUDE.md) |
| `test/` | Unit tests (domain logic, repositories with an in-memory DB, calendar sync with a fake bridge) | [lib/CLAUDE.md](lib/CLAUDE.md) |
| `packages/` | Two local Kotlin plugins: `calendar_bridge` (Android calendar), `running_progress` (notification progress / Live Update) | [packages/CLAUDE.md](packages/CLAUDE.md) |
| `android/` | Android project: manifest, launcher icon variants, signing, `MainActivity` | [android/CLAUDE.md](android/CLAUDE.md) |
| `docs/` | Research, design, dev setup, handoff, UI concepts | [docs/CLAUDE.md](docs/CLAUDE.md) |
| `branding/app-icon.svg` | Master of the app icon (the restaurant's sign); the Android icon layers are generated from it | |
| `scripts/` | `build-apk.sh` (APK into `dist/`), `install-apk.sh`, `release-notes.sh` (release notes from commit prefixes), `emulator.sh`, `emulator-test-calendar.sh` (local test calendar), `update_test_server.dart` (fake release for testing the in-app update), `windows/start-adb-server.cmd` | [docs/03-dev-setup.md](docs/03-dev-setup.md) |
| `.devcontainer/` | The dev container: Flutter 3.47.9, Android SDK, JDK 17, emulator, adb wrapper | [docs/03-dev-setup.md](docs/03-dev-setup.md) |
| `.github/workflows/` | `ci.yml` (analyze + tests on main and PRs), `release.yml` (signed APK and GitHub release on `v*` tags) | 03-dev-setup.md §9 |
| `.githooks/` | `commit-msg`: rejects commit subjects without a type prefix | 03-dev-setup.md §9 |
| `.vscode/tasks.json` | Tasks: analyze, test, build APKs, install, emulator start/stop, device pairing, logs | |
| `dist/`, `build/` | Build output, git-ignored | |

## Environment

- **Everything builds in the dev container.** In the VS Code extension inside the container, run `flutter`, `dart` and `adb` directly in `/workspaces/akai-timetrack`. From a Windows shell, go through WSL: `wsl.exe -e docker ps` for the container name, then `wsl.exe -e docker exec <name> bash -lc 'cd /workspaces/akai-timetrack && …'`.
- **The repo lives in WSL** since 2026-11-05: `/home/paga/Projects/akai-timetrack` (ext4). `C:\Users\paga\Projects\akai-timetrack` is only a link to it, so reading through it from Windows is the slow side now. Run git and builds in WSL or the container. Build times there: `flutter analyze` 20–30 s, `flutter test` 25 s, a debug APK about 25 s incremental, about 3 min clean (03-dev-setup.md §8).

  Run long builds in the background and do other work meanwhile. When you wait, wait on the process you started. VS Code's own Dart analysis server always runs, so a loop on "is the analyzer running" never ends.
- **Emulator:** `emulator-5554`, inside the container (task *Emulator: Start*). It has a local test calendar (`scripts/emulator-test-calendar.sh`) and is in dark mode.
  - The user tests in it too, so don't drive the UI blindly. Take a screenshot first: `adb exec-out screencap -p > build/shot.png`, then read the PNG.
  - Tap coordinates are device pixels (1440×3120).
  - Undo test data you create (test shifts, recordings, changed settings), or tell the user.
- **Phone:** the user's Pixel 7 Pro (Android 16 QPR; Live Updates work there). adb reaches it only while the Windows adb server runs.

Common commands: `flutter analyze` (must report no issues), `flutter test`, `dart format lib test packages`, `flutter gen-l10n` after ARB changes, `dart run build_runner build -d` after table changes, `bash scripts/build-apk.sh debug|release`, `adb install -r dist/<apk>`.

## Working agreements with the user

- **One commit per finished feature**, made as soon as the feature is checked. Commit messages have an imperative summary with a type prefix, a body saying what and why, and the `Co-Authored-By` trailer.
- **Type prefixes** (checked by `.githooks/commit-msg`; the release notes are built from them by `scripts/release-notes.sh`): `Feature:` new things she can do, `Bugfix:` something broken works again, `Improvement:` existing behaviour or looks got better, `Docs:` docs only, `Dev:` build, CI, tooling, tests, `Release:` version bumps (left out of the notes). Example: `Feature: Export the month's hours`. The summary after the prefix appears in the release notes as is, so write it for her, not for a developer, when the type is Feature, Bugfix or Improvement. **Push only when the user asks.**
- **Git identity:** the repo-local GitHub noreply address (`git config user.email` shows `…@users.noreply.github.com`). Never use the global work address; check it before the first commit of a session.
- **Parallelize longer work.** Split it into well-described chunks for Sonnet subagents: files, the exact change, conventions, and "no commits". Then verify their work yourself (diff, analyze, tests, emulator) before committing. Never let two agents edit the same files. Only one agent at a time drives the emulator.
- **Ask before:**
  - adding dependencies;
  - changing app or package names;
  - design choices with trade-offs.

  Offer the options with a recommendation. For visual choices, build real prototypes in the app and show screenshots; the user liked that for the week strip.
- **Secrets never go into git, chat or docs:** `android/key.properties`, `android/*.jks`, `.devcontainer/.env`. The release key's backup is the user's job; remind them if the key changes.
- **Releases:** raise `version:` in `pubspec.yaml` (name and a higher build number), commit, push, then push the tag `vX.Y.Z` (with the user's OK). See 03-dev-setup.md §9.

## Quality bar

- **Check changes in the real app**, not only in tests: build, install on the emulator, screenshot. When colours or theming change, look at dark *and* light mode. A release-only problem (shrinking, signing) needs a release build.
- Domain and data changes come with unit tests. `flutter analyze` stays clean.
- **Keep the docs current in the same commit:**
  - `docs/HANDOFF.md` for state and open points;
  - `docs/02-design.md` for behaviour (deviations from the original design go in §16);
  - `docs/03-dev-setup.md` for the workflow.
- German UI texts must read naturally, and every key also gets its English translation.
- Report honestly what was checked and what wasn't (for example "only on the emulator, not on a phone").

## Pitfalls seen in this repo

- Python on Windows writes CRLF in text mode. Use `newline=''` or binary writes, or the Write/Edit tools.
- Shell heredocs mangle backslashes, for example in regexes. Put such scripts in a file.
- The release build drops resources referenced only by name. Add them to `android/app/src/main/res/raw/keep.xml`; `ic_notification` once made the release app hang on the splash screen.
- `main()` must reach `runApp` even if a setup step fails.
- Switching the app icon variant closes the app (an Android activity-alias quirk). The app warns before doing it.
- Import Material through `lib/ui/material.dart` in UI code, never `package:flutter/material.dart`.
