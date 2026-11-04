import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permissions and phone settings that make reminders reliable.
abstract final class DeviceSetup {
  static Future<bool> notificationsAllowed() =>
      Permission.notification.isGranted;

  static Future<bool> requestNotifications() async =>
      (await Permission.notification.request()).isGranted;

  /// Exact reminders. Since Android 14 the user has to allow this in the
  /// "Alarms & reminders" settings page, which `request` opens.
  static Future<bool> exactAlarmsAllowed() =>
      Permission.scheduleExactAlarm.isGranted;

  static Future<bool> requestExactAlarms() async =>
      (await Permission.scheduleExactAlarm.request()).isGranted;

  static Future<bool> batteryUnrestricted() =>
      Permission.ignoreBatteryOptimizations.isGranted;

  static Future<bool> requestBatteryUnrestricted() async =>
      (await Permission.ignoreBatteryOptimizations.request()).isGranted;

  static Future<bool> requestCalendar() async =>
      (await Permission.calendarFullAccess.request()).isGranted;

  /// Xiaomi, Redmi and POCO phones stop background apps very strictly and
  /// need extra settings (Autostart, battery saver).
  static Future<bool> isXiaomi() async {
    final info = await DeviceInfoPlugin().androidInfo;
    final maker = '${info.manufacturer} ${info.brand}'.toLowerCase();
    return ['xiaomi', 'redmi', 'poco'].any(maker.contains);
  }

  /// Opens Xiaomi's Autostart list, or the app's settings if that fails.
  static Future<void> openAutostartSettings() async {
    try {
      await const AndroidIntent(
        componentName:
            'com.miui.permcenter.autostart.AutoStartManagementActivity',
        package: 'com.miui.securitycenter',
      ).launch();
    } catch (_) {
      await openAppSettings();
    }
  }

  /// The app's own settings page (on Xiaomi: battery saver is in there).
  static Future<void> openAppSettingsPage() => openAppSettings();
}
