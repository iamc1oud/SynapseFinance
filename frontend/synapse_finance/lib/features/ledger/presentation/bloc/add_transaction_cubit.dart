import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../settings/domain/usecases/get_user_currencies_usecase.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/create_income_usecase.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'add_transaction_state.dart';

@injectable
class AddTransactionCubit extends Cubit<AddTransactionState> {
  final GetAccountsUseCase _getAccountsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateExpenseUseCase _createExpenseUseCase;
  final CreateIncomeUseCase _createIncomeUseCase;
  final GetUserCurrenciesUseCase _getUserCurrenciesUseCase;

  AddTransactionCubit(
    this._getAccountsUseCase,
    this._getCategoriesUseCase,
    this._createExpenseUseCase,
    this._createIncomeUseCase,
    this._getUserCurrenciesUseCase,
  ) : super(AddTransactionState(selectedDate: DateTime.now()));

  Future<void> loadData() async {
    emit(state.copyWith(status: AddTransactionStatus.loading));

    final accountsResult = await _getAccountsUseCase(const GetAccountsParams());
    final categoriesResult = await _getCategoriesUseCase(
      GetCategoriesParams(categoryType: _typeString(state.transactionType)),
    );
    final currenciesResult = await _getUserCurrenciesUseCase(const NoParams());

    accountsResult.fold(
      (failure) => emit(state.copyWith(
        status: AddTransactionStatus.error,
        errorMessage: failure.message,
      )),
      (accounts) {
        categoriesResult.fold(
          (failure) => emit(state.copyWith(
            status: AddTransactionStatus.error,
            errorMessage: failure.message,
          )),
          (categories) {
            final currencies = currenciesResult.fold((_) => state.availableCurrencies, (c) => c);
            final mainCurrency = currencies.isNotEmpty
                ? currencies.firstWhere((c) => c.isMain, orElse: () => currencies.first).currency
                : null;
            emit(state.copyWith(
              status: AddTransactionStatus.initial,
              accounts: accounts,
              selectedAccount: accounts.isNotEmpty ? accounts.first : null,
              categories: categories,
              availableCurrencies: currencies,
              selectedCurrency: mainCurrency,
              clearError: true,
            ));
          },
        );
      },
    );
  }

  Future<void> switchType(TransactionType type) async {
    if (state.transactionType == type) return;

    emit(state.copyWith(
      transactionType: type,
      clearSelectedCategory: true,
      categories: const [],
    ));

    final result = await _getCategoriesUseCase(
      GetCategoriesParams(categoryType: _typeString(type)),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (categories) => emit(state.copyWith(categories: categories)),
    );
  }

  void inputDigit(String digit) {
    final current = state.amountInput;
    if (digit == '.' && current.contains('.')) return;
    // Limit to 2 decimal places
    if (current.contains('.')) {
      final parts = current.split('.');
      if (parts[1].length >= 2) return;
    }
    // Remove leading zero unless adding decimal
    if (current == '0' && digit != '.') {
      emit(state.copyWith(amountInput: digit));
    } else {
      emit(state.copyWith(amountInput: current + digit));
    }
  }

  void deleteDigit() {
    final current = state.amountInput;
    if (current.length <= 1) {
      emit(state.copyWith(amountInput: '0'));
    } else {
      emit(state.copyWith(amountInput: current.substring(0, current.length - 1)));
    }
  }

  void selectAccount(Account account) {
    emit(state.copyWith(selectedAccount: account));
  }

  void selectCategory(Category category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void updateNote(String note) {
    emit(state.copyWith(note: note));
  }

  void selectCurrency(String currency) {
    emit(state.copyWith(selectedCurrency: currency));
  }

  Future<void> save() async {
    if (state.amount <= 0) {
      emit(state.copyWith(
        status: AddTransactionStatus.error,
        errorMessage: 'Please enter an amount',
      ));
      return;
    }
    if (state.selectedAccount == null) {
      emit(state.copyWith(
        status: AddTransactionStatus.error,
        errorMessage: 'Please select an account',
      ));
      return;
    }
    if (state.selectedCategory == null) {
      emit(state.copyWith(
        status: AddTransactionStatus.error,
        errorMessage: 'Please select a category',
      ));
      return;
    }

    emit(state.copyWith(status: AddTransactionStatus.saving, clearError: true));

    final currency = state.selectedCurrency;

    final params = state.transactionType == TransactionType.expense
        ? CreateExpenseParams(
            amount: state.amount,
            accountId: state.selectedAccount!.id,
            categoryId: state.selectedCategory!.id,
            date: state.selectedDate,
            note: state.note,
            tagIds: state.selectedTagIds,
            currency: currency,
          )
        : null;

    final incomeParams = state.transactionType == TransactionType.income
        ? CreateIncomeParams(
            amount: state.amount,
            accountId: state.selectedAccount!.id,
            categoryId: state.selectedCategory!.id,
            date: state.selectedDate,
            note: state.note,
            tagIds: state.selectedTagIds,
            currency: currency,
          )
        : null;

    final result = params != null
        ? await _createExpenseUseCase(params)
        : await _createIncomeUseCase(incomeParams!);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddTransactionStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AddTransactionStatus.saved)),
    );
  }

  Future<void> reset() async {
    emit(AddTransactionState(selectedDate: DateTime.now()));
    await loadData();
  }

  String _typeString(TransactionType type) =>
      type == TransactionType.expense ? 'expense' : 'income';
}
