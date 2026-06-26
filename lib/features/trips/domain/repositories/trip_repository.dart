import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/trips/domain/entities/trip.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class TripRepository {
  Stream<List<Trip>> watchByPeriod(DateTime start, DateTime end);
  Future<Either<Failure, Trip>> addTrip(Trip trip);
  Future<Either<Failure, Trip>> updateTrip(Trip trip);
  Future<Either<Failure, Unit>> deleteTrip(String tripId);
}
