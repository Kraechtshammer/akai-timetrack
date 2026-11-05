import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/domain/salary.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

WageRate rate(String validFrom, int cents) => WageRate(
  id: 'rate-$validFrom',
  validFrom: validFrom,
  hourlyCents: cents,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  final rates = [rate('2026-11-01', 1390), rate('2027-01-01', 1460)];

  group('rateOn', () {
    test('takes the newest rate that has started', () {
      expect(rateOn('2026-11-01', rates), 1390);
      expect(rateOn('2026-12-31', rates), 1390);
      expect(rateOn('2027-01-01', rates), 1460);
      expect(rateOn('2027-06-15', rates), 1460);
    });

    test('the first rate also counts before it starts', () {
      expect(rateOn('2026-03-10', rates), 1390);
    });

    test('is null without rates', () {
      expect(rateOn('2026-11-01', const []), isNull);
    });
  });

  group('ratesInMonth', () {
    test('one rate for a month without a change', () {
      expect(ratesInMonth(DateTime(2026, 12), rates), [rates[0]]);
      expect(ratesInMonth(DateTime(2027, 2), rates), [rates[1]]);
    });

    test('the first rate for months before it', () {
      expect(ratesInMonth(DateTime(2026, 5), rates), [rates[0]]);
    });

    test('a rate starting on the 1st replaces the old one', () {
      expect(ratesInMonth(DateTime(2027, 1), rates), [rates[1]]);
    });

    test('both rates when one starts during the month', () {
      final mid = [rate('2026-11-01', 1390), rate('2026-12-15', 1460)];
      expect(ratesInMonth(DateTime(2026, 12), mid), mid);
    });

    test('a first rate starting mid-month is listed once', () {
      final late = [rate('2026-11-15', 1390)];
      expect(ratesInMonth(DateTime(2026, 11), late), late);
    });

    test('empty without rates', () {
      expect(ratesInMonth(DateTime(2026, 11), const []), isEmpty);
    });
  });

  group('payForMonth', () {
    final now = DateTime(2026, 11, 18, 12);

    test('is null without a rate', () {
      final shifts = [testShift(day: DateTime(2026, 11, 2))];
      expect(payForMonth(shifts, const [], now), isNull);
    });

    test('earned counts recorded shifts, expected adds the rest', () {
      final shifts = [
        // Recorded: 4 h and 5.5 h - 0.5 h break = 9 h.
        testShift(
          day: DateTime(2026, 11, 2),
          type: ShiftType.lunch,
          planned: '12:00-16:00',
          actual: '12:00-16:00',
        ),
        testShift(
          day: DateTime(2026, 11, 3),
          actual: '17:30-23:00',
          breakMinutes: 30,
        ),
        // Missed (not recorded, in the past): 5.5 h planned.
        testShift(day: DateTime(2026, 11, 10)),
        // Planned: 5.5 h.
        testShift(day: DateTime(2026, 11, 20)),
      ];
      final pay = payForMonth(shifts, [rate('2026-11-01', 1400)], now)!;
      expect(pay.earnedMinutes, 9 * 60);
      expect(pay.earnedCents, 9 * 1400);
      expect(pay.expectedMinutes, 20 * 60);
      expect(pay.expectedCents, 20 * 1400);
    });

    test('a running shift counts as expected only', () {
      final running = testShift(
        day: DateTime(2026, 11, 18),
        type: ShiftType.lunch,
        planned: '12:00-16:00',
        rawStart: DateTime(2026, 11, 18, 11, 55),
      );
      final pay = payForMonth([running], [rate('2026-11-01', 1400)], now)!;
      expect(pay.earnedCents, 0);
      expect(pay.expectedCents, 4 * 1400);
    });

    test('each shift is paid at the rate of its day', () {
      final change = [rate('2026-11-01', 1200), rate('2026-11-16', 1500)];
      final shifts = [
        testShift(day: DateTime(2026, 11, 2), actual: '17:00-23:00'),
        testShift(day: DateTime(2026, 11, 16), actual: '17:00-23:00'),
      ];
      final pay = payForMonth(shifts, change, now)!;
      expect(pay.earnedCents, 6 * 1200 + 6 * 1500);
    });

    test('rounds cents once per rate, not per shift', () {
      // 3 × 20 min at 13,90 €/h: 3 × 4,633 € = 13,90 €, not 3 × 4,63 €.
      final shifts = [
        for (final d in [2, 3, 4])
          testShift(
            day: DateTime(2026, 11, d),
            planned: '17:00-17:20',
            actual: '17:00-17:20',
          ),
      ];
      final pay = payForMonth(shifts, [rate('2026-11-01', 1390)], now)!;
      expect(pay.earnedCents, 1390);
    });

    test('an empty month is zero', () {
      final pay = payForMonth(const [], [rate('2026-11-01', 1400)], now)!;
      expect(pay.earnedCents, 0);
      expect(pay.expectedCents, 0);
    });
  });
}
