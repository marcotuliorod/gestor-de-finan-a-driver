import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/network/api_client.dart';
import 'package:driver_finance/core/utils/uuid_generator.dart';
import 'package:driver_finance/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:driver_finance/features/vehicle/domain/entities/vehicle.dart';
import 'package:driver_finance/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:driver_finance/features/vehicle/domain/usecases/create_vehicle.dart';
import 'package:driver_finance/features/vehicle/domain/usecases/update_vehicle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(
    database: ref.watch($db.appDatabaseProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

final watchVehicleProvider = StreamProvider<Vehicle?>((ref) {
  return ref.watch(vehicleRepositoryProvider).watchVehicle();
});

class VehicleFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Either<Failure, Vehicle>> save({
    String? existingId,
    required String userId,
    required String make,
    required String model,
    required int year,
    required String licensePlate,
    required String fuelType,
    required double tankCapacityL,
    required int purchasePriceCents,
    int usefulLifeMonths = 60,
    double residualValuePct = 0.20,
    int currentOdometer = 0,
  }) async {
    state = const AsyncLoading();

    final vehicle = Vehicle(
      id: existingId ?? generateUuid(),
      userId: userId,
      make: make,
      model: model,
      year: year,
      licensePlate: licensePlate,
      fuelType: fuelType,
      tankCapacityL: tankCapacityL,
      purchasePriceCents: purchasePriceCents,
      usefulLifeMonths: usefulLifeMonths,
      residualValuePct: residualValuePct,
      currentOdometer: currentOdometer,
    );

    final repo = ref.read(vehicleRepositoryProvider);
    final result = existingId != null
        ? await UpdateVehicleUseCase(repo)(vehicle)
        : await CreateVehicleUseCase(repo)(vehicle);

    state = const AsyncData(null);
    return result;
  }
}

final vehicleFormNotifierProvider =
    AsyncNotifierProvider<VehicleFormNotifier, void>(VehicleFormNotifier.new);
