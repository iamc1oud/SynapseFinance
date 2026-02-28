import '../../domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.name,
    required super.accountType,
    required super.balance,
    required super.currency,
    required super.icon,
    required super.isActive,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int,
      name: json['name'] as String,
      accountType: json['account_type'] as String,
      balance: double.parse(json['balance']).toDouble(),
      currency: json['currency'] as String,
      icon: json['icon'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
