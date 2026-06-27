import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/platform/domain/entities/app_platform.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PlatformRepository {
  Stream<List<AppPlatform>> watchPlatforms();
  Future<Either<Failure, List<AppPlatform>>> getPlatforms();
  Future<Either<Failure, Unit>> seedDefaultPlatforms(String userId);
  Future<Either<Failure, Unit>> togglePlatform(String id,
      {required bool isActive});
  Future<Either<Failure, Unit>> addPlatform(String userId, String customName);
}
