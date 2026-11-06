import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/app_update.dart';

/// Where the releases come from. The repository is public, so no token.
/// For testing, a build can point elsewhere with
/// `--dart-define=UPDATE_RELEASE_URL=...` (scripts/update_test_server.dart).
const _latestReleaseUrl = String.fromEnvironment(
  'UPDATE_RELEASE_URL',
  defaultValue: 'https://api.github.com/repos/Kraechtshammer/akai-timetrack/releases/latest',
);

/// The recent releases, for "What's new" after an update. Overridden with
/// `--dart-define=UPDATE_RELEASES_URL=...` for tests.
const _releasesUrl = String.fromEnvironment(
  'UPDATE_RELEASES_URL',
  defaultValue: 'https://api.github.com/repos/Kraechtshammer/akai-timetrack/releases?per_page=20',
);

/// How an install ended (PackageInstaller's status codes, sent by
/// MainActivity.kt). Success is rarely seen: Android stops the app to
/// replace it.
class InstallResult {
  const InstallResult(this.status, this.message);

  static const success = 0;
  static const aborted = 3;

  final int status;
  final String? message;

  bool get wasAborted => status == aborted;
}

/// Checks GitHub for a newer release, downloads its APK into the app's
/// files and hands it to Android's installer (MainActivity.kt, channel
/// `de.garten.akaitimetrack/updater`). UI isolate only.
class UpdateService {
  UpdateService() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'installResult') {
        final args = Map<String, dynamic>.from(call.arguments as Map);
        _results.add(
          InstallResult(args['status'] as int, args['message'] as String?),
        );
      }
    });
  }

  static const _channel = MethodChannel('de.garten.akaitimetrack/updater');

  final _results = StreamController<InstallResult>.broadcast();

  /// Install results, after [install] (not when the user confirmed the
  /// update: then the app is stopped).
  Stream<InstallResult> get installResults => _results.stream;

  Future<AppVersion?> installedVersion() async => AppVersion.tryParse(
    await _channel.invokeMethod<String>('installedVersion') ?? '',
  );

  /// The latest release, or null if there is none with an APK. Throws on
  /// network errors.
  Future<ReleaseInfo?> fetchLatest() async {
    final json = await _getJson(_latestReleaseUrl);
    return json is Map<String, dynamic> ? ReleaseInfo.fromJson(json) : null;
  }

  /// The recent releases (GitHub lists the newest 20). Throws on network
  /// errors.
  Future<List<ReleaseNotes>> fetchReleases() async {
    final json = await _getJson(_releasesUrl);
    if (json is! List) return const [];
    return [
      for (final release in json.whereType<Map<String, dynamic>>())
        ?ReleaseNotes.fromJson(release),
    ];
  }

  /// GitHub's answer, or null for 404 (no release yet).
  Future<Object?> _getJson(String url) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set(HttpHeaders.userAgentHeader, 'TimeTrack-App');
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      if (response.statusCode == HttpStatus.notFound) {
        await response.drain<void>();
        return null;
      }
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw HttpException('GitHub answered ${response.statusCode}');
      }
      return jsonDecode(await response.transform(utf8.decoder).join());
    } finally {
      client.close();
    }
  }

  Future<Directory> _dir() async {
    final dir = Directory(
      '${(await getApplicationSupportDirectory()).path}/updates',
    );
    return dir.create(recursive: true);
  }

  /// The complete APK of [release], if it was downloaded already.
  Future<File?> downloaded(ReleaseInfo release) async {
    final file = File('${(await _dir()).path}/${apkFileName(release.version)}');
    return await file.exists() && await file.length() == release.apkSize
        ? file
        : null;
  }

  /// Downloads the APK of [release]. [onProgress] gets 0…1.
  Future<File> download(
    ReleaseInfo release,
    void Function(double progress) onProgress,
  ) async {
    final target = File(
      '${(await _dir()).path}/${apkFileName(release.version)}',
    );
    final part = File('${target.path}.part');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      // GitHub redirects to its file storage; HttpClient follows that.
      final request = await client.getUrl(Uri.parse(release.apkUrl));
      request.headers.set(HttpHeaders.userAgentHeader, 'TimeTrack-App');
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw HttpException('Download answered ${response.statusCode}');
      }
      final sink = part.openWrite();
      var received = 0;
      try {
        // A stalled connection fails instead of hanging forever.
        await for (final chunk in response.timeout(
          const Duration(seconds: 30),
        )) {
          sink.add(chunk);
          received += chunk.length;
          onProgress((received / release.apkSize).clamp(0, 1));
        }
      } finally {
        await sink.close();
      }
      if (received != release.apkSize) {
        await part.delete();
        throw const HttpException('Download incomplete');
      }
      return await part.rename(target.path);
    } catch (_) {
      if (await part.exists()) await part.delete();
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Deletes APKs of the installed version or older and broken downloads,
  /// i.e. what's left after an update. Call when no download runs.
  Future<void> cleanUp(AppVersion installed) async {
    final files = {
      for (final file in await (await _dir()).list().toList())
        if (file is File) file.uri.pathSegments.last: file,
    };
    for (final name in updateFilesToDelete(files.keys, installed)) {
      await files[name]!.delete();
    }
  }

  /// The size of all downloaded update files in bytes (0 if none).
  Future<int> filesSize() async {
    var size = 0;
    await for (final entity in (await _dir()).list()) {
      if (entity is File) size += await entity.length();
    }
    return size;
  }

  /// Deletes all downloaded update files (the "delete update file" button).
  Future<void> deleteAll() async {
    final dir = await _dir();
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// Whether the user allowed TimeTrack to install apps.
  Future<bool> canInstall() async =>
      await _channel.invokeMethod<bool>('canInstall') ?? false;

  /// Opens Android's "Install unknown apps" switch for TimeTrack.
  Future<void> openInstallPermission() =>
      _channel.invokeMethod<void>('openInstallPermission');

  /// Hands [apk] to Android's installer, which asks the user to confirm.
  /// Abandons an earlier, unfinished install first.
  Future<void> install(File apk) =>
      _channel.invokeMethod<void>('install', {'path': apk.path});
}
