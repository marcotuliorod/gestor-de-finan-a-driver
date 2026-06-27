import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/auth/domain/entities/app_user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> watchAuthState();
  AppUser? get currentUser;
  Future<Either<Failure, Unit>> signInWithGoogle();
  Future<Either<Failure, Unit>> signOut();
  Future<Either<Failure, Unit>> deleteAccount();
  Future<Either<Failure, Unit>> updateDisplayName(String name);
  Future<Either<Failure, AppUser>> signInWithApple();
}
