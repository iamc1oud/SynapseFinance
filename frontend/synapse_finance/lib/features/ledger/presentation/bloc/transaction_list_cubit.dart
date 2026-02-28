import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_transactions_by_category_usecase.dart';
import 'transaction_list_state.dart';

@injectable
class TransactionListCubit extends Cubit<TransactionListState> {
  final GetTransactionsByCategoryUseCase _getTransactionsByCategoryUseCase;

  TransactionListCubit(this._getTransactionsByCategoryUseCase)
      : super(TransactionListState.initial());

  Future<void> loadData() async {
    emit(state.copyWith(status: TransactionListStatus.loading, clearError: true));

    final result = await _getTransactionsByCategoryUseCase(
      GetTransactionsByCategoryParams(
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: TransactionListStatus.error,
        errorMessage: failure.message,
      )),
      (groups) => emit(state.copyWith(
        status: TransactionListStatus.loaded,
        categoryGroups: groups,
        // Auto-expand the top category if none are expanded yet
        expandedCategoryIds: state.expandedCategoryIds.isEmpty && groups.isNotEmpty
            ? [groups.first.categoryId]
            : state.expandedCategoryIds,
      )),
    );
  }

  void selectDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    // If the selected date is in a different week, update the week start
    final monday = d.subtract(Duration(days: d.weekday - 1));
    emit(state.copyWith(selectedDate: d, currentWeekStart: monday));
    loadData();
  }

  void setViewMode(ViewMode mode) {
    emit(state.copyWith(viewMode: mode));
    loadData();
  }

  void previousPeriod() {
    if (viewMode == ViewMode.week) {
      final prevMonday = state.currentWeekStart.subtract(const Duration(days: 7));
      final dayOffset = state.selectedDate.weekday - 1;
      final newSelected = prevMonday.add(Duration(days: dayOffset));
      emit(state.copyWith(
        currentWeekStart: prevMonday,
        selectedDate: newSelected,
      ));
    } else {
      final prev = DateTime(
        state.selectedDate.year,
        state.selectedDate.month - 1,
        1,
      );
      emit(state.copyWith(selectedDate: prev));
    }
    loadData();
  }

  void nextPeriod() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (viewMode == ViewMode.week) {
      final nextMonday = state.currentWeekStart.add(const Duration(days: 7));
      if (nextMonday.isAfter(today)) return; // already at current week
      final dayOffset = state.selectedDate.weekday - 1;
      final newSelected = nextMonday.add(Duration(days: dayOffset));
      final capped = newSelected.isAfter(today) ? today : newSelected;
      emit(state.copyWith(currentWeekStart: nextMonday, selectedDate: capped));
    } else {
      final next = DateTime(
        state.selectedDate.year,
        state.selectedDate.month + 1,
        1,
      );
      final thisMonth = DateTime(now.year, now.month, 1);
      if (next.isAfter(thisMonth)) return; // already at current month
      emit(state.copyWith(selectedDate: next));
    }
    loadData();
  }

  ViewMode get viewMode => state.viewMode;

  void toggleCategory(int categoryId) {
    final expanded = List<int>.from(state.expandedCategoryIds);
    if (expanded.contains(categoryId)) {
      expanded.remove(categoryId);
    } else {
      expanded.add(categoryId);
    }
    emit(state.copyWith(expandedCategoryIds: expanded));
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void dismissAiSuggestion() {
    emit(state.copyWith(aiSuggestionDismissed: true));
  }
}
