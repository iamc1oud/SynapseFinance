import '../../domain/entities/sub_currency.dart';

class SubCurrencyModel extends SubCurrency {
  const SubCurrencyModel({
    required super.id,
    required super.currency,
    required super.exchangeRate,
    required super.unitPosition,
    super.isMain,
  });

  factory SubCurrencyModel.fromJson(Map<String, dynamic> json) {
    return SubCurrencyModel(
      id: json['id'] as int,
      currency: json['currency'] as String,
      exchangeRate: (json['exchange_rate'] as num).toDouble(),
      unitPosition: json['unit_position'] as String,
      isMain: json['is_main'] as bool? ?? false,
    );
  }
}
