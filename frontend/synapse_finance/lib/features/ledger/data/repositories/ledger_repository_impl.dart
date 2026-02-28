import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../datasources/ledger_api_client.dart';

@LazySingleton(as: LedgerRepository)
class LedgerRepositoryImpl implements LedgerRepository {
  final LedgerApiClient _apiClient;

  LedgerRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    try {
      final accounts = await _apiClient.getAccounts();
      return Right(accounts);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories({
    String? categoryType,
  }) async {
    try {
      final categories = await _apiClient.getCategories(
        categoryType: categoryType,
      );
      return Right(categories);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> getTags() async {
    try {
      final tags = await _apiClient.getTags();
      return Right(tags);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> createExpense({
    required double amount,
    required int accountId,
    required int categoryId,
    required DateTime date,
    required String note,
    required List<int> tagIds,
  }) async {
    try {
      await _apiClient.createExpense(
        amount: amount,
        accountId: accountId,
        categoryId: categoryId,
        date: DateFormat('yyyy-MM-dd').format(date),
        note: note,
        tagIds: tagIds,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> createIncome({
    required double amount,
    required int accountId,
    required int categoryId,
    required DateTime date,
    required String note,
    required List<int> tagIds,
  }) async {
    try {
      await _apiClient.createIncome(
        amount: amount,
        accountId: accountId,
        categoryId: categoryId,
        date: DateFormat('yyyy-MM-dd').format(date),
        note: note,
        tagIds: tagIds,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> createTransfer({
    required double amount,
    required int fromAccountId,
    required int toAccountId,
    required DateTime date,
    required String note,
    required List<int> tagIds,
  }) async {
    try {
      await _apiClient.createTransfer(
        amount: amount,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        date: DateFormat('yyyy-MM-dd').format(date),
        note: note,
        tagIds: tagIds,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final detail =
            e.response?.data?['detail'] as String? ?? 'Something went wrong';
        return ServerFailure(detail, statusCode: statusCode);
      default:
        return ServerFailure('${e.message}');
    }
  }
}
