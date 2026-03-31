import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class AiSettingsRepository {
  Future<Either<Failure, String?>> getAiBaseUrl();
  Future<Either<Failure, String?>> getAiModel();
  Future<Either<Failure, String?>> getAiApiKey();
  
  Future<Either<Failure, void>> saveAiBaseUrl(String baseUrl);
  Future<Either<Failure, void>> saveAiModel(String model);
  Future<Either<Failure, void>> saveAiApiKey(String? apiKey);
}