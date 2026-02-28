import 'package:equatable/equatable.dart';

import '../../domain/entities/category_transaction_group.dart';

enum TransactionListStatus { initial, loading, loaded, error }

enum ViewMode { week, month }

class TransactionListState extends Equatable {
  final TransactionListStatus status;
  final ViewMode viewMode;
  final DateTime selectedDate;       // Specific day (week mode) or 1st of month (month mode)
  final DateTime currentWeekStart;   // Monday of the displayed week
  final List<CategoryTransactionGroup> categoryGroups;
  final List<int> expandedCategoryIds;
  final String searchQuery;
  final bool aiSuggestionDismissed;
  final String? errorMessage;

  const TransactionListState({
    required this.status,
    required this.viewMode,
    required this.selectedDate,
    required this.currentWeekStart,
    required this.categoryGroups,
    required this.expandedCategoryIds,
    required this.searchQuery,
    required this.aiSuggestionDismissed,
    this.errorMessage,
  });

  factory TransactionListState.initial() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return TransactionListState(
      status: TransactionListStatus.initial,
      viewMode: ViewMode.week,
      selectedDate: today,
      currentWeekStart: monday,
      categoryGroups: const [],
      expandedCategoryIds: const [],
      searchQuery: '',
      aiSuggestionDismissed: false,
    );
  }

  /// The start of the date range sent to the API.
  DateTime get dateFrom {
    if (viewMode == ViewMode.week) return selectedDate;
    return DateTime(selectedDate.year, selectedDate.month, 1);
  }

  /// The end of the date range sent to the API.
  DateTime get dateTo {
    if (viewMode == ViewMode.week) return selectedDate;
    final nextMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }

  double get totalSpending =>
      categoryGroups.fold(0.0, (sum, g) => sum + g.total);

  /// The 7 days of the currently displayed week.
  List<DateTime> get weekDays =>
      List.generate(7, (i) => currentWeekStart.add(Duration(days: i)));

  /// Category groups filtered by the search query.
  List<CategoryTransactionGroup> get filteredGroups {
    if (searchQuery.isEmpty) return categoryGroups;
    final q = searchQuery.toLowerCase();
    return categoryGroups
        .where((g) => g.categoryName.toLowerCase().contains(q))
        .toList();
  }

  TransactionListState copyWith({
    TransactionListStatus? status,
    ViewMode? viewMode,
    DateTime? selectedDate,
    DateTime? currentWeekStart,
    List<CategoryTransactionGroup>? categoryGroups,
    List<int>? expandedCategoryIds,
    String? searchQuery,
    bool? aiSuggestionDismissed,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionListState(
      status: status ?? this.status,
      viewMode: viewMode ?? this.viewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      currentWeekStart: currentWeekStart ?? this.currentWeekStart,
      categoryGroups: categoryGroups ?? this.categoryGroups,
      expandedCategoryIds: expandedCategoryIds ?? this.expandedCategoryIds,
      searchQuery: searchQuery ?? this.searchQuery,
      aiSuggestionDismissed: aiSuggestionDismissed ?? this.aiSuggestionDismissed,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status, viewMode, selectedDate, currentWeekStart, categoryGroups,
    expandedCategoryIds, searchQuery, aiSuggestionDismissed, errorMessage,
  ];
}
