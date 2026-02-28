import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class GetCategoriesUseCase implements UseCase<List<Category>, GetCategoriesParams> {
  final LedgerRepository _repository;

  GetCategoriesUseCase(this._repository);

  @override
  Future<Either<Failure, List<Category>>> call(GetCategoriesParams params) {
    return _repository.getCategories(categoryType: params.categoryType);
  }
}

class GetCategoriesParams extends Equatable {
  final String? categoryType;

  const GetCategoriesParams({this.categoryType});

  @override
  List<Object?> get props => [categoryType];
}
