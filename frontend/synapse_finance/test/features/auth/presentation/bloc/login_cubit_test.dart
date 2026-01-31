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
import 'package:synapse_finance/features/auth/presentation/bloc/login_cubit.dart';
import 'package:synapse_finance/features/auth/presentation/bloc/login_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockCheckAuthStatusUseCase extends Mock
    implements CheckAuthStatusUseCase {}

class FakeLoginParams extends Fake implements LoginParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late LoginCubit loginCubit;
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
    loginCubit = LoginCubit(mockLoginUseCase, authCubit);
  });

  tearDown(() {
    loginCubit.close();
    authCubit.close();
  });

  const testUser = User(
    id: 1,
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
  );

  group('initial state', () {
    test('should have empty email and password', () {
      expect(loginCubit.state.email, '');
      expect(loginCubit.state.password, '');
      expect(loginCubit.state.status, LoginStatus.initial);
      expect(loginCubit.state.obscurePassword, true);
    });
  });

  group('emailChanged', () {
    test('should update email', () {
      loginCubit.emailChanged('test@example.com');

      expect(loginCubit.state.email, 'test@example.com');
      expect(loginCubit.state.status, LoginStatus.initial);
    });
  });

  group('passwordChanged', () {
    test('should update password', () {
      loginCubit.passwordChanged('password123');

      expect(loginCubit.state.password, 'password123');
      expect(loginCubit.state.status, LoginStatus.initial);
    });
  });

  group('togglePasswordVisibility', () {
    test('should toggle obscurePassword', () {
      expect(loginCubit.state.obscurePassword, true);

      loginCubit.togglePasswordVisibility();
      expect(loginCubit.state.obscurePassword, false);

      loginCubit.togglePasswordVisibility();
      expect(loginCubit.state.obscurePassword, true);
    });
  });

  group('login', () {
    test('should emit failure when email and password are empty', () async {
      await loginCubit.login();

      expect(loginCubit.state.status, LoginStatus.failure);
      expect(loginCubit.state.errorMessage, 'Please fill in all fields');
    });

    test('should emit success on successful login', () async {
      when(
        () => mockLoginUseCase(any()),
      ).thenAnswer((_) async => const Right(testUser));

      loginCubit.emailChanged('test@example.com');
      loginCubit.passwordChanged('password123');

      await loginCubit.login();

      expect(loginCubit.state.status, LoginStatus.success);
    });

    test('should emit failure on failed login', () async {
      when(() => mockLoginUseCase(any())).thenAnswer(
        (_) async => const Left(AuthenticationFailure('Invalid credentials')),
      );

      loginCubit.emailChanged('test@example.com');
      loginCubit.passwordChanged('password123');

      await loginCubit.login();

      expect(loginCubit.state.status, LoginStatus.failure);
      expect(loginCubit.state.errorMessage, 'Invalid credentials');
    });

    test('should emit validation errors on 400 response', () async {
      when(() => mockLoginUseCase(any())).thenAnswer(
        (_) async => const Left(
          ValidationFailure(
            'Validation error',
            fieldErrors: {
              'email': ['Invalid email format'],
            },
          ),
        ),
      );

      loginCubit.emailChanged('invalid-email');
      loginCubit.passwordChanged('password123');

      await loginCubit.login();

      expect(loginCubit.state.status, LoginStatus.failure);
      expect(loginCubit.state.emailError, 'Invalid email format');
    });
  });

  group('clearError', () {
    test('should clear error and reset status', () async {
      when(() => mockLoginUseCase(any())).thenAnswer(
        (_) async => const Left(AuthenticationFailure('Invalid credentials')),
      );

      loginCubit.emailChanged('test@example.com');
      loginCubit.passwordChanged('password123');
      await loginCubit.login();

      expect(loginCubit.state.status, LoginStatus.failure);

      loginCubit.clearError();

      expect(loginCubit.state.status, LoginStatus.initial);
      expect(loginCubit.state.errorMessage, null);
    });
  });

  group('isValid', () {
    test('should return false when email is empty', () {
      loginCubit.passwordChanged('password123');

      expect(loginCubit.state.isValid, false);
    });

    test('should return false when password is empty', () {
      loginCubit.emailChanged('test@example.com');

      expect(loginCubit.state.isValid, false);
    });

    test('should return true when both email and password are provided', () {
      loginCubit.emailChanged('test@example.com');
      loginCubit.passwordChanged('password123');

      expect(loginCubit.state.isValid, true);
    });
  });
}
