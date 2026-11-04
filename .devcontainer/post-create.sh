#!/usr/bin/env bash
# Runs once after the container is created (postCreateCommand). Each step runs even if an
# earlier one failed. Any failed step is listed at the end and can be rerun on its own.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

failed=()
step() {
  echo "==> $1"
  shift
  "$@" || failed+=("$*")
}

step "Installing the Claude Code CLI" npm install -g @anthropic-ai/claude-code
# Android only: hide the Linux-desktop and web targets from the device picker and `flutter doctor`.
step "Configuring Flutter for Android only" flutter config --no-enable-linux-desktop --no-enable-web
step "Fetching Flutter packages" flutter pub get

if [ ${#failed[@]} -gt 0 ]; then
  echo >&2
  echo "These setup steps failed, rerun them in a terminal:" >&2
  printf '  %s\n' "${failed[@]}" >&2
  exit 1
fi
