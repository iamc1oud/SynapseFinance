import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>()..checkAuthStatus(),
      child: Builder(
        builder: (context) {
          final authCubit = context.read<AuthCubit>();
          final appRouter = AppRouter(authCubit);

          return MaterialApp.router(
            title: 'AI Expense Manager',

            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
