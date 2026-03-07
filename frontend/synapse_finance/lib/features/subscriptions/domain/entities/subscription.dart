import 'package:equatable/equatable.dart';

import '../../../ledger/domain/entities/account.dart';
import '../../../ledger/domain/entities/category.dart';

class Subscription extends Equatable {
  final int id;
  final String name;
  final double amount;
  final String currency;
  final String frequency;
  final int? customIntervalDays;
  final Category? category;
  final Account account;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final bool isActive;
  final bool reminderEnabled;
  final int reminderDaysBefore;
  final String note;
  final String icon;

  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.frequency,
    this.customIntervalDays,
    this.category,
    required this.account,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    required this.isActive,
    required this.reminderEnabled,
    required this.reminderDaysBefore,
    required this.note,
    required this.icon,
  });

  String get frequencyLabel {
    switch (frequency) {
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      case 'custom':
        return 'Every $customIntervalDays days';
      default:
        return frequency;
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        currency,
        frequency,
        customIntervalDays,
        category,
        account,
        startDate,
        endDate,
        nextDueDate,
        isActive,
        reminderEnabled,
        reminderDaysBefore,
        note,
        icon,
      ];
}
