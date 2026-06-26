import 'package:driver_finance/core/database/app_database.dart';
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/utils/uuid_generator.dart';
import 'package:driver_finance/features/fuel/data/repositories/fuel_repository_impl.dart';
import 'package:driver_finance/features/fuel/domain/entities/fuel_record.dart';
import 'package:driver_finance/features/fuel/domain/repositories/fuel_repository.dart';
import 'package:driver_finance/features/fuel/domain/usecases/add_fuel_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final fuelRepositoryProvider = Provider<FuelRepository>((ref) {
  return FuelRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    supabase: Supabase.instance.client,
  );
});

final watchFuelRecordsProvider = StreamProvider<List<FuelRecord>>((ref) {
  return ref.watch(fuelRepositoryProvider).watchAll();
});

class FuelFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Either<Failure, FuelRecord>> save({
    required String userId,
    required String vehicleId,
    required int amountCents,
    required double liters,
    required int odometer,
    required String fuelType,
    required DateTime recordDate,
  }) async {
    state = const AsyncLoading();
    final record = FuelRecord(
      id: generateUuid(),
      expenseId: generateUuid(),
      userId: userId,
      vehicleId: vehicleId,
      amountCents: amountCents,
      liters: liters,
      odometer: odometer,
      fuelType: fuelType,
      recordDate: recordDate,
      createdAt: DateTime.now(),
    );
    final result = await AddFuelRecordUseCase(
      ref.read(fuelRepositoryProvider),
    )(record);
    state = const AsyncData(null);
    return result;
  }
}

final fuelFormNotifierProvider =
    AsyncNotifierProvider<FuelFormNotifier, void>(FuelFormNotifier.new);
