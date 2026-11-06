import '../data/database.dart';

/// The launcher icon designs, in the order of the picker.
enum IconDesign { cloche, akai, penguinBlack, penguinNavy }

/// The launcher icon shapes (see android/app/src/main/res/mipmap-anydpi-v26).
/// The launcher decides the icon's shape and apps can't find it out, so the
/// user picks the shape that fits.
enum IconShape {
  /// For circular masks (Pixel).
  round,

  /// For squircle masks (Xiaomi).
  squircle,

  /// The whole squircle icon, scaled down; the launcher fills the rest.
  small,
}

/// A design in a shape. One activity alias per combination on the Android
/// side, named by [key].
class AppIcon {
  const AppIcon(this.design, this.shape);

  static const fallback = AppIcon(IconDesign.cloche, IconShape.round);

  final IconDesign design;
  final IconShape shape;

  /// For example `cloche.round`.
  String get key => '${design.name}.${shape.name}';

  /// Unknown or missing keys give [fallback].
  static AppIcon parse(String? key) {
    final parts = key?.split('.');
    if (parts == null || parts.length != 2) return fallback;
    final design = IconDesign.values.asNameMap()[parts[0]];
    final shape = IconShape.values.asNameMap()[parts[1]];
    if (design == null || shape == null) return fallback;
    return AppIcon(design, shape);
  }

  AppIcon withDesign(IconDesign design) => AppIcon(design, shape);

  AppIcon withShape(IconShape shape) => AppIcon(design, shape);

  @override
  bool operator ==(Object other) =>
      other is AppIcon && other.design == design && other.shape == shape;

  @override
  int get hashCode => Object.hash(design, shape);

  @override
  String toString() => 'AppIcon($key)';
}

/// The secret designs are unlocked by the "This is me" person's name.
bool secretIconsUnlocked(Iterable<TeamMember> members) =>
    members.any((m) => m.isMe && m.name.trim().toLowerCase() == 'yuki');

/// Whether [restaurant] (the setting) is AKAI, whose sign is an icon
/// design and whose red is the default colour. Trimmed, any case.
bool isAkaiRestaurant(String restaurant) =>
    restaurant.trim().toLowerCase() == 'akai';

/// The designs the picker shows: the AKAI sign only for AKAI, the secret
/// ones only when unlocked. The current one always shows.
List<IconDesign> iconDesignsOffered({
  required Iterable<TeamMember> members,
  required String restaurant,
  required IconDesign current,
}) {
  final unlocked = secretIconsUnlocked(members);
  final akai = isAkaiRestaurant(restaurant);
  bool offered(IconDesign d) => switch (d) {
    IconDesign.akai => akai,
    IconDesign.penguinBlack || IconDesign.penguinNavy => unlocked,
    IconDesign.cloche => true,
  };
  return [
    for (final d in IconDesign.values)
      if (offered(d) || d == current) d,
  ];
}
