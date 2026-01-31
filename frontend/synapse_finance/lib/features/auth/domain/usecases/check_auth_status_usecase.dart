import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class CheckAuthStatusUseCase implements UseCase<bool, NoParams> {
  final AuthRepository _repository;

  CheckAuthStatusUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return _repository.isLoggedIn();
  }
}
