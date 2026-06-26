import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/platform/domain/repositories/platform_repository.dart';
import 'package:fpdart/fpdart.dart';

class SeedDefaultPlatformsUseCase {
  const SeedDefaultPlatformsUseCase(this._repository);

  final PlatformRepository _repository;

  Future<Either<Failure, Unit>> call(String userId) =>
      _repository.seedDefaultPlatforms(userId);
}
