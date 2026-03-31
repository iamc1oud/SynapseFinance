import 'package:equatable/equatable.dart';

class AiSettings extends Equatable {
  final String baseUrl;
  final String model;
  final String? apiKey;

  const AiSettings({
    required this.baseUrl,
    required this.model,
    this.apiKey,
  });

  AiSettings copyWith({
    String? baseUrl,
    String? model,
    String? apiKey,
  }) {
    return AiSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  List<Object?> get props => [baseUrl, model, apiKey];
}