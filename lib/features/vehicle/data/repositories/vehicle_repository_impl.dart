import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/vehicle/domain/entities/vehicle.dart';
import 'package:driver_finance/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl({
    required $db.AppDatabase database,
    required SupabaseClient supabase,
  })  : _db = database,
        _supabase = supabase;

  final $db.AppDatabase _db;
  final SupabaseClient _supabase;

  @override
  Stream<Vehicle?> watchVehicle() {
    return (_db.select(_db.vehicles)
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => row != null ? _toDomain(row) : null);
  }

  @override
  Future<Either<Failure, Vehicle?>> getVehicle() async {
    try {
      final row = await (_db.select(_db.vehicles)
            ..where((t) => t.deletedAt.isNull())
            ..limit(1))
          .getSingleOrNull();
      return right(row != null ? _toDomain(row) : null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasAnyVehicle() async {
    try {
      final row = await (_db.select(_db.vehicles)
            ..where((t) => t.deletedAt.isNull())
            ..limit(1))
          .getSingleOrNull();
      return right(row != null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> createVehicle(Vehicle vehicle) async {
    try {
      final now = DateTime.now();
      await _db.into(_db.vehicles).insert(
            $db.VehiclesCompanion(
              id: Value(vehicle.id),
              userId: Value(vehicle.userId),
              make: Value(vehicle.make),
              model: Value(vehicle.model),
              year: Value(vehicle.year),
              licensePlate: Value(vehicle.licensePlate),
              fuelType: Value(vehicle.fuelType),
              tankCapacityL: Value(vehicle.tankCapacityL),
              purchasePriceCents: Value(vehicle.purchasePriceCents),
              usefulLifeMonths: Value(vehicle.usefulLifeMonths),
              residualValuePct: Value(vehicle.residualValuePct),
              currentOdometer: Value(vehicle.currentOdometer),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value('pending'),
            ),
          );
      _syncToSupabase(vehicle.id);
      return right(vehicle);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> updateVehicle(Vehicle vehicle) async {
    try {
      await (_db.update(_db.vehicles)
            ..where((t) => t.id.equals(vehicle.id)))
          .write($db.VehiclesCompanion(
        make: Value(vehicle.make),
        model: Value(vehicle.model),
        year: Value(vehicle.year),
        licensePlate: Value(vehicle.licensePlate),
        fuelType: Value(vehicle.fuelType),
        tankCapacityL: Value(vehicle.tankCapacityL),
        purchasePriceCents: Value(vehicle.purchasePriceCents),
        usefulLifeMonths: Value(vehicle.usefulLifeMonths),
        residualValuePct: Value(vehicle.residualValuePct),
        currentOdometer: Value(vehicle.currentOdometer),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
      _syncToSupabase(vehicle.id);
      return right(vehicle);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  void _syncToSupabase(String vehicleId) {
    _doSync(vehicleId);
  }

  Future<void> _doSync(String vehicleId) async {
    try {
      final row = await (_db.select(_db.vehicles)
            ..where((t) => t.id.equals(vehicleId)))
          .getSingleOrNull();
      if (row == null) return;

      await _supabase.from('vehicles').upsert({
        'id': row.id,
        'user_id': row.userId,
        'make': row.make,
        'model': row.model,
        'year': row.year,
        'license_plate': row.licensePlate,
        'fuel_type': row.fuelType,
        'tank_capacity_l': row.tankCapacityL,
        'purchase_price_cents': row.purchasePriceCents,
        'useful_life_months': row.usefulLifeMonths,
        'residual_value_pct': row.residualValuePct,
        'current_odometer': row.currentOdometer,
        'updated_at': row.updatedAt.toIso8601String(),
      });

      await (_db.update(_db.vehicles)
            ..where((t) => t.id.equals(vehicleId)))
          .write($db.VehiclesCompanion(
        syncStatus: const Value('synced'),
        syncedAt: Value(DateTime.now()),
      ));
    } catch (_) {
      // Sync failure is silent — will retry via sync queue
    }
  }

  Vehicle _toDomain($db.Vehicle row) => Vehicle(
        id: row.id,
        userId: row.userId,
        make: row.make,
        model: row.model,
        year: row.year,
        licensePlate: row.licensePlate,
        fuelType: row.fuelType,
        tankCapacityL: row.tankCapacityL,
        purchasePriceCents: row.purchasePriceCents,
        usefulLifeMonths: row.usefulLifeMonths,
        residualValuePct: row.residualValuePct,
        currentOdometer: row.currentOdometer,
      );
}
