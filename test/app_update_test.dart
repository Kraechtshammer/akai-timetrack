import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/data/settings_repository.dart';
import 'package:akai_timetrack/domain/app_update.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

AppVersion v(String text) => AppVersion.tryParse(text)!;

void main() {
  group('AppVersion', () {
    test('parses tags, version names and build numbers', () {
      expect(v('v1.0.2').parts, [1, 0, 2]);
      expect(v('1.0.2').parts, [1, 0, 2]);
      expect(v('1.0.2+3').parts, [1, 0, 2]);
      expect(v(' v2 ').parts, [2]);
      expect(AppVersion.tryParse('latest'), isNull);
      expect(AppVersion.tryParse(''), isNull);
    });

    test('compares numerically, missing parts count as 0', () {
      expect(v('1.0.10') > v('1.0.9'), isTrue);
      expect(v('1.1') > v('1.0.9'), isTrue);
      expect(v('1.0') == v('1.0.0'), isTrue);
      expect(v('1.0').hashCode, v('1.0.0').hashCode);
      expect(v('1.0.1') <= v('1.0.1'), isTrue);
      expect(v('1.0.2') <= v('1.0.1'), isFalse);
      expect(v('1.0.2').toString(), '1.0.2');
    });
  });

  group('ReleaseInfo.fromJson', () {
    Map<String, dynamic> release({
      String tag = 'v1.0.2',
      bool draft = false,
      bool prerelease = false,
      List<Map<String, dynamic>>? assets,
    }) => {
      'tag_name': tag,
      'draft': draft,
      'prerelease': prerelease,
      'body': '## New\n\n- Something\n',
      'assets':
          assets ??
          [
            {
              'name': 'notes.txt',
              'size': 1,
              'browser_download_url': 'https://x/notes.txt',
            },
            {
              'name': 'timetrack-1.0.2.apk',
              'size': 23456789,
              'browser_download_url': 'https://x/timetrack-1.0.2.apk',
            },
          ],
    };

    test('takes the version, the notes and the APK asset', () {
      final info = ReleaseInfo.fromJson(release())!;
      expect(info.version, v('1.0.2'));
      expect(info.apkUrl, 'https://x/timetrack-1.0.2.apk');
      expect(info.apkSize, 23456789);
      expect(info.notes, contains('Something'));
    });

    test('ignores drafts, pre-releases, bad tags and releases without APK', () {
      expect(ReleaseInfo.fromJson(release(draft: true)), isNull);
      expect(ReleaseInfo.fromJson(release(prerelease: true)), isNull);
      expect(ReleaseInfo.fromJson(release(tag: 'nightly')), isNull);
      expect(ReleaseInfo.fromJson(release(assets: [])), isNull);
    });
  });

  group('userNotes', () {
    test('keeps New, Fixed and Improved, drops the rest', () {
      const body = '''
## New

- Export the month's hours, grouped by week
- In-app updates

## Fixed

- **Snack bar** closes again

## Improved

- Wavy bar in the [month card](https://example.com)

## Behind the scenes

- Move the repo into WSL

All commits: [v1.0.0...v1.0.1](https://github.com/x/y/compare/v1.0.0...v1.0.1)
''';
      final sections = userNotes(body);
      expect(sections.map((s) => s.kind), [
        NotesKind.added,
        NotesKind.fixed,
        NotesKind.improved,
      ]);
      expect(sections[0].items, [
        "Export the month's hours, grouped by week",
        'In-app updates',
      ]);
      expect(sections[1].items, ['Snack bar closes again']);
      expect(sections[2].items, ['Wavy bar in the month card']);
    });

    test('a release with only behind-the-scenes changes has no notes', () {
      expect(userNotes('## Behind the scenes\n\n- CI\n'), isEmpty);
      expect(userNotes(''), isEmpty);
    });

    test('a hand-written text without headings is shown as it is', () {
      final sections = userNotes('Kleine Korrekturen.\n- Und **mehr**\n');
      expect(sections.single.kind, NotesKind.other);
      expect(sections.single.items, ['Kleine Korrekturen.', 'Und mehr']);
    });
  });

  test('updateFilesToDelete keeps only a newer APK', () {
    final names = [
      apkFileName(v('1.0.1')),
      apkFileName(v('1.0.0')),
      apkFileName(v('1.0.2')),
      'timetrack-1.0.3.apk.part',
      'something-else.txt',
    ];
    expect(updateFilesToDelete(names, v('1.0.1')), [
      'timetrack-1.0.1.apk',
      'timetrack-1.0.0.apk',
      'timetrack-1.0.3.apk.part',
    ]);
  });

  test('updateCheckDue: first time, after 6 hours, or a clock set back', () {
    final now = DateTime(2026, 11, 5, 12);
    expect(updateCheckDue(null, now), isTrue);
    expect(updateCheckDue(now.subtract(const Duration(hours: 5)), now), false);
    expect(updateCheckDue(now.subtract(const Duration(hours: 6)), now), true);
    expect(updateCheckDue(now.add(const Duration(hours: 1)), now), isTrue);
  });

  test(
    'update status keys are stored but do not rebuild the settings',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = SettingsRepository(db);
      final emitted = <Object>[];
      final sub = repo.watch().listen(emitted.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();
      final before = emitted.length;

      await repo.setStatus(SettingsRepository.lastUpdateCheck, '2026-11-05');
      await repo.setStatus(SettingsRepository.updatePopupShown, '1.0.2');
      await pumpEventQueue();

      expect(await repo.status(SettingsRepository.updatePopupShown), '1.0.2');
      expect(
        await repo.status(SettingsRepository.lastUpdateCheck),
        '2026-11-05',
      );
      expect(emitted.length, before);
    },
  );
}
