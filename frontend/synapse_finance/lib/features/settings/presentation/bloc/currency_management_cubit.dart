import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/currency_repository.dart';
import 'currency_management_state.dart';

@injectable
class CurrencyManagementCubit extends Cubit<CurrencyManagementState> {
  final CurrencyRepository _repository;

  CurrencyManagementCubit(this._repository)
      : super(const CurrencyManagementState());

  Future<void> loadCurrencies() async {
    emit(state.copyWith(status: CurrencyManagementStatus.loading));

    final currenciesResult = await _repository.getUserCurrencies();
    final ratesResult = await _repository.getExchangeRates();

    currenciesResult.fold(
      (failure) => emit(state.copyWith(
        status: CurrencyManagementStatus.error,
        errorMessage: failure.message,
      )),
      (currencies) {
        final main = currencies.where((c) => c.isMain).firstOrNull;
        final subs = currencies.where((c) => !c.isMain).toList();

        ratesResult.fold(
          (failure) => emit(state.copyWith(
            status: CurrencyManagementStatus.loaded,
            mainCurrency: main,
            subCurrencies: subs,
            lastUpdated: DateTime.now(),
          )),
          (rates) => emit(state.copyWith(
            status: CurrencyManagementStatus.loaded,
            mainCurrency: main,
            subCurrencies: subs,
            exchangeRates: rates,
            lastUpdated: DateTime.now(),
          )),
        );
      },
    );
  }

  Future<void> addSubCurrency(String currency) async {
    final result = await _repository.addSubCurrency(currency);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => loadCurrencies(),
    );
  }

  Future<void> deleteSubCurrency(int id) async {
    final result = await _repository.deleteSubCurrency(id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => loadCurrencies(),
    );
  }

  Future<void> updateExchangeRate(int id, double rate) async {
    final result = await _repository.updateExchangeRate(id, rate);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => loadCurrencies(),
    );
  }

  Future<void> changePrimaryCurrency(String currency) async {
    emit(state.copyWith(status: CurrencyManagementStatus.loading));
    final result = await _repository.changePrimaryCurrency(currency);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CurrencyManagementStatus.loaded,
        errorMessage: failure.message,
      )),
      (_) => loadCurrencies(),
    );
  }

  Future<void> refreshRates() async {
    emit(state.copyWith(isRefreshing: true));
    final result = await _repository.refreshRates();
    result.fold(
      (failure) => emit(state.copyWith(
        isRefreshing: false,
        errorMessage: failure.message,
      )),
      (rates) => emit(state.copyWith(
        isRefreshing: false,
        exchangeRates: rates,
        lastUpdated: DateTime.now(),
      )),
    );
  }
}
