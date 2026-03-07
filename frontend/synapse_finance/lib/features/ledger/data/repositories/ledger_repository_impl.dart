import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_spending.dart';
import '../../domain/entities/category_transaction_group.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../datasources/ledger_api_client.dart';

@LazySingleton(as: LedgerRepository)
class LedgerRepositoryImpl implements LedgerRepository {
  final LedgerApiClient _apiClient;

  LedgerRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<Account>>> getAccounts({bool? isActive}) async {
    try {
      final accounts = await _apiClient.getAccounts(isActive: isActive);
      return Right(accounts);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Account>> createAccount({
    required String name,
    required String accountType,
    required double balance,
    required String currency,
    required String icon,
  }) async {
    try {
      final account = await _apiClient.createAccount(
        name: name,
        accountType: accountType,
        balance: balance,
        currency: currency,
        icon: icon,
      );
      return Right(account);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Account>> updateAccount({
    required int id,
    String? name,
    String? accountType,
    String? currency,
    String? icon,
  }) async {
    try {
      final account = await _apiClient.updateAccount(
        id,
        name: name,
        accountType: accountType,
        currency: currency,
        icon: icon,
      );
      return Right(account);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Account>> archiveAccount({required int id}) async {
    try {
      final account = await _apiClient.archiveAccount(id);
      return Right(account);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Account>> restoreAccount({required int id}) async {
    try {
      final account = await _apiClient.restoreAccount(id);
      return Right(account);
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
  Future<Either<Failure, Category>> createCategory({
    required String name,
    required String icon,
    required String categoryType,
  }) async {
    try {
      final category = await _apiClient.createCategory(
        name: name,
        icon: icon,
        categoryType: categoryType,
      );
      return Right(category);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Category>> archiveCategory({required int id}) async {
    try {
      final category = await _apiClient.archiveCategory(id);
      return Right(category);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Category>> restoreCategory({required int id}) async {
    try {
      final category = await _apiClient.restoreCategory(id);
      return Right(category);
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
  Future<Either<Failure, List<Transaction>>> getTransactions({
    String? transactionType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final transactions = await _apiClient.getTransactions(
        transactionType: transactionType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      return Right(transactions);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<CategorySpending>>> getCategorySpending({
    String transactionType = 'expense',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final spending = await _apiClient.getCategorySpending(
        transactionType: transactionType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      return Right(spending);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryTransactionGroup>>> getTransactionsByCategory({
    String transactionType = 'expense',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final groups = await _apiClient.getTransactionsByCategory(
        transactionType: transactionType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      return Right(groups);
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
        final detail = _extractErrorMessage(e.response?.data);
        return ServerFailure(detail, statusCode: statusCode);
      default:
        return ServerFailure('${e.message}');
    }
  }

  /// Handles the two error shapes Django Ninja can return:
  ///   • Map  → {"detail": "message"}
  ///   • List → [{"loc": [...], "msg": "...", "type": "..."}]  (422 validation)
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Something went wrong';
    if (data is String) return data.isNotEmpty ? data : 'Something went wrong';
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map) return first['msg'] as String? ?? 'Something went wrong';
      }
      return 'Something went wrong';
    }
    if (data is List && data.isNotEmpty) {
      // Django Ninja 422 validation format
      final first = data.first;
      if (first is Map) return first['msg'] as String? ?? 'Validation error';
      return 'Validation error';
    }
    return 'Something went wrong';
  }
}
