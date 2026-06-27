import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/auth/domain/entities/app_user.dart';
import 'package:driver_finance/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required SupabaseClient supabase,
  }) : _supabase = supabase;

  final SupabaseClient _supabase;

  @override
  Stream<AppUser?> watchAuthState() {
    return _supabase.auth.onAuthStateChange.map(
      (data) {
        final user = data.session?.user;
        return user != null ? _toAppUser(user) : null;
      },
    );
  }

  @override
  AppUser? get currentUser {
    final user = _supabase.auth.currentUser;
    return user != null ? _toAppUser(user) : null;
  }

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.marcotuliorod.driverfinance://login-callback',
      );
      return right(unit);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    try {
      await _supabase.rpc('delete_account');
      await _supabase.auth.signOut();
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final idToken = credential.identityToken;
      if (idToken == null) {
        return left(const AuthFailure('Token Apple não disponível'));
      }
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );
      if (response.user == null) {
        return left(const AuthFailure('Usuário não retornado pelo servidor'));
      }
      return right(_toAppUser(response.user!));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return left(const AuthFailure('Login cancelado pelo usuário'));
      }
      return left(AuthFailure(e.message));
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateDisplayName(String name) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': name}),
      );
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  AppUser _toAppUser(User user) => AppUser(
        id: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['full_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      );
}
