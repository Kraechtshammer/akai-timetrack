import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';
import '../domain/app_update.dart';
import '../platform/app_update.dart';
import 'providers.dart';

enum UpdatePhase { idle, checking, downloading, installing }

enum UpdateProblem {
  /// GitHub couldn't be reached.
  checkFailed,
  downloadFailed,

  /// "Install unknown apps" is still off for TimeTrack.
  noPermission,

  /// The user cancelled Android's install dialog.
  installAborted,

  /// Android refused the APK (e.g. signed with another key).
  installFailed,
}

@immutable
class UpdateState {
  const UpdateState({
    this.installed,
    this.latest,
    this.phase = UpdatePhase.idle,
    this.progress = 0,
    this.apkReady = false,
    this.filesSize = 0,
    this.lastCheck,
    this.problem,
    this.problemMessage,
  });

  final AppVersion? installed;

  /// A release newer than the installed version, if any.
  final ReleaseInfo? latest;
  final UpdatePhase phase;

  /// Download progress, 0…1.
  final double progress;

  /// The APK of [latest] is downloaded completely.
  final bool apkReady;

  /// All downloaded update files, in bytes.
  final int filesSize;
  final DateTime? lastCheck;
  final UpdateProblem? problem;

  /// Android's reason for [UpdateProblem.installFailed].
  final String? problemMessage;

  bool get busy => phase != UpdatePhase.idle;
}

final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());

final updateProvider = NotifierProvider<UpdateController, UpdateState>(
  UpdateController.new,
);

/// Looks for updates (on start and on resume, at most every 6 hours, or by
/// hand), downloads the APK and starts Android's installer. The APK stays
/// until the new version runs (then [checkIfDue] deletes it) or the user
/// deletes it, so "restart update" needn't download it again.
class UpdateController extends Notifier<UpdateState> {
  UpdateService get _service => ref.read(updateServiceProvider);
  SettingsRepository get _settings => ref.read(servicesProvider).settings;

  var _cleanedUp = false;

  /// The update waits for the user to allow installing apps.
  var _awaitingPermission = false;

  @override
  UpdateState build() {
    final sub = _service.installResults.listen(_onInstallResult);
    ref.onDispose(sub.cancel);
    return const UpdateState();
  }

  void _set({
    AppVersion? installed,
    ReleaseInfo? Function()? latest,
    UpdatePhase? phase,
    double? progress,
    bool? apkReady,
    int? filesSize,
    DateTime? lastCheck,
    UpdateProblem? Function()? problem,
    String? problemMessage,
  }) {
    final s = state;
    final newProblem = problem == null ? s.problem : problem();
    state = UpdateState(
      installed: installed ?? s.installed,
      latest: latest == null ? s.latest : latest(),
      phase: phase ?? s.phase,
      progress: progress ?? s.progress,
      apkReady: apkReady ?? s.apkReady,
      filesSize: filesSize ?? s.filesSize,
      lastCheck: lastCheck ?? s.lastCheck,
      problem: newProblem,
      problemMessage: newProblem == null
          ? null
          : problemMessage ?? s.problemMessage,
    );
  }

  Future<AppVersion?> _installed() async {
    if (state.installed != null) return state.installed;
    final version = await _service.installedVersion();
    _set(installed: version);
    return version;
  }

  Future<void> _refreshFiles() async {
    final latest = state.latest;
    _set(
      apkReady: latest != null && await _service.downloaded(latest) != null,
      filesSize: await _service.filesSize(),
    );
  }

  /// On start and when the app comes back: deletes the APK of an update
  /// that has been installed meanwhile, and checks if the last check is
  /// [updateCheckInterval] ago.
  Future<void> checkIfDue() async {
    if (state.busy) return;
    try {
      final installed = await _installed();
      if (!_cleanedUp && installed != null) {
        _cleanedUp = true;
        await _service.cleanUp(installed);
      }
      final last = DateTime.tryParse(
        await _settings.status(SettingsRepository.lastUpdateCheck) ?? '',
      );
      if (last != null) _set(lastCheck: last);
      if (updateCheckDue(last, DateTime.now())) {
        await check();
      } else {
        await _refreshFiles();
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  /// Looks for a newer release now. Returns false if GitHub couldn't be
  /// reached.
  Future<bool> check() async {
    if (state.busy) return false;
    _set(phase: UpdatePhase.checking, problem: () => null);
    var ok = true;
    try {
      final installed = await _installed();
      final release = await _service.fetchLatest();
      final now = DateTime.now();
      await _settings.setStatus(
        SettingsRepository.lastUpdateCheck,
        now.toIso8601String(),
      );
      _set(
        lastCheck: now,
        latest: () =>
            release != null && installed != null && release.version > installed
            ? release
            : null,
      );
    } catch (e) {
      debugPrint('Update check failed: $e');
      ok = false;
      _set(problem: () => UpdateProblem.checkFailed);
    }
    await _refreshFiles();
    _set(phase: UpdatePhase.idle);
    return ok;
  }

  /// Whether the popup should show for the found update: once per version.
  Future<bool> popupDue() async {
    final latest = state.latest;
    if (latest == null) return false;
    final shown = AppVersion.tryParse(
      await _settings.status(SettingsRepository.updatePopupShown) ?? '',
    );
    return shown == null || latest.version > shown;
  }

  Future<void> markPopupShown() async {
    final latest = state.latest;
    if (latest == null) return;
    await _settings.setStatus(
      SettingsRepository.updatePopupShown,
      '${latest.version}',
    );
  }

  /// Downloads the APK if needed and starts the installer. Also the
  /// "restart update" button: it abandons an unfinished install first.
  Future<void> install() async {
    final latest = state.latest;
    if (latest == null || state.phase == UpdatePhase.downloading) return;
    _set(problem: () => null);
    try {
      if (!await _service.canInstall()) {
        // Continues in [resumed] once the user comes back from Settings.
        _awaitingPermission = true;
        await _service.openInstallPermission();
        return;
      }
      var apk = await _service.downloaded(latest);
      if (apk == null) {
        _set(phase: UpdatePhase.downloading, progress: 0);
        try {
          apk = await _service.download(
            latest,
            // Whole percents are enough and spare the UI ~400 rebuilds.
            (p) {
              if ((p * 100).floor() != (state.progress * 100).floor()) {
                _set(progress: p);
              }
            },
          );
        } catch (e) {
          debugPrint('Update download failed: $e');
          _set(
            phase: UpdatePhase.idle,
            problem: () => UpdateProblem.downloadFailed,
          );
          await _refreshFiles();
          return;
        }
        await _refreshFiles();
      }
      _set(phase: UpdatePhase.installing);
      await _service.install(apk);
      // Android now asks the user. If they confirm, the app is stopped and
      // replaced; otherwise [_onInstallResult] gets the answer.
    } on PlatformException catch (e) {
      debugPrint('Update install failed: $e');
      _set(
        phase: UpdatePhase.idle,
        problem: () => UpdateProblem.installFailed,
        problemMessage: e.message,
      );
    } on FileSystemException catch (e) {
      debugPrint('Update file failed: $e');
      _set(
        phase: UpdatePhase.idle,
        problem: () => UpdateProblem.downloadFailed,
      );
    }
  }

  void _onInstallResult(InstallResult result) {
    if (result.status == InstallResult.success) {
      _set(phase: UpdatePhase.idle);
      return;
    }
    _set(
      phase: UpdatePhase.idle,
      problem: () => result.wasAborted
          ? UpdateProblem.installAborted
          : UpdateProblem.installFailed,
      problemMessage: result.message,
    );
  }

  /// The app came back to the foreground.
  Future<void> resumed() async {
    if (_awaitingPermission) {
      _awaitingPermission = false;
      if (await _service.canInstall()) {
        await install();
      } else {
        _set(problem: () => UpdateProblem.noPermission);
      }
      return;
    }
    await checkIfDue();
  }

  /// Deletes all downloaded update files (also while an install hangs).
  Future<void> deleteFiles() async {
    if (state.phase == UpdatePhase.downloading) return;
    await _service.deleteAll();
    _set(phase: UpdatePhase.idle);
    await _refreshFiles();
  }
}
