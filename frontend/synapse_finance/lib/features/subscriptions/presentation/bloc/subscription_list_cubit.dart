import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/delete_subscription_usecase.dart';
import '../../domain/usecases/get_subscriptions_usecase.dart';
import '../../domain/usecases/toggle_subscription_usecase.dart';
import 'subscription_list_state.dart';

@injectable
class SubscriptionListCubit extends Cubit<SubscriptionListState> {
  final GetSubscriptionsUseCase _getSubscriptionsUseCase;
  final ToggleSubscriptionUseCase _toggleSubscriptionUseCase;
  final DeleteSubscriptionUseCase _deleteSubscriptionUseCase;

  SubscriptionListCubit(
    this._getSubscriptionsUseCase,
    this._toggleSubscriptionUseCase,
    this._deleteSubscriptionUseCase,
  ) : super(const SubscriptionListState());

  Future<void> loadSubscriptions() async {
    emit(state.copyWith(status: SubscriptionListStatus.loading));

    final result = await _getSubscriptionsUseCase(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: SubscriptionListStatus.error,
        errorMessage: failure.message,
      )),
      (summary) => emit(state.copyWith(
        status: SubscriptionListStatus.loaded,
        totalMonthlyCost: summary.totalMonthlyCost,
        activeCount: summary.activeCount,
        subscriptions: summary.subscriptions,
        clearError: true,
      )),
    );
  }

  Future<void> toggleSubscription(int id) async {
    final result = await _toggleSubscriptionUseCase(
      ToggleSubscriptionParams(id: id),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (updatedSub) {
        final updated = state.subscriptions.map((s) {
          return s.id == updatedSub.id ? updatedSub : s;
        }).toList();
        final activeCount = updated.where((s) => s.isActive).length;
        emit(state.copyWith(
          subscriptions: updated,
          activeCount: activeCount,
          clearError: true,
        ));
      },
    );
  }

  Future<void> deleteSubscription(int id) async {
    final result = await _deleteSubscriptionUseCase(
      DeleteSubscriptionParams(id: id),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final updated = state.subscriptions.where((s) => s.id != id).toList();
        final activeCount = updated.where((s) => s.isActive).length;
        emit(state.copyWith(
          subscriptions: updated,
          activeCount: activeCount,
          clearError: true,
        ));
      },
    );
  }
}
