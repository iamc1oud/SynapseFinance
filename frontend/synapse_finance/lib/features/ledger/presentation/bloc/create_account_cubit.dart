import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/create_account_usecase.dart';
import 'create_account_state.dart';

@injectable
class CreateAccountCubit extends Cubit<CreateAccountState> {
  final CreateAccountUseCase _createAccountUseCase;

  CreateAccountCubit(this._createAccountUseCase)
      : super(const CreateAccountState());

  void setName(String name) {
    emit(state.copyWith(name: name, clearError: true));
  }

  void setAccountType(String type) {
    emit(state.copyWith(accountType: type));
  }

  void setBalance(double balance) {
    emit(state.copyWith(balance: balance));
  }

  void setCurrency(String currency) {
    emit(state.copyWith(currency: currency));
  }

  void setIcon(String icon) {
    emit(state.copyWith(selectedIcon: icon));
  }

  Future<void> save() async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: CreateAccountStatus.error,
        errorMessage: 'Please enter an account name',
      ));
      return;
    }

    emit(state.copyWith(status: CreateAccountStatus.saving, clearError: true));

    final result = await _createAccountUseCase(
      CreateAccountParams(
        name: state.name.trim(),
        accountType: state.accountType,
        balance: state.balance,
        currency: state.currency,
        icon: state.selectedIcon,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CreateAccountStatus.error,
        errorMessage: failure.message,
      )),
      (account) => emit(state.copyWith(
        status: CreateAccountStatus.saved,
        createdAccount: account,
      )),
    );
  }
}
