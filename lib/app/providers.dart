import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_settings.dart';
import '../data/database.dart';
import 'services.dart';

/// Set in main() with the services created at start.
final servicesProvider = Provider<AppServices>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(servicesProvider).settings.watch(),
);

/// A range of days: from (inclusive) to (exclusive).
typedef DayRange = (DateTime from, DateTime to);

/// Shifts in a range of days, kept up to date.
final shiftsProvider = StreamProvider.family<List<Shift>, DayRange>(
  (ref, range) =>
      ref.watch(servicesProvider).shifts.watchDays(range.$1, range.$2),
);

final runningShiftProvider = StreamProvider<Shift?>(
  (ref) => ref.watch(servicesProvider).shifts.watchRunning(),
);

/// The current time, updated every 20 seconds (for countdowns and "today").
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 20), (_) => DateTime.now());
});

extension SettingsOrDefault on WidgetRef {
  AppSettings get settings =>
      watch(settingsProvider).value ?? const AppSettings();
  DateTime get now => watch(nowProvider).value ?? DateTime.now();
  AppServices get services => read(servicesProvider);
}
