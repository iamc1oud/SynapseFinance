import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/account.dart';
import '../../domain/usecases/create_transfer_usecase.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/get_tags_usecase.dart';
import 'add_transfer_state.dart';

@injectable
class AddTransferCubit extends Cubit<AddTransferState> {
  final GetAccountsUseCase _getAccountsUseCase;
  final GetTagsUseCase _getTagsUseCase;
  final CreateTransferUseCase _createTransferUseCase;

  AddTransferCubit(
    this._getAccountsUseCase,
    this._getTagsUseCase,
    this._createTransferUseCase,
  ) : super(AddTransferState(selectedDate: DateTime.now()));

  Future<void> loadData() async {
    emit(state.copyWith(status: AddTransferStatus.loading));

    final accountsResult = await _getAccountsUseCase(const NoParams());
    final tagsResult = await _getTagsUseCase(const NoParams());

    accountsResult.fold(
      (failure) => emit(state.copyWith(
        status: AddTransferStatus.error,
        errorMessage: failure.message,
      )),
      (accounts) {
        tagsResult.fold(
          (failure) => emit(state.copyWith(
            status: AddTransferStatus.error,
            errorMessage: failure.message,
          )),
          (tags) => emit(state.copyWith(
            status: AddTransferStatus.initial,
            accounts: accounts,
            fromAccount: accounts.isNotEmpty ? accounts.first : null,
            toAccount: accounts.length > 1 ? accounts[1] : null,
            tags: tags,
            clearError: true,
          )),
        );
      },
    );
  }

  void inputDigit(String digit) {
    final current = state.amountInput;
    if (digit == '.' && current.contains('.')) return;
    if (current.contains('.')) {
      final parts = current.split('.');
      if (parts[1].length >= 2) return;
    }
    if (current == '0' && digit != '.') {
      emit(state.copyWith(amountInput: digit));
    } else {
      emit(state.copyWith(amountInput: current + digit));
    }
  }

  void deleteDigit() {
    final current = state.amountInput;
    if (current.length <= 1) {
      emit(state.copyWith(amountInput: '0'));
    } else {
      emit(state.copyWith(amountInput: current.substring(0, current.length - 1)));
    }
  }

  void selectFromAccount(Account account) {
    emit(state.copyWith(fromAccount: account));
  }

  void selectToAccount(Account account) {
    emit(state.copyWith(toAccount: account));
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void updateNote(String note) {
    emit(state.copyWith(note: note));
  }

  void toggleTag(int tagId) {
    final current = List<int>.from(state.selectedTagIds);
    if (current.contains(tagId)) {
      current.remove(tagId);
    } else {
      current.add(tagId);
    }
    emit(state.copyWith(selectedTagIds: current));
  }

  Future<void> confirm() async {
    if (state.amount <= 0) {
      emit(state.copyWith(
        status: AddTransferStatus.error,
        errorMessage: 'Please enter an amount',
      ));
      return;
    }
    if (state.fromAccount == null || state.toAccount == null) {
      emit(state.copyWith(
        status: AddTransferStatus.error,
        errorMessage: 'Please select both accounts',
      ));
      return;
    }
    if (state.fromAccount!.id == state.toAccount!.id) {
      emit(state.copyWith(
        status: AddTransferStatus.error,
        errorMessage: 'From and To accounts must be different',
      ));
      return;
    }

    emit(state.copyWith(status: AddTransferStatus.saving, clearError: true));

    final result = await _createTransferUseCase(
      CreateTransferParams(
        amount: state.amount,
        fromAccountId: state.fromAccount!.id,
        toAccountId: state.toAccount!.id,
        date: state.selectedDate,
        note: state.note,
        tagIds: state.selectedTagIds,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddTransferStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AddTransferStatus.saved)),
    );
  }
}
