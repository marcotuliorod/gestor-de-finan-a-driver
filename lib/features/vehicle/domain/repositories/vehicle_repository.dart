import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/vehicle/domain/entities/vehicle.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class VehicleRepository {
  Stream<Vehicle?> watchVehicle();
  Future<Either<Failure, Vehicle?>> getVehicle();
  Future<Either<Failure, Vehicle>> createVehicle(Vehicle vehicle);
  Future<Either<Failure, Vehicle>> updateVehicle(Vehicle vehicle);
  Future<Either<Failure, bool>> hasAnyVehicle();
}
