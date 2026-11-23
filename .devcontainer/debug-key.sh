#!/usr/bin/env bash
# Keeps the debug signing key on the emulator volume (~/.android-emu), which survives container
# rebuilds and is shared by all app projects. Without this, a rebuild makes a new random key and
# the phone refuses the next debug build as an update (signatures do not match).
set -euo pipefail
kept="$HOME/.android-emu/debug.keystore"
local="$HOME/.android/debug.keystore"
mkdir -p "$HOME/.android"
if [ ! -f "$kept" ]; then
  if [ -f "$local" ] && [ ! -L "$local" ]; then
    cp "$local" "$kept"
  else
    keytool -genkeypair -keystore "$kept" -storepass android -keypass android \
      -alias androiddebugkey -dname "CN=Android Debug,O=Android,C=US" \
      -keyalg RSA -keysize 2048 -validity 10000 > /dev/null
  fi
fi
ln -sf "$kept" "$local"
