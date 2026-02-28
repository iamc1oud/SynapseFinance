import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final int id;
  final String name;
  final String accountType;
  final double balance;
  final String currency;
  final String icon;
  final bool isActive;

  const Account({
    required this.id,
    required this.name,
    required this.accountType,
    required this.balance,
    required this.currency,
    required this.icon,
    required this.isActive,
  });

  String get formattedBalance =>
      '${currency == 'USD' ? '\$' : currency} ${balance.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [id, name, accountType, balance, currency, icon, isActive];
}
