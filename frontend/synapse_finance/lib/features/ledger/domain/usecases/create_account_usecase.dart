import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/account.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class CreateAccountUseCase
    implements UseCase<Account, CreateAccountParams> {
  final LedgerRepository _repository;

  CreateAccountUseCase(this._repository);

  @override
  Future<Either<Failure, Account>> call(CreateAccountParams params) {
    return _repository.createAccount(
      name: params.name,
      accountType: params.accountType,
      balance: params.balance,
      currency: params.currency,
      icon: params.icon,
    );
  }
}

class CreateAccountParams {
  final String name;
  final String accountType;
  final double balance;
  final String currency;
  final String icon;

  const CreateAccountParams({
    required this.name,
    required this.accountType,
    this.balance = 0.0,
    this.currency = 'USD',
    this.icon = '',
  });
}
