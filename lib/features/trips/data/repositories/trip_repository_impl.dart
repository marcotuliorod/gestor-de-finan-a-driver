import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/trips/domain/entities/trip.dart';
import 'package:driver_finance/features/trips/domain/repositories/trip_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({
    required $db.AppDatabase database,
    required SupabaseClient supabase,
  })  : _db = database,
        _supabase = supabase;

  final $db.AppDatabase _db;
  final SupabaseClient _supabase;

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
              tripDate: Value(trip.tripDate),
              notes: Value(trip.notes),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value('pending'),
            ),
          );
      _syncToSupabase(trip.id);
      return right(trip);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Trip>> updateTrip(Trip trip) async {
    try {
      await (_db.update(_db.trips)
            ..where((t) => t.id.equals(trip.id)))
          .write($db.TripsCompanion(
        grossAmountCents: Value(trip.grossAmountCents),
        bonusAmountCents: Value(trip.bonusAmountCents),
        tipAmountCents: Value(trip.tipAmountCents),
        promotionCents: Value(trip.promotionCents),
        cancellationCents: Value(trip.cancellationCents),
        tripDate: Value(trip.tripDate),
        notes: Value(trip.notes),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
      _syncToSupabase(trip.id);
      return right(trip);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrip(String tripId) async {
    try {
      await (_db.update(_db.trips)
            ..where((t) => t.id.equals(tripId)))
          .write($db.TripsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
      _syncDeleteToSupabase(tripId);
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  void _syncToSupabase(String tripId) {
    _doSync(tripId);
  }

  Future<void> _doSync(String tripId) async {
    try {
      final row = await (_db.select(_db.trips)
            ..where((t) => t.id.equals(tripId)))
          .getSingleOrNull();
      if (row == null) return;

      await _supabase.from('trips').upsert({
        'id': row.id,
        'user_id': row.userId,
        'platform_id': row.platformId,
        'gross_amount_cents': row.grossAmountCents,
        'bonus_amount_cents': row.bonusAmountCents,
        'tip_amount_cents': row.tipAmountCents,
        'promotion_cents': row.promotionCents,
        'cancellation_cents': row.cancellationCents,
        'trip_date': row.tripDate.toIso8601String(),
        'notes': row.notes,
        'updated_at': row.updatedAt.toIso8601String(),
      });

      await (_db.update(_db.trips)
            ..where((t) => t.id.equals(tripId)))
          .write($db.TripsCompanion(
        syncStatus: const Value('synced'),
        syncedAt: Value(DateTime.now()),
      ));
    } catch (_) {}
  }

  void _syncDeleteToSupabase(String tripId) {
    _doSyncDelete(tripId);
  }

  Future<void> _doSyncDelete(String tripId) async {
    try {
      final row = await (_db.select(_db.trips)
            ..where((t) => t.id.equals(tripId)))
          .getSingleOrNull();
      if (row == null || row.deletedAt == null) return;

      await _supabase.from('trips').upsert({
        'id': tripId,
        'deleted_at': row.deletedAt!.toIso8601String(),
        'updated_at': row.updatedAt.toIso8601String(),
      });
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
        tripDate: row.tripDate,
        notes: row.notes,
        createdAt: row.createdAt,
      );
}
