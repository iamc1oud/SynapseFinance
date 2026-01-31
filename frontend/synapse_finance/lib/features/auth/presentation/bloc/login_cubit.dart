import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_cubit.dart';
import 'auth_state.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  final AuthCubit _authCubit;

  LoginCubit(this._loginUseCase, this._authCubit) : super(const LoginState());

  void emailChanged(String email) {
    emit(state.copyWith(email: email, status: LoginStatus.initial));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(password: password, status: LoginStatus.initial));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> login() async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Please fill in all fields',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _loginUseCase(
      LoginParams(email: state.email, password: state.password),
    );

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(
            state.copyWith(
              status: LoginStatus.failure,
              errorMessage: failure.message,
              fieldErrors: failure.fieldErrors,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: LoginStatus.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (user) {
        _authCubit.emit(AuthState.authenticated(user));
        emit(state.copyWith(status: LoginStatus.success));
      },
    );
  }

  void clearError() {
    emit(state.copyWith(status: LoginStatus.initial));
  }
}
