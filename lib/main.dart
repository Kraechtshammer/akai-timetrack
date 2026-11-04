import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.create();
  await services.notifications.initialize(
    onResponse: services.handleNotificationAction,
    onBackgroundResponse: onNotificationActionInBackground,
    l10n: await services.l10n(),
  );
  // Catch up on reminders and the calendar (e.g. after a reboot).
  unawaited(services.syncAll());

  runApp(
    ProviderScope(
      overrides: [servicesProvider.overrideWithValue(services)],
      child: const TimeTrackApp(),
    ),
  );
}
