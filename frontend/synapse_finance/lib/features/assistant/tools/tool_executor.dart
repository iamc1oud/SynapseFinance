import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../ledger/data/datasources/ledger_api_client.dart';
import '../../settings/data/datasources/currency_api_client.dart';
import '../../subscriptions/data/datasources/subscription_api_client.dart';

@lazySingleton
class ToolExecutor {
  final LedgerApiClient _ledgerApi;
  final SubscriptionApiClient _subscriptionApi;
  final CurrencyApiClient _currencyApi;

  ToolExecutor(this._ledgerApi, this._subscriptionApi, this._currencyApi);

  Future<Map<String, dynamic>> execute(
    String toolName,
    Map<String, dynamic> args,
  ) async {
    return switch (toolName) {
      'list_accounts' => _listAccounts(),
      'list_transactions' => _listTransactions(args),
      'spending_by_category' => _spendingByCategory(args),
      'list_categories' => _listCategories(),
      'list_subscriptions' => _listSubscriptions(),
      'list_tags' => _listTags(),
      'get_currency_info' => _getCurrencyInfo(),
      'create_expense' => _createExpense(args),
      'create_income' => _createIncome(args),
      'create_transfer' => _createTransfer(args),
      'create_category' => _createCategory(args),
      'delete_transaction' => _deleteTransaction(args),
      _ => throw Exception('Unknown tool: $toolName'),
    };
  }

  Future<Map<String, dynamic>> _listAccounts() async {
    final accounts = await _ledgerApi.getAccounts();
    return {
      'accounts': accounts
          .map(
            (a) => {
              'id': a.id,
              'name': a.name,
              'account_type': a.accountType,
              'balance': a.balance,
              'currency': a.currency,
              'is_active': a.isActive,
            },
          )
          .toList(),
    };
  }

  Future<Map<String, dynamic>> _listTransactions(
    Map<String, dynamic> args,
  ) async {
    final txns = await _ledgerApi.getTransactions(
      transactionType: args['transaction_type'] as String?,
      dateFrom: _parseDate(args['date_from']),
      dateTo: _parseDate(args['date_to']),
    );

    debugPrint('${txns}');
    return {
      'transactions': txns
          .map(
            (t) => {
              'id': t.id,
              'type': t.transactionType,
              'amount': t.amount,
              'account': t.account.name,
              'to_account': t.toAccount?.name,
              'category': t.category?.name,
              'note': t.note,
              'date': DateFormat('yyyy-MM-dd').format(t.date),
              'tags': t.tags,
            },
          )
          .toList(),
    };
  }

  Future<Map<String, dynamic>> _spendingByCategory(
    Map<String, dynamic> args,
  ) async {
    final spending = await _ledgerApi.getCategorySpending(
      transactionType: (args['transaction_type'] as String?) ?? 'expense',
      dateFrom: _parseDate(args['date_from']),
      dateTo: _parseDate(args['date_to']),
    );
    return {
      'spending': spending
          .map(
            (s) => {
              'category_id': s.categoryId,
              'category': s.categoryName,
              'total': s.total,
            },
          )
          .toList(),
    };
  }

  Future<Map<String, dynamic>> _listCategories() async {
    final categories = await _ledgerApi.getCategories();
    return {
      'categories': categories
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'category_type': c.categoryType,
              'icon': c.icon,
            },
          )
          .toList(),
    };
  }

  Future<Map<String, dynamic>> _listSubscriptions() async {
    final summary = await _subscriptionApi.getSubscriptions();
    return {
      'subscriptions': summary.subscriptions
          .map(
            (s) => {
              'id': s.id,
              'name': s.name,
              'amount': s.amount,
              'currency': s.currency,
              'frequency': s.frequency,
              'is_active': s.isActive,
              'next_due_date': s.nextDueDate.toIso8601String(),
            },
          )
          .toList(),
      'total_monthly_cost': summary.totalMonthlyCost,
    };
  }

  Future<Map<String, dynamic>> _listTags() async {
    final tags = await _ledgerApi.getTags();
    return {
      'tags': tags.map((t) => {'id': t.id, 'name': t.name}).toList(),
    };
  }

  Future<Map<String, dynamic>> _getCurrencyInfo() async {
    final currencies = await _currencyApi.getUserCurrencies();
    return {
      'currencies': currencies
          .map(
            (c) => {
              'id': c.id,
              'currency': c.currency,
              'is_main': c.isMain,
              'exchange_rate': c.exchangeRate,
              'unit_position': c.unitPosition,
            },
          )
          .toList(),
    };
  }

  Future<Map<String, dynamic>> _createExpense(Map<String, dynamic> args) async {
    await _ledgerApi.createExpense(
      amount: (args['amount'] as num).toDouble(),
      accountId: args['account_id'] as int,
      categoryId: args['category_id'] as int,
      date:
          (args['date'] as String?) ??
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
      note: (args['note'] as String?) ?? '',
      tagIds:
          (args['tag_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
      currency: args['currency'] as String?,
    );
    return {'success': true, 'message': 'Expense created successfully'};
  }

  Future<Map<String, dynamic>> _createIncome(Map<String, dynamic> args) async {
    await _ledgerApi.createIncome(
      amount: (args['amount'] as num).toDouble(),
      accountId: args['account_id'] as int,
      categoryId: args['category_id'] as int,
      date:
          (args['date'] as String?) ??
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
      note: (args['note'] as String?) ?? '',
      tagIds:
          (args['tag_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
      currency: args['currency'] as String?,
    );
    return {'success': true, 'message': 'Income created successfully'};
  }

  Future<Map<String, dynamic>> _createTransfer(
    Map<String, dynamic> args,
  ) async {
    await _ledgerApi.createTransfer(
      amount: (args['amount'] as num).toDouble(),
      fromAccountId: args['from_account_id'] as int,
      toAccountId: args['to_account_id'] as int,
      date:
          (args['date'] as String?) ??
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
      note: (args['note'] as String?) ?? '',
      tagIds:
          (args['tag_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
    );
    return {'success': true, 'message': 'Transfer completed successfully'};
  }

  Future<Map<String, dynamic>> _createCategory(
    Map<String, dynamic> args,
  ) async {
    final category = await _ledgerApi.createCategory(
      name: args['name'] as String,
      icon: args['icon'] as String,
      categoryType: args['category_type'] as String,
    );
    return {
      'success': true,
      'category': {
        'id': category.id,
        'name': category.name,
        'category_type': category.categoryType,
        'icon': category.icon,
      },
    };
  }

  Future<Map<String, dynamic>> _deleteTransaction(
    Map<String, dynamic> args,
  ) async {
    // Note: The existing API client doesn't have a deleteTransaction method.
    // This will need to be added to LedgerApiClient.
    throw UnimplementedError(
      'deleteTransaction not yet implemented in LedgerApiClient',
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }
}
