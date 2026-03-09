import '../../domain/entities/exchange_rate.dart';

class ExchangeRateModel extends ExchangeRate {
  const ExchangeRateModel({
    required super.baseCurrency,
    required super.targetCurrency,
    required super.rate,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      baseCurrency: json['base_currency'] as String,
      targetCurrency: json['target_currency'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }
}
