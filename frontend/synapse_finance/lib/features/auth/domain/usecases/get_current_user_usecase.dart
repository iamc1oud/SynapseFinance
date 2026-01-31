import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class GetCurrentUserUseCase implements UseCase<User, NoParams> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
