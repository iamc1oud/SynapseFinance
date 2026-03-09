import 'package:equatable/equatable.dart';

class ExchangeRate extends Equatable {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;

  const ExchangeRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
  });

  @override
  List<Object?> get props => [baseCurrency, targetCurrency, rate];
}
