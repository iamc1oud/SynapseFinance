import 'package:equatable/equatable.dart';

import 'transaction.dart';

class CategoryTransactionGroup extends Equatable {
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final double total;
  final List<Transaction> transactions;

  const CategoryTransactionGroup({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.total,
    required this.transactions,
  });

  @override
  List<Object?> get props => [
    categoryId, categoryName, categoryIcon, total, transactions,
  ];
}
