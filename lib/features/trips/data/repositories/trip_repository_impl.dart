import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/network/api_client.dart';
import 'package:driver_finance/core/utils/date_only.dart';
import 'package:driver_finance/features/trips/domain/entities/trip.dart';
import 'package:driver_finance/features/trips/domain/repositories/trip_repository.dart';
import 'package:fpdart/fpdart.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({
    required $db.AppDatabase database,
    required ApiClient apiClient,
  })  : _db = database,
        _apiClient = apiClient;

  final $db.AppDatabase _db;
  final ApiClient _apiClient;

  @override
  Stream<List<Trip>> watchByPeriod(DateTime start, DateTime end) {
    return (_db.select(_db.trips)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.tripDate.isBiggerOrEqualValue(start) &
                t.tripDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.tripDate)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<Either<Failure, Trip>> addTrip(Trip trip) async {
    try {
      final now = DateTime.now();
      await _db.into(_db.trips).insert(
            $db.TripsCompanion(
              id: Value(trip.id),
              userId: Value(trip.userId),
              platformId: Value(trip.platformId),
              grossAmountCents: Value(trip.grossAmountCents),
              bonusAmountCents: Value(trip.bonusAmountCents),
              tipAmountCents: Value(trip.tipAmountCents),
              promotionCents: Value(trip.promotionCents),
              cancellationCents: Value(trip.cancellationCents),
              durationMinutes: Value(trip.durationMinutes),
              tripDate: Value(trip.tripDate),
              notes: Value(trip.notes),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value('pending'),
            ),
          );
      _syncToBackend(trip.id);
      return right(trip);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Trip>> updateTrip(Trip trip) async {
    try {
      await (_db.update(_db.trips)..where((t) => t.id.equals(trip.id)))
          .write($db.TripsCompanion(
        grossAmountCents: Value(trip.grossAmountCents),
        bonusAmountCents: Value(trip.bonusAmountCents),
        tipAmountCents: Value(trip.tipAmountCents),
        promotionCents: Value(trip.promotionCents),
        cancellationCents: Value(trip.cancellationCents),
        durationMinutes: Value(trip.durationMinutes),
        tripDate: Value(trip.tripDate),
        notes: Value(trip.notes),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
      _syncToBackend(trip.id);
      return right(trip);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrip(String tripId) async {
    try {
      await (_db.update(_db.trips)..where((t) => t.id.equals(tripId)))
          .write($db.TripsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
      _syncDeleteToBackend(tripId);
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  void _syncToBackend(String tripId) {
    _doSync(tripId);
  }

  Future<void> _doSync(String tripId) async {
    try {
      final row = await (_db.select(_db.trips)
            ..where((t) => t.id.equals(tripId)))
          .getSingleOrNull();
      if (row == null) return;

      await _apiClient.dio.put<void>('/api/v1/trips/$tripId', data: {
        'platform_id': row.platformId,
        'gross_amount_cents': row.grossAmountCents,
        'bonus_amount_cents': row.bonusAmountCents,
        'tip_amount_cents': row.tipAmountCents,
        'promotion_cents': row.promotionCents,
        'cancellation_cents': row.cancellationCents,
        'duration_minutes': row.durationMinutes,
        'trip_date': dateOnly(row.tripDate),
        'notes': row.notes,
      });

      await (_db.update(_db.trips)..where((t) => t.id.equals(tripId)))
          .write($db.TripsCompanion(
        syncStatus: const Value('synced'),
        syncedAt: Value(DateTime.now()),
      ));
    } on DioException catch (e) {
      _apiClient.reportSyncFailure('trips', tripId, e);
    } catch (_) {}
  }

  void _syncDeleteToBackend(String tripId) {
    _doSyncDelete(tripId);
  }

  Future<void> _doSyncDelete(String tripId) async {
    try {
      await _apiClient.dio.delete<void>('/api/v1/trips/$tripId');
    } on DioException catch (e) {
      _apiClient.reportSyncFailure('trips', tripId, e);
    } catch (_) {}
  }

  Trip _toDomain($db.Trip row) => Trip(
        id: row.id,
        userId: row.userId,
        platformId: row.platformId,
        grossAmountCents: row.grossAmountCents,
        bonusAmountCents: row.bonusAmountCents,
        tipAmountCents: row.tipAmountCents,
        promotionCents: row.promotionCents,
        cancellationCents: row.cancellationCents,
        durationMinutes: row.durationMinutes,
        tripDate: row.tripDate,
        notes: row.notes,
        createdAt: row.createdAt,
      );
}
