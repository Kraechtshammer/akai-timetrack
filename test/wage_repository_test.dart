import 'package:akai_timetrack/data/database.dart';
import 'package:akai_timetrack/data/wage_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late WageRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = WageRepository(db);
  });
  tearDown(() => db.close());

  test('starts empty', () async {
    expect(await repo.watchAll().first, isEmpty);
  });

  test('inserts a rate', () async {
    await repo.setRate(DateTime(2026, 1, 1), 1350);
    final rates = await repo.watchAll().first;
    expect(rates, hasLength(1));
    expect(rates.single.validFrom, '2026-01-01');
    expect(rates.single.hourlyCents, 1350);
  });

  test('orders by validFrom', () async {
    await repo.setRate(DateTime(2026, 7, 1), 1500);
    await repo.setRate(DateTime(2025, 3, 1), 1300);
    await repo.setRate(DateTime(2026, 1, 1), 1400);
    final rates = await repo.watchAll().first;
    expect(rates.map((r) => r.validFrom), [
      '2025-03-01',
      '2026-01-01',
      '2026-07-01',
    ]);
    expect(rates.map((r) => r.hourlyCents), [1300, 1400, 1500]);
  });

  test('the same validFrom updates the rate', () async {
    await repo.setRate(DateTime(2026, 1, 1), 1350);
    final first = (await repo.watchAll().first).single;
    await repo.setRate(DateTime(2026, 1, 1, 15), 1400);
    final rates = await repo.watchAll().first;
    expect(rates, hasLength(1));
    expect(rates.single.id, first.id);
    expect(rates.single.hourlyCents, 1400);
  });

  test('deletes a rate', () async {
    await repo.setRate(DateTime(2026, 1, 1), 1350);
    await repo.setRate(DateTime(2026, 7, 1), 1500);
    await repo.deleteRate(DateTime(2026, 1, 1));
    final rates = await repo.watchAll().first;
    expect(rates.map((r) => r.validFrom), ['2026-07-01']);
  });

  test('deleting a missing day does nothing', () async {
    await repo.setRate(DateTime(2026, 1, 1), 1350);
    await repo.deleteRate(DateTime(2026, 2, 1));
    expect(await repo.watchAll().first, hasLength(1));
  });
}
