import '../../domain/entities/subscription_summary.dart';
import 'subscription_model.dart';

class SubscriptionSummaryModel extends SubscriptionSummary {
  const SubscriptionSummaryModel({
    required super.totalMonthlyCost,
    required super.activeCount,
    required super.subscriptions,
  });

  factory SubscriptionSummaryModel.fromJson(Map<String, dynamic> json) {
    final list = json['subscriptions'] as List<dynamic>;
    return SubscriptionSummaryModel(
      totalMonthlyCost: double.parse(json['total_monthly_cost'].toString()),
      activeCount: json['active_count'] as int,
      subscriptions: list
          .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
