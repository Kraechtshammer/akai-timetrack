#!/usr/bin/env bash
# Installed as /opt/android-sdk/platform-tools/adb in the dev container; the real adb is adb-real.
#
# Uses the adb server on Windows (scripts/windows/start-adb-server.cmd) when it's running, so the
# container sees USB phones, wireless-debugging phones and emulators attached to Windows. When it
# isn't running, adb falls back to its own server inside the container (wireless debugging still
# works then, USB doesn't), instead of failing and taking the Flutter tooling down with it.
#
# Finding Windows from the container:
#   Docker Desktop:          host.docker.internal
#   Docker Engine in WSL 2:  the WSL VM's default gateway (container runs with --network=host)
#
# Overrides: set ADB_SERVER_SOCKET yourself to force a server, or ADB_MODE=local to never use Windows.
real="$(dirname "$(readlink -f "$0")")/adb-real"
port="${ADB_WINDOWS_PORT:-5037}"
# An empty ADB_SERVER_SOCKET makes adb fail ("unknown socket specification"); treat it as unset.
[ -n "${ADB_SERVER_SOCKET:-}" ] || unset ADB_SERVER_SOCKET

if [ -z "${ADB_SERVER_SOCKET:-}" ] && [ "${ADB_MODE:-auto}" != "local" ]; then
  host="$(getent hosts host.docker.internal 2>/dev/null | awk '{print $1; exit}')"
  [ -n "$host" ] || host="$(ip route 2>/dev/null | awk '/^default/ {print $3; exit}')"
  if [ -n "$host" ] && timeout 1 bash -c "exec 3<>/dev/tcp/$host/$port" 2>/dev/null; then
    export ADB_SERVER_SOCKET="tcp:$host:$port"
  fi
fi

# The container's own fallback server gets a different port, so (with --network=host on WSL) it
# never occupies port 5037 that the Windows adb server needs.
[ -n "${ADB_SERVER_SOCKET:-}" ] || export ANDROID_ADB_SERVER_PORT="${ANDROID_ADB_SERVER_PORT:-5039}"

exec "$real" "$@"
