import '../../domain/entities/category_spending.dart';

class CategorySpendingModel extends CategorySpending {
  const CategorySpendingModel({
    required super.categoryId,
    required super.categoryName,
    required super.categoryIcon,
    required super.total,
  });

  factory CategorySpendingModel.fromJson(Map<String, dynamic> json) {
    return CategorySpendingModel(
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      categoryIcon: json['category_icon'] as String? ?? '',
      total: double.parse(json['total'].toString()),
    );
  }
}
