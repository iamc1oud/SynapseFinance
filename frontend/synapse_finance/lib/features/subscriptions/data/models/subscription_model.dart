import '../../../ledger/data/models/account_model.dart';
import '../../../ledger/data/models/category_model.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.name,
    required super.amount,
    required super.currency,
    required super.frequency,
    super.customIntervalDays,
    super.category,
    required super.account,
    required super.startDate,
    super.endDate,
    required super.nextDueDate,
    required super.isActive,
    required super.reminderEnabled,
    required super.reminderDaysBefore,
    required super.note,
    required super.icon,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'] as String,
      frequency: json['frequency'] as String,
      customIntervalDays: json['custom_interval_days'] as int?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      account:
          AccountModel.fromJson(json['account'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      nextDueDate: DateTime.parse(json['next_due_date'] as String),
      isActive: json['is_active'] as bool,
      reminderEnabled: json['reminder_enabled'] as bool,
      reminderDaysBefore: json['reminder_days_before'] as int,
      note: json['note'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }
}
