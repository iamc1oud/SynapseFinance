import 'package:equatable/equatable.dart';

import 'account.dart';
import 'category.dart';

class Transaction extends Equatable {
  final int id;
  final String transactionType; // 'expense', 'income', 'transfer'
  final double amount;
  final Account account;
  final Account? toAccount;
  final Category? category;
  final String note;
  final DateTime date;
  final List<String> tags;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.account,
    this.toAccount,
    this.category,
    required this.note,
    required this.date,
    required this.tags,
    required this.createdAt,
  });

  bool get isExpense => transactionType == 'expense';
  bool get isIncome => transactionType == 'income';
  bool get isTransfer => transactionType == 'transfer';

  @override
  List<Object?> get props => [
    id, transactionType, amount, account, toAccount,
    category, note, date, tags, createdAt,
  ];
}
