import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

@lazySingleton
class ToggleSubscriptionUseCase
    implements UseCase<Subscription, ToggleSubscriptionParams> {
  final SubscriptionRepository _repository;

  ToggleSubscriptionUseCase(this._repository);

  @override
  Future<Either<Failure, Subscription>> call(ToggleSubscriptionParams params) {
    return _repository.toggleSubscription(id: params.id);
  }
}

class ToggleSubscriptionParams extends Equatable {
  final int id;

  const ToggleSubscriptionParams({required this.id});

  @override
  List<Object?> get props => [id];
}
