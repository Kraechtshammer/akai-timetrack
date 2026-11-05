import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_settings.dart';
import '../data/database.dart';
import '../data/settings_repository.dart';
import '../platform/app_icon.dart';
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

/// Daily pool totals ("Tagestopf") with a day in the range.
final tipDaysProvider = StreamProvider.family<List<TipDay>, DayRange>(
  (ref, range) =>
      ref.watch(servicesProvider).tips.watchDays(range.$1, range.$2),
);

/// Weekly payouts ("Ausgezahlt") of the weeks starting in the range.
final tipPayoutsProvider = StreamProvider.family<List<TipPayout>, DayRange>(
  (ref, range) =>
      ref.watch(servicesProvider).tips.watchPayouts(range.$1, range.$2),
);

/// The day whose tip prompt on Heute she closed (`yyyy-MM-dd`).
final tipPromptDismissedProvider = StreamProvider<String?>(
  (ref) => ref
      .watch(servicesProvider)
      .settings
      .watchStatus(SettingsRepository.tipPromptDismissed),
);

final runningShiftProvider = StreamProvider<Shift?>(
  (ref) => ref.watch(servicesProvider).shifts.watchRunning(),
);

/// When the calendar sync last finished without errors.
final lastCalendarSyncProvider = StreamProvider<DateTime?>(
  (ref) => ref.watch(servicesProvider).settings.watchLastCalendarSync(),
);

/// How many shifts still wait for the calendar sync.
final pendingSyncCountProvider = StreamProvider<int>(
  (ref) => ref.watch(servicesProvider).shifts.watchPendingSyncCount(),
);

/// The launcher icon variant (read from Android). Invalidate after a change.
final appIconProvider = FutureProvider<AppIcon>((ref) => AppIcons.current());

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
