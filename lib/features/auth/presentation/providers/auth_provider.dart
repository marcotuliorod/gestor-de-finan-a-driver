import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/network/api_client.dart';
import 'package:driver_finance/core/network/auth_session.dart';
import 'package:driver_finance/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:driver_finance/features/auth/domain/entities/app_user.dart';
import 'package:driver_finance/features/auth/domain/repositories/auth_repository.dart';
import 'package:driver_finance/features/auth/domain/usecases/delete_account.dart';
import 'package:driver_finance/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:driver_finance/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:driver_finance/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    session: ref.watch(authSessionProvider),
  );
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).watchAuthState();
});

/// Id do usuário logado, reativo a login/logout — substitui as leituras
/// diretas de `Supabase.instance.client.auth.currentUser?.id` que existiam
/// fora da camada de auth.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.id;
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Either<Failure, Unit>> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await SignInWithGoogleUseCase(
      ref.read(authRepositoryProvider),
    )();
    state = const AsyncData(null);
    return result;
  }

  Future<Either<Failure, AppUser>> signInWithApple() async {
    state = const AsyncLoading();
    final result = await SignInWithAppleUseCase(
      ref.read(authRepositoryProvider),
    )();
    state = const AsyncData(null);
    return result;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await SignOutUseCase(ref.read(authRepositoryProvider))();
    state = const AsyncData(null);
  }

  Future<Either<Failure, Unit>> deleteAccount() async {
    state = const AsyncLoading();
    final result = await DeleteAccountUseCase(
      ref.read(authRepositoryProvider),
    )();
    state = const AsyncData(null);
    return result;
  }

  Future<Either<Failure, Unit>> updateDisplayName(String name) async {
    state = const AsyncLoading();
    final result =
        await ref.read(authRepositoryProvider).updateDisplayName(name);
    state = const AsyncData(null);
    return result;
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
