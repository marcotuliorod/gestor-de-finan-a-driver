import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/trips/domain/entities/trip.dart';
import 'package:driver_finance/features/trips/domain/repositories/trip_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateTripUseCase {
  const UpdateTripUseCase(this._repository);

  final TripRepository _repository;

  Future<Either<Failure, Trip>> call(Trip trip) => _repository.updateTrip(trip);
}
