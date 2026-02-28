import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class CreateIncomeUseCase implements UseCase<void, CreateIncomeParams> {
  final LedgerRepository _repository;

  CreateIncomeUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(CreateIncomeParams params) {
    return _repository.createIncome(
      amount: params.amount,
      accountId: params.accountId,
      categoryId: params.categoryId,
      date: params.date,
      note: params.note,
      tagIds: params.tagIds,
    );
  }
}

class CreateIncomeParams extends Equatable {
  final double amount;
  final int accountId;
  final int categoryId;
  final DateTime date;
  final String note;
  final List<int> tagIds;

  const CreateIncomeParams({
    required this.amount,
    required this.accountId,
    required this.categoryId,
    required this.date,
    required this.note,
    required this.tagIds,
  });

  @override
  List<Object?> get props => [amount, accountId, categoryId, date, note, tagIds];
}
