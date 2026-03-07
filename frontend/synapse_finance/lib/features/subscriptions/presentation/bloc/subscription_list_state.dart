import 'package:equatable/equatable.dart';

import '../../domain/entities/subscription.dart';

enum SubscriptionListStatus { initial, loading, loaded, error }

class SubscriptionListState extends Equatable {
  final SubscriptionListStatus status;
  final double totalMonthlyCost;
  final int activeCount;
  final List<Subscription> subscriptions;
  final String? errorMessage;

  const SubscriptionListState({
    this.status = SubscriptionListStatus.initial,
    this.totalMonthlyCost = 0,
    this.activeCount = 0,
    this.subscriptions = const [],
    this.errorMessage,
  });

  SubscriptionListState copyWith({
    SubscriptionListStatus? status,
    double? totalMonthlyCost,
    int? activeCount,
    List<Subscription>? subscriptions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubscriptionListState(
      status: status ?? this.status,
      totalMonthlyCost: totalMonthlyCost ?? this.totalMonthlyCost,
      activeCount: activeCount ?? this.activeCount,
      subscriptions: subscriptions ?? this.subscriptions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        totalMonthlyCost,
        activeCount,
        subscriptions,
        errorMessage,
      ];
}
