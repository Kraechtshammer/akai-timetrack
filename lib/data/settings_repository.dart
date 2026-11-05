import 'package:flutter/foundation.dart' show mapEquals;

import 'app_settings.dart';
import 'database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  /// When the calendar sync last finished without errors (device status,
  /// not a setting, so changing it doesn't rebuild the app).
  static const _lastCalendarSync = 'lastCalendarSync';

  /// When the app last looked for an update (device status).
  static const lastUpdateCheck = 'lastUpdateCheck';

  /// The newest version the update popup was shown for (device status).
  static const updatePopupShown = 'updatePopupShown';

  static const _statusKeys = {
    _lastCalendarSync,
    lastUpdateCheck,
    updatePopupShown,
  };

  Future<AppSettings> load() async =>
      AppSettings.fromMap(_toMap(await _db.select(_db.settings).get()));

  Stream<AppSettings> watch() => _db
      .select(_db.settings)
      .watch()
      .map(
        (rows) => _toMap(rows)..removeWhere((k, _) => _statusKeys.contains(k)),
      )
      .distinct(mapEquals)
      .map(AppSettings.fromMap);

  Future<void> setLastCalendarSync(DateTime time) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: _lastCalendarSync,
          value: '${time.millisecondsSinceEpoch}',
        ),
      );

  Stream<DateTime?> watchLastCalendarSync() =>
      (_db.select(_db.settings)..where((s) => s.key.equals(_lastCalendarSync)))
          .watchSingleOrNull()
          .map((row) {
            final ms = int.tryParse(row?.value ?? '');
            return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
          });

  /// A device status value (one of the status keys above).
  Future<String?> status(String key) async => (await (_db.select(
    _db.settings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setStatus(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  /// Applies [change] to the current settings and saves the result.
  Future<AppSettings> update(AppSettings Function(AppSettings) change) async {
    final next = change(await load());
    await _db.transaction(() async {
      for (final MapEntry(:key, :value) in next.toMap().entries) {
        if (value == null) {
          await (_db.delete(
            _db.settings,
          )..where((s) => s.key.equals(key))).go();
        } else {
          await _db
              .into(_db.settings)
              .insertOnConflictUpdate(
                SettingsCompanion.insert(key: key, value: value),
              );
        }
      }
    });
    return next;
  }

  Map<String, String> _toMap(List<SettingEntry> rows) => {
    for (final row in rows) row.key: row.value,
  };
}
