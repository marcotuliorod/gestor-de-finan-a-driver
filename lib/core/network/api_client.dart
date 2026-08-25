import 'dart:async';

import 'package:dio/dio.dart';
import 'package:driver_finance/core/network/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

/// Endpoints de auth que nunca recebem o access token atual — `google` e
/// `apple` ainda não têm sessão, `refresh` e `logout` se autenticam com o
/// refresh token no corpo da requisição.
const _noAuthHeaderPaths = [
  '/api/v1/auth/google',
  '/api/v1/auth/apple',
  '/api/v1/auth/refresh',
  '/api/v1/auth/logout',
];

/// Cliente HTTP para o backend próprio (Python/FastAPI), substituindo o
/// papel do `SupabaseClient` para auth: anexa o access token em toda
/// requisição autenticada e renova automaticamente em caso de 401.
class ApiClient {
  ApiClient({required AuthSession session, Dio? dio})
      : _session = session,
        dio = dio ?? Dio(BaseOptions(baseUrl: _apiBaseUrl)) {
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final token = _session.accessToken;
              if (token != null && !_noAuthHeaderPaths.contains(options.path)) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              handler.next(options);
            },
            onError: (error, handler) async {
              final options = error.requestOptions;
              final alreadyRetried = options.extra['df_retried'] == true;
              final canRefresh =
                  error.response?.statusCode == 401 &&
                      !_noAuthHeaderPaths.contains(options.path) &&
                      _session.refreshToken != null &&
                      !alreadyRetried;

              if (!canRefresh) {
                handler.next(error);
                return;
              }

              final refreshed = await _refresh();
              if (!refreshed) {
                handler.next(error);
                return;
              }

              try {
                options.extra['df_retried'] = true;
                options.headers['Authorization'] =
                    'Bearer ${_session.accessToken}';
                final response = await this.dio.fetch<dynamic>(options);
                handler.resolve(response);
              } on DioException catch (retryError) {
                handler.next(retryError);
              }
            },
          ),
        );
  }

  final Dio dio;
  final AuthSession _session;
  Future<bool>? _refreshing;

  Future<bool> _refresh() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = _session.refreshToken;
    if (refreshToken == null) return false;
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data!;
      await _session.updateTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      await _session.clear();
      return false;
    }
  }

  /// Reporta uma falha de sincronização em background ao Sentry em vez de
  /// descartá-la silenciosamente — os repositórios de dados chamam isto no
  /// `catch` do push fire-and-forget para o backend (o registro local via
  /// Drift já foi salvo com sucesso; só a sincronização remota falhou).
  void reportSyncFailure(String resource, String id, Object error) {
    unawaited(
      Sentry.captureException(
        error,
        withScope: (scope) {
          scope.setTag('sync_resource', resource);
          scope.setExtra('sync_record_id', id);
        },
      ),
    );
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(session: ref.watch(authSessionProvider));
});
