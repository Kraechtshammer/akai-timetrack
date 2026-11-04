#!/usr/bin/env bash
# Installs the newest APK from dist/ on the connected phone or emulator (keeps app data).
#   scripts/install-apk.sh [debug|release]   (default: release)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

mode="${1:-release}"
apk="$(ls -t dist/timetrack-*-"$mode".apk 2>/dev/null | head -n 1 || true)"
if [ -z "$apk" ]; then
  echo "No $mode APK in dist/. Run the build task first." >&2
  exit 1
fi

devices="$(adb devices | awk 'NR > 1 && $2 == "device" {print $1}')"
count="$(printf '%s\n' "$devices" | grep -c . || true)"
if [ "$count" -eq 0 ]; then
  echo "No device found. Is the adb server running on Windows (scripts/windows/start-adb-server.cmd)" >&2
  echo "and is the phone connected (USB or wireless debugging)? See docs/03-dev-setup.md." >&2
  exit 1
fi
if [ "$count" -gt 1 ] && [ -z "${ANDROID_SERIAL:-}" ]; then
  echo "Several devices connected; choose one with ANDROID_SERIAL=<serial>:" >&2
  printf '  %s\n' $devices >&2
  exit 1
fi

echo "Installing $apk ..."
adb install -r "$apk"
