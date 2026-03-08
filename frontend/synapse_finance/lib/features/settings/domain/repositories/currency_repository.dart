import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/sub_currency.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, List<SubCurrency>>> getUserCurrencies();
}
