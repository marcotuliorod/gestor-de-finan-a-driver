import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/utils/uuid_generator.dart';
import 'package:driver_finance/features/maintenance/data/repositories/maintenance_repository_impl.dart';
import 'package:driver_finance/features/maintenance/domain/entities/maintenance_record.dart';
import 'package:driver_finance/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  return MaintenanceRepositoryImpl(
    database: ref.watch($db.appDatabaseProvider),
    supabase: Supabase.instance.client,
  );
});

final watchMaintenanceProvider = StreamProvider<List<MaintenanceRecord>>((ref) {
  return ref.watch(maintenanceRepositoryProvider).watchAll();
});

class MaintenanceNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Either<Failure, MaintenanceRecord>> addRecord({
    required String userId,
    required String vehicleId,
    required String type,
    String? description,
    required int costCents,
    required int odometer,
    required DateTime maintenanceDate,
    int? nextMaintenanceKm,
    DateTime? nextMaintenanceDate,
  }) async {
    state = const AsyncLoading();
    final record = MaintenanceRecord(
      id: generateUuid(),
      userId: userId,
      vehicleId: vehicleId,
      type: type,
      description: description,
      costCents: costCents,
      odometer: odometer,
      maintenanceDate: maintenanceDate,
      nextMaintenanceKm: nextMaintenanceKm,
      nextMaintenanceDate: nextMaintenanceDate,
      createdAt: DateTime.now(),
    );
    final result =
        await ref.read(maintenanceRepositoryProvider).addRecord(record);
    state = const AsyncData(null);
    return result;
  }

  Future<void> deleteRecord(String id) async {
    await ref.read(maintenanceRepositoryProvider).deleteRecord(id);
  }
}

final maintenanceNotifierProvider =
    AsyncNotifierProvider<MaintenanceNotifier, void>(MaintenanceNotifier.new);
