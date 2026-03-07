import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/auth_event_bus.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final AuthEventBus _authEventBus;
  final AuthRepository _authRepository;

  late final StreamSubscription<AuthEvent> _eventSubscription;

  AuthCubit(
    this._loginUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._checkAuthStatusUseCase,
    this._authEventBus,
    this._authRepository,
  ) : super(const AuthState.initial()) {
    _eventSubscription = _authEventBus.stream.listen((event) {
      if (event == AuthEvent.sessionExpired) {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    return super.close();
  }

  /// Same as [checkAuthStatus] but waits at least 2 seconds so the splash
  /// screen has time to animate before the router redirects.
  Future<void> checkAuthStatusDelayed() async {
    emit(const AuthState.loading());

    // Run auth check and minimum delay in parallel
    late AuthState resolvedState;
    await Future.wait([
      (() async {
        final result = await _checkAuthStatusUseCase(const NoParams());
        await result.fold(
          (failure) async {
            resolvedState = const AuthState.unauthenticated();
          },
          (isLoggedIn) async {
            if (isLoggedIn) {
              final userResult = await _getCurrentUserUseCase(const NoParams());
              resolvedState = userResult.fold(
                (_) => const AuthState.unauthenticated(),
                (user) => AuthState.authenticated(user),
              );
            } else {
              resolvedState = const AuthState.unauthenticated();
            }
          },
        );
      })(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    emit(resolvedState);
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());

    final result = await _checkAuthStatusUseCase(const NoParams());

    await result.fold(
      (failure) async => emit(const AuthState.unauthenticated()),
      (isLoggedIn) async {
        if (isLoggedIn) {
          await _loadCurrentUser();
        } else {
          emit(const AuthState.unauthenticated());
        }
      },
    );
  }

  Future<void> _loadCurrentUser() async {
    final result = await _getCurrentUserUseCase(const NoParams());

    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthState.loading());

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> logout() async {
    emit(const AuthState.loading());

    final result = await _logoutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  Future<String?> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) async {
    final result = await _authRepository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
    );

    return result.fold(
      (failure) => failure.message,
      (user) {
        emit(AuthState.authenticated(user));
        return null;
      },
    );
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      emit(const AuthState.unauthenticated());
    }
  }
}
