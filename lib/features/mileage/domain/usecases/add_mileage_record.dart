import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/mileage/domain/entities/mileage_record.dart';
import 'package:driver_finance/features/mileage/domain/repositories/mileage_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddMileageRecordUseCase {
  const AddMileageRecordUseCase(this._repository);

  final MileageRepository _repository;

  Future<Either<Failure, MileageRecord>> call(MileageRecord record) {
    if (record.endOdometer <= record.startOdometer) {
      return Future.value(
        left(const ValidationFailure(
          'Km final deve ser maior que km inicial',
        )),
      );
    }
    if (record.workKm + record.personalKm != record.totalKm) {
      return Future.value(
        left(const ValidationFailure(
          'Km trabalho + km pessoal deve ser igual ao total',
        )),
      );
    }
    return _repository.addMileageRecord(record);
  }
}
