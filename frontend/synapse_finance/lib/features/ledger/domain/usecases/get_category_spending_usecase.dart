import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/category_spending.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class GetCategorySpendingUseCase {
  final LedgerRepository _repository;

  GetCategorySpendingUseCase(this._repository);

  Future<Either<Failure, List<CategorySpending>>> call(
    GetCategorySpendingParams params,
  ) {
    return _repository.getCategorySpending(
      transactionType: params.transactionType,
      dateFrom: params.dateFrom,
      dateTo: params.dateTo,
    );
  }
}

class GetCategorySpendingParams {
  final String transactionType;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const GetCategorySpendingParams({
    this.transactionType = 'expense',
    this.dateFrom,
    this.dateTo,
  });
}
