import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/maintenance/domain/entities/maintenance_record.dart';
import 'package:driver_finance/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl({
    required $db.AppDatabase database,
    required SupabaseClient supabase,
  })  : _db = database,
        _supabase = supabase;

  final $db.AppDatabase _db;
  final SupabaseClient _supabase;

  @override
  Stream<List<MaintenanceRecord>> watchAll() {
    return (_db.select(_db.maintenanceRecords)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.maintenanceDate)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<Either<Failure, MaintenanceRecord>> addRecord(
    MaintenanceRecord record,
  ) async {
    try {
      final now = DateTime.now();
      await _db.into(_db.maintenanceRecords).insert(
            $db.MaintenanceRecordsCompanion(
              id: Value(record.id),
              userId: Value(record.userId),
              vehicleId: Value(record.vehicleId),
              type: Value(record.type),
              description: Value(record.description),
              costCents: Value(record.costCents),
              odometer: Value(record.odometer),
              maintenanceDate: Value(record.maintenanceDate),
              nextMaintenanceKm: Value(record.nextMaintenanceKm),
              nextMaintenanceDate: Value(record.nextMaintenanceDate),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      _syncToSupabase(record.id);
      return right(record);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord(String id) async {
    try {
      final now = DateTime.now();
      await (_db.update(_db.maintenanceRecords)..where((t) => t.id.equals(id)))
          .write(
        $db.MaintenanceRecordsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      return right(null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  void _syncToSupabase(String id) {
    _doSync(id);
  }

  Future<void> _doSync(String id) async {
    try {
      final row = await (_db.select(_db.maintenanceRecords)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;

      await _supabase.from('maintenance_records').upsert({
        'id': row.id,
        'user_id': row.userId,
        'vehicle_id': row.vehicleId,
        'type': row.type,
        'description': row.description,
        'cost_cents': row.costCents,
        'odometer': row.odometer,
        'maintenance_date': row.maintenanceDate.toIso8601String(),
        'next_maintenance_km': row.nextMaintenanceKm,
        'next_maintenance_date': row.nextMaintenanceDate?.toIso8601String(),
        'updated_at': row.updatedAt.toIso8601String(),
      });

      await (_db.update(_db.maintenanceRecords)..where((t) => t.id.equals(id)))
          .write(
        $db.MaintenanceRecordsCompanion(
          syncStatus: const Value('synced'),
          syncedAt: Value(DateTime.now()),
        ),
      );
    } catch (_) {}
  }

  MaintenanceRecord _toDomain($db.MaintenanceRecord row) => MaintenanceRecord(
        id: row.id,
        userId: row.userId,
        vehicleId: row.vehicleId,
        type: row.type,
        description: row.description,
        costCents: row.costCents,
        odometer: row.odometer,
        maintenanceDate: row.maintenanceDate,
        nextMaintenanceKm: row.nextMaintenanceKm,
        nextMaintenanceDate: row.nextMaintenanceDate,
        createdAt: row.createdAt,
      );
}
