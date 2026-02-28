import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/create_category_usecase.dart';
import 'create_category_state.dart';

@injectable
class CreateCategoryCubit extends Cubit<CreateCategoryState> {
  final CreateCategoryUseCase _createCategoryUseCase;

  CreateCategoryCubit(this._createCategoryUseCase)
      : super(const CreateCategoryState());

  void setCategoryType(String type) {
    emit(state.copyWith(categoryType: type));
  }

  void setName(String name) {
    emit(state.copyWith(name: name, clearError: true));
  }

  void setIcon(String icon) {
    emit(state.copyWith(selectedIcon: icon));
  }

  Future<void> save() async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: CreateCategoryStatus.error,
        errorMessage: 'Please enter a category name',
      ));
      return;
    }

    emit(state.copyWith(status: CreateCategoryStatus.saving, clearError: true));

    final result = await _createCategoryUseCase(
      CreateCategoryParams(
        name: state.name.trim(),
        icon: state.selectedIcon,
        categoryType: state.categoryType,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CreateCategoryStatus.error,
        errorMessage: failure.message,
      )),
      (category) => emit(state.copyWith(
        status: CreateCategoryStatus.saved,
        createdCategory: category,
      )),
    );
  }
}
