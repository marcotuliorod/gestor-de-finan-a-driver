import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/utils/uuid_generator.dart';
import 'package:driver_finance/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:driver_finance/features/trips/domain/entities/trip.dart';
import 'package:driver_finance/features/trips/domain/repositories/trip_repository.dart';
import 'package:driver_finance/features/trips/domain/usecases/add_trip.dart';
import 'package:driver_finance/features/trips/domain/usecases/delete_trip.dart';
import 'package:driver_finance/features/trips/domain/usecases/update_trip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepositoryImpl(
    database: ref.watch($db.appDatabaseProvider),
    supabase: Supabase.instance.client,
  );
});

final watchTripsProvider = StreamProvider.family<List<Trip>, (DateTime, DateTime)>(
  (ref, period) {
    final repo = ref.watch(tripRepositoryProvider);
    return repo.watchByPeriod(period.$1, period.$2);
  },
);

class TripFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Either<Failure, Trip>> save({
    String? existingId,
    required String userId,
    required String platformId,
    required int grossAmountCents,
    int bonusAmountCents = 0,
    int tipAmountCents = 0,
    int promotionCents = 0,
    int cancellationCents = 0,
    required DateTime tripDate,
    String? notes,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(tripRepositoryProvider);
    final trip = Trip(
      id: existingId ?? generateUuid(),
      userId: userId,
      platformId: platformId,
      grossAmountCents: grossAmountCents,
      bonusAmountCents: bonusAmountCents,
      tipAmountCents: tipAmountCents,
      promotionCents: promotionCents,
      cancellationCents: cancellationCents,
      tripDate: tripDate,
      notes: notes?.isEmpty == true ? null : notes,
      createdAt: DateTime.now(),
    );
    final Either<Failure, Trip> result;
    if (existingId != null) {
      result = await UpdateTripUseCase(repo)(trip);
    } else {
      result = await AddTripUseCase(repo)(trip);
    }
    state = const AsyncData(null);
    return result;
  }

  Future<Either<Failure, Unit>> delete(String tripId) async {
    state = const AsyncLoading();
    final result =
        await DeleteTripUseCase(ref.read(tripRepositoryProvider))(tripId);
    state = const AsyncData(null);
    return result;
  }
}

final tripFormNotifierProvider =
    AsyncNotifierProvider<TripFormNotifier, void>(TripFormNotifier.new);
