import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String icon;
  final String categoryType; // expense | income
  final bool isArchived;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.categoryType,
    this.isArchived = false,
  });

  bool get isExpense => categoryType == 'expense';

  @override
  List<Object?> get props => [id, name, icon, categoryType, isArchived];
}
