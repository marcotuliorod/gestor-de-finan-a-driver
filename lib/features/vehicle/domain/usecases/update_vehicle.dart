import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/vehicle/domain/entities/vehicle.dart';
import 'package:driver_finance/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateVehicleUseCase {
  const UpdateVehicleUseCase(this._repository);

  final VehicleRepository _repository;

  Future<Either<Failure, Vehicle>> call(Vehicle vehicle) =>
      _repository.updateVehicle(vehicle);
}
