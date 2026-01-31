import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final String email;
  final String password;
  final bool obscurePassword;
  final String? errorMessage;
  final Map<String, List<String>>? fieldErrors;

  const LoginState({
    this.status = LoginStatus.initial,
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.errorMessage,
    this.fieldErrors,
  });

  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  String? get emailError => fieldErrors?['email']?.firstOrNull;
  String? get passwordError => fieldErrors?['password']?.firstOrNull;

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    bool? obscurePassword,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
    status,
    email,
    password,
    obscurePassword,
    errorMessage,
    fieldErrors,
  ];
}
