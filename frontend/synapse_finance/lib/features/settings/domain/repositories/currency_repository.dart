import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/exchange_rate.dart';
import '../entities/sub_currency.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, List<SubCurrency>>> getUserCurrencies();
  Future<Either<Failure, List<ExchangeRate>>> getExchangeRates();
  Future<Either<Failure, SubCurrency>> addSubCurrency(String currency, {String unitPosition});
  Future<Either<Failure, void>> deleteSubCurrency(int id);
  Future<Either<Failure, SubCurrency>> updateExchangeRate(int id, double rate);
  Future<Either<Failure, List<ExchangeRate>>> refreshRates();
  Future<Either<Failure, void>> changePrimaryCurrency(String currency);
}
