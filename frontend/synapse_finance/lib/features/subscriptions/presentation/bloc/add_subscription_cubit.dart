import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../ledger/domain/entities/account.dart';
import '../../../ledger/domain/entities/category.dart';
import '../../../ledger/domain/usecases/get_accounts_usecase.dart';
import '../../../ledger/domain/usecases/get_categories_usecase.dart';
import '../../../settings/domain/usecases/get_user_currencies_usecase.dart';
import '../../domain/usecases/create_subscription_usecase.dart';
import 'add_subscription_state.dart';

@injectable
class AddSubscriptionCubit extends Cubit<AddSubscriptionState> {
  final GetAccountsUseCase _getAccountsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateSubscriptionUseCase _createSubscriptionUseCase;
  final GetUserCurrenciesUseCase _getUserCurrenciesUseCase;

  AddSubscriptionCubit(
    this._getAccountsUseCase,
    this._getCategoriesUseCase,
    this._createSubscriptionUseCase,
    this._getUserCurrenciesUseCase,
  ) : super(AddSubscriptionState(startDate: DateTime.now()));

  Future<void> loadData() async {
    emit(state.copyWith(status: AddSubscriptionStatus.loading));

    final accountsResult =
        await _getAccountsUseCase(const GetAccountsParams());
    final categoriesResult = await _getCategoriesUseCase(
      const GetCategoriesParams(categoryType: 'expense'),
    );
    final currenciesResult = await _getUserCurrenciesUseCase(const NoParams());

    accountsResult.fold(
      (failure) => emit(state.copyWith(
        status: AddSubscriptionStatus.error,
        errorMessage: failure.message,
      )),
      (accounts) {
        categoriesResult.fold(
          (failure) => emit(state.copyWith(
            status: AddSubscriptionStatus.error,
            errorMessage: failure.message,
          )),
          (categories) {
            final currencies = currenciesResult.fold((_) => state.availableCurrencies, (c) => c);
            final mainCurrency = currencies.isNotEmpty
                ? currencies.firstWhere((c) => c.isMain, orElse: () => currencies.first).currency
                : 'USD';
            emit(state.copyWith(
              status: AddSubscriptionStatus.initial,
              accounts: accounts,
              selectedAccount: accounts.isNotEmpty ? accounts.first : null,
              categories: categories,
              availableCurrencies: currencies,
              currency: mainCurrency,
              clearError: true,
            ));
          },
        );
      },
    );
  }

  void setName(String name) => emit(state.copyWith(name: name));

  void setAmount(String amount) => emit(state.copyWith(amountInput: amount));

  void setCurrency(String currency) =>
      emit(state.copyWith(currency: currency));

  void setFrequency(String frequency) {
    if (frequency != 'custom') {
      emit(state.copyWith(frequency: frequency, clearCustomInterval: true));
    } else {
      emit(state.copyWith(frequency: frequency));
    }
  }

  void setCustomIntervalDays(int days) =>
      emit(state.copyWith(customIntervalDays: days));

  void selectAccount(Account account) =>
      emit(state.copyWith(selectedAccount: account));

  void selectCategory(Category? category) {
    if (category == null) {
      emit(state.copyWith(clearSelectedCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: category));
    }
  }

  void setStartDate(DateTime date) => emit(state.copyWith(startDate: date));

  void setEndDate(DateTime? date) {
    if (date == null) {
      emit(state.copyWith(clearEndDate: true));
    } else {
      emit(state.copyWith(endDate: date));
    }
  }

  void setReminderEnabled(bool enabled) =>
      emit(state.copyWith(reminderEnabled: enabled));

  void setReminderDaysBefore(int days) =>
      emit(state.copyWith(reminderDaysBefore: days));

  void setNote(String note) => emit(state.copyWith(note: note));

  void setIcon(String icon) => emit(state.copyWith(icon: icon));

  Future<void> save() async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: AddSubscriptionStatus.error,
        errorMessage: 'Please fill in all required fields',
      ));
      return;
    }

    if (state.frequency == 'custom' && state.customIntervalDays == null) {
      emit(state.copyWith(
        status: AddSubscriptionStatus.error,
        errorMessage: 'Please enter a custom interval',
      ));
      return;
    }

    emit(state.copyWith(status: AddSubscriptionStatus.saving, clearError: true));

    final result = await _createSubscriptionUseCase(
      CreateSubscriptionParams(
        name: state.name.trim(),
        amount: state.amount,
        currency: state.currency,
        frequency: state.frequency,
        customIntervalDays: state.customIntervalDays,
        categoryId: state.selectedCategory?.id,
        accountId: state.selectedAccount!.id,
        startDate: state.startDate,
        endDate: state.endDate,
        reminderEnabled: state.reminderEnabled,
        reminderDaysBefore: state.reminderDaysBefore,
        note: state.note,
        icon: state.icon,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddSubscriptionStatus.error,
        errorMessage: failure.message,
      )),
      (subscription) => emit(state.copyWith(
        status: AddSubscriptionStatus.saved,
        savedSubscription: subscription,
      )),
    );
  }
}
