import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/account.dart';
import '../../domain/usecases/archive_account_usecase.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/update_account_usecase.dart';
import 'account_settings_state.dart';

@injectable
class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  final GetAccountsUseCase _getAccountsUseCase;
  final ArchiveAccountUseCase _archiveAccountUseCase;
  final RestoreAccountUseCase _restoreAccountUseCase;
  final UpdateAccountUseCase _updateAccountUseCase;

  AccountSettingsCubit(
    this._getAccountsUseCase,
    this._archiveAccountUseCase,
    this._restoreAccountUseCase,
    this._updateAccountUseCase,
  ) : super(const AccountSettingsState());

  Future<void> loadAccounts() async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));

    // Fetch active and archived accounts separately
    final activeResult = await _getAccountsUseCase(
      const GetAccountsParams(isActive: true),
    );
    final archivedResult = await _getAccountsUseCase(
      const GetAccountsParams(isActive: false),
    );

    activeResult.fold(
      (failure) => emit(state.copyWith(
        status: AccountSettingsStatus.error,
        errorMessage: failure.message,
      )),
      (active) {
        final archived = archivedResult.fold(
          (_) => <Account>[],
          (list) => list,
        );
        emit(state.copyWith(
          status: AccountSettingsStatus.loaded,
          activeAccounts: active,
          archivedAccounts: archived,
        ));
      },
    );
  }

  Future<void> archiveAccount(int id) async {
    final result = await _archiveAccountUseCase(
      ArchiveAccountParams(id: id),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => loadAccounts(),
    );
  }

  Future<void> restoreAccount(int id) async {
    final result = await _restoreAccountUseCase(
      RestoreAccountParams(id: id),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => loadAccounts(),
    );
  }

  Future<void> updateAccount({
    required int id,
    String? name,
    String? accountType,
    String? currency,
    String? icon,
  }) async {
    final result = await _updateAccountUseCase(
      UpdateAccountParams(
        id: id,
        name: name,
        accountType: accountType,
        currency: currency,
        icon: icon,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => loadAccounts(),
    );
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
