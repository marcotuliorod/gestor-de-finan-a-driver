import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/vehicle/domain/entities/vehicle.dart';
import 'package:driver_finance/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateVehicleUseCase {
  const CreateVehicleUseCase(this._repository);

  final VehicleRepository _repository;

  Future<Either<Failure, Vehicle>> call(Vehicle vehicle) {
    if (vehicle.make.trim().isEmpty) {
      return Future.value(left(const ValidationFailure('Marca é obrigatória')));
    }
    if (vehicle.model.trim().isEmpty) {
      return Future.value(left(const ValidationFailure('Modelo é obrigatório')));
    }
    if (vehicle.year < 1950 || vehicle.year > DateTime.now().year + 1) {
      return Future.value(left(const ValidationFailure('Ano inválido')));
    }
    if (vehicle.purchasePriceCents <= 0) {
      return Future.value(
          left(const ValidationFailure('Valor de compra deve ser positivo')));
    }
    return _repository.createVehicle(vehicle);
  }
}
