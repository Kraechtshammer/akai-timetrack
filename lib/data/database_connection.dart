import 'package:drift_flutter/drift_flutter.dart';

import 'database.dart';

/// The app's database file.
AppDatabase openAppDatabase() => AppDatabase(
  driftDatabase(
    name: 'timetrack',
    // The app and the notification buttons (which run in a background
    // isolate) share one connection, so screens update right away.
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  ),
);
