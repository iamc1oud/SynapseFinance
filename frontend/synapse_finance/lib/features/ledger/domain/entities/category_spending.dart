import 'package:equatable/equatable.dart';

class CategorySpending extends Equatable {
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final double total;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.total,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, categoryIcon, total];
}
