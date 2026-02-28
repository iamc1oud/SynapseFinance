import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';

enum CreateCategoryStatus { initial, saving, saved, error }

class CreateCategoryState extends Equatable {
  final CreateCategoryStatus status;
  final String categoryType; // 'expense' | 'income'
  final String name;
  final String selectedIcon;
  final Category? createdCategory;
  final String? errorMessage;

  const CreateCategoryState({
    this.status = CreateCategoryStatus.initial,
    this.categoryType = 'expense',
    this.name = '',
    this.selectedIcon = 'circle',
    this.createdCategory,
    this.errorMessage,
  });

  bool get isValid => name.trim().isNotEmpty;

  CreateCategoryState copyWith({
    CreateCategoryStatus? status,
    String? categoryType,
    String? name,
    String? selectedIcon,
    Category? createdCategory,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateCategoryState(
      status: status ?? this.status,
      categoryType: categoryType ?? this.categoryType,
      name: name ?? this.name,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      createdCategory: createdCategory ?? this.createdCategory,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, categoryType, name, selectedIcon, createdCategory, errorMessage];
}
