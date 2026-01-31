import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_client.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiClient _apiClient;
  final AuthLocalDataSource _localDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(
    this._apiClient,
    this._localDataSource,
    this._tokenStorage,
  );

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.login(
        LoginRequest(email: email, password: password),
      );

      await _tokenStorage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );

      await _localDataSource.cacheUser(response.user);

      return Right(response.user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _apiClient.register(
        RegisterRequest(
          email: email,
          password: password,
          passwordConfirm: passwordConfirm,
          firstName: firstName,
          lastName: lastName,
        ),
      );

      await _tokenStorage.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );

      await _localDataSource.cacheUser(response.user);

      return Right(response.user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.logout({'refresh': refreshToken});
      }
      await _localDataSource.clearCache();
      return const Right(null);
    } on DioException catch (e) {
      await _localDataSource.clearCache();
      return Left(_handleDioError(e));
    } catch (e) {
      await _localDataSource.clearCache();
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      final user = await _apiClient.getCurrentUser();
      await _localDataSource.cacheUser(user);
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await _localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return const Right(false);
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'No internet connection. Please check your network.',
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);
      case DioExceptionType.cancel:
        return const ServerFailure('Request was cancelled.');
      default:
        return ServerFailure('An unexpected error occurred: ${e.message}');
    }
  }

  Failure _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    switch (statusCode) {
      case 400:
        if (data is Map<String, dynamic>) {
          final fieldErrors = <String, List<String>>{};
          data.forEach((key, value) {
            if (value is List) {
              fieldErrors[key] = value.cast<String>();
            } else if (value is String) {
              fieldErrors[key] = [value];
            }
          });
          final message =
              data['detail'] as String? ??
              data['message'] as String? ??
              'Validation error';
          return ValidationFailure(message, fieldErrors: fieldErrors);
        }
        return const ValidationFailure('Invalid request');
      case 401:
        return const AuthenticationFailure(
          'Invalid credentials. Please try again.',
        );
      case 403:
        return const AuthenticationFailure(
          'You do not have permission to perform this action.',
        );
      case 404:
        return const ServerFailure('Resource not found.', statusCode: 404);
      case 500:
        return const ServerFailure(
          'Server error. Please try again later.',
          statusCode: 500,
        );
      default:
        return ServerFailure(
          'An error occurred. Please try again.',
          statusCode: statusCode,
        );
    }
  }
}
