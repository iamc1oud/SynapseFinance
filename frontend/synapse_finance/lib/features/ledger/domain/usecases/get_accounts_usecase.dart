import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/account.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class GetAccountsUseCase implements UseCase<List<Account>, GetAccountsParams> {
  final LedgerRepository _repository;

  GetAccountsUseCase(this._repository);

  @override
  Future<Either<Failure, List<Account>>> call(GetAccountsParams params) {
    return _repository.getAccounts(isActive: params.isActive);
  }
}

class GetAccountsParams extends Equatable {
  final bool? isActive;

  const GetAccountsParams({this.isActive});

  @override
  List<Object?> get props => [isActive];
}
