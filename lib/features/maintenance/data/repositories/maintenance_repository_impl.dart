import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/network/api_client.dart';
import 'package:driver_finance/core/utils/date_only.dart';
import 'package:driver_finance/features/maintenance/domain/entities/maintenance_record.dart';
import 'package:driver_finance/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:fpdart/fpdart.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl({
    required $db.AppDatabase database,
    required ApiClient apiClient,
  })  : _db = database,
        _apiClient = apiClient;

  final $db.AppDatabase _db;
  final ApiClient _apiClient;

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
              syncStatus: const Value('pending'),
            ),
          );
      _syncToBackend(record.id);
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
          syncStatus: const Value('pending'),
        ),
      );
      _syncDeleteToBackend(id);
      return right(null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  void _syncToBackend(String id) {
    _doSync(id);
  }

  Future<void> _doSync(String id) async {
    try {
      final row = await (_db.select(_db.maintenanceRecords)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;

      await _apiClient.dio.put<void>('/api/v1/maintenance-records/$id', data: {
        'vehicle_id': row.vehicleId,
        'type': row.type,
        'description': row.description,
        'cost_cents': row.costCents,
        'odometer': row.odometer,
        'maintenance_date': dateOnly(row.maintenanceDate),
        'next_maintenance_km': row.nextMaintenanceKm,
        'next_maintenance_date': row.nextMaintenanceDate != null
            ? dateOnly(row.nextMaintenanceDate!)
            : null,
      });

      await (_db.update(_db.maintenanceRecords)..where((t) => t.id.equals(id)))
          .write(
        $db.MaintenanceRecordsCompanion(
          syncStatus: const Value('synced'),
          syncedAt: Value(DateTime.now()),
        ),
      );
    } on DioException catch (e) {
      _apiClient.reportSyncFailure('maintenance_records', id, e);
    } catch (_) {}
  }

  void _syncDeleteToBackend(String id) {
    _doSyncDelete(id);
  }

  Future<void> _doSyncDelete(String id) async {
    try {
      await _apiClient.dio.delete<void>('/api/v1/maintenance-records/$id');
    } on DioException catch (e) {
      _apiClient.reportSyncFailure('maintenance_records', id, e);
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
