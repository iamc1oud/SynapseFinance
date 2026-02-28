import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account.dart';
import '../entities/category.dart';
import '../entities/category_spending.dart';
import '../entities/category_transaction_group.dart';
import '../entities/tag.dart';
import '../entities/transaction.dart';

abstract class LedgerRepository {
  Future<Either<Failure, List<Account>>> getAccounts();
  Future<Either<Failure, List<Category>>> getCategories({String? categoryType});
  Future<Either<Failure, Category>> createCategory({
    required String name,
    required String icon,
    required String categoryType,
  });
  Future<Either<Failure, List<Tag>>> getTags();

  Future<Either<Failure, List<Transaction>>> getTransactions({
    String? transactionType,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<Either<Failure, List<CategorySpending>>> getCategorySpending({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<Either<Failure, List<CategoryTransactionGroup>>> getTransactionsByCategory({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<Either<Failure, void>> createExpense({
    required double amount,
    required int accountId,
    required int categoryId,
    required DateTime date,
    required String note,
    required List<int> tagIds,
  });

  Future<Either<Failure, void>> createIncome({
    required double amount,
    required int accountId,
    required int categoryId,
    required DateTime date,
    required String note,
    required List<int> tagIds,
  });

  Future<Either<Failure, void>> createTransfer({
    required double amount,
    required int fromAccountId,
    required int toAccountId,
    required DateTime date,
    required String note,
    required List<int> tagIds,
  });
}
