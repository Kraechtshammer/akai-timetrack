import 'package:akai_timetrack/data/app_settings.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/domain/month_summary.dart';
import 'package:akai_timetrack/domain/reminder_planner.dart';
import 'package:akai_timetrack/domain/shift_info.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  final now = DateTime(2026, 11, 4, 16, 40);
  final recorded = testShift(
    day: DateTime(2026, 11, 2),
    actual: '17:30-23:00',
    breakMinutes: 30,
  );
  final missed = testShift(day: DateTime(2026, 11, 3));
  final upcoming = testShift(day: DateTime(2026, 11, 4));
  final later = testShift(
    day: DateTime(2026, 11, 15),
    type: ShiftType.lunch,
    planned: '12:00-16:00',
  );

  test('month summary', () {
    final summary = summarizeMonth([recorded, missed, upcoming, later], now);
    expect(summary.recordedMinutes, 300); // 5.5 h - 30 min break
    expect(summary.missedShifts, 1);
    expect(summary.upcomingShifts, 2);
    expect(summary.upcomingMinutes, 330 + 240);
    // recorded + missed + both upcoming
    expect(summary.expectedMinutes, 300 + 330 + 330 + 240);
  });

  group('reminders', () {
    const settings = AppSettings();

    test('start reminders only for planned shifts within two weeks', () {
      final farAway = testShift(day: DateTime(2026, 12, 1));
      final reminders = planReminders(
        [recorded, missed, upcoming, later, farAway],
        settings,
        now,
      );
      expect(reminders.map((r) => (r.shift, r.kind, r.at)), [
        (upcoming, ReminderKind.start, DateTime(2026, 11, 4, 17, 15)),
        (later, ReminderKind.start, DateTime(2026, 11, 15, 11, 45)),
      ]);
    });

    test('no reminder once its time has passed', () {
      final reminders = planReminders(
        [upcoming],
        settings,
        DateTime(2026, 11, 4, 17, 20),
      );
      expect(reminders, isEmpty);
    });

    test('running shift gets the overrun question', () {
      final running = testShift(
        day: DateTime(2026, 11, 4),
        rawStart: DateTime(2026, 11, 4, 17, 32),
      );
      final reminders = planReminders([running], settings, now);
      expect(reminders.single.kind, ReminderKind.overrun);
      expect(reminders.single.at, DateTime(2026, 11, 4, 23, 30));

      // After the planned end + 30 min: ask again 30 min from now.
      final late = DateTime(2026, 11, 4, 23, 40);
      expect(
        planReminders([running], settings, late).single.at,
        DateTime(2026, 11, 5, 0, 10),
      );
    });
  });

  test('custom shifts count as lunch when they start before 15:00', () {
    final day = DateTime(2026, 11, 6);
    expect(testShift(day: day, type: ShiftType.lunch).isLunchSlot, isTrue);
    expect(testShift(day: day).isLunchSlot, isFalse);
    final early = testShift(
      day: day,
      type: ShiftType.custom,
      planned: '14:30-18:00',
    );
    final late = testShift(
      day: day,
      type: ShiftType.custom,
      planned: '15:00-22:00',
    );
    expect(early.isLunchSlot, isTrue);
    expect(late.isLunchSlot, isFalse);
  });
}
