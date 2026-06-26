import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/trips/domain/repositories/trip_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteTripUseCase {
  const DeleteTripUseCase(this._repository);

  final TripRepository _repository;

  Future<Either<Failure, Unit>> call(String tripId) =>
      _repository.deleteTrip(tripId);
}
