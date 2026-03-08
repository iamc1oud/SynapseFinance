import 'package:equatable/equatable.dart';

class SubCurrency extends Equatable {
  final int id;
  final String currency;
  final double exchangeRate;
  final String unitPosition;
  final bool isMain;

  const SubCurrency({
    required this.id,
    required this.currency,
    required this.exchangeRate,
    required this.unitPosition,
    this.isMain = false,
  });

  @override
  List<Object?> get props => [id, currency, exchangeRate, unitPosition, isMain];
}
