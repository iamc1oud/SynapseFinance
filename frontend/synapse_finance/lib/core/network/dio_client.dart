import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';

@module
abstract class DioModule {
  @lazySingleton
  Logger get logger => Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([authInterceptor, loggingInterceptor]);

    return dio;
  }
}
