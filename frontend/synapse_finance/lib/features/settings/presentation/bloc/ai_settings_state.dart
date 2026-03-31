import 'package:equatable/equatable.dart';

import '../../domain/entities/ai_settings.dart';

class AiSettingsState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final AiSettings? settings;
  final String? error;

  const AiSettingsState({
    this.isLoading = false,
    this.isSaving = false,
    this.settings,
    this.error,
  });

  AiSettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    AiSettings? settings,
    String? error,
  }) {
    return AiSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      settings: settings ?? this.settings,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSaving, settings, error];
}