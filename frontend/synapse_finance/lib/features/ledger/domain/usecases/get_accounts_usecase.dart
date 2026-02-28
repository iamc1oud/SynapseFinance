import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/account.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class GetAccountsUseCase implements UseCase<List<Account>, NoParams> {
  final LedgerRepository _repository;

  GetAccountsUseCase(this._repository);

  @override
  Future<Either<Failure, List<Account>>> call(NoParams params) {
    return _repository.getAccounts();
  }
}
