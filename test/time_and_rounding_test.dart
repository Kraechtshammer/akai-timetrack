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
}
