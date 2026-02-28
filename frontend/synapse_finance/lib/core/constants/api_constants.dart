class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.1.9:8000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/token/refresh';
  static const String user = '/auth/user';

  // Ledger endpoints
  static const String accounts = '/ledger/accounts';
  static const String categories = '/ledger/categories';
  static const String tags = '/ledger/tags';
  static const String transactions = '/ledger/transactions';
  static const String expenseTransaction = '/ledger/transactions/expense';
  static const String incomeTransaction = '/ledger/transactions/income';
  static const String transferTransaction = '/ledger/transactions/transfer';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
