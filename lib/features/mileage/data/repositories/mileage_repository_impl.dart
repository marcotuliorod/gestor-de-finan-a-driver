import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/mileage/domain/entities/mileage_record.dart';
import 'package:driver_finance/features/mileage/domain/repositories/mileage_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MileageRepositoryImpl implements MileageRepository {
  MileageRepositoryImpl({
    required $db.AppDatabase database,
    required SupabaseClient supabase,
  })  : _db = database,
        _supabase = supabase;

  final $db.AppDatabase _db;
  final SupabaseClient _supabase;

  @override
  Stream<List<MileageRecord>> watchByPeriod(
    DateTime start,
    DateTime end,
  ) {
    return (_db.select(_db.mileageRecords)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.recordDate.isBiggerOrEqualValue(start) &
                t.recordDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<Either<Failure, MileageRecord>> addMileageRecord(
    MileageRecord record,
  ) async {
    try {
      final now = DateTime.now();
      await _db.into(_db.mileageRecords).insert(
            $db.MileageRecordsCompanion(
              id: Value(record.id),
              userId: Value(record.userId),
              vehicleId: Value(record.vehicleId),
              startOdometer: Value(record.startOdometer),
              endOdometer: Value(record.endOdometer),
              workKm: Value(record.workKm),
              personalKm: Value(record.personalKm),
              recordDate: Value(record.recordDate),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value('pending'),
            ),
          );
      _syncToSupabase(record.id);
      return right(record);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<int?> getLastOdometer(String vehicleId) async {
    final row = await (_db.select(_db.mileageRecords)
          ..where(
            (t) => t.vehicleId.equals(vehicleId) & t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.endOdometer)])
          ..limit(1))
        .getSingleOrNull();
    return row?.endOdometer;
  }

  void _syncToSupabase(String recordId) {
    _doSync(recordId);
  }

  Future<void> _doSync(String recordId) async {
    try {
      final row = await (_db.select(_db.mileageRecords)
            ..where((t) => t.id.equals(recordId)))
          .getSingleOrNull();
      if (row == null) return;

      await _supabase.from('mileage_records').upsert({
        'id': row.id,
        'user_id': row.userId,
        'vehicle_id': row.vehicleId,
        'start_odometer': row.startOdometer,
        'end_odometer': row.endOdometer,
        'work_km': row.workKm,
        'personal_km': row.personalKm,
        'record_date': row.recordDate.toIso8601String(),
        'updated_at': row.updatedAt.toIso8601String(),
      });

      await (_db.update(_db.mileageRecords)
            ..where((t) => t.id.equals(recordId)))
          .write($db.MileageRecordsCompanion(
        syncStatus: const Value('synced'),
        syncedAt: Value(DateTime.now()),
      ));
    } catch (_) {}
  }

  MileageRecord _toDomain($db.MileageRecord row) => MileageRecord(
        id: row.id,
        userId: row.userId,
        vehicleId: row.vehicleId,
        startOdometer: row.startOdometer,
        endOdometer: row.endOdometer,
        workKm: row.workKm,
        personalKm: row.personalKm,
        recordDate: row.recordDate,
        createdAt: row.createdAt,
      );
}
