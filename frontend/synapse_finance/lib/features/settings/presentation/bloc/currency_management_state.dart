import 'package:equatable/equatable.dart';

import '../../domain/entities/exchange_rate.dart';
import '../../domain/entities/sub_currency.dart';

enum CurrencyManagementStatus { initial, loading, loaded, error }

class CurrencyManagementState extends Equatable {
  final CurrencyManagementStatus status;
  final SubCurrency? mainCurrency;
  final List<SubCurrency> subCurrencies;
  final List<ExchangeRate> exchangeRates;
  final DateTime? lastUpdated;
  final bool isRefreshing;
  final String? errorMessage;

  const CurrencyManagementState({
    this.status = CurrencyManagementStatus.initial,
    this.mainCurrency,
    this.subCurrencies = const [],
    this.exchangeRates = const [],
    this.lastUpdated,
    this.isRefreshing = false,
    this.errorMessage,
  });

  CurrencyManagementState copyWith({
    CurrencyManagementStatus? status,
    SubCurrency? mainCurrency,
    List<SubCurrency>? subCurrencies,
    List<ExchangeRate>? exchangeRates,
    DateTime? lastUpdated,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CurrencyManagementState(
      status: status ?? this.status,
      mainCurrency: mainCurrency ?? this.mainCurrency,
      subCurrencies: subCurrencies ?? this.subCurrencies,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  double? getRateForCurrency(String currencyCode, String mainCode) {
    final rate = exchangeRates
        .where(
          (r) => r.baseCurrency == currencyCode && r.targetCurrency == mainCode,
        )
        .firstOrNull;
    return rate?.rate;
  }

  @override
  List<Object?> get props => [
        status,
        mainCurrency,
        subCurrencies,
        exchangeRates,
        lastUpdated,
        isRefreshing,
        errorMessage,
      ];
}
