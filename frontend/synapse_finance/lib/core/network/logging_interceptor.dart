import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@lazySingleton
class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('REQUEST[${options.method}] => PATH: ${options.path}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    _logger.e('Error message: ${err.message}');
    handler.next(err);
  }
}
