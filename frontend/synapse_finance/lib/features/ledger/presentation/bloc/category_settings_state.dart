import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';

enum CategorySettingsStatus { initial, loading, loaded, error }

class CategorySettingsState extends Equatable {
  final CategorySettingsStatus status;
  final List<Category> activeCategories;
  final List<Category> archivedCategories;
  final String? errorMessage;
  final String searchQuery;

  const CategorySettingsState({
    this.status = CategorySettingsStatus.initial,
    this.activeCategories = const [],
    this.archivedCategories = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  List<Category> get filteredActiveCategories {
    if (searchQuery.isEmpty) return activeCategories;
    final query = searchQuery.toLowerCase();
    return activeCategories
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  }

  List<Category> get filteredArchivedCategories {
    if (searchQuery.isEmpty) return archivedCategories;
    final query = searchQuery.toLowerCase();
    return archivedCategories
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  }

  CategorySettingsState copyWith({
    CategorySettingsStatus? status,
    List<Category>? activeCategories,
    List<Category>? archivedCategories,
    String? errorMessage,
    String? searchQuery,
    bool clearError = false,
  }) {
    return CategorySettingsState(
      status: status ?? this.status,
      activeCategories: activeCategories ?? this.activeCategories,
      archivedCategories: archivedCategories ?? this.archivedCategories,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeCategories,
        archivedCategories,
        errorMessage,
        searchQuery,
      ];
}
