import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/fuel/domain/entities/fuel_record.dart';
import 'package:driver_finance/features/fuel/domain/repositories/fuel_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FuelRepositoryImpl implements FuelRepository {
  FuelRepositoryImpl({
    required $db.AppDatabase database,
    required SupabaseClient supabase,
  })  : _db = database,
        _supabase = supabase;

  final $db.AppDatabase _db;
  final SupabaseClient _supabase;

  @override
  Stream<List<FuelRecord>> watchAll() {
    return (_db.select(_db.fuelRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .asyncMap((rows) async {
      final result = <FuelRecord>[];
      for (final row in rows) {
        final expense = await (_db.select(_db.expenses)
              ..where((e) => e.id.equals(row.expenseId)))
            .getSingleOrNull();
        if (expense != null && expense.deletedAt == null) {
          result.add(_toDomain(row, expense));
        }
      }
      return result;
    });
  }

  @override
  Future<Either<Failure, FuelRecord>> addFuelRecord(
    FuelRecord record,
  ) async {
    try {
      final now = DateTime.now();
      await _db.transaction(() async {
        await _db.into(_db.expenses).insert(
              $db.ExpensesCompanion(
                id: Value(record.expenseId),
                userId: Value(record.userId),
                vehicleId: Value(record.vehicleId),
                category: const Value('fuel'),
                amountCents: Value(record.amountCents),
                expenseDate: Value(record.recordDate),
                isRecurring: const Value(false),
                createdAt: Value(now),
                updatedAt: Value(now),
                syncStatus: const Value('pending'),
              ),
            );
        await _db.into(_db.fuelRecords).insert(
              $db.FuelRecordsCompanion(
                id: Value(record.id),
                expenseId: Value(record.expenseId),
                userId: Value(record.userId),
                vehicleId: Value(record.vehicleId),
                liters: Value(record.liters),
                odometer: Value(record.odometer),
                fuelType: Value(record.fuelType),
                createdAt: Value(now),
              ),
            );
      });
      _syncToSupabase(record.id, record.expenseId);
      return right(record);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<double?> getAverageConsumption(String vehicleId) async {
    final rows = await (_db.select(_db.fuelRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([(t) => OrderingTerm.asc(t.odometer)]))
        .get();
    if (rows.length < 2) return null;

    int totalKm = 0;
    double totalLiters = 0;
    for (int i = 1; i < rows.length; i++) {
      totalKm += rows[i].odometer - rows[i - 1].odometer;
      totalLiters += rows[i].liters;
    }
    if (totalLiters <= 0 || totalKm <= 0) return null;
    return totalKm / totalLiters;
  }

  void _syncToSupabase(String fuelId, String expenseId) {
    _doSync(fuelId, expenseId);
  }

  Future<void> _doSync(String fuelId, String expenseId) async {
    try {
      final fuel = await (_db.select(_db.fuelRecords)
            ..where((t) => t.id.equals(fuelId)))
          .getSingleOrNull();
      final expense = await (_db.select(_db.expenses)
            ..where((t) => t.id.equals(expenseId)))
          .getSingleOrNull();
      if (fuel == null || expense == null) return;

      await _supabase.from('expenses').upsert({
        'id': expense.id,
        'user_id': expense.userId,
        'vehicle_id': expense.vehicleId,
        'category': 'fuel',
        'amount_cents': expense.amountCents,
        'expense_date': expense.expenseDate.toIso8601String(),
        'is_recurring': false,
        'updated_at': expense.updatedAt.toIso8601String(),
      });
      await _supabase.from('fuel_records').upsert({
        'id': fuel.id,
        'expense_id': fuel.expenseId,
        'user_id': fuel.userId,
        'vehicle_id': fuel.vehicleId,
        'liters': fuel.liters,
        'odometer': fuel.odometer,
        'fuel_type': fuel.fuelType,
      });

      await (_db.update(_db.expenses)
            ..where((t) => t.id.equals(expenseId)))
          .write($db.ExpensesCompanion(
        syncStatus: const Value('synced'),
        syncedAt: Value(DateTime.now()),
      ));
    } catch (_) {}
  }

  FuelRecord _toDomain(
    $db.FuelRecord row,
    $db.Expense expense,
  ) =>
      FuelRecord(
        id: row.id,
        expenseId: row.expenseId,
        userId: row.userId,
        vehicleId: row.vehicleId,
        amountCents: expense.amountCents,
        liters: row.liters,
        odometer: row.odometer,
        fuelType: row.fuelType,
        recordDate: expense.expenseDate,
        createdAt: row.createdAt,
      );
}
