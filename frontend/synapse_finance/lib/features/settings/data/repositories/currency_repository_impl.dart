import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/sub_currency.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_api_client.dart';

@LazySingleton(as: CurrencyRepository)
class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyApiClient _apiClient;

  CurrencyRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<SubCurrency>>> getUserCurrencies() async {
    try {
      final currencies = await _apiClient.getUserCurrencies();
      return Right(currencies);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Left(NetworkFailure('No internet connection.'));
      }
      final detail = e.response?.data is Map
          ? (e.response!.data as Map)['detail'] as String? ??
              'Something went wrong'
          : 'Something went wrong';
      return Left(ServerFailure(detail));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }
}
