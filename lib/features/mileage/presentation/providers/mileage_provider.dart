import 'package:driver_finance/core/database/app_database.dart';
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/utils/uuid_generator.dart';
import 'package:driver_finance/features/mileage/data/repositories/mileage_repository_impl.dart';
import 'package:driver_finance/features/mileage/domain/entities/mileage_record.dart';
import 'package:driver_finance/features/mileage/domain/repositories/mileage_repository.dart';
import 'package:driver_finance/features/mileage/domain/usecases/add_mileage_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final mileageRepositoryProvider = Provider<MileageRepository>((ref) {
  return MileageRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    supabase: Supabase.instance.client,
  );
});

final watchMileageProvider =
    StreamProvider.family<List<MileageRecord>, (DateTime, DateTime)>(
  (ref, period) {
    final repo = ref.watch(mileageRepositoryProvider);
    return repo.watchByPeriod(period.$1, period.$2);
  },
);

class MileageFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Either<Failure, MileageRecord>> save({
    required String userId,
    required String vehicleId,
    required int startOdometer,
    required int endOdometer,
    required int workKm,
    required int personalKm,
    required DateTime recordDate,
  }) async {
    state = const AsyncLoading();
    final record = MileageRecord(
      id: generateUuid(),
      userId: userId,
      vehicleId: vehicleId,
      startOdometer: startOdometer,
      endOdometer: endOdometer,
      workKm: workKm,
      personalKm: personalKm,
      recordDate: recordDate,
      createdAt: DateTime.now(),
    );
    final result = await AddMileageRecordUseCase(
      ref.read(mileageRepositoryProvider),
    )(record);
    state = const AsyncData(null);
    return result;
  }
}

final mileageFormNotifierProvider =
    AsyncNotifierProvider<MileageFormNotifier, void>(
  MileageFormNotifier.new,
);
