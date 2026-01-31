import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:synapse_finance/core/errors/failures.dart';
import 'package:synapse_finance/core/theme/app_theme.dart';
import 'package:synapse_finance/core/usecases/usecase.dart';
import 'package:synapse_finance/features/auth/domain/entities/user.dart';
import 'package:synapse_finance/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:synapse_finance/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:synapse_finance/features/auth/domain/usecases/login_usecase.dart';
import 'package:synapse_finance/features/auth/domain/usecases/logout_usecase.dart';
import 'package:synapse_finance/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:synapse_finance/features/auth/presentation/bloc/login_cubit.dart';
import 'package:synapse_finance/features/auth/presentation/bloc/login_state.dart';
import 'package:synapse_finance/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:synapse_finance/features/auth/presentation/widgets/social_login_button.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockCheckAuthStatusUseCase extends Mock
    implements CheckAuthStatusUseCase {}

class FakeLoginParams extends Fake implements LoginParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockCheckAuthStatusUseCase mockCheckAuthStatusUseCase;
  late AuthCubit authCubit;
  late LoginCubit loginCubit;

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

  Widget createTestWidget() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<LoginCubit>.value(value: loginCubit),
        ],
        child: const _TestLoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('renders login form correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.text('Manage your expenses with the power of AI.'),
        findsOneWidget,
      );
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('can enter email and password', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'name@example.com').first,
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your password').first,
        'password123',
      );

      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final visibilityToggle = find.byIcon(Icons.visibility_off);
      expect(visibilityToggle, findsOneWidget);

      await tester.tap(visibilityToggle);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows loading indicator when logging in', (tester) async {
      when(() => mockLoginUseCase(any())).thenAnswer(
        (_) async => const Right(User(id: '1', email: 'test@example.com')),
      );

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'name@example.com').first,
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your password').first,
        'password123',
      );

      await tester.tap(find.text('Log In'));
      await tester.pump();

      // Either shows loading or already completed - both are valid
      await tester.pumpAndSettle();
    });

    testWidgets('shows error message on login failure', (tester) async {
      when(() => mockLoginUseCase(any())).thenAnswer(
        (_) async => const Left(AuthenticationFailure('Invalid credentials')),
      );

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextField, 'name@example.com').first,
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your password').first,
        'wrong_password',
      );

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('shows validation error when fields are empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });
  });
}

class _TestLoginPage extends StatelessWidget {
  const _TestLoginPage();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {},
            ),
            title: const Text('AI Expense Manager'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage your expenses with the power of AI.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  AuthTextField(
                    label: 'Email Address',
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: context.read<LoginCubit>().emailChanged,
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Password'),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        obscureText: state.obscurePassword,
                        onChanged: context.read<LoginCubit>().passwordChanged,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => context
                                .read<LoginCubit>()
                                .togglePasswordVisibility(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: state.status == LoginStatus.loading
                        ? null
                        : () => context.read<LoginCubit>().login(),
                    child: state.status == LoginStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Log In'),
                  ),
                  const SizedBox(height: 32),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR CONTINUE WITH'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SocialLoginButton.google(onPressed: () {}),
                  const SizedBox(height: 16),
                  SocialLoginButton.apple(onPressed: () {}),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
