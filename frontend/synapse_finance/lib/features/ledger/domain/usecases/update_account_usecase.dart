import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/account.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class UpdateAccountUseCase
    implements UseCase<Account, UpdateAccountParams> {
  final LedgerRepository _repository;

  UpdateAccountUseCase(this._repository);

  @override
  Future<Either<Failure, Account>> call(UpdateAccountParams params) {
    return _repository.updateAccount(
      id: params.id,
      name: params.name,
      accountType: params.accountType,
      currency: params.currency,
      icon: params.icon,
    );
  }
}

class UpdateAccountParams extends Equatable {
  final int id;
  final String? name;
  final String? accountType;
  final String? currency;
  final String? icon;

  const UpdateAccountParams({
    required this.id,
    this.name,
    this.accountType,
    this.currency,
    this.icon,
  });

  @override
  List<Object?> get props => [id, name, accountType, currency, icon];
}
