import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/ai_settings.dart';
import '../../domain/usecases/get_ai_settings_usecase.dart';
import '../../domain/usecases/save_ai_settings_usecase.dart';
import 'ai_settings_state.dart';

@injectable
class AiSettingsCubit extends Cubit<AiSettingsState> {
  final GetAiSettingsUseCase _getAiSettingsUseCase;
  final SaveAiSettingsUseCase _saveAiSettingsUseCase;

  AiSettingsCubit(
    this._getAiSettingsUseCase,
    this._saveAiSettingsUseCase,
  ) : super(const AiSettingsState());

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));

    final result = await _getAiSettingsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (settings) => emit(state.copyWith(
        isLoading: false,
        settings: settings,
        error: null,
      )),
    );
  }

  Future<void> saveSettings(AiSettings settings) async {
    emit(state.copyWith(isSaving: true));

    final result = await _saveAiSettingsUseCase(settings);
    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        error: failure.message,
      )),
      (_) => emit(state.copyWith(
        isSaving: false,
        settings: settings,
        error: null,
      )),
    );
  }

  void updateBaseUrl(String baseUrl) {
    if (state.settings != null) {
      final updatedSettings = state.settings!.copyWith(baseUrl: baseUrl);
      emit(state.copyWith(settings: updatedSettings));
    }
  }

  void updateModel(String model) {
    if (state.settings != null) {
      final updatedSettings = state.settings!.copyWith(model: model);
      emit(state.copyWith(settings: updatedSettings));
    }
  }

  void updateApiKey(String? apiKey) {
    if (state.settings != null) {
      final updatedSettings = state.settings!.copyWith(apiKey: apiKey);
      emit(state.copyWith(settings: updatedSettings));
    }
  }
}