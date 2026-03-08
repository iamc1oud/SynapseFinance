import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account.dart';
import '../entities/category.dart';
import '../entities/category_spending.dart';
import '../entities/category_transaction_group.dart';
import '../entities/tag.dart';
import '../entities/transaction.dart';

abstract class LedgerRepository {
  Future<Either<Failure, List<Account>>> getAccounts({bool? isActive});
  Future<Either<Failure, Account>> createAccount({
    required String name,
    required String accountType,
    required double balance,
    required String currency,
    required String icon,
  });
  Future<Either<Failure, Account>> updateAccount({
    required int id,
    String? name,
    String? accountType,
    String? currency,
    String? icon,
  });
  Future<Either<Failure, Account>> archiveAccount({required int id});
  Future<Either<Failure, Account>> restoreAccount({required int id});
  Future<Either<Failure, List<Category>>> getCategories({String? categoryType});
  Future<Either<Failure, Category>> createCategory({
    required String name,
    required String icon,
    required String categoryType,
  });
  Future<Either<Failure, Category>> archiveCategory({required int id});
  Future<Either<Failure, Category>> restoreCategory({required int id});
  Future<Either<Failure, List<Tag>>> getTags();

  Future<Either<Failure, List<Transaction>>> getTransactions({
    String? transactionType,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<Either<Failure, List<CategorySpending>>> getCategorySpending({
    String transactionType = 'expense',
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<Either<Failure, List<CategoryTransactionGroup>>> getTransactionsByCategory({
    String transactionType = 'expense',
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
    String? currency,
  });

  Future<Either<Failure, void>> createIncome({
    required double amount,
    required int accountId,
    required int categoryId,
    required DateTime date,
    required String note,
    required List<int> tagIds,
    String? currency,
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
