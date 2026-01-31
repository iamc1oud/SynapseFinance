import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return _repository.register(
      email: params.email,
      password: params.password,
      passwordConfirm: params.passwordConfirm,
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String passwordConfirm;
  final String? firstName;
  final String? lastName;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.passwordConfirm,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    passwordConfirm,
    firstName,
    lastName,
  ];
}
