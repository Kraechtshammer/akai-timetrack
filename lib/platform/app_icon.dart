import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/settings_repository.dart';
import '../domain/app_icons.dart';
import 'device_setup.dart';

export '../domain/app_icons.dart';

/// Switches the launcher icon (one activity alias per design and shape, see
/// MainActivity.kt). Only available in the app, not in the background isolate.
abstract final class AppIcons {
  static const _channel = MethodChannel('de.garten.akaitimetrack/app_icon');

  static Future<AppIcon> current() async =>
      AppIcon.parse(await _channel.invokeMethod<String>('current'));

  /// The launcher may take a few seconds to show the new icon, and some
  /// launchers drop the old icon from the home screen.
  static Future<void> set(AppIcon icon) =>
      _channel.invokeMethod<void>('set', {'icon': icon.key});

  /// On the first start: Xiaomi phones get the squircle shape, which fits
  /// their launcher's icon shape. Everything else keeps the round default.
  static Future<void> chooseDefaultOnce(SettingsRepository settings) async {
    try {
      if ((await settings.load()).appIconChosen) return;
      if (await DeviceSetup.isXiaomi()) {
        await set(const AppIcon(IconDesign.cloche, IconShape.squircle));
      }
      await settings.update((s) => s.copyWith(appIconChosen: true));
    } catch (e) {
      debugPrint('App icon default failed: $e');
    }
  }
}
