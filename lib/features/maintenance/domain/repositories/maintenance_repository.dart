import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/maintenance/domain/entities/maintenance_record.dart';
import 'package:fpdart/fpdart.dart';

abstract class MaintenanceRepository {
  Stream<List<MaintenanceRecord>> watchAll();
  Future<Either<Failure, MaintenanceRecord>> addRecord(
    MaintenanceRecord record,
  );
  Future<Either<Failure, void>> deleteRecord(String id);
}
