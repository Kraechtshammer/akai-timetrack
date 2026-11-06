import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/domain/app_icons.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime(2026, 11, 1);

TeamMember person(String name, {bool isMe = false}) => TeamMember(
  id: name,
  name: name,
  core: false,
  isMe: isMe,
  active: true,
  createdAt: _t,
  updatedAt: _t,
);

void main() {
  test('key round trip for all combinations', () {
    var n = 0;
    for (final d in IconDesign.values) {
      for (final s in IconShape.values) {
        final icon = AppIcon(d, s);
        expect(icon.key, '${d.name}.${s.name}');
        expect(AppIcon.parse(icon.key), icon);
        n++;
      }
    }
    expect(n, 12);
  });

  test('unknown key gives the fallback', () {
    const fallback = AppIcon(IconDesign.cloche, IconShape.round);
    expect(AppIcon.fallback, fallback);
    for (final key in [null, '', 'round', 'x.y', 'cloche.x', 'a.b.c']) {
      expect(AppIcon.parse(key), fallback);
    }
  });

  test('secretIconsUnlocked', () {
    expect(secretIconsUnlocked([person('Yuki', isMe: true)]), isTrue);
    expect(secretIconsUnlocked([person(' yuki ', isMe: true)]), isTrue);
    expect(secretIconsUnlocked([person('YUKI', isMe: true)]), isTrue);
    expect(secretIconsUnlocked([person('Yuki')]), isFalse);
    expect(secretIconsUnlocked([person('Anna', isMe: true)]), isFalse);
    expect(secretIconsUnlocked([]), isFalse);
  });

  test('isAkaiRestaurant', () {
    expect(isAkaiRestaurant('AKAI'), isTrue);
    expect(isAkaiRestaurant(' akai '), isTrue);
    expect(isAkaiRestaurant('Akai Sushi'), isFalse);
    expect(isAkaiRestaurant(''), isFalse);
  });

  test('iconDesignsOffered', () {
    final locked = [person('Anna', isMe: true)];
    final unlocked = [person('Yuki', isMe: true)];
    List<IconDesign> offered(
      List<TeamMember> members, {
      String restaurant = 'AKAI',
      IconDesign current = IconDesign.cloche,
    }) => iconDesignsOffered(
      members: members,
      restaurant: restaurant,
      current: current,
    );

    expect(offered(locked), [IconDesign.cloche, IconDesign.akai]);
    expect(offered(unlocked), IconDesign.values);
    expect(offered(locked, current: IconDesign.penguinNavy), [
      IconDesign.cloche,
      IconDesign.akai,
      IconDesign.penguinNavy,
    ]);
    // The AKAI sign only for AKAI, unless it is the current icon.
    expect(offered(locked, restaurant: 'Da Mario'), [IconDesign.cloche]);
    expect(offered(locked, restaurant: ''), [IconDesign.cloche]);
    expect(offered(locked, restaurant: 'Da Mario', current: IconDesign.akai), [
      IconDesign.cloche,
      IconDesign.akai,
    ]);
  });
}
