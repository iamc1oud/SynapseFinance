import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ai_settings.dart';
import '../repositories/ai_settings_repository.dart';

@lazySingleton
class GetAiSettingsUseCase {
  final AiSettingsRepository _repository;

  GetAiSettingsUseCase(this._repository);

  Future<Either<Failure, AiSettings>> call() async {
    try {
      final baseUrlResult = await _repository.getAiBaseUrl();
      final modelResult = await _repository.getAiModel();
      final apiKeyResult = await _repository.getAiApiKey();

      return Right(AiSettings(
        baseUrl: baseUrlResult.fold(
          (failure) => 'http://192.168.1.15:11434/v1', // Default
          (url) => url ?? 'http://192.168.1.15:11434/v1',
        ),
        model: modelResult.fold(
          (failure) => 'llama3.1:8b', // Default
          (model) => model ?? 'llama3.1:8b',
        ),
        apiKey: apiKeyResult.fold(
          (failure) => null,
          (key) => key,
        ),
      ));
    } catch (e) {
      return Left(ServerFailure('Failed to get AI settings: $e'));
    }
  }
}