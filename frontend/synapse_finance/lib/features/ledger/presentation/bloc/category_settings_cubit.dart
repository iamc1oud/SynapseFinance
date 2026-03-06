import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/archive_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'category_settings_state.dart';

@injectable
class CategorySettingsCubit extends Cubit<CategorySettingsState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final ArchiveCategoryUseCase _archiveCategoryUseCase;
  final RestoreCategoryUseCase _restoreCategoryUseCase;

  String _categoryType = 'expense';

  CategorySettingsCubit(
    this._getCategoriesUseCase,
    this._archiveCategoryUseCase,
    this._restoreCategoryUseCase,
  ) : super(const CategorySettingsState());

  Future<void> loadCategories(String categoryType) async {
    _categoryType = categoryType;
    emit(state.copyWith(status: CategorySettingsStatus.loading));

    final result = await _getCategoriesUseCase(
      GetCategoriesParams(categoryType: categoryType),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CategorySettingsStatus.error,
        errorMessage: failure.message,
      )),
      (categories) {
        final active = categories.where((c) => !c.isArchived).toList();
        final archived = categories.where((c) => c.isArchived).toList();
        emit(state.copyWith(
          status: CategorySettingsStatus.loaded,
          activeCategories: active,
          archivedCategories: archived,
        ));
      },
    );
  }

  Future<void> archiveCategory(int id) async {
    final result = await _archiveCategoryUseCase(
      ArchiveCategoryParams(id: id),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (_) => loadCategories(_categoryType),
    );
  }

  Future<void> restoreCategory(int id) async {
    final result = await _restoreCategoryUseCase(
      RestoreCategoryParams(id: id),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (_) => loadCategories(_categoryType),
    );
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
