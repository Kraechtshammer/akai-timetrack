import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:akai_timetrack/app/shift_colors.dart';
import 'package:akai_timetrack/app/theme.dart';
import 'package:akai_timetrack/data/app_settings.dart';

void main() {
  const r = ShiftColorRole.recorded,
      m = ShiftColorRole.missed,
      l = ShiftColorRole.lunch,
      e = ShiftColorRole.evening;

  // Where a role would look like the theme colour, it moves to the next
  // candidate (docs/02-design.md §8).
  const expected = {
    ThemeSeed.akaiRed: {r: 'sage', m: 'honey', l: 'apricot', e: 'periwinkle'},
    ThemeSeed.terracotta: {r: 'sage', m: 'honey', l: 'rose', e: 'periwinkle'},
    ThemeSeed.blue: {r: 'sage', m: 'honey', l: 'apricot', e: 'plum'},
    ThemeSeed.green: {r: 'teal', m: 'honey', l: 'apricot', e: 'periwinkle'},
    ThemeSeed.violet: {r: 'sage', m: 'honey', l: 'apricot', e: 'steel blue'},
  };

  for (final MapEntry(key: seed, value: picks) in expected.entries) {
    for (final b in Brightness.values) {
      test('${seed.name} ${b.name}: roles stay clear of the theme colour', () {
        final colors = ShiftColors.forScheme(schemeFor(seed, b, null));
        expect(colors.picks, picks);
      });
    }
  }

  test('the AKAI sage, honey and periwinkle are the designed tones', () {
    final dark = ShiftColors.forScheme(
      schemeFor(ThemeSeed.akaiRed, Brightness.dark, null),
    );
    expect(dark.recorded, const Color(0xFF9AD4A2));
    expect(dark.missed, const Color(0xFFF2BE6E));
    expect(dark.evening, const Color(0xFFB8C3FF));
  });

  test('the today border is the primary colour unless overridden', () {
    final scheme = schemeFor(ThemeSeed.blue, Brightness.dark, null);
    expect(ShiftColors.forScheme(scheme).today, scheme.primary);
    expect(
      ShiftColors.forScheme(scheme, today: const Color(0xFFC62828)).today,
      const Color(0xFFC62828),
    );
  });

  test('AKAI red marks today with the real red in dark mode too', () {
    expect(
      todayColorFor(ThemeSeed.akaiRed, Brightness.dark),
      seedColors[ThemeSeed.akaiRed],
    );
    expect(todayColorFor(ThemeSeed.akaiRed, Brightness.light), isNull);
    expect(todayColorFor(ThemeSeed.blue, Brightness.dark), isNull);
  });
}
