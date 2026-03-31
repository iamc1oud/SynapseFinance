import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ai_settings.dart';
import '../repositories/ai_settings_repository.dart';

@lazySingleton
class SaveAiSettingsUseCase {
  final AiSettingsRepository _repository;

  SaveAiSettingsUseCase(this._repository);

  Future<Either<Failure, void>> call(AiSettings settings) async {
    try {
      final baseUrlResult = await _repository.saveAiBaseUrl(settings.baseUrl);
      if (baseUrlResult.isLeft()) return baseUrlResult;

      final modelResult = await _repository.saveAiModel(settings.model);
      if (modelResult.isLeft()) return modelResult;

      final apiKeyResult = await _repository.saveAiApiKey(settings.apiKey);
      if (apiKeyResult.isLeft()) return apiKeyResult;

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save AI settings: $e'));
    }
  }
}