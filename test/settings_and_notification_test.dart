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

    test('restaurant: round trip, empty on a fresh install, AKAI on older '
        'installs', () {
      final stored = {
        for (final MapEntry(:key, :value) in const AppSettings(
          restaurant: 'Da Mario',
        ).toMap().entries)
          key: ?value,
      };
      expect(AppSettings.fromMap(stored).restaurant, 'Da Mario');
      expect(AppSettings.fromMap(const {}).restaurant, '');
      expect(
        AppSettings.fromMap(const {'onboardingDone': 'true'}).restaurant,
        'AKAI',
      );
      // Cleared on purpose: stays empty.
      expect(
        AppSettings.fromMap(const {'onboardingDone': 'true', 'restaurant': ''})
            .restaurant,
        '',
      );
    });

    test('daily pool: off on a fresh install, on for older installs, '
        'stored once saved', () {
      Map<String, String> stored(AppSettings s) => {
        for (final MapEntry(:key, :value) in s.toMap().entries) key: ?value,
      };
      expect(AppSettings.fromMap(const {}).tipPool, isFalse);
      expect(
        AppSettings.fromMap(const {'onboardingDone': 'true'}).tipPool,
        isTrue,
      );
      // The setup's last step saves every key, so a fresh install keeps
      // the pool off after onboardingDone turns true.
      final afterSetup = stored(
        AppSettings.fromMap(const {}).copyWith(onboardingDone: true),
      );
      expect(AppSettings.fromMap(afterSetup).tipPool, isFalse);
      // Turned off on an older install: stays off.
      final off = stored(
        AppSettings.fromMap(const {'onboardingDone': 'true'})
            .copyWith(tipPool: false),
      );
      expect(AppSettings.fromMap(off).tipPool, isFalse);
    });

    test('defaults: AKAI red and icons', () {
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
