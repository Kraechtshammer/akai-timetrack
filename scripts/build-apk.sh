#!/usr/bin/env bash
# Builds an APK and copies it to dist/ with the app version in its name, so it's easy to
# find from Windows (e.g. to copy it to a phone by hand).
#   scripts/build-apk.sh [debug|release]   (default: release)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

mode="${1:-release}"
case "$mode" in debug|release) ;; *) echo "Usage: $0 [debug|release]" >&2; exit 2 ;; esac

flutter build apk "--$mode"

version="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}' | tr '+' '-')"
mkdir -p dist
out="dist/timetrack-${version}-${mode}.apk"
cp "build/app/outputs/flutter-apk/app-${mode}.apk" "$out"
echo
echo "APK: $out"
