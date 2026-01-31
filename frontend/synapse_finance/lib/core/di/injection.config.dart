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
      () => _i908.AuthInterceptor(gh<_i964.TokenStorage>()),
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

class _$SharedPreferencesModule extends _i992.SharedPreferencesModule {}
