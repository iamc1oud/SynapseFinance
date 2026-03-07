import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_summary.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_api_client.dart';

@LazySingleton(as: SubscriptionRepository)
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionApiClient _apiClient;

  SubscriptionRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, SubscriptionSummary>> getSubscriptions() async {
    try {
      final summary = await _apiClient.getSubscriptions();
      return Right(summary);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Subscription>> createSubscription({
    required String name,
    required double amount,
    required String currency,
    required String frequency,
    int? customIntervalDays,
    int? categoryId,
    required int accountId,
    required DateTime startDate,
    DateTime? endDate,
    required bool reminderEnabled,
    required int reminderDaysBefore,
    required String note,
    required String icon,
  }) async {
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final sub = await _apiClient.createSubscription(
        name: name,
        amount: amount,
        currency: currency,
        frequency: frequency,
        customIntervalDays: customIntervalDays,
        categoryId: categoryId,
        accountId: accountId,
        startDate: fmt.format(startDate),
        endDate: endDate != null ? fmt.format(endDate) : null,
        reminderEnabled: reminderEnabled,
        reminderDaysBefore: reminderDaysBefore,
        note: note,
        icon: icon,
      );
      return Right(sub);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Subscription>> toggleSubscription({
    required int id,
  }) async {
    try {
      final sub = await _apiClient.toggleSubscription(id);
      return Right(sub);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubscription({required int id}) async {
    try {
      await _apiClient.deleteSubscription(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final detail = _extractErrorMessage(e.response?.data);
        return ServerFailure(detail, statusCode: statusCode);
      default:
        return ServerFailure('${e.message}');
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Something went wrong';
    if (data is String) return data.isNotEmpty ? data : 'Something went wrong';
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map) {
          return first['msg'] as String? ?? 'Something went wrong';
        }
      }
      return 'Something went wrong';
    }
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) return first['msg'] as String? ?? 'Validation error';
      return 'Validation error';
    }
    return 'Something went wrong';
  }
}
