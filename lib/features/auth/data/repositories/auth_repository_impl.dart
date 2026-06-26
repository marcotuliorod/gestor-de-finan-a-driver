import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/auth/domain/entities/app_user.dart';
import 'package:driver_finance/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required SupabaseClient supabase,
    required GoogleSignIn googleSignIn,
  })  : _supabase = supabase,
        _googleSignIn = googleSignIn;

  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;

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
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return left(const AuthFailure('Login cancelado pelo usuário'));
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        return left(const AuthFailure('Token Google não disponível'));
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );

      if (response.user == null) {
        return left(const AuthFailure('Usuário não retornado pelo servidor'));
      }

      return right(_toAppUser(response.user!));
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _googleSignIn.signOut();
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
      await _googleSignIn.signOut();
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
