import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/exchange_rate_model.dart';
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

  Future<List<ExchangeRateModel>> getExchangeRates() async {
    final response = await _dio.get(ApiConstants.currencyRates);
    final data = response.data as List<dynamic>;
    return data
        .map((e) => ExchangeRateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SubCurrencyModel> addSubCurrency(
    String currency, {
    String unitPosition = 'front',
  }) async {
    final response = await _dio.post(
      ApiConstants.addSubCurrency,
      data: {'currency': currency, 'unit_position': unitPosition},
    );
    return SubCurrencyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteSubCurrency(int id) async {
    await _dio.delete('${ApiConstants.addSubCurrency}/$id');
  }

  Future<SubCurrencyModel> updateExchangeRate(int id, double rate) async {
    final response = await _dio.put(
      '${ApiConstants.addSubCurrency}/$id/rate',
      data: {'exchange_rate': rate},
    );
    return SubCurrencyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ExchangeRateModel>> refreshRates() async {
    final response = await _dio.post(ApiConstants.refreshRates);
    final data = response.data as List<dynamic>;
    return data
        .map((e) => ExchangeRateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> changePrimaryCurrency(String currency) async {
    await _dio.post(
      ApiConstants.changePrimaryCurrency,
      data: {'currency': currency},
    );
  }
}
