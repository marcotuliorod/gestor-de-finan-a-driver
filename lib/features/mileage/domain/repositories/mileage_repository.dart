import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/mileage/domain/entities/mileage_record.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class MileageRepository {
  Stream<List<MileageRecord>> watchByPeriod(DateTime start, DateTime end);
  Future<Either<Failure, MileageRecord>> addMileageRecord(
    MileageRecord record,
  );
  Future<int?> getLastOdometer(String vehicleId);
}
