import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/currency_management_cubit.dart';
import '../bloc/currency_management_state.dart';
import '../constants/fiat_currencies.dart';

class ChangePrimaryCurrencyPage extends StatelessWidget {
  final String newCurrency;
  final String currentCurrency;

  const ChangePrimaryCurrencyPage({
    super.key,
    required this.newCurrency,
    required this.currentCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A1A0A) : const Color(0xFFF0F4F0);
    final surface = isDark ? const Color(0xFF122112) : const Color(0xFFFFFFFF);
    final onSurface = isDark ? Colors.white : const Color(0xFF0D1B0D);
    final secondary =
        isDark ? const Color(0xFF8B9E8B) : const Color(0xFF4A5C4A);

    final newName = fiatCurrencies[newCurrency]?.$1 ?? newCurrency;
    final currentName = fiatCurrencies[currentCurrency]?.$1 ?? currentCurrency;

    return BlocListener<CurrencyManagementCubit, CurrencyManagementState>(
      listener: (context, state) {
        if (state.status == CurrencyManagementStatus.loaded &&
            state.mainCurrency?.currency == newCurrency) {
          // Successfully changed — pop back to currency management
          Navigator.of(context).pop(true);
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFF85149),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: onSurface),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          title: Text(
            'Change Primary Currency',
            style: TextStyle(
              color: onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Warning icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF85149).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 44,
                  color: Color(0xFFF85149),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'This action is irreversible',
                style: TextStyle(
                  color: const Color(0xFFF85149),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'You are about to change your primary currency from '
                '$currentName ($currentCurrency) to $newName ($newCurrency).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Warning cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF85149).withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The following data will be permanently deleted:',
                      style: TextStyle(
                        color: const Color(0xFFF85149),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _WarningItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'All transactions',
                      secondary: secondary,
                      onSurface: onSurface,
                    ),
                    const SizedBox(height: 10),
                    _WarningItem(
                      icon: Icons.account_balance_rounded,
                      label: 'All accounts and balances',
                      secondary: secondary,
                      onSurface: onSurface,
                    ),
                    const SizedBox(height: 10),
                    _WarningItem(
                      icon: Icons.autorenew_rounded,
                      label: 'All subscriptions',
                      secondary: secondary,
                      onSurface: onSurface,
                    ),
                    const SizedBox(height: 10),
                    _WarningItem(
                      icon: Icons.currency_exchange_rounded,
                      label: 'All sub-currencies',
                      secondary: secondary,
                      onSurface: onSurface,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'This cannot be undone. You will start fresh with '
                '$newName as your new base currency.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // Action buttons
              BlocBuilder<CurrencyManagementCubit, CurrencyManagementState>(
                builder: (context, state) {
                  final isLoading =
                      state.status == CurrencyManagementStatus.loading;

                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<CurrencyManagementCubit>()
                                  .changePrimaryCurrency(newCurrency),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF85149),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFFF85149).withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Delete All Data & Change Currency',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: onSurface,
                            side: BorderSide(
                              color: secondary.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color secondary;
  final Color onSurface;

  const _WarningItem({
    required this.icon,
    required this.label,
    required this.secondary,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFF85149)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
