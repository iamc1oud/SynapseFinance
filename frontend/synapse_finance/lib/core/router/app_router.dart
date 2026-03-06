import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/ledger/domain/usecases/create_category_usecase.dart';
import '../../features/ledger/presentation/bloc/add_transaction_cubit.dart';
import '../../features/ledger/presentation/bloc/add_transfer_cubit.dart';
import '../../features/ledger/presentation/bloc/create_category_cubit.dart';
import '../../features/ledger/presentation/pages/add_transaction_page.dart';
import '../../features/ledger/presentation/pages/add_transfer_page.dart';
import '../../features/ledger/presentation/pages/create_category_page.dart';
import '../di/injection.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter(this.authCubit);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final status = authCubit.state.status;
      final location = state.matchedLocation;

      // Stay on splash while auth is resolving
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return location == '/splash' ? null : '/splash';
      }

      // Auth resolved — navigate away from splash
      final isAuthenticated = status == AuthStatus.authenticated;

      if (location == '/splash') {
        return isAuthenticated ? '/' : '/login';
      }

      if (!isAuthenticated && location != '/login') {
        return '/login';
      }

      if (isAuthenticated && location == '/login') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AddTransactionCubit>(),
          child: const AddTransactionPage(),
        ),
      ),
      GoRoute(
        path: '/add-transfer',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AddTransferCubit>(),
          child: const AddTransferPage(),
        ),
      ),
      GoRoute(
        path: '/create-category',
        builder: (context, state) => BlocProvider(
          create: (_) => CreateCategoryCubit(getIt<CreateCategoryUseCase>()),
          child: const CreateCategoryPage(),
        ),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
