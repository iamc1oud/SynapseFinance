import 'package:equatable/equatable.dart';

import '../../domain/entities/account.dart';

enum AccountSettingsStatus { initial, loading, loaded, error }

class AccountSettingsState extends Equatable {
  final AccountSettingsStatus status;
  final List<Account> activeAccounts;
  final List<Account> archivedAccounts;
  final String? errorMessage;
  final String searchQuery;

  const AccountSettingsState({
    this.status = AccountSettingsStatus.initial,
    this.activeAccounts = const [],
    this.archivedAccounts = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  List<Account> get filteredActiveAccounts {
    if (searchQuery.isEmpty) return activeAccounts;
    final query = searchQuery.toLowerCase();
    return activeAccounts
        .where((a) => a.name.toLowerCase().contains(query))
        .toList();
  }

  List<Account> get filteredArchivedAccounts {
    if (searchQuery.isEmpty) return archivedAccounts;
    final query = searchQuery.toLowerCase();
    return archivedAccounts
        .where((a) => a.name.toLowerCase().contains(query))
        .toList();
  }

  AccountSettingsState copyWith({
    AccountSettingsStatus? status,
    List<Account>? activeAccounts,
    List<Account>? archivedAccounts,
    String? errorMessage,
    String? searchQuery,
    bool clearError = false,
  }) {
    return AccountSettingsState(
      status: status ?? this.status,
      activeAccounts: activeAccounts ?? this.activeAccounts,
      archivedAccounts: archivedAccounts ?? this.archivedAccounts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeAccounts,
        archivedAccounts,
        errorMessage,
        searchQuery,
      ];
}
