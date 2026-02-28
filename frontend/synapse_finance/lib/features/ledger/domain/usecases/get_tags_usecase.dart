import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/tag.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class GetTagsUseCase implements UseCase<List<Tag>, NoParams> {
  final LedgerRepository _repository;

  GetTagsUseCase(this._repository);

  @override
  Future<Either<Failure, List<Tag>>> call(NoParams params) {
    return _repository.getTags();
  }
}
