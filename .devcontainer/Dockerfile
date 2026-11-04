# Dev container for TimeTrack: Flutter SDK + Android SDK (no emulator, see docs/03-dev-setup.md).
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Pinned for reproducible builds. To upgrade, change the version and rebuild the container.
# Current versions: https://docs.flutter.dev/release/archive
ARG FLUTTER_VERSION=3.47.9
ARG ANDROID_CMDLINE_TOOLS=13114758
ARG ANDROID_PLATFORM=android-36
ARG ANDROID_BUILD_TOOLS=36.0.0

ENV ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    FLUTTER_ROOT=/opt/flutter \
    PUB_CACHE=/home/vscode/.pub-cache
ENV PATH=/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:/home/vscode/.pub-cache/bin:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:${PATH}

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openjdk-17-jdk-headless unzip xz-utils zip curl git jq ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /opt/android-sdk /opt/flutter \
 && chown -R vscode:vscode /opt/android-sdk /opt/flutter

USER vscode

# Android SDK: command-line tools, platform tools (adb), one platform and build tools.
# Anything else Gradle needs (e.g. the NDK) is downloaded by the warm-up build below.
RUN curl -fsSL -o /tmp/clt.zip \
      "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS}_latest.zip" \
 && mkdir -p "$ANDROID_HOME/cmdline-tools" \
 && unzip -q /tmp/clt.zip -d "$ANDROID_HOME/cmdline-tools" \
 && mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" \
 && rm /tmp/clt.zip \
 && (yes | sdkmanager --licenses > /dev/null) \
 && sdkmanager --install "platform-tools" "platforms;${ANDROID_PLATFORM}" "build-tools;${ANDROID_BUILD_TOOLS}" > /dev/null

# Flutter SDK from the official release archive.
RUN archive=$(curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json \
      | jq -r --arg v "$FLUTTER_VERSION" \
          '.releases[] | select(.channel == "stable" and .version == $v and .dart_sdk_arch == "x64") | .archive' \
      | head -n 1) \
 && test -n "$archive" \
 && curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/$archive" | tar -xJ -C /opt \
 && git config --global --add safe.directory /opt/flutter \
 && flutter --disable-analytics \
 && dart --disable-analytics \
 && flutter precache --android \
 && (yes | flutter doctor --android-licenses > /dev/null) \
 && flutter doctor -v

# Warm-up build: makes Gradle, the Android Gradle plugin, the NDK and Flutter's Android
# artifacts part of the image, so the first real build doesn't download gigabytes.
RUN cd /tmp \
 && flutter create --platforms android --project-name warmup warmup > /dev/null \
 && cd warmup \
 && flutter build apk --debug \
 && cd / && rm -rf /tmp/warmup

# adb wrapper: uses the adb server on Windows when it's running, otherwise a local one
# (see adb-wrapper.sh). Kept last so changing it doesn't invalidate the big layers above.
# `ip` (for finding Windows from Docker in WSL) comes with the base image.
RUN mv "$ANDROID_HOME/platform-tools/adb" "$ANDROID_HOME/platform-tools/adb-real"
COPY --chown=vscode:vscode --chmod=755 adb-wrapper.sh /opt/android-sdk/platform-tools/adb

# Android emulator (scripts/emulator.sh): the libraries its window needs. The emulator itself and
# the Android image are downloaded on demand into the volume at ~/.android-emu, not into the image.
USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libpulse0 libgl1 libegl1 libnss3 libnspr4 libxcomposite1 libxcursor1 libxi6 libxtst6 \
      libasound2t64 libxdamage1 libxrandr2 libxkbfile1 libxkbcommon0 libxkbcommon-x11-0 \
      libx11-xcb1 libxcb-cursor0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
      libxcb-render-util0 libxcb-shape0 libxcb-xinerama0 libxcb-xkb1 libdbus-1-3 \
      libfontconfig1 libbsd0 libsm6 libice6 \
 && rm -rf /var/lib/apt/lists/*
USER vscode
# Created here so the Docker volume mounted on it starts out owned by vscode.
RUN mkdir -p /home/vscode/.android-emu
