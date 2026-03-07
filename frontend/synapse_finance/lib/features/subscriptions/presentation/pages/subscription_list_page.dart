import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/subscription.dart';
import '../bloc/subscription_list_cubit.dart';
import '../bloc/subscription_list_state.dart';

class SubscriptionListPage extends StatefulWidget {
  const SubscriptionListPage({super.key});

  @override
  State<SubscriptionListPage> createState() => _SubscriptionListPageState();
}

class _SubscriptionListPageState extends State<SubscriptionListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionListCubit>().loadSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(
          'Recurring',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<SubscriptionListCubit, SubscriptionListState>(
        builder: (context, state) {
          if (state.status == SubscriptionListStatus.loading) {
            return Center(
              child: CircularProgressIndicator(color: c.primary),
            );
          }

          if (state.status == SubscriptionListStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: c.error),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Something went wrong',
                    style: TextStyle(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context
                        .read<SubscriptionListCubit>()
                        .loadSubscriptions(),
                    child: Text('Retry', style: TextStyle(color: c.primary)),
                  ),
                ],
              ),
            );
          }

          if (state.subscriptions.isEmpty &&
              state.status == SubscriptionListStatus.loaded) {
            return RefreshIndicator(
              onRefresh: () => context
                  .read<SubscriptionListCubit>()
                  .loadSubscriptions(),
              color: c.primary,
              backgroundColor: c.surface,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.autorenew_rounded,
                            size: 56,
                            color: c.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No subscriptions yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first recurring payment',
                            style: TextStyle(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context
                .read<SubscriptionListCubit>()
                .loadSubscriptions(),
            color: c.primary,
            backgroundColor: c.surface,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _TotalMonthlyCostCard(
                  totalMonthlyCost: state.totalMonthlyCost,
                  activeCount: state.activeCount,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        'ACTIVE SUBSCRIPTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: c.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${state.activeCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: c.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...state.subscriptions.map(
                  (sub) => _SubscriptionCard(subscription: sub),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TotalMonthlyCostCard extends StatelessWidget {
  final double totalMonthlyCost;
  final int activeCount;

  const _TotalMonthlyCostCard({
    required this.totalMonthlyCost,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.primary.withValues(alpha: 0.2),
            c.primaryDark.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: c.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL MONTHLY RECURRING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '\$${totalMonthlyCost.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$activeCount active subscription${activeCount != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 13,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  const _SubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Dismissible(
      key: ValueKey(subscription.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: c.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: c.error),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: c.surface,
            title: Text('Delete Subscription',
                style: TextStyle(color: c.textPrimary)),
            content: Text(
              'Delete "${subscription.name}"? This cannot be undone.',
              style: TextStyle(color: c.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Delete', style: TextStyle(color: c.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context
            .read<SubscriptionListCubit>()
            .deleteSubscription(subscription.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  subscription.icon.isNotEmpty
                      ? subscription.icon
                      : subscription.name.isNotEmpty
                          ? subscription.name[0].toUpperCase()
                          : '?',
                  style: TextStyle(
                    fontSize: subscription.icon.isNotEmpty ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: c.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: subscription.isActive
                          ? c.textPrimary
                          : c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Next: ${dateFormat.format(subscription.nextDueDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${subscription.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: subscription.isActive
                        ? c.textPrimary
                        : c.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subscription.frequencyLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 28,
              child: Switch.adaptive(
                value: subscription.isActive,
                onChanged: (_) {
                  context
                      .read<SubscriptionListCubit>()
                      .toggleSubscription(subscription.id);
                },
                activeThumbColor: c.primary,
                activeTrackColor: c.primary.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
