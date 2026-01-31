import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
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

  AuthCubit(
    this._loginUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._checkAuthStatusUseCase,
  ) : super(const AuthState.initial());

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

  void clearError() {
    if (state.status == AuthStatus.error) {
      emit(const AuthState.unauthenticated());
    }
  }
}
