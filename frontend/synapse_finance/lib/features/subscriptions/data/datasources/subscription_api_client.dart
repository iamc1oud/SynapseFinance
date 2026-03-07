import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/subscription_model.dart';
import '../models/subscription_summary_model.dart';

@lazySingleton
class SubscriptionApiClient {
  final Dio _dio;

  SubscriptionApiClient(this._dio);

  Future<SubscriptionSummaryModel> getSubscriptions() async {
    final response = await _dio.get(ApiConstants.subscriptions);
    return SubscriptionSummaryModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<SubscriptionModel> createSubscription({
    required String name,
    required double amount,
    required String currency,
    required String frequency,
    int? customIntervalDays,
    int? categoryId,
    required int accountId,
    required String startDate,
    String? endDate,
    required bool reminderEnabled,
    required int reminderDaysBefore,
    required String note,
    required String icon,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'amount': amount.toStringAsFixed(2),
      'currency': currency,
      'frequency': frequency,
      'account_id': accountId,
      'start_date': startDate,
      'reminder_enabled': reminderEnabled,
      'reminder_days_before': reminderDaysBefore,
      'note': note,
      'icon': icon,
    };
    if (customIntervalDays != null) {
      data['custom_interval_days'] = customIntervalDays;
    }
    if (categoryId != null) data['category_id'] = categoryId;
    if (endDate != null) data['end_date'] = endDate;

    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.subscriptions,
      data: data,
    );
    return SubscriptionModel.fromJson(response.data!);
  }

  Future<SubscriptionModel> toggleSubscription(int id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiConstants.subscriptions}$id/toggle',
    );
    return SubscriptionModel.fromJson(response.data!);
  }

  Future<void> deleteSubscription(int id) async {
    await _dio.delete('${ApiConstants.subscriptions}$id');
  }
}
