import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/exchange_rate.dart';
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
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<ExchangeRate>>> getExchangeRates() async {
    try {
      final rates = await _apiClient.getExchangeRates();
      return Right(rates);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, SubCurrency>> addSubCurrency(
    String currency, {
    String unitPosition = 'front',
  }) async {
    try {
      final sc = await _apiClient.addSubCurrency(
        currency,
        unitPosition: unitPosition,
      );
      return Right(sc);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubCurrency(int id) async {
    try {
      await _apiClient.deleteSubCurrency(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, SubCurrency>> updateExchangeRate(
    int id,
    double rate,
  ) async {
    try {
      final sc = await _apiClient.updateExchangeRate(id, rate);
      return Right(sc);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<ExchangeRate>>> refreshRates() async {
    try {
      final rates = await _apiClient.refreshRates();
      return Right(rates);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePrimaryCurrency(String currency) async {
    try {
      await _apiClient.changePrimaryCurrency(currency);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure('No internet connection.');
    }
    final detail = e.response?.data is Map
        ? (e.response!.data as Map)['detail'] as String? ??
            'Something went wrong'
        : 'Something went wrong';
    return ServerFailure(detail);
  }
}
