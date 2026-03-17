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

import '../../features/assistant/data/datasources/ai_service.dart' as _i96;
import '../../features/assistant/di/assistant_module.dart' as _i898;
import '../../features/assistant/presentation/bloc/chat_cubit.dart' as _i1024;
import '../../features/assistant/tools/tool_executor.dart' as _i853;
import '../../features/assistant/tools/tool_registry.dart' as _i30;
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
import '../../features/ledger/data/datasources/ledger_api_client.dart' as _i881;
import '../../features/ledger/data/repositories/ledger_repository_impl.dart'
    as _i321;
import '../../features/ledger/domain/repositories/ledger_repository.dart'
    as _i11;
import '../../features/ledger/domain/usecases/archive_account_usecase.dart'
    as _i292;
import '../../features/ledger/domain/usecases/archive_category_usecase.dart'
    as _i507;
import '../../features/ledger/domain/usecases/create_account_usecase.dart'
    as _i146;
import '../../features/ledger/domain/usecases/create_category_usecase.dart'
    as _i188;
import '../../features/ledger/domain/usecases/create_expense_usecase.dart'
    as _i1031;
import '../../features/ledger/domain/usecases/create_income_usecase.dart'
    as _i1038;
import '../../features/ledger/domain/usecases/create_transfer_usecase.dart'
    as _i283;
import '../../features/ledger/domain/usecases/get_accounts_usecase.dart'
    as _i326;
import '../../features/ledger/domain/usecases/get_categories_usecase.dart'
    as _i549;
import '../../features/ledger/domain/usecases/get_category_spending_usecase.dart'
    as _i817;
import '../../features/ledger/domain/usecases/get_tags_usecase.dart' as _i501;
import '../../features/ledger/domain/usecases/get_transactions_by_category_usecase.dart'
    as _i417;
import '../../features/ledger/domain/usecases/get_transactions_usecase.dart'
    as _i1058;
import '../../features/ledger/domain/usecases/update_account_usecase.dart'
    as _i426;
import '../../features/ledger/presentation/bloc/account_settings_cubit.dart'
    as _i718;
import '../../features/ledger/presentation/bloc/add_transaction_cubit.dart'
    as _i99;
import '../../features/ledger/presentation/bloc/add_transfer_cubit.dart'
    as _i784;
import '../../features/ledger/presentation/bloc/category_settings_cubit.dart'
    as _i696;
import '../../features/ledger/presentation/bloc/create_account_cubit.dart'
    as _i444;
import '../../features/ledger/presentation/bloc/create_category_cubit.dart'
    as _i395;
import '../../features/ledger/presentation/bloc/transaction_list_cubit.dart'
    as _i660;
import '../../features/settings/data/datasources/currency_api_client.dart'
    as _i1055;
import '../../features/settings/data/repositories/currency_repository_impl.dart'
    as _i575;
import '../../features/settings/domain/repositories/currency_repository.dart'
    as _i44;
import '../../features/settings/domain/usecases/get_user_currencies_usecase.dart'
    as _i165;
import '../../features/settings/presentation/bloc/currency_management_cubit.dart'
    as _i797;
import '../../features/subscriptions/data/datasources/subscription_api_client.dart'
    as _i22;
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart'
    as _i944;
import '../../features/subscriptions/domain/repositories/subscription_repository.dart'
    as _i384;
import '../../features/subscriptions/domain/usecases/create_subscription_usecase.dart'
    as _i33;
import '../../features/subscriptions/domain/usecases/delete_subscription_usecase.dart'
    as _i170;
import '../../features/subscriptions/domain/usecases/get_subscriptions_usecase.dart'
    as _i607;
import '../../features/subscriptions/domain/usecases/toggle_subscription_usecase.dart'
    as _i990;
import '../../features/subscriptions/presentation/bloc/add_subscription_cubit.dart'
    as _i843;
import '../../features/subscriptions/presentation/bloc/subscription_list_cubit.dart'
    as _i978;
import '../network/auth_event_bus.dart' as _i702;
import '../network/auth_interceptor.dart' as _i908;
import '../network/dio_client.dart' as _i667;
import '../network/logging_interceptor.dart' as _i551;
import '../network/token_storage.dart' as _i964;
import '../theme/theme_cubit.dart' as _i611;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    final secureStorageModule = _$SecureStorageModule();
    final assistantModule = _$AssistantModule();
    final sharedPreferencesModule = _$SharedPreferencesModule();
    gh.lazySingleton<_i702.AuthEventBus>(() => _i702.AuthEventBus());
    gh.lazySingleton<_i974.Logger>(() => dioModule.logger);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage,
    );
    gh.lazySingleton<_i30.ToolRegistry>(() => assistantModule.toolRegistry);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i96.AiService>(
      () => _i96.AiService(gh<_i30.ToolRegistry>()),
    );
    gh.lazySingleton<_i964.TokenStorage>(
      () => _i964.TokenStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i611.ThemeCubit>(
      () => _i611.ThemeCubit(gh<_i460.SharedPreferences>()),
    );
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
      () => _i908.AuthInterceptor(
        gh<_i964.TokenStorage>(),
        gh<_i702.AuthEventBus>(),
      ),
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
    gh.lazySingleton<_i881.LedgerApiClient>(
      () => _i881.LedgerApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1055.CurrencyApiClient>(
      () => _i1055.CurrencyApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i22.SubscriptionApiClient>(
      () => _i22.SubscriptionApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i552.AuthApiClient>(),
        gh<_i992.AuthLocalDataSource>(),
        gh<_i964.TokenStorage>(),
      ),
    );
    gh.lazySingleton<_i11.LedgerRepository>(
      () => _i321.LedgerRepositoryImpl(gh<_i881.LedgerApiClient>()),
    );
    gh.lazySingleton<_i853.ToolExecutor>(
      () => _i853.ToolExecutor(
        gh<_i881.LedgerApiClient>(),
        gh<_i22.SubscriptionApiClient>(),
        gh<_i1055.CurrencyApiClient>(),
      ),
    );
    gh.lazySingleton<_i44.CurrencyRepository>(
      () => _i575.CurrencyRepositoryImpl(gh<_i1055.CurrencyApiClient>()),
    );
    gh.lazySingleton<_i292.ArchiveAccountUseCase>(
      () => _i292.ArchiveAccountUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i292.RestoreAccountUseCase>(
      () => _i292.RestoreAccountUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i507.ArchiveCategoryUseCase>(
      () => _i507.ArchiveCategoryUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i507.RestoreCategoryUseCase>(
      () => _i507.RestoreCategoryUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i146.CreateAccountUseCase>(
      () => _i146.CreateAccountUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i188.CreateCategoryUseCase>(
      () => _i188.CreateCategoryUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i1031.CreateExpenseUseCase>(
      () => _i1031.CreateExpenseUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i1038.CreateIncomeUseCase>(
      () => _i1038.CreateIncomeUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i283.CreateTransferUseCase>(
      () => _i283.CreateTransferUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i326.GetAccountsUseCase>(
      () => _i326.GetAccountsUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i549.GetCategoriesUseCase>(
      () => _i549.GetCategoriesUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i817.GetCategorySpendingUseCase>(
      () => _i817.GetCategorySpendingUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i501.GetTagsUseCase>(
      () => _i501.GetTagsUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i417.GetTransactionsByCategoryUseCase>(
      () => _i417.GetTransactionsByCategoryUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i1058.GetTransactionsUseCase>(
      () => _i1058.GetTransactionsUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.lazySingleton<_i426.UpdateAccountUseCase>(
      () => _i426.UpdateAccountUseCase(gh<_i11.LedgerRepository>()),
    );
    gh.factory<_i784.AddTransferCubit>(
      () => _i784.AddTransferCubit(
        gh<_i326.GetAccountsUseCase>(),
        gh<_i501.GetTagsUseCase>(),
        gh<_i283.CreateTransferUseCase>(),
      ),
    );
    gh.lazySingleton<_i384.SubscriptionRepository>(
      () => _i944.SubscriptionRepositoryImpl(gh<_i22.SubscriptionApiClient>()),
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
    gh.factory<_i696.CategorySettingsCubit>(
      () => _i696.CategorySettingsCubit(
        gh<_i549.GetCategoriesUseCase>(),
        gh<_i507.ArchiveCategoryUseCase>(),
        gh<_i507.RestoreCategoryUseCase>(),
      ),
    );
    gh.factory<_i395.CreateCategoryCubit>(
      () => _i395.CreateCategoryCubit(gh<_i188.CreateCategoryUseCase>()),
    );
    gh.factory<_i444.CreateAccountCubit>(
      () => _i444.CreateAccountCubit(gh<_i146.CreateAccountUseCase>()),
    );
    gh.factory<_i718.AccountSettingsCubit>(
      () => _i718.AccountSettingsCubit(
        gh<_i326.GetAccountsUseCase>(),
        gh<_i292.ArchiveAccountUseCase>(),
        gh<_i292.RestoreAccountUseCase>(),
        gh<_i426.UpdateAccountUseCase>(),
      ),
    );
    gh.lazySingleton<_i52.AuthCubit>(
      () => _i52.AuthCubit(
        gh<_i188.LoginUseCase>(),
        gh<_i48.LogoutUseCase>(),
        gh<_i17.GetCurrentUserUseCase>(),
        gh<_i52.CheckAuthStatusUseCase>(),
        gh<_i702.AuthEventBus>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i797.CurrencyManagementCubit>(
      () => _i797.CurrencyManagementCubit(gh<_i44.CurrencyRepository>()),
    );
    gh.lazySingleton<_i165.GetUserCurrenciesUseCase>(
      () => _i165.GetUserCurrenciesUseCase(gh<_i44.CurrencyRepository>()),
    );
    gh.factory<_i660.TransactionListCubit>(
      () => _i660.TransactionListCubit(
        gh<_i417.GetTransactionsByCategoryUseCase>(),
        gh<_i44.CurrencyRepository>(),
      ),
    );
    gh.factory<_i1024.ChatCubit>(
      () => _i1024.ChatCubit(
        gh<_i96.AiService>(),
        gh<_i30.ToolRegistry>(),
        gh<_i853.ToolExecutor>(),
      ),
    );
    gh.factory<_i99.AddTransactionCubit>(
      () => _i99.AddTransactionCubit(
        gh<_i326.GetAccountsUseCase>(),
        gh<_i549.GetCategoriesUseCase>(),
        gh<_i1031.CreateExpenseUseCase>(),
        gh<_i1038.CreateIncomeUseCase>(),
        gh<_i165.GetUserCurrenciesUseCase>(),
      ),
    );
    gh.lazySingleton<_i33.CreateSubscriptionUseCase>(
      () => _i33.CreateSubscriptionUseCase(gh<_i384.SubscriptionRepository>()),
    );
    gh.lazySingleton<_i170.DeleteSubscriptionUseCase>(
      () => _i170.DeleteSubscriptionUseCase(gh<_i384.SubscriptionRepository>()),
    );
    gh.lazySingleton<_i607.GetSubscriptionsUseCase>(
      () => _i607.GetSubscriptionsUseCase(gh<_i384.SubscriptionRepository>()),
    );
    gh.lazySingleton<_i990.ToggleSubscriptionUseCase>(
      () => _i990.ToggleSubscriptionUseCase(gh<_i384.SubscriptionRepository>()),
    );
    gh.factory<_i843.AddSubscriptionCubit>(
      () => _i843.AddSubscriptionCubit(
        gh<_i326.GetAccountsUseCase>(),
        gh<_i549.GetCategoriesUseCase>(),
        gh<_i33.CreateSubscriptionUseCase>(),
        gh<_i165.GetUserCurrenciesUseCase>(),
      ),
    );
    gh.factory<_i978.SubscriptionListCubit>(
      () => _i978.SubscriptionListCubit(
        gh<_i607.GetSubscriptionsUseCase>(),
        gh<_i990.ToggleSubscriptionUseCase>(),
        gh<_i170.DeleteSubscriptionUseCase>(),
      ),
    );
    gh.factory<_i281.LoginCubit>(
      () => _i281.LoginCubit(gh<_i188.LoginUseCase>(), gh<_i52.AuthCubit>()),
    );
    return this;
  }
}

class _$DioModule extends _i667.DioModule {}

class _$SecureStorageModule extends _i964.SecureStorageModule {}

class _$AssistantModule extends _i898.AssistantModule {}

class _$SharedPreferencesModule extends _i992.SharedPreferencesModule {}
