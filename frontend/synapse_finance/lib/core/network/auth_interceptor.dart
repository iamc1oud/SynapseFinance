import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import 'token_storage.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  AuthInterceptor(this._tokenStorage);

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
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final response = await _retry(err.requestOptions);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.post(
        ApiConstants.refreshToken,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'] as String;
        final newRefreshToken = response.data['refresh'] as String?;

        await _tokenStorage.saveAccessToken(newAccessToken);
        if (newRefreshToken != null) {
          await _tokenStorage.saveRefreshToken(newRefreshToken);
        }
        return true;
      }
    } catch (_) {
      await _tokenStorage.clearTokens();
    }
    return false;
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

    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
