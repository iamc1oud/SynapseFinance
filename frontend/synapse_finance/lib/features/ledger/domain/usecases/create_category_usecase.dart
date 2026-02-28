import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/ledger_repository.dart';

@lazySingleton
class CreateCategoryUseCase implements UseCase<Category, CreateCategoryParams> {
  final LedgerRepository _repository;

  CreateCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, Category>> call(CreateCategoryParams params) {
    return _repository.createCategory(
      name: params.name,
      icon: params.icon,
      categoryType: params.categoryType,
    );
  }
}

class CreateCategoryParams {
  final String name;
  final String icon;
  final String categoryType;

  const CreateCategoryParams({
    required this.name,
    required this.icon,
    required this.categoryType,
  });
}
