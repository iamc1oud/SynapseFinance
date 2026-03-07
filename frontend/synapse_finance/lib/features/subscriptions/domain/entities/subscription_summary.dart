import 'package:equatable/equatable.dart';

import 'subscription.dart';

class SubscriptionSummary extends Equatable {
  final double totalMonthlyCost;
  final int activeCount;
  final List<Subscription> subscriptions;

  const SubscriptionSummary({
    required this.totalMonthlyCost,
    required this.activeCount,
    required this.subscriptions,
  });

  @override
  List<Object?> get props => [totalMonthlyCost, activeCount, subscriptions];
}
