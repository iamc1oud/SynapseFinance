import 'package:equatable/equatable.dart';

import '../../domain/entities/account.dart';

enum CreateAccountStatus { initial, saving, saved, error }

class CreateAccountState extends Equatable {
  final CreateAccountStatus status;
  final String name;
  final String accountType;
  final double balance;
  final String currency;
  final String selectedIcon;
  final Account? createdAccount;
  final String? errorMessage;

  const CreateAccountState({
    this.status = CreateAccountStatus.initial,
    this.name = '',
    this.accountType = 'checking',
    this.balance = 0.0,
    this.currency = 'USD',
    this.selectedIcon = 'account_balance',
    this.createdAccount,
    this.errorMessage,
  });

  bool get isValid => name.trim().isNotEmpty;

  CreateAccountState copyWith({
    CreateAccountStatus? status,
    String? name,
    String? accountType,
    double? balance,
    String? currency,
    String? selectedIcon,
    Account? createdAccount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateAccountState(
      status: status ?? this.status,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      createdAccount: createdAccount ?? this.createdAccount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        name,
        accountType,
        balance,
        currency,
        selectedIcon,
        createdAccount,
        errorMessage,
      ];
}
