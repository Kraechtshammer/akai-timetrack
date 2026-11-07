import 'package:akai_timetrack/core/time.dart';
import 'package:akai_timetrack/domain/rounding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DateTime at(int h, int m, [int s = 0]) => DateTime(2026, 11, 4, h, m, s);

  group('roundShift', () {
    test('nearest quarter rounds both ends to the closest quarter', () {
      final (start, end) = roundShift(
        at(17, 32),
        at(22, 41),
        RoundingMode.nearestQuarter,
      );
      expect(start, at(17, 30));
      expect(end, at(22, 45));
    });

    test('exactly 7:30 past a quarter rounds up', () {
      final (start, _) = roundShift(
        at(12, 7, 30),
        at(16, 0),
        RoundingMode.nearestQuarter,
      );
      expect(start, at(12, 15));
      final (start2, _) = roundShift(
        at(12, 7, 29),
        at(16, 0),
        RoundingMode.nearestQuarter,
      );
      expect(start2, at(12, 0));
    });

    test('in favour: start down, end up', () {
      final (start, end) = roundShift(
        at(12, 10),
        at(22, 50),
        RoundingMode.inFavour,
      );
      expect(start, at(12, 0));
      expect(end, at(23, 0));
    });

    test('strict: start up, end down', () {
      final (start, end) = roundShift(
        at(12, 10),
        at(22, 50),
        RoundingMode.strict,
      );
      expect(start, at(12, 15));
      expect(end, at(22, 45));
    });

    test('a very short shift still lasts 15 minutes', () {
      final (start, end) = roundShift(
        at(12, 1),
        at(12, 5),
        RoundingMode.nearestQuarter,
      );
      expect(start, at(12, 0));
      expect(end, at(12, 15));
    });
  });

  group('time helpers', () {
    test('ISO week numbers', () {
      expect(isoWeekNumber(DateTime(2026, 11, 4)), 45);
      expect(isoWeekNumber(DateTime(2026, 10, 26)), 44);
      expect(isoWeekNumber(DateTime(2027, 1, 1)), 53); // Friday, week of 2026
      expect(isoWeekNumber(DateTime(2027, 1, 4)), 1);
    });

    test('weekStart is Monday', () {
      expect(weekStart(DateTime(2026, 11, 8, 15)), DateTime(2026, 11, 2));
      expect(weekStart(DateTime(2026, 11, 2)), DateTime(2026, 11, 2));
    });

    test('timesOn moves an end before the start to the next day', () {
      final (start, end) = timesOn(DateTime(2026, 11, 4), 22 * 60, 2 * 60);
      expect(start, DateTime(2026, 11, 4, 22));
      expect(end, DateTime(2026, 11, 5, 2));
    });
  });

  // These only catch a daylight saving bug when the tests run in a zone that
  // has one: CI and the VS Code test task set TZ=Europe/Berlin.
  group('across daylight saving changes', () {
    test('ISO week numbers in summer time', () {
      expect(isoWeekNumber(DateTime(2026, 3, 30)), 14); // first summer Monday
      expect(isoWeekNumber(DateTime(2026, 4, 15)), 16);
      expect(isoWeekNumber(DateTime(2026, 7, 1)), 27);
      expect(isoWeekNumber(DateTime(2026, 10, 25)), 43); // last summer day
    });

    test('weekStart over the clock change is midnight on Monday', () {
      expect(weekStart(DateTime(2026, 3, 29, 12)), DateTime(2026, 3, 23));
      expect(weekStart(DateTime(2026, 10, 25, 12)), DateTime(2026, 10, 19));
      expect(weekStart(DateTime(2026, 3, 30, 12)), DateTime(2026, 3, 30));
    });

    test('daysBetween counts calendar days', () {
      expect(daysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
      expect(daysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
      expect(daysBetween(DateTime(2026, 1, 1), DateTime(2027, 1, 1)), 365);
    });

    test(
      'an overnight shift ends at the right time on clock-change nights',
      () {
        // The clocks change early on these Sundays, so a shift that starts
        // that evening ends 23 or 25 hours after the previous midnight.
        final (_, springEnd) = timesOn(DateTime(2026, 3, 29), 18 * 60, 60);
        expect(springEnd, DateTime(2026, 3, 30, 1));
        final (_, autumnEnd) = timesOn(DateTime(2026, 10, 25), 18 * 60, 60);
        expect(autumnEnd, DateTime(2026, 10, 26, 1));
      },
    );
  });
}
