import 'package:akai_timetrack/data/app_settings.dart';
import 'package:akai_timetrack/platform/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettings', () {
    test('new keys survive a round trip through the stored form', () {
      const settings = AppSettings(
        themeSeed: ThemeSeed.terracotta,
        weekMarks: WeekMarkStyle.bars,
      );
      final stored = {
        for (final MapEntry(:key, :value) in settings.toMap().entries)
          key: ?value,
      };
      final read = AppSettings.fromMap(stored);
      expect(read.themeSeed, ThemeSeed.terracotta);
      expect(read.weekMarks, WeekMarkStyle.bars);
    });

    test('defaults: AKAI-Rot and icons', () {
      final read = AppSettings.fromMap(const {});
      expect(read.themeSeed, ThemeSeed.akaiRed);
      expect(read.weekMarks, WeekMarkStyle.icons);
    });

    test('unknown values fall back to the defaults', () {
      final read = AppSettings.fromMap(const {
        'weekMarks': 'dots',
        'themeSeed': 'pink',
      });
      expect(read.weekMarks, WeekMarkStyle.icons);
      expect(read.themeSeed, ThemeSeed.akaiRed);
    });
  });

  group('running notification progress', () {
    final start = DateTime(2026, 11, 4, 17, 30);
    final end = DateTime(2026, 11, 4, 23);
    int at(int h, int m) => NotificationService.runningProgress(
      start,
      end,
      DateTime(2026, 11, 4, h, m),
    );

    test('runs from 0 at the start to full at the planned end', () {
      expect(at(17, 30), 0);
      expect(at(20, 15), 500);
      expect(at(23, 0), NotificationService.runningProgressSteps);
    });

    test('stays within bounds before the start and after the end', () {
      expect(at(17, 0), 0);
      expect(at(23, 45), NotificationService.runningProgressSteps);
    });

    test('an end before the start counts as full', () {
      expect(
        NotificationService.runningProgress(end, start, end),
        NotificationService.runningProgressSteps,
      );
    });
  });
}
