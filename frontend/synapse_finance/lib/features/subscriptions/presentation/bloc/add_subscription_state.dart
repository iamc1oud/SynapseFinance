import 'package:equatable/equatable.dart';

import '../../../ledger/domain/entities/account.dart';
import '../../../ledger/domain/entities/category.dart';
import '../../domain/entities/subscription.dart';

enum AddSubscriptionStatus { initial, loading, saving, saved, error }

class AddSubscriptionState extends Equatable {
  final AddSubscriptionStatus status;
  final String name;
  final String amountInput;
  final String currency;
  final String frequency;
  final int? customIntervalDays;
  final List<Account> accounts;
  final Account? selectedAccount;
  final List<Category> categories;
  final Category? selectedCategory;
  final DateTime startDate;
  final DateTime? endDate;
  final bool reminderEnabled;
  final int reminderDaysBefore;
  final String note;
  final String icon;
  final Subscription? savedSubscription;
  final String? errorMessage;

  const AddSubscriptionState({
    this.status = AddSubscriptionStatus.initial,
    this.name = '',
    this.amountInput = '',
    this.currency = 'USD',
    this.frequency = 'monthly',
    this.customIntervalDays,
    this.accounts = const [],
    this.selectedAccount,
    this.categories = const [],
    this.selectedCategory,
    required this.startDate,
    this.endDate,
    this.reminderEnabled = false,
    this.reminderDaysBefore = 1,
    this.note = '',
    this.icon = '',
    this.savedSubscription,
    this.errorMessage,
  });

  double get amount => double.tryParse(amountInput) ?? 0.0;

  bool get isValid =>
      name.trim().isNotEmpty && amount > 0 && selectedAccount != null;

  AddSubscriptionState copyWith({
    AddSubscriptionStatus? status,
    String? name,
    String? amountInput,
    String? currency,
    String? frequency,
    int? customIntervalDays,
    bool clearCustomInterval = false,
    List<Account>? accounts,
    Account? selectedAccount,
    bool clearSelectedAccount = false,
    List<Category>? categories,
    Category? selectedCategory,
    bool clearSelectedCategory = false,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    String? note,
    String? icon,
    Subscription? savedSubscription,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddSubscriptionState(
      status: status ?? this.status,
      name: name ?? this.name,
      amountInput: amountInput ?? this.amountInput,
      currency: currency ?? this.currency,
      frequency: frequency ?? this.frequency,
      customIntervalDays: clearCustomInterval
          ? null
          : (customIntervalDays ?? this.customIntervalDays),
      accounts: accounts ?? this.accounts,
      selectedAccount: clearSelectedAccount
          ? null
          : (selectedAccount ?? this.selectedAccount),
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      note: note ?? this.note,
      icon: icon ?? this.icon,
      savedSubscription: savedSubscription ?? this.savedSubscription,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        name,
        amountInput,
        currency,
        frequency,
        customIntervalDays,
        accounts,
        selectedAccount,
        categories,
        selectedCategory,
        startDate,
        endDate,
        reminderEnabled,
        reminderDaysBefore,
        note,
        icon,
        savedSubscription,
        errorMessage,
      ];
}
