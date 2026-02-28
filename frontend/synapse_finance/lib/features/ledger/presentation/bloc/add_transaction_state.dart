import 'package:equatable/equatable.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/tag.dart';

enum TransactionType { expense, income }

enum AddTransactionStatus { initial, loading, saving, saved, error }

class AddTransactionState extends Equatable {
  final AddTransactionStatus status;
  final TransactionType transactionType;
  final String amountInput; // raw string built by numpad
  final List<Account> accounts;
  final Account? selectedAccount;
  final List<Category> categories;
  final Category? selectedCategory;
  final DateTime selectedDate;
  final String note;
  final List<Tag> tags;
  final List<int> selectedTagIds;
  final String? errorMessage;

  const AddTransactionState({
    this.status = AddTransactionStatus.initial,
    this.transactionType = TransactionType.expense,
    this.amountInput = '0',
    this.accounts = const [],
    this.selectedAccount,
    this.categories = const [],
    this.selectedCategory,
    required this.selectedDate,
    this.note = '',
    this.tags = const [],
    this.selectedTagIds = const [],
    this.errorMessage,
  });

  double get amount {
    final parsed = double.tryParse(amountInput) ?? 0.0;
    return parsed;
  }

  String get displayAmount {
    if (amountInput == '0') return '0.00';
    if (amountInput.contains('.')) return amountInput;
    return amountInput;
  }

  AddTransactionState copyWith({
    AddTransactionStatus? status,
    TransactionType? transactionType,
    String? amountInput,
    List<Account>? accounts,
    Account? selectedAccount,
    bool clearSelectedAccount = false,
    List<Category>? categories,
    Category? selectedCategory,
    bool clearSelectedCategory = false,
    DateTime? selectedDate,
    String? note,
    List<Tag>? tags,
    List<int>? selectedTagIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddTransactionState(
      status: status ?? this.status,
      transactionType: transactionType ?? this.transactionType,
      amountInput: amountInput ?? this.amountInput,
      accounts: accounts ?? this.accounts,
      selectedAccount: clearSelectedAccount ? null : (selectedAccount ?? this.selectedAccount),
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedDate: selectedDate ?? this.selectedDate,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status, transactionType, amountInput, accounts, selectedAccount,
    categories, selectedCategory, selectedDate, note, tags, selectedTagIds,
    errorMessage,
  ];
}
