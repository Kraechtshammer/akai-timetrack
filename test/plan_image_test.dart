import 'package:akai_timetrack/data/app_settings.dart';
import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/domain/roster.dart';
import 'package:akai_timetrack/l10n/app_localizations.dart';
import 'package:akai_timetrack/ui/roster/plan_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

// The shareable team plan picture (F11).

final monday = DateTime(2026, 11, 9);
final created = DateTime(2026, 11, 1);

TeamMember person(String name) => TeamMember(
  id: name,
  name: name,
  core: false,
  isMe: false,
  active: true,
  createdAt: created,
  updatedAt: created,
);

TeamAssignment placed(String name, TeamSlot slot, {int? start}) =>
    TeamAssignment(
      id: 'x-$name-$slot',
      day: slot.dayKey,
      shift: slot.shift,
      memberId: name,
      startMinutes: start,
      createdAt: created,
      updatedAt: created,
    );

RosterWeek build(List<TeamMember> members, List<TeamAssignment> assignments) =>
    RosterWeek(
      weekStart: monday,
      members: members,
      answers: const [],
      assignments: assignments,
      needs: const [],
      defaults: StaffNeeds.standard,
    );

Future<void> pump(WidgetTester tester, RosterWeek week, String lang) async {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final l10n = lookupAppLocalizations(Locale(lang));
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1600, 900)),
        child: TeamPlanImage(
          week: week,
          starts: const TeamStarts(660, 1050),
          l10n: l10n,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
    await initializeDateFormatting('en');
  });

  final names = ['Anna', 'Ben', 'Carla'].map(person).toList();

  RosterWeek normal() {
    final slots = [
      for (var i = 0; i < 6; i++)
        for (final s in TeamShift.values)
          TeamSlot(DateTime(2026, 11, 9 + i), s),
    ];
    return build(names, [
      for (final slot in slots)
        for (final n in names)
          placed(
            n.id,
            slot,
            start: n.id == 'Carla' && slot == slots[1] ? 1110 : null,
          ),
    ]);
  }

  testWidgets('normal week, German', (tester) async {
    await pump(tester, normal(), 'de');
    expect(tester.takeException(), isNull);
    expect(find.text('Anna'), findsWidgets);
    expect(find.textContaining('ab 18:30', findRichText: true), findsOneWidget);
  });

  testWidgets('normal week, English', (tester) async {
    await pump(tester, normal(), 'en');
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Ben', findRichText: true), findsWidgets);
    expect(
      find.textContaining('from 18:30', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('crowded week with a long name', (tester) async {
    final crowd = [
      for (var i = 1; i <= 7; i++) person('Person $i'),
      person('Maximilian-Alexander Wolfgang Q'),
    ];
    final slot = TeamSlot(monday, TeamShift.evening);
    final week = build(crowd, [
      for (final p in crowd) placed(p.id, slot, start: 1110),
    ]);
    await pump(tester, week, 'de');
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Person 3', findRichText: true), findsOneWidget);
    expect(find.textContaining('ab 18:30', findRichText: true), findsWidgets);
  });
}
