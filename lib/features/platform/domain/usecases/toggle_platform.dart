import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/platform/domain/repositories/platform_repository.dart';
import 'package:fpdart/fpdart.dart';

class TogglePlatformUseCase {
  const TogglePlatformUseCase(this._repository);

  final PlatformRepository _repository;

  Future<Either<Failure, Unit>> call(String id, {required bool isActive}) =>
      _repository.togglePlatform(id, isActive: isActive);
}
