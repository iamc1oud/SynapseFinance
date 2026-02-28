import '../../domain/entities/category_transaction_group.dart';
import 'transaction_model.dart';

class CategoryTransactionGroupModel extends CategoryTransactionGroup {
  const CategoryTransactionGroupModel({
    required super.categoryId,
    required super.categoryName,
    required super.categoryIcon,
    required super.total,
    required super.transactions,
  });

  factory CategoryTransactionGroupModel.fromJson(Map<String, dynamic> json) {
    return CategoryTransactionGroupModel(
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      categoryIcon: json['category_icon'] as String? ?? '',
      total: double.parse(json['total'].toString()),
      transactions: (json['transactions'] as List<dynamic>)
          .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
