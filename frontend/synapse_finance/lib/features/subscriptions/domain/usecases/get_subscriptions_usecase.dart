import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/subscription_summary.dart';
import '../repositories/subscription_repository.dart';

@lazySingleton
class GetSubscriptionsUseCase implements UseCase<SubscriptionSummary, NoParams> {
  final SubscriptionRepository _repository;

  GetSubscriptionsUseCase(this._repository);

  @override
  Future<Either<Failure, SubscriptionSummary>> call(NoParams params) {
    return _repository.getSubscriptions();
  }
}
