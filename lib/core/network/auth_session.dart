import 'dart:async';
import 'dart:convert';

import 'package:driver_finance/features/auth/domain/entities/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda a sessão do backend próprio (access/refresh token + usuário) em
/// armazenamento seguro do device, e notifica mudanças de estado de auth.
class AuthSession {
  AuthSession({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'df_access_token';
  static const _refreshTokenKey = 'df_refresh_token';
  static const _userKey = 'df_session_user';

  final FlutterSecureStorage _storage;
  final _controller = StreamController<AppUser?>.broadcast();

  String? _accessToken;
  String? _refreshToken;
  AppUser? _user;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  AppUser? get currentUser => _user;

  /// Emite o snapshot atual para cada novo assinante e depois repassa
  /// mudanças futuras — `_controller.stream` sozinho é um broadcast stream
  /// e não reproduz eventos passados para quem assina depois de `load()`.
  Stream<AppUser?> get authStateChanges async* {
    yield _user;
    yield* _controller.stream;
  }

  /// Lê a sessão persistida do storage seguro. Deve ser chamado uma vez, em
  /// `main.dart`, antes do app renderizar a primeira tela.
  Future<void> load() async {
    _accessToken = await _storage.read(key: _accessTokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);
    final rawUser = await _storage.read(key: _userKey);
    _user = rawUser != null
        ? _userFromJson(jsonDecode(rawUser) as Map<String, dynamic>)
        : null;
    _controller.add(_user);
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required AppUser user,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _user = user;
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _userKey, value: jsonEncode(_userToJson(user))),
    ]);
    _controller.add(_user);
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> updateUser(AppUser user) async {
    _user = user;
    await _storage.write(key: _userKey, value: jsonEncode(_userToJson(user)));
    _controller.add(_user);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userKey),
    ]);
    _controller.add(null);
  }

  Map<String, dynamic> _userToJson(AppUser user) => {
        'id': user.id,
        'email': user.email,
        'displayName': user.displayName,
        'avatarUrl': user.avatarUrl,
      };

  AppUser _userFromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}

final authSessionProvider = Provider<AuthSession>((ref) {
  throw UnimplementedError(
    'Override authSessionProvider em main.dart via ProviderScope, '
    'após AuthSession().load()',
  );
});
