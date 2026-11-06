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

  // October 2026 starts on a Thursday (KW 40 = 28.09.–04.10.) and ends on a
  // Saturday (KW 44 = 26.10.–01.11.).
  final october = DateTime(2026, 10);
  final afterOctober = DateTime(2026, 11, 4, 12);
  final shifts = [
    testShift(day: DateTime(2026, 9, 30), actual: '17:30-23:00'), // September
    testShift(
      day: DateTime(2026, 10, 1),
      type: ShiftType.lunch,
      planned: '12:00-16:00',
      actual: '12:00-16:00',
    ),
    testShift(day: DateTime(2026, 10, 5), actual: '17:30-23:00'),
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
    testShift(day: DateTime(2026, 11, 1), actual: '17:30-22:45'), // November
  ];

  test('German month text grouped by week, cut at the month edges', () {
    final text = buildExportText(
      month: october,
      shifts: shifts,
      now: afterOctober,
      l10n: de,
    );
    expect(
      text,
      'Arbeitszeiten Oktober 2026\n'
      '\n'
      'KW 40 (01.10.–04.10.)\n'
      'Do 01.10.: 12:00–16:00 (4,0 h)\n'
      'Woche gesamt: 4,0 h\n'
      '\n'
      'KW 41 (05.10.–11.10.)\n'
      'Mo 05.10.: 17:30–23:00 (5,5 h)\n'
      'Woche gesamt: 5,5 h\n'
      '\n'
      'KW 44 (26.10.–31.10.)\n'
      'Mo 26.10.: 12:00–16:00 (4,0 h)\n'
      'Fr 30.10.: 12:00–15:30 (3,5 h), 17:30–23:00, 30 min Pause (5,0 h)\n'
      'Woche gesamt: 12,5 h\n'
      '\n'
      'Oktober gesamt: 22,0 h',
    );
  });

  test('the running month says "bisher"', () {
    final text = buildExportText(
      month: DateTime(2026, 11),
      shifts: shifts,
      now: afterOctober,
      l10n: de,
    );
    expect(
      text,
      'Arbeitszeiten November 2026\n'
      '\n'
      'KW 44 (01.11.–01.11.)\n'
      'So 01.11.: 17:30–22:45 (5,25 h)\n'
      'Woche gesamt: 5,25 h\n'
      '\n'
      'November bisher: 5,25 h',
    );
  });

  test('a month without recorded shifts has only header and total', () {
    final text = buildExportText(
      month: DateTime(2026, 12),
      shifts: shifts,
      now: afterOctober,
      l10n: de,
    );
    expect(text, 'Arbeitszeiten Dezember 2026\n\nDezember bisher: 0,0 h');
  });

  test('the header names the restaurant, if set', () {
    String header(AppLocalizations l10n, String restaurant) => buildExportText(
      month: DateTime(2026, 12),
      shifts: shifts,
      now: afterOctober,
      l10n: l10n,
      restaurant: restaurant,
    ).split('\n').first;
    expect(header(de, 'AKAI'), 'Arbeitszeiten Dezember 2026 – AKAI');
    expect(header(en, ' AKAI '), 'Working hours December 2026 – AKAI');
    expect(header(de, '  '), 'Arbeitszeiten Dezember 2026');
  });

  test('English text', () {
    final text = buildExportText(
      month: october,
      shifts: shifts,
      now: afterOctober,
      l10n: en,
    );
    expect(text.split('\n').first, 'Working hours October 2026');
    expect(text, contains('CW 40 (01/10–04/10)\nThu 01/10: 12:00–16:00'));
    expect(
      text,
      contains(
        'Fri 30/10: 12:00–15:30 (3.5 h), '
        '17:30–23:00, 30 min break (5.0 h)',
      ),
    );
    expect(text, contains('Week total: 12.5 h'));
    expect(text, endsWith('October total: 22.0 h'));
  });
}
