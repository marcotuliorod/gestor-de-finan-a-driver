import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/auth/domain/entities/app_user.dart';
import 'package:driver_finance/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AppUser>> call() => _repository.signInWithGoogle();
}
