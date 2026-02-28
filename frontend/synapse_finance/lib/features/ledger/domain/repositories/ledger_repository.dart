import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account.dart';
import '../entities/category.dart';
import '../entities/tag.dart';

abstract class LedgerRepository {
  Future<Either<Failure, List<Account>>> getAccounts();
  Future<Either<Failure, List<Category>>> getCategories({String? categoryType});
  Future<Either<Failure, List<Tag>>> getTags();

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
