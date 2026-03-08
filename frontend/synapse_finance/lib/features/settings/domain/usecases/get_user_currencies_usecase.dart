import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sub_currency.dart';
import '../repositories/currency_repository.dart';

@lazySingleton
class GetUserCurrenciesUseCase implements UseCase<List<SubCurrency>, NoParams> {
  final CurrencyRepository _repository;

  GetUserCurrenciesUseCase(this._repository);

  @override
  Future<Either<Failure, List<SubCurrency>>> call(NoParams params) {
    return _repository.getUserCurrencies();
  }
}
