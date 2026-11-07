import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/time.dart';
import 'database.dart';

/// Reads and writes the daily pool totals ("Tagestopf") and the weekly
/// payouts ("Ausgezahlt"). See docs/02-design.md §3 and §4.7.
class TipRepository {
  TipRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Pool totals with a day in [from, to).
  Stream<List<TipDay>> watchDays(DateTime from, DateTime to) =>
      (_db.select(_db.tipDays)
            ..where(
              (t) =>
                  t.day.isBiggerOrEqualValue(dayKey(from)) &
                  t.day.isSmallerThanValue(dayKey(to)),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.day)]))
          .watch();

  /// Payouts of the weeks starting in [from, to).
  Stream<List<TipPayout>> watchPayouts(DateTime from, DateTime to) =>
      (_db.select(_db.tipPayouts)
            ..where(
              (t) =>
                  t.weekStart.isBiggerOrEqualValue(dayKey(from)) &
                  t.weekStart.isSmallerThanValue(dayKey(to)),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.weekStart)]))
          .watch();

  // The upserts run select and write in one transaction, so a double tap
  // can't hit the unique key.

  /// Saves the pool total of [day]; null deletes it.
  Future<void> setDay(DateTime day, int? cents) => _db.transaction(() async {
    final key = dayKey(day);
    final existing = await (_db.select(
      _db.tipDays,
    )..where((t) => t.day.equals(key))).getSingleOrNull();
    final now = DateTime.now();
    if (cents == null) {
      if (existing != null) {
        await (_db.delete(_db.tipDays)..where((t) => t.day.equals(key))).go();
      }
    } else if (existing == null) {
      await _db
          .into(_db.tipDays)
          .insert(
            TipDay(
              id: _uuid.v4(),
              day: key,
              poolCents: cents,
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await _db
          .update(_db.tipDays)
          .replace(existing.copyWith(poolCents: cents, updatedAt: now));
    }
  });

  /// Saves the payout of the week starting on [weekStart]; null deletes it.
  Future<void> setPayout(DateTime weekStart, int? cents) =>
      _db.transaction(() async {
        final key = dayKey(weekStart);
        final existing = await (_db.select(
          _db.tipPayouts,
        )..where((t) => t.weekStart.equals(key))).getSingleOrNull();
        final now = DateTime.now();
        if (cents == null) {
          if (existing != null) {
            await (_db.delete(
              _db.tipPayouts,
            )..where((t) => t.weekStart.equals(key))).go();
          }
        } else if (existing == null) {
          await _db
              .into(_db.tipPayouts)
              .insert(
                TipPayout(
                  id: _uuid.v4(),
                  weekStart: key,
                  amountCents: cents,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        } else {
          await _db
              .update(_db.tipPayouts)
              .replace(existing.copyWith(amountCents: cents, updatedAt: now));
        }
      });
}
