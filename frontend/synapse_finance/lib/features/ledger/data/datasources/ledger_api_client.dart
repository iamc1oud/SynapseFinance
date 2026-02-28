import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/tag_model.dart';

@lazySingleton
class LedgerApiClient {
  final Dio _dio;

  LedgerApiClient(this._dio);

  Future<List<AccountModel>> getAccounts() async {
    final response = await _dio.get(ApiConstants.accounts);
    final list = response.data as List<dynamic>;
    return list.map((e) => AccountModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CategoryModel>> getCategories({String? categoryType}) async {
    final response = await _dio.get(
      ApiConstants.categories,
      queryParameters: categoryType != null ? {'category_type': categoryType} : null,
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    required String categoryType,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.categories,
      data: {'name': name, 'icon': icon, 'category_type': categoryType},
    );
    return CategoryModel.fromJson(response.data!);
  }

  Future<List<TagModel>> getTags() async {
    final response = await _dio.get(ApiConstants.tags);
    final list = response.data as List<dynamic>;
    return list.map((e) => TagModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createExpense({
    required double amount,
    required int accountId,
    required int categoryId,
    required String date,
    required String note,
    required List<int> tagIds,
  }) async {
    await _dio.post(ApiConstants.expenseTransaction, data: {
      'amount': amount.toStringAsFixed(2),
      'account_id': accountId,
      'category_id': categoryId,
      'date': date,
      'note': note,
      'tag_ids': tagIds,
    });
  }

  Future<void> createIncome({
    required double amount,
    required int accountId,
    required int categoryId,
    required String date,
    required String note,
    required List<int> tagIds,
  }) async {
    await _dio.post(ApiConstants.incomeTransaction, data: {
      'amount': amount.toStringAsFixed(2),
      'account_id': accountId,
      'category_id': categoryId,
      'date': date,
      'note': note,
      'tag_ids': tagIds,
    });
  }

  Future<void> createTransfer({
    required double amount,
    required int fromAccountId,
    required int toAccountId,
    required String date,
    required String note,
    required List<int> tagIds,
  }) async {
    await _dio.post(ApiConstants.transferTransaction, data: {
      'amount': amount.toStringAsFixed(2),
      'from_account_id': fromAccountId,
      'to_account_id': toAccountId,
      'date': date,
      'note': note,
      'tag_ids': tagIds,
    });
  }
}
