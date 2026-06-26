import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/fuel/domain/entities/fuel_record.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class FuelRepository {
  Stream<List<FuelRecord>> watchAll();
  Future<Either<Failure, FuelRecord>> addFuelRecord(FuelRecord record);
  Future<double?> getAverageConsumption(String vehicleId);
}
