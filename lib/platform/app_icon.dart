import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/settings_repository.dart';
import 'device_setup.dart';

/// The launcher icon variants (see android/app/src/main/res/mipmap-anydpi-v26).
/// The launcher decides the icon's shape and apps can't find it out, so the
/// user picks the variant that fits.
enum AppIcon {
  /// Red ring around a dark-red disc. For circular masks (Pixel).
  round,

  /// The original sign: red frame, dark-red squircle panel. For squircle
  /// masks (Xiaomi).
  squircle,

  /// The whole squircle sign, scaled down; the launcher fills the rest.
  small,
}

/// Switches the launcher icon (one activity alias per variant, see
/// MainActivity.kt). Only available in the app, not in the background isolate.
abstract final class AppIcons {
  static const _channel = MethodChannel('de.garten.akaitimetrack/app_icon');

  static Future<AppIcon> current() async =>
      AppIcon.values.asNameMap()[await _channel.invokeMethod<String>(
        'current',
      )] ??
      AppIcon.round;

  /// The launcher may take a few seconds to show the new icon, and some
  /// launchers drop the old icon from the home screen.
  static Future<void> set(AppIcon icon) =>
      _channel.invokeMethod<void>('set', {'icon': icon.name});

  /// On the first start: Xiaomi phones get the squircle icon, which fits
  /// their launcher's icon shape. Everything else keeps the round default.
  static Future<void> chooseDefaultOnce(SettingsRepository settings) async {
    try {
      if ((await settings.load()).appIconChosen) return;
      if (await DeviceSetup.isXiaomi()) await set(AppIcon.squircle);
      await settings.update((s) => s.copyWith(appIconChosen: true));
    } catch (e) {
      debugPrint('App icon default failed: $e');
    }
  }
}
