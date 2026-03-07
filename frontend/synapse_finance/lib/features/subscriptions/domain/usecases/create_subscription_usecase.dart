import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

@lazySingleton
class CreateSubscriptionUseCase
    implements UseCase<Subscription, CreateSubscriptionParams> {
  final SubscriptionRepository _repository;

  CreateSubscriptionUseCase(this._repository);

  @override
  Future<Either<Failure, Subscription>> call(CreateSubscriptionParams params) {
    return _repository.createSubscription(
      name: params.name,
      amount: params.amount,
      currency: params.currency,
      frequency: params.frequency,
      customIntervalDays: params.customIntervalDays,
      categoryId: params.categoryId,
      accountId: params.accountId,
      startDate: params.startDate,
      endDate: params.endDate,
      reminderEnabled: params.reminderEnabled,
      reminderDaysBefore: params.reminderDaysBefore,
      note: params.note,
      icon: params.icon,
    );
  }
}

class CreateSubscriptionParams extends Equatable {
  final String name;
  final double amount;
  final String currency;
  final String frequency;
  final int? customIntervalDays;
  final int? categoryId;
  final int accountId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool reminderEnabled;
  final int reminderDaysBefore;
  final String note;
  final String icon;

  const CreateSubscriptionParams({
    required this.name,
    required this.amount,
    required this.currency,
    required this.frequency,
    this.customIntervalDays,
    this.categoryId,
    required this.accountId,
    required this.startDate,
    this.endDate,
    required this.reminderEnabled,
    required this.reminderDaysBefore,
    required this.note,
    required this.icon,
  });

  @override
  List<Object?> get props => [
        name,
        amount,
        currency,
        frequency,
        customIntervalDays,
        categoryId,
        accountId,
        startDate,
        endDate,
        reminderEnabled,
        reminderDaysBefore,
        note,
        icon,
      ];
}
