import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/subscription_repository.dart';

@lazySingleton
class DeleteSubscriptionUseCase
    implements UseCase<void, DeleteSubscriptionParams> {
  final SubscriptionRepository _repository;

  DeleteSubscriptionUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteSubscriptionParams params) {
    return _repository.deleteSubscription(id: params.id);
  }
}

class DeleteSubscriptionParams extends Equatable {
  final int id;

  const DeleteSubscriptionParams({required this.id});

  @override
  List<Object?> get props => [id];
}
