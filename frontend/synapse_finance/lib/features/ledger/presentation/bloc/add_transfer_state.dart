import 'package:equatable/equatable.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/tag.dart';

enum AddTransferStatus { initial, loading, saving, saved, error }

class AddTransferState extends Equatable {
  final AddTransferStatus status;
  final String amountInput;
  final List<Account> accounts;
  final Account? fromAccount;
  final Account? toAccount;
  final DateTime selectedDate;
  final String note;
  final List<Tag> tags;
  final List<int> selectedTagIds;
  final String? errorMessage;

  const AddTransferState({
    this.status = AddTransferStatus.initial,
    this.amountInput = '0',
    this.accounts = const [],
    this.fromAccount,
    this.toAccount,
    required this.selectedDate,
    this.note = '',
    this.tags = const [],
    this.selectedTagIds = const [],
    this.errorMessage,
  });

  double get amount => double.tryParse(amountInput) ?? 0.0;

  AddTransferState copyWith({
    AddTransferStatus? status,
    String? amountInput,
    List<Account>? accounts,
    Account? fromAccount,
    bool clearFromAccount = false,
    Account? toAccount,
    bool clearToAccount = false,
    DateTime? selectedDate,
    String? note,
    List<Tag>? tags,
    List<int>? selectedTagIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddTransferState(
      status: status ?? this.status,
      amountInput: amountInput ?? this.amountInput,
      accounts: accounts ?? this.accounts,
      fromAccount: clearFromAccount ? null : (fromAccount ?? this.fromAccount),
      toAccount: clearToAccount ? null : (toAccount ?? this.toAccount),
      selectedDate: selectedDate ?? this.selectedDate,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status, amountInput, accounts, fromAccount, toAccount,
    selectedDate, note, tags, selectedTagIds, errorMessage,
  ];
}
