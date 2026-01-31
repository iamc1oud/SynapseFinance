import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:synapse_finance/core/errors/failures.dart';
import 'package:synapse_finance/core/usecases/usecase.dart';
import 'package:synapse_finance/features/auth/domain/entities/user.dart';
import 'package:synapse_finance/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:synapse_finance/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:synapse_finance/features/auth/domain/usecases/login_usecase.dart';
import 'package:synapse_finance/features/auth/domain/usecases/logout_usecase.dart';
import 'package:synapse_finance/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:synapse_finance/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockCheckAuthStatusUseCase extends Mock
    implements CheckAuthStatusUseCase {}

class FakeLoginParams extends Fake implements LoginParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late AuthCubit authCubit;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockCheckAuthStatusUseCase mockCheckAuthStatusUseCase;

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockCheckAuthStatusUseCase = MockCheckAuthStatusUseCase();
    authCubit = AuthCubit(
      mockLoginUseCase,
      mockLogoutUseCase,
      mockGetCurrentUserUseCase,
      mockCheckAuthStatusUseCase,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  const testUser = User(
    id: 1,
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
  );

  group('initial state', () {
    test('should be AuthState.initial', () {
      expect(authCubit.state, const AuthState.initial());
    });
  });

  group('checkAuthStatus', () {
    test('should emit authenticated when user is logged in', () async {
      when(
        () => mockCheckAuthStatusUseCase(any()),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => mockGetCurrentUserUseCase(any()),
      ).thenAnswer((_) async => const Right(testUser));

      final expectedStates = [
        const AuthState.loading(),
        const AuthState.authenticated(testUser),
      ];

      expectLater(authCubit.stream, emitsInOrder(expectedStates));

      await authCubit.checkAuthStatus();
    });

    test('should emit unauthenticated when user is not logged in', () async {
      when(
        () => mockCheckAuthStatusUseCase(any()),
      ).thenAnswer((_) async => const Right(false));

      final expectedStates = [
        const AuthState.loading(),
        const AuthState.unauthenticated(),
      ];

      expectLater(authCubit.stream, emitsInOrder(expectedStates));

      await authCubit.checkAuthStatus();
    });

    test('should emit unauthenticated on failure', () async {
      when(
        () => mockCheckAuthStatusUseCase(any()),
      ).thenAnswer((_) async => const Left(CacheFailure('Cache error')));

      final expectedStates = [
        const AuthState.loading(),
        const AuthState.unauthenticated(),
      ];

      expectLater(authCubit.stream, emitsInOrder(expectedStates));

      await authCubit.checkAuthStatus();
    });
  });

  group('login', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    test('should emit authenticated on successful login', () async {
      when(
        () => mockLoginUseCase(any()),
      ).thenAnswer((_) async => const Right(testUser));

      final expectedStates = [
        const AuthState.loading(),
        const AuthState.authenticated(testUser),
      ];

      expectLater(authCubit.stream, emitsInOrder(expectedStates));

      await authCubit.login(email: testEmail, password: testPassword);
    });

    test('should emit error on failed login', () async {
      when(() => mockLoginUseCase(any())).thenAnswer(
        (_) async => const Left(AuthenticationFailure('Invalid credentials')),
      );

      final expectedStates = [
        const AuthState.loading(),
        const AuthState.error('Invalid credentials'),
      ];

      expectLater(authCubit.stream, emitsInOrder(expectedStates));

      await authCubit.login(email: testEmail, password: testPassword);
    });
  });

  group('logout', () {
    test('should emit unauthenticated on successful logout', () async {
      when(
        () => mockLogoutUseCase(any()),
      ).thenAnswer((_) async => const Right(null));

      final expectedStates = [
        const AuthState.loading(),
        const AuthState.unauthenticated(),
      ];

      expectLater(authCubit.stream, emitsInOrder(expectedStates));

      await authCubit.logout();
    });

    test('should emit error on failed logout', () async {
      when(
        () => mockLogoutUseCase(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

      final expectedStates = [
        const AuthState.loading(),
        const AuthState.error('Server error'),
      ];

      expectLater(authCubit.stream, emitsInOrder(expectedStates));

      await authCubit.logout();
    });
  });

  group('clearError', () {
    test('should emit unauthenticated when in error state', () async {
      when(() => mockLoginUseCase(any())).thenAnswer(
        (_) async => const Left(AuthenticationFailure('Invalid credentials')),
      );

      await authCubit.login(email: 'test@test.com', password: 'password');

      expect(authCubit.state.status, AuthStatus.error);

      authCubit.clearError();

      expect(authCubit.state.status, AuthStatus.unauthenticated);
    });
  });
}
