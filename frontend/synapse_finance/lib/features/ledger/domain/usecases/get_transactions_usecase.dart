import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class GetTransactionsUseCase {
  final LedgerRepository _repository;

  GetTransactionsUseCase(this._repository);

  Future<Either<Failure, List<Transaction>>> call(
    GetTransactionsParams params,
  ) {
    return _repository.getTransactions(
      transactionType: params.transactionType,
      dateFrom: params.dateFrom,
      dateTo: params.dateTo,
    );
  }
}

class GetTransactionsParams {
  final String? transactionType;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const GetTransactionsParams({
    this.transactionType,
    this.dateFrom,
    this.dateTo,
  });
}
