@echo off
rem Runs on Windows (not in the dev container). Starts the adb server so that adb in the
rem dev container can reach phones (USB and wireless debugging) and emulators on this PC.
rem Keep this window open while you work; close it (or press Ctrl+C) to stop the server.
rem
rem The server listens on all network interfaces. If Windows Firewall asks, allow access
rem on PRIVATE networks only. Don't leave it running on public Wi-Fi.
rem See docs/03-dev-setup.md.

where adb >nul 2>nul
if errorlevel 1 (
  echo adb not found. Install Android platform-tools: winget install Google.PlatformTools
  pause
  exit /b 1
)

adb kill-server >nul 2>nul
echo Starting adb server for the dev container on port 5037 ...
adb -a -P 5037 nodaemon server start
