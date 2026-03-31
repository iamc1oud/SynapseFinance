import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/home_widget_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';

/// Used for Background Updates using Workmanager Plugin
@pragma("vm:entry-point")
void callbackDispatcher() async {
  // Initialize dependencies for background task
  await configureDependencies();
  
  Workmanager().executeTask((taskName, inputData) async {
    try {
      final homeWidgetService = getIt<HomeWidgetService>();
      await homeWidgetService.updateNetWorthWidget();
      return true;
    } catch (e) {
      // Fallback to basic update if service fails
      final now = DateTime.now();
      await Future.wait<bool?>([
        HomeWidget.saveWidgetData('title', 'Synapse Finance'),
        HomeWidget.saveWidgetData(
          'message',
          'Last updated: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        ),
      ]);
      
      if (Platform.isAndroid) {
        await HomeWidget.updateWidget(
          qualifiedAndroidName: 'com.example.synapse_finance.SynapseFinanceWidgetReceiver',
        );
      } else if (Platform.isIOS) {
        await HomeWidget.updateWidget(
          iOSName: 'SynapseFinanceWidget',
        );
      }
      return false;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await configureDependencies();
  
  // Initialize home widget service
  final homeWidgetService = getIt<HomeWidgetService>();
  await homeWidgetService.initialize();
  
  // Initialize deep link service
  final deepLinkService = getIt<DeepLinkService>();
  await deepLinkService.initialize();
  
  // Initialize workmanager for background updates
  Workmanager().initialize(callbackDispatcher);
  
  // Schedule periodic net worth updates (every 15 minutes)
  Workmanager().registerPeriodicTask(
    'net_worth_update',
    'updateNetWorth',
    frequency: const Duration(minutes: 15),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
        BlocProvider(
          create: (_) => getIt<AuthCubit>()..checkAuthStatusDelayed(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authCubit = context.read<AuthCubit>();
          final appRouter = AppRouter(authCubit);

          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                title: 'Synapse Finance',
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                routerConfig: appRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
