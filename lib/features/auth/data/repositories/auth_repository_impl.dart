import 'package:dio/dio.dart';
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/core/network/api_client.dart';
import 'package:driver_finance/core/network/auth_session.dart';
import 'package:driver_finance/features/auth/domain/entities/app_user.dart';
import 'package:driver_finance/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required AuthSession session,
    GoogleSignIn? googleSignIn,
  })  : _apiClient = apiClient,
        _session = session,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email']);

  final ApiClient _apiClient;
  final AuthSession _session;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AppUser?> watchAuthState() => _session.authStateChanges;

  @override
  AppUser? get currentUser => _session.currentUser;

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return left(const AuthFailure('Login cancelado pelo usuário'));
      }
      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        return left(const AuthFailure('Token Google não disponível'));
      }

      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/google',
        data: {'id_token': idToken},
      );
      await _saveSession(response.data!);
      return right(unit);
    } on DioException catch (e) {
      return left(AuthFailure(_dioMessage(e)));
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

      final fullName = [credential.givenName, credential.familyName]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');

      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/apple',
        data: {
          'identity_token': idToken,
          if (fullName.isNotEmpty) 'full_name': fullName,
        },
      );
      final user = await _saveSession(response.data!);
      return right(user);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return left(const AuthFailure('Login cancelado pelo usuário'));
      }
      return left(AuthFailure(e.message));
    } on DioException catch (e) {
      return left(AuthFailure(_dioMessage(e)));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      final refreshToken = _session.refreshToken;
      if (refreshToken != null) {
        try {
          await _apiClient.dio.post<void>(
            '/api/v1/auth/logout',
            data: {'refresh_token': refreshToken},
          );
        } catch (_) {
          // Revogação no servidor é best-effort — a sessão local é limpa
          // de qualquer forma logo abaixo.
        }
      }
      await _googleSignIn.signOut();
      await _session.clear();
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    try {
      await _apiClient.dio.delete<void>('/api/v1/auth/account');
      await _googleSignIn.signOut();
      await _session.clear();
      return right(unit);
    } on DioException catch (e) {
      return left(AuthFailure(_dioMessage(e)));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateDisplayName(String name) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        '/api/v1/auth/me',
        data: {'display_name': name},
      );
      await _session.updateUser(_userFromJson(response.data!));
      return right(unit);
    } on DioException catch (e) {
      return left(AuthFailure(_dioMessage(e)));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  Future<AppUser> _saveSession(Map<String, dynamic> data) async {
    final user = _userFromJson(data['user'] as Map<String, dynamic>);
    await _session.save(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      user: user,
    );
    return user;
  }

  AppUser _userFromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['display_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
      );

  String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['detail'] is String) {
      return data['detail'] as String;
    }
    return e.message ?? 'Erro de autenticação';
  }
}
