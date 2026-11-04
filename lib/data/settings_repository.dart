import 'app_settings.dart';
import 'database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<AppSettings> load() async =>
      AppSettings.fromMap(_toMap(await _db.select(_db.settings).get()));

  Stream<AppSettings> watch() => _db
      .select(_db.settings)
      .watch()
      .map((rows) => AppSettings.fromMap(_toMap(rows)));

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
