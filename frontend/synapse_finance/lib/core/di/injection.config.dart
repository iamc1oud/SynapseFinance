// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_api_client.dart' as _i552;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i992;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart'
    as _i52;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/bloc/auth_cubit.dart' as _i52;
import '../../features/auth/presentation/bloc/login_cubit.dart' as _i281;
import '../../features/ledger/data/datasources/ledger_api_client.dart' as _i620;
import '../../features/ledger/data/repositories/ledger_repository_impl.dart'
    as _i621;
import '../../features/ledger/domain/repositories/ledger_repository.dart'
    as _i622;
import '../../features/ledger/domain/usecases/create_category_usecase.dart'
    as _i631;
import '../../features/ledger/domain/usecases/create_expense_usecase.dart'
    as _i623;
import '../../features/ledger/domain/usecases/create_income_usecase.dart'
    as _i624;
import '../../features/ledger/domain/usecases/create_transfer_usecase.dart'
    as _i625;
import '../../features/ledger/domain/usecases/get_accounts_usecase.dart'
    as _i626;
import '../../features/ledger/domain/usecases/get_categories_usecase.dart'
    as _i627;
import '../../features/ledger/domain/usecases/get_tags_usecase.dart' as _i628;
import '../../features/ledger/presentation/bloc/add_transaction_cubit.dart'
    as _i629;
import '../../features/ledger/presentation/bloc/add_transfer_cubit.dart'
    as _i630;
import '../network/auth_event_bus.dart' as _i100;
import '../network/auth_interceptor.dart' as _i908;
import '../network/dio_client.dart' as _i667;
import '../network/logging_interceptor.dart' as _i551;
import '../network/token_storage.dart' as _i964;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    final secureStorageModule = _$SecureStorageModule();
    final sharedPreferencesModule = _$SharedPreferencesModule();
    gh.lazySingleton<_i974.Logger>(() => dioModule.logger);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage,
    );
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i964.TokenStorage>(
      () => _i964.TokenStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i100.AuthEventBus>(() => _i100.AuthEventBus());
    gh.lazySingleton<_i551.LoggingInterceptor>(
      () => _i551.LoggingInterceptor(gh<_i974.Logger>()),
    );
    gh.lazySingleton<_i992.AuthLocalDataSource>(
      () => _i992.AuthLocalDataSourceImpl(
        gh<_i460.SharedPreferences>(),
        gh<_i964.TokenStorage>(),
      ),
    );
    gh.lazySingleton<_i908.AuthInterceptor>(
      () => _i908.AuthInterceptor(gh<_i964.TokenStorage>(), gh<_i100.AuthEventBus>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(
        gh<_i908.AuthInterceptor>(),
        gh<_i551.LoggingInterceptor>(),
      ),
    );
    gh.lazySingleton<_i552.AuthApiClient>(
      () => _i552.AuthApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i552.AuthApiClient>(),
        gh<_i992.AuthLocalDataSource>(),
        gh<_i964.TokenStorage>(),
      ),
    );
    gh.lazySingleton<_i52.CheckAuthStatusUseCase>(
      () => _i52.CheckAuthStatusUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i17.GetCurrentUserUseCase>(
      () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i52.AuthCubit>(
      () => _i52.AuthCubit(
        gh<_i188.LoginUseCase>(),
        gh<_i48.LogoutUseCase>(),
        gh<_i17.GetCurrentUserUseCase>(),
        gh<_i52.CheckAuthStatusUseCase>(),
        gh<_i100.AuthEventBus>(),
      ),
    );
    gh.factory<_i281.LoginCubit>(
      () => _i281.LoginCubit(gh<_i188.LoginUseCase>(), gh<_i52.AuthCubit>()),
    );

    // Ledger
    gh.lazySingleton<_i620.LedgerApiClient>(
      () => _i620.LedgerApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i622.LedgerRepository>(
      () => _i621.LedgerRepositoryImpl(gh<_i620.LedgerApiClient>()),
    );
    gh.lazySingleton<_i626.GetAccountsUseCase>(
      () => _i626.GetAccountsUseCase(gh<_i622.LedgerRepository>()),
    );
    gh.lazySingleton<_i627.GetCategoriesUseCase>(
      () => _i627.GetCategoriesUseCase(gh<_i622.LedgerRepository>()),
    );
    gh.lazySingleton<_i628.GetTagsUseCase>(
      () => _i628.GetTagsUseCase(gh<_i622.LedgerRepository>()),
    );
    gh.lazySingleton<_i631.CreateCategoryUseCase>(
      () => _i631.CreateCategoryUseCase(gh<_i622.LedgerRepository>()),
    );
    gh.lazySingleton<_i623.CreateExpenseUseCase>(
      () => _i623.CreateExpenseUseCase(gh<_i622.LedgerRepository>()),
    );
    gh.lazySingleton<_i624.CreateIncomeUseCase>(
      () => _i624.CreateIncomeUseCase(gh<_i622.LedgerRepository>()),
    );
    gh.lazySingleton<_i625.CreateTransferUseCase>(
      () => _i625.CreateTransferUseCase(gh<_i622.LedgerRepository>()),
    );
    gh.factory<_i629.AddTransactionCubit>(
      () => _i629.AddTransactionCubit(
        gh<_i626.GetAccountsUseCase>(),
        gh<_i627.GetCategoriesUseCase>(),
        gh<_i623.CreateExpenseUseCase>(),
        gh<_i624.CreateIncomeUseCase>(),
      ),
    );
    gh.factory<_i630.AddTransferCubit>(
      () => _i630.AddTransferCubit(
        gh<_i626.GetAccountsUseCase>(),
        gh<_i628.GetTagsUseCase>(),
        gh<_i625.CreateTransferUseCase>(),
      ),
    );
    return this;
  }
}

class _$DioModule extends _i667.DioModule {}

class _$SecureStorageModule extends _i964.SecureStorageModule {}

class _$SharedPreferencesModule extends _i992.SharedPreferencesModule {}
