import '../../domain/entities/transaction.dart';
import 'account_model.dart';
import 'category_model.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.transactionType,
    required super.amount,
    required super.account,
    super.toAccount,
    super.category,
    required super.note,
    required super.date,
    required super.tags,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      transactionType: json['transaction_type'] as String,
      amount: double.parse(json['amount'].toString()),
      account: AccountModel.fromJson(json['account'] as Map<String, dynamic>),
      toAccount: json['to_account'] != null
          ? AccountModel.fromJson(json['to_account'] as Map<String, dynamic>)
          : null,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      note: json['note'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      tags: (json['tags'] as List<dynamic>)
          .map((t) => (t as Map<String, dynamic>)['name'] as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
