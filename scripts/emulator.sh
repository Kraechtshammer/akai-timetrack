#!/usr/bin/env bash
# Android emulator inside the dev container. Needs Docker in WSL 2: KVM (/dev/kvm) for speed and
# WSLg for the window. Everything it downloads lives in the Docker volume mounted at
# ~/.android-emu, so it survives container rebuilds. See docs/03-dev-setup.md.
#
#   scripts/emulator.sh setup   one time: emulator + Android image (~3 GB download), creates the device
#   scripts/emulator.sh start   opens the emulator window and waits until Android has booted
#   scripts/emulator.sh stop    shuts the emulator down
#   scripts/emulator.sh wipe    factory reset (deletes apps, data and the Google sign-in)
set -euo pipefail

EMU_ROOT="${EMU_ROOT:-$HOME/.android-emu}"   # separate SDK root, on the Docker volume
API="${EMU_API:-36}"
IMAGE="system-images;android-${API};google_apis_playstore;x86_64"
AVD="${EMU_AVD:-TimeTrack_Pixel}"
DEVICE_PROFILE="${EMU_DEVICE:-pixel_7_pro}"
LOG="$EMU_ROOT/emulator.log"
CONSOLE_PORT=5554
ADB_PORT=$((CONSOLE_PORT + 1))
export ANDROID_AVD_HOME="$EMU_ROOT/avd"

die() { echo "Error: $*" >&2; exit 1; }

# Prints the adb serial the emulator has right now, if any. With the container's own adb server
# the emulator registers itself (emulator-5554); with the Windows adb server we connect to it via
# localhost, which WSL forwards to Windows (127.0.0.1:5555).
serial() {
  adb devices | awk -v a="emulator-$CONSOLE_PORT" -v b="127.0.0.1:$ADB_PORT" \
    '($1 == a || $1 == b) && $2 != "offline" {print $1; exit}'
}

port_open() { timeout 1 bash -c "exec 3<>/dev/tcp/${2:-127.0.0.1}/$1" 2>/dev/null; }

# True when adb goes through the Windows adb server (same check as .devcontainer/adb-wrapper.sh).
using_windows_adb() {
  [ "${ADB_MODE:-auto}" != "local" ] || return 1
  if [ -n "${ADB_SERVER_SOCKET:-}" ]; then return 0; fi
  local host
  host="$(getent hosts host.docker.internal 2>/dev/null | awk '{print $1; exit}')"
  [ -n "$host" ] || host="$(ip route 2>/dev/null | awk '/^default/ {print $3; exit}')"
  [ -n "$host" ] && port_open "${ADB_WINDOWS_PORT:-5037}" "$host"
}

setup() {
  mkdir -p "$EMU_ROOT" "$ANDROID_AVD_HOME"
  # Same licenses as the main SDK (accepted when the image was built)
  cp -rn "$ANDROID_HOME/licenses" "$EMU_ROOT/" 2>/dev/null || true
  echo "==> Downloading the emulator and $IMAGE (about 3 GB, this takes a while)"
  sdkmanager --sdk_root="$EMU_ROOT" --install "emulator" "$IMAGE" "cmdline-tools;latest"
  ln -sfn "$ANDROID_HOME/platform-tools" "$EMU_ROOT/platform-tools"

  echo "==> Creating the virtual device '$AVD' ($DEVICE_PROFILE, Android $API)"
  echo "no" | ANDROID_HOME="$EMU_ROOT" ANDROID_SDK_ROOT="$EMU_ROOT" \
    "$EMU_ROOT/cmdline-tools/latest/bin/avdmanager" create avd \
      --force --name "$AVD" --package "$IMAGE" --device "$DEVICE_PROFILE"

  cfg="$ANDROID_AVD_HOME/$AVD.avd/config.ini"
  set_cfg() { sed -i "/^$1=/d" "$cfg"; echo "$1=$2" >> "$cfg"; }
  set_cfg hw.keyboard yes            # type with the PC keyboard
  set_cfg hw.ramSize 4096
  set_cfg disk.dataPartition.size 8G
  set_cfg hw.gpu.enabled yes
  set_cfg hw.gpu.mode swiftshader_indirect
  set_cfg showDeviceFrame no
  echo
  echo "Done. Start it with the task 'Emulator: Start' (or: scripts/emulator.sh start)."
}

start() {
  [ -x "$EMU_ROOT/emulator/emulator" ] && [ -d "$ANDROID_AVD_HOME/$AVD.avd" ] \
    || die "the emulator isn't set up yet. Run the task 'Emulator: Set up (one time)' first."
  [ -e /dev/kvm ] || die "/dev/kvm is missing. The emulator needs Docker in WSL 2 (see docs/03-dev-setup.md)."
  [ -w /dev/kvm ] || sudo chmod 666 /dev/kvm
  [ -S /tmp/.X11-unix/X0 ] || die "no WSLg display at /tmp/.X11-unix/X0 (see docs/03-dev-setup.md)."

  if pgrep -f "qemu-system.*-avd $AVD" > /dev/null || port_open "$CONSOLE_PORT"; then
    echo "The emulator is already running."
  else
    echo "==> Starting the emulator (log: $LOG)"
    # After a crash or a killed emulator, the next start waits on a "send crash report?" dialog
    # before booting. Old crash data isn't useful here, so drop it.
    rm -rf /tmp/android-*/emu-crash-*.db 2>/dev/null || true
    ulimit -c 0   # no multi-GB core dumps in the project folder if it crashes
    cd "$EMU_ROOT"
    # ANDROID_ADB_SERVER_PORT: lets it register with the container's own adb server (see
    # .devcontainer/adb-wrapper.sh) when the Windows server isn't running.
    DISPLAY=:0 QT_QPA_PLATFORM=xcb ANDROID_ADB_SERVER_PORT=5039 \
    ANDROID_HOME="$EMU_ROOT" ANDROID_SDK_ROOT="$EMU_ROOT" \
      setsid nohup "$EMU_ROOT/emulator/emulator" -avd "$AVD" -port "$CONSOLE_PORT" \
        -gpu swiftshader_indirect -no-audio -no-boot-anim ${EMU_EXTRA_ARGS:-} \
        > "$LOG" 2>&1 < /dev/null &
  fi

  echo "==> Waiting for the emulator"
  for _ in $(seq 120); do port_open "$ADB_PORT" && break; sleep 1; done
  port_open "$ADB_PORT" || { tail -n 30 "$LOG" >&2; die "the emulator didn't start (log above)."; }

  if using_windows_adb; then
    # The Windows adb server reaches the emulator through WSL's localhost forwarding.
    adb connect "127.0.0.1:$ADB_PORT" > /dev/null
  fi
  # Otherwise the emulator registers itself with the container's adb server as emulator-5554.
  s=""
  for _ in $(seq 60); do s="$(serial)"; [ -n "$s" ] && break; sleep 1; done
  [ -n "$s" ] || die "adb can't see the emulator. Check 'adb devices' and the log at $LOG."

  echo "==> Waiting for Android to boot ($s)"
  adb -s "$s" wait-for-device
  for _ in $(seq 300); do
    [ "$(adb -s "$s" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] && break
    sleep 1
  done
  [ "$(adb -s "$s" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] \
    || die "Android didn't finish booting within 5 minutes (log: $LOG)."
  echo
  echo "Emulator ready as '$s'. Pick it in VS Code's device picker, then F5."
}

stop() {
  s="$(serial)"
  if [ -n "$s" ]; then
    adb -s "$s" emu kill > /dev/null 2>&1 || true
    adb disconnect "127.0.0.1:$ADB_PORT" > /dev/null 2>&1 || true
  fi
  for _ in $(seq 20); do pgrep -f "qemu-system.*-avd $AVD" > /dev/null || break; sleep 1; done
  pkill -f "qemu-system.*-avd $AVD" 2>/dev/null || true
  echo "Emulator stopped."
}

wipe() {
  stop
  EMU_EXTRA_ARGS="-wipe-data" start
}

case "${1:-}" in
  setup) setup ;;
  start) start ;;
  stop) stop ;;
  wipe) wipe ;;
  *) echo "Usage: $0 setup|start|stop|wipe" >&2; exit 2 ;;
esac
