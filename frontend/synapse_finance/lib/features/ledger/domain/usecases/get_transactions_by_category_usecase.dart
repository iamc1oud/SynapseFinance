import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/category_transaction_group.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class GetTransactionsByCategoryUseCase {
  final LedgerRepository _repository;

  GetTransactionsByCategoryUseCase(this._repository);

  Future<Either<Failure, List<CategoryTransactionGroup>>> call(
    GetTransactionsByCategoryParams params,
  ) {
    return _repository.getTransactionsByCategory(
      transactionType: params.transactionType,
      dateFrom: params.dateFrom,
      dateTo: params.dateTo,
    );
  }
}

class GetTransactionsByCategoryParams {
  final String transactionType;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const GetTransactionsByCategoryParams({
    this.transactionType = 'expense',
    this.dateFrom,
    this.dateTo,
  });
}
