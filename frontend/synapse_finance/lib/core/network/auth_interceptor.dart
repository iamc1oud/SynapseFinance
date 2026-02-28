import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import 'auth_event_bus.dart';
import 'token_storage.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final AuthEventBus _authEventBus;

  AuthInterceptor(this._tokenStorage, this._authEventBus);

  // Lock: prevents multiple concurrent refresh calls.
  bool _isRefreshing = false;
  final _pendingCompleters = <Completer<bool>>[];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't try to refresh if this request IS the refresh call — avoids loops.
    if (err.requestOptions.path.contains(ApiConstants.refreshToken)) {
      await _handleRefreshFailure();
      return handler.next(err);
    }

    // If a refresh is already in flight, wait for it to finish.
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _pendingCompleters.add(completer);
      final refreshed = await completer.future;
      if (refreshed) {
        final response = await _retry(err.requestOptions);
        return handler.resolve(response);
      }
      return handler.next(err);
    }

    _isRefreshing = true;
    final refreshed = await _refreshToken();
    _isRefreshing = false;

    // Notify all queued requests of the refresh outcome.
    for (final c in _pendingCompleters) {
      c.complete(refreshed);
    }
    _pendingCompleters.clear();

    if (refreshed) {
      final response = await _retry(err.requestOptions);
      return handler.resolve(response);
    }

    handler.next(err);
  }

  /// Exchange refresh token for new access + refresh tokens.
  /// Returns true on success, false on any failure.
  Future<bool> _refreshToken() async {
    try {
      final storedRefresh = await _tokenStorage.getRefreshToken();
      if (storedRefresh == null) {
        await _handleRefreshFailure();
        return false;
      }

      // Use a bare Dio instance so this call bypasses our interceptor.
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
        ),
      );

      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'refresh_token': storedRefresh},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final newAccess = data['access_token'] as String?;
        final newRefresh = data['refresh_token'] as String?;

        if (newAccess == null) {
          await _handleRefreshFailure();
          return false;
        }

        await _tokenStorage.saveAccessToken(newAccess);
        if (newRefresh != null) {
          await _tokenStorage.saveRefreshToken(newRefresh);
        }
        return true;
      }
    } catch (_) {
      // Network error or bad response during refresh.
    }

    await _handleRefreshFailure();
    return false;
  }

  Future<void> _handleRefreshFailure() async {
    await _tokenStorage.clearTokens();
    _authEventBus.publish(AuthEvent.sessionExpired);
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final accessToken = await _tokenStorage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
