import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/services.dart';
import 'platform/app_icon.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.create();
  try {
    await services.notifications.initialize(
      onResponse: services.handleNotificationAction,
      onBackgroundResponse: onNotificationActionInBackground,
      l10n: await services.l10n(),
    );
  } catch (e, stack) {
    // The app must still open (e.g. a missing resource in a release build
    // once kept it on the splash screen); it just has no notifications.
    debugPrint('Notification setup failed: $e\n$stack');
  }
  unawaited(AppIcons.chooseDefaultOnce(services.settings));
  // Catch up on reminders and the calendar (e.g. after a reboot).
  unawaited(services.syncAll());

  runApp(
    ProviderScope(
      overrides: [servicesProvider.overrideWithValue(services)],
      child: const TimeTrackApp(),
    ),
  );
}
