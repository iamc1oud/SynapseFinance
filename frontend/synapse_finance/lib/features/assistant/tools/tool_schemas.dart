import 'tool_registry.dart';

List<ToolDefinition> getAllTools() => [...readOnlyTools, ...mutationTools];

final readOnlyTools = [
  ToolDefinition(
    name: 'list_accounts',
    description: 'Get all user bank accounts with current balances.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDefinition(
    name: 'list_transactions',
    description:
        'Get transactions. Filter by type (expense/income/transfer), date range.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'transaction_type': {
          'type': 'string',
          'enum': ['expense', 'income', 'transfer'],
          'description': 'Filter by transaction type',
        },
        'date_from': {
          'type': 'string',
          'format': 'date',
          'description': 'Start date (YYYY-MM-DD)',
        },
        'date_to': {
          'type': 'string',
          'format': 'date',
          'description': 'End date (YYYY-MM-DD)',
        },
      },
    },
  ),
  ToolDefinition(
    name: 'spending_by_category',
    description: 'Get total spending grouped by category for a date range.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'transaction_type': {
          'type': 'string',
          'enum': ['expense', 'income'],
          'description': 'Type of transactions to summarize',
        },
        'date_from': {
          'type': 'string',
          'format': 'date',
          'description': 'Start date (YYYY-MM-DD)',
        },
        'date_to': {
          'type': 'string',
          'format': 'date',
          'description': 'End date (YYYY-MM-DD)',
        },
      },
    },
  ),
  ToolDefinition(
    name: 'list_subscriptions',
    description: 'Get all recurring subscriptions with amounts and frequency.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDefinition(
    name: 'list_categories',
    description: 'Get all expense and income categories.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDefinition(
    name: 'list_tags',
    description: 'Get all user-defined tags.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
  ToolDefinition(
    name: 'get_currency_info',
    description: 'Get primary currency and sub-currencies with exchange rates.',
    inputSchema: {'type': 'object', 'properties': {}},
  ),
];

final mutationTools = [
  ToolDefinition(
    name: 'create_expense',
    description:
        'Record an expense transaction. Deducts from the specified account.',
    isMutation: true,
    inputSchema: {
      'type': 'object',
      'properties': {
        'amount': {'type': 'number', 'description': 'Expense amount'},
        'account_id': {
          'type': 'integer',
          'description': 'Account to deduct from',
        },
        'category_id': {
          'type': 'integer',
          'description': 'Expense category ID',
        },
        'note': {'type': 'string', 'description': 'Optional note'},
        'date': {
          'type': 'string',
          'format': 'date',
          'description': 'Date (YYYY-MM-DD), defaults to today',
        },
        'currency': {'type': 'string', 'description': 'Currency code'},
        'tag_ids': {
          'type': 'array',
          'items': {'type': 'integer'},
          'description': 'Optional tag IDs',
        },
      },
      'required': ['amount', 'account_id', 'category_id'],
    },
  ),
  ToolDefinition(
    name: 'create_income',
    description: 'Record income. Adds to the specified account.',
    isMutation: true,
    inputSchema: {
      'type': 'object',
      'properties': {
        'amount': {'type': 'number', 'description': 'Income amount'},
        'account_id': {
          'type': 'integer',
          'description': 'Account to add to',
        },
        'category_id': {
          'type': 'integer',
          'description': 'Income category ID',
        },
        'note': {'type': 'string', 'description': 'Optional note'},
        'date': {
          'type': 'string',
          'format': 'date',
          'description': 'Date (YYYY-MM-DD), defaults to today',
        },
        'currency': {'type': 'string', 'description': 'Currency code'},
        'tag_ids': {
          'type': 'array',
          'items': {'type': 'integer'},
          'description': 'Optional tag IDs',
        },
      },
      'required': ['amount', 'account_id', 'category_id'],
    },
  ),
  ToolDefinition(
    name: 'create_transfer',
    description: 'Transfer money between two accounts.',
    isMutation: true,
    inputSchema: {
      'type': 'object',
      'properties': {
        'amount': {'type': 'number', 'description': 'Transfer amount'},
        'from_account_id': {
          'type': 'integer',
          'description': 'Source account ID',
        },
        'to_account_id': {
          'type': 'integer',
          'description': 'Destination account ID',
        },
        'note': {'type': 'string', 'description': 'Optional note'},
        'date': {
          'type': 'string',
          'format': 'date',
          'description': 'Date (YYYY-MM-DD), defaults to today',
        },
      },
      'required': ['amount', 'from_account_id', 'to_account_id'],
    },
  ),
  ToolDefinition(
    name: 'delete_transaction',
    description:
        'Delete a transaction by ID and reverse its balance effect.',
    isMutation: true,
    inputSchema: {
      'type': 'object',
      'properties': {
        'transaction_id': {
          'type': 'integer',
          'description': 'Transaction ID to delete',
        },
      },
      'required': ['transaction_id'],
    },
  ),
];
