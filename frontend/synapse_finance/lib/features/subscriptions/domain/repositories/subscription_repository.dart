import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/subscription.dart';
import '../entities/subscription_summary.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, SubscriptionSummary>> getSubscriptions();
  Future<Either<Failure, Subscription>> createSubscription({
    required String name,
    required double amount,
    required String currency,
    required String frequency,
    int? customIntervalDays,
    int? categoryId,
    required int accountId,
    required DateTime startDate,
    DateTime? endDate,
    required bool reminderEnabled,
    required int reminderDaysBefore,
    required String note,
    required String icon,
  });
  Future<Either<Failure, Subscription>> toggleSubscription({required int id});
  Future<Either<Failure, void>> deleteSubscription({required int id});
}
