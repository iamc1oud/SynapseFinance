import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class ArchiveCategoryUseCase
    implements UseCase<Category, ArchiveCategoryParams> {
  final LedgerRepository _repository;

  ArchiveCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, Category>> call(ArchiveCategoryParams params) {
    return _repository.archiveCategory(id: params.id);
  }
}

class ArchiveCategoryParams extends Equatable {
  final int id;

  const ArchiveCategoryParams({required this.id});

  @override
  List<Object?> get props => [id];
}

@lazySingleton
class RestoreCategoryUseCase
    implements UseCase<Category, RestoreCategoryParams> {
  final LedgerRepository _repository;

  RestoreCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, Category>> call(RestoreCategoryParams params) {
    return _repository.restoreCategory(id: params.id);
  }
}

class RestoreCategoryParams extends Equatable {
  final int id;

  const RestoreCategoryParams({required this.id});

  @override
  List<Object?> get props => [id];
}
