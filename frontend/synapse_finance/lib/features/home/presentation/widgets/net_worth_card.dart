import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/home_widget_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ledger/domain/usecases/get_net_worth_usecase.dart';

class NetWorthCard extends StatefulWidget {
  const NetWorthCard({super.key});

  @override
  State<NetWorthCard> createState() => _NetWorthCardState();
}

class _NetWorthCardState extends State<NetWorthCard> {
  bool _isLoading = false;
  double? _netWorth;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNetWorth();
  }

  Future<void> _loadNetWorth() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final getNetWorthUseCase = getIt<GetNetWorthUseCase>();
      final result = await getNetWorthUseCase();
      
      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        },
        (netWorth) {
          setState(() {
            _netWorth = netWorth;
            _isLoading = false;
          });
          
          // Update home widget
          final homeWidgetService = getIt<HomeWidgetService>();
          homeWidgetService.updateNetWorthWidget();
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to load net worth';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary.withValues(alpha: 0.1),
              colors.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Net Worth',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isLoading ? null : _loadNetWorth,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          color: colors.primary,
                          size: 20,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(
                  color: colors.error,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (_netWorth != null)
              Text(
                _formatCurrency(_netWorth!),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                '\$0.00',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.widgets,
                  size: 14,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Also available in home widget',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}