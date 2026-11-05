// Serves a fake "latest release" for testing the in-app update on the emulator.
//
//   dart run scripts/update_test_server.dart <apk> <version> [port]
//   adb reverse tcp:8765 tcp:8765
//
// The installed app must be older than <version>, built with
//   --dart-define=UPDATE_RELEASE_URL=http://127.0.0.1:8765/latest.json
// and signed with the same key as <apk> (two debug builds, for example).
// See docs/03-dev-setup.md, "Testing the in-app update".
import 'dart:convert';
import 'dart:io';

const _notes = '''## New

- Update the app from within the app (test release)

## Fixed

- **Snack bar** closes again

## Behind the scenes

- This section is not shown in the app

All commits: [v1.0.0...v1.0.1](https://example.com)
''';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln(
      'Usage: dart run scripts/update_test_server.dart <apk> <version> [port]',
    );
    exit(64);
  }
  final apk = File(args[0]);
  final version = args[1];
  final port = args.length > 2 ? int.parse(args[2]) : 8765;
  if (!apk.existsSync()) {
    stderr.writeln('No such file: ${apk.path}');
    exit(66);
  }
  final apkName = 'timetrack-$version.apk';
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln(
    'Serving $apkName (${apk.lengthSync()} bytes) as v$version on port $port',
  );

  await for (final request in server) {
    stdout.writeln('${request.method} ${request.uri}');
    final response = request.response;
    if (request.uri.path == '/latest.json') {
      response.headers.contentType = ContentType.json;
      response.write(
        jsonEncode({
          'tag_name': 'v$version',
          'draft': false,
          'prerelease': false,
          'body': _notes,
          'assets': [
            {
              'name': apkName,
              'size': apk.lengthSync(),
              'browser_download_url': 'http://127.0.0.1:$port/$apkName',
            },
          ],
        }),
      );
    } else if (request.uri.path == '/$apkName') {
      response.headers
        ..contentType = ContentType(
          'application',
          'vnd.android.package-archive',
        )
        ..contentLength = apk.lengthSync();
      await response.addStream(apk.openRead());
    } else {
      response.statusCode = HttpStatus.notFound;
    }
    await response.close();
  }
}
