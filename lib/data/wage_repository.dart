import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/time.dart';
import 'database.dart';

/// Reads and writes the user's hourly wage rates, each valid from a day
/// on. See docs/02-design.md §3 and §4.8.
class WageRepository {
  WageRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// All rates, the one valid from the earliest day first.
  Stream<List<WageRate>> watchAll() => (_db.select(
    _db.wageRates,
  )..orderBy([(t) => OrderingTerm(expression: t.validFrom)])).watch();

  // Select and write share a transaction, so a double tap can't hit the
  // unique key.

  /// Saves the rate valid from [validFrom] on, replacing one of the same day.
  Future<void> setRate(DateTime validFrom, int cents) =>
      _db.transaction(() async {
        final key = dayKey(validFrom);
        final existing = await (_db.select(
          _db.wageRates,
        )..where((t) => t.validFrom.equals(key))).getSingleOrNull();
        final now = DateTime.now();
        if (existing == null) {
          await _db
              .into(_db.wageRates)
              .insert(
                WageRate(
                  id: _uuid.v4(),
                  validFrom: key,
                  hourlyCents: cents,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        } else {
          await _db
              .update(_db.wageRates)
              .replace(existing.copyWith(hourlyCents: cents, updatedAt: now));
        }
      });

  /// Removes the rate valid from [validFrom] on, if there is one.
  Future<void> deleteRate(DateTime validFrom) => (_db.delete(
    _db.wageRates,
  )..where((t) => t.validFrom.equals(dayKey(validFrom)))).go();
}
