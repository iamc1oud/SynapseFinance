import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/sub_currency_model.dart';

@lazySingleton
class CurrencyApiClient {
  final Dio _dio;

  CurrencyApiClient(this._dio);

  Future<List<SubCurrencyModel>> getUserCurrencies() async {
    final response = await _dio.get(ApiConstants.userCurrencies);
    final data = response.data as Map<String, dynamic>;

    final main = SubCurrencyModel.fromJson(
      data['main_currency'] as Map<String, dynamic>,
    );

    final subList = data['sub_currencies'] as List<dynamic>;
    final subs = subList
        .map((e) => SubCurrencyModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return [main, ...subs];
  }
}
