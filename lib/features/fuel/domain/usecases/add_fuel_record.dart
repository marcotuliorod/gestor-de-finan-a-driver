import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/fuel/domain/entities/fuel_record.dart';
import 'package:driver_finance/features/fuel/domain/repositories/fuel_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddFuelRecordUseCase {
  const AddFuelRecordUseCase(this._repository);

  final FuelRepository _repository;

  Future<Either<Failure, FuelRecord>> call(FuelRecord record) {
    if (record.amountCents <= 0) {
      return Future.value(
        left(const ValidationFailure('Valor deve ser maior que zero')),
      );
    }
    if (record.liters <= 0) {
      return Future.value(
        left(const ValidationFailure('Litros deve ser maior que zero')),
      );
    }
    if (record.odometer < 0) {
      return Future.value(
        left(const ValidationFailure('Odômetro inválido')),
      );
    }
    return _repository.addFuelRecord(record);
  }
}
