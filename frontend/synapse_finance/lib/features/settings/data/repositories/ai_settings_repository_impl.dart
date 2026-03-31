import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/ai_settings_repository.dart';

@LazySingleton(as: AiSettingsRepository)
class AiSettingsRepositoryImpl implements AiSettingsRepository {
  final SharedPreferences _prefs;

  AiSettingsRepositoryImpl(this._prefs);

  static const String _aiBaseUrlKey = 'ai_base_url';
  static const String _aiModelKey = 'ai_model';
  static const String _aiApiKeyKey = 'ai_api_key';

  @override
  Future<Either<Failure, String?>> getAiBaseUrl() async {
    try {
      final baseUrl = _prefs.getString(_aiBaseUrlKey);
      return Right(baseUrl);
    } catch (e) {
      return Left(CacheFailure('Failed to get AI base URL: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getAiModel() async {
    try {
      final model = _prefs.getString(_aiModelKey);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure('Failed to get AI model: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getAiApiKey() async {
    try {
      final apiKey = _prefs.getString(_aiApiKeyKey);
      return Right(apiKey);
    } catch (e) {
      return Left(CacheFailure('Failed to get AI API key: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAiBaseUrl(String baseUrl) async {
    try {
      await _prefs.setString(_aiBaseUrlKey, baseUrl);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save AI base URL: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAiModel(String model) async {
    try {
      await _prefs.setString(_aiModelKey, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save AI model: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAiApiKey(String? apiKey) async {
    try {
      if (apiKey == null || apiKey.isEmpty) {
        await _prefs.remove(_aiApiKeyKey);
      } else {
        await _prefs.setString(_aiApiKeyKey, apiKey);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save AI API key: $e'));
    }
  }
}