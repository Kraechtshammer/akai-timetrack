import 'dart:ui';

import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/domain/export_text.dart';
import 'package:akai_timetrack/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
    await initializeDateFormatting('en');
  });

  final de = lookupAppLocalizations(const Locale('de'));
  final en = lookupAppLocalizations(const Locale('en'));

  // KW 44 2026: Mon 26.10. – Sun 01.11. (spans October and November)
  final week = DateTime(2026, 10, 26);
  final shifts = [
    testShift(day: DateTime(2026, 10, 5), actual: '17:30-23:00'), // earlier
    testShift(
      day: DateTime(2026, 10, 26),
      type: ShiftType.lunch,
      planned: '12:00-16:00',
      actual: '12:00-16:00',
    ),
    testShift(
      day: DateTime(2026, 10, 30),
      type: ShiftType.lunch,
      planned: '12:00-15:30',
      actual: '12:00-15:30',
    ),
    testShift(
      day: DateTime(2026, 10, 30),
      actual: '17:30-23:00',
      breakMinutes: 30,
    ),
    testShift(day: DateTime(2026, 10, 31)), // planned only: not exported
    testShift(day: DateTime(2026, 11, 1), actual: '17:30-22:45'),
  ];

  test('German text with breaks and both month totals', () {
    final text = buildExportText(
      week: week,
      shifts: shifts,
      includeMonthTotals: true,
      l10n: de,
    );
    expect(
      text,
      'Arbeitszeiten KW 44 (26.10.–01.11.2026)\n'
      'Mo 26.10.: 12:00–16:00 (4,0 h)\n'
      'Fr 30.10.: 12:00–15:30 (3,5 h), 17:30–23:00, 30 min Pause (5,0 h)\n'
      'So 01.11.: 17:30–22:45 (5,25 h)\n'
      'Woche gesamt: 17,75 h\n'
      'Oktober gesamt: 18,0 h\n'
      'November bisher: 5,25 h',
    );
  });

  test('month totals can be left out', () {
    final text = buildExportText(
      week: week,
      shifts: shifts,
      includeMonthTotals: false,
      l10n: de,
    );
    expect(text.split('\n').last, 'Woche gesamt: 17,75 h');
  });

  test('English text', () {
    final text = buildExportText(
      week: week,
      shifts: shifts,
      includeMonthTotals: true,
      l10n: en,
    );
    expect(text.split('\n').first, 'Working hours CW 44 (26/10–01/11/2026)');
    expect(
      text,
      contains(
        'Fri 30/10: 12:00–15:30 (3.5 h), '
        '17:30–23:00, 30 min break (5.0 h)',
      ),
    );
    expect(text, contains('October total: 18.0 h'));
    expect(text, endsWith('November so far: 5.25 h'));
  });

  test('a week inside one month has one month line', () {
    final text = buildExportText(
      week: DateTime(2026, 10, 5),
      shifts: shifts,
      includeMonthTotals: true,
      l10n: de,
    );
    expect(text.split('\n').last, 'Oktober bisher: 5,5 h');
  });
}
