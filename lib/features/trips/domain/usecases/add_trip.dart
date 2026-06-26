import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/trips/domain/entities/trip.dart';
import 'package:driver_finance/features/trips/domain/repositories/trip_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddTripUseCase {
  const AddTripUseCase(this._repository);

  final TripRepository _repository;

  Future<Either<Failure, Trip>> call(Trip trip) {
    if (trip.grossAmountCents < 0) {
      return Future.value(
        left(const ValidationFailure('Valor bruto não pode ser negativo')),
      );
    }
    if (trip.platformId.isEmpty) {
      return Future.value(
        left(const ValidationFailure('Selecione uma plataforma')),
      );
    }
    return _repository.addTrip(trip);
  }
}
