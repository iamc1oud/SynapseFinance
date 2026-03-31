import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class GetNetWorthUseCase {
  final LedgerRepository _repository;

  GetNetWorthUseCase(this._repository);

  Future<Either<Failure, double>> call() async {
    final result = await _repository.getAccounts(isActive: true);
    
    return result.fold(
      (failure) => Left(failure),
      (accounts) {
        final netWorth = accounts.fold<double>(
          0.0,
          (sum, account) => sum + account.balance,
        );
        return Right(netWorth);
      },
    );
  }
}