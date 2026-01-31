import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:synapse_finance/core/errors/failures.dart';
import 'package:synapse_finance/core/network/token_storage.dart';
import 'package:synapse_finance/features/auth/data/datasources/auth_api_client.dart';
import 'package:synapse_finance/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:synapse_finance/features/auth/data/models/auth_tokens_model.dart';
import 'package:synapse_finance/features/auth/data/models/login_request.dart';
import 'package:synapse_finance/features/auth/data/models/login_response.dart';
import 'package:synapse_finance/features/auth/data/models/user_model.dart';
import 'package:synapse_finance/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthApiClient extends Mock implements AuthApiClient {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

class FakeLoginRequest extends Fake implements LoginRequest {}

class FakeUserModel extends Fake implements UserModel {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthApiClient mockApiClient;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockTokenStorage mockTokenStorage;

  setUpAll(() {
    registerFallbackValue(FakeLoginRequest());
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockApiClient = MockAuthApiClient();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockTokenStorage = MockTokenStorage();
    repository = AuthRepositoryImpl(
      mockApiClient,
      mockLocalDataSource,
      mockTokenStorage,
    );
  });

  group('login', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testUser = UserModel(
      id: 1,
      email: testEmail,
      firstName: 'Test',
      lastName: 'User',
    );
    const testTokens = AuthTokensModel(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      tokenType: 'Bearer',
    );
    const testResponse = LoginResponse(user: testUser, tokens: testTokens);

    test('should return User when login is successful', () async {
      when(
        () => mockApiClient.login(any()),
      ).thenAnswer((_) async => testResponse);
      when(
        () => mockTokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockLocalDataSource.cacheUser(any())).thenAnswer((_) async {});

      final result = await repository.login(
        email: testEmail,
        password: testPassword,
      );

      expect(result, const Right(testUser));
      verify(() => mockApiClient.login(any())).called(1);
      verify(
        () => mockTokenStorage.saveTokens(
          accessToken: testTokens.accessToken,
          refreshToken: testTokens.refreshToken,
        ),
      ).called(1);
      verify(() => mockLocalDataSource.cacheUser(testUser)).called(1);
    });

    test(
      'should return AuthenticationFailure when credentials are invalid',
      () async {
        when(() => mockApiClient.login(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/login/'),
            response: Response(
              requestOptions: RequestOptions(path: '/auth/login/'),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await repository.login(
          email: testEmail,
          password: testPassword,
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<AuthenticationFailure>()),
          (_) => fail('Should return failure'),
        );
      },
    );

    test('should return NetworkFailure when there is no internet', () async {
      when(() => mockApiClient.login(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login/'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.login(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure for 400 response', () async {
      when(() => mockApiClient.login(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login/'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login/'),
            statusCode: 400,
            data: {
              'email': ['This field is required'],
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.login(
        email: testEmail,
        password: testPassword,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('logout', () {
    test('should clear cache and return success', () async {
      when(
        () => mockTokenStorage.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh_token');
      when(() => mockApiClient.logout(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.clearCache()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, const Right(null));
      verify(() => mockLocalDataSource.clearCache()).called(1);
    });

    test('should clear cache even if API call fails', () async {
      when(
        () => mockTokenStorage.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh_token');
      when(() => mockApiClient.logout(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/logout/'),
          type: DioExceptionType.connectionError,
        ),
      );
      when(() => mockLocalDataSource.clearCache()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.isLeft(), true);
      verify(() => mockLocalDataSource.clearCache()).called(1);
    });
  });

  group('getCurrentUser', () {
    const testUser = UserModel(
      id: 1,
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
    );

    test('should return cached user if available', () async {
      when(
        () => mockLocalDataSource.getCachedUser(),
      ).thenAnswer((_) async => testUser);

      final result = await repository.getCurrentUser();

      expect(result, const Right(testUser));
      verifyNever(() => mockApiClient.getCurrentUser());
    });

    test('should fetch from API if no cached user', () async {
      when(
        () => mockLocalDataSource.getCachedUser(),
      ).thenAnswer((_) async => null);
      when(
        () => mockApiClient.getCurrentUser(),
      ).thenAnswer((_) async => testUser);
      when(() => mockLocalDataSource.cacheUser(any())).thenAnswer((_) async {});

      final result = await repository.getCurrentUser();

      expect(result, const Right(testUser));
      verify(() => mockApiClient.getCurrentUser()).called(1);
      verify(() => mockLocalDataSource.cacheUser(testUser)).called(1);
    });
  });

  group('isLoggedIn', () {
    test('should return true when user is logged in', () async {
      when(
        () => mockLocalDataSource.isLoggedIn(),
      ).thenAnswer((_) async => true);

      final result = await repository.isLoggedIn();

      expect(result, const Right(true));
    });

    test('should return false when user is not logged in', () async {
      when(
        () => mockLocalDataSource.isLoggedIn(),
      ).thenAnswer((_) async => false);

      final result = await repository.isLoggedIn();

      expect(result, const Right(false));
    });

    test('should return false on exception', () async {
      when(() => mockLocalDataSource.isLoggedIn()).thenThrow(Exception());

      final result = await repository.isLoggedIn();

      expect(result, const Right(false));
    });
  });
}
