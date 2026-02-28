import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../bloc/add_transaction_state.dart';

class TransactionTypeToggle extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onTypeSelected;
  final VoidCallback onTransferTap;

  const TransactionTypeToggle({
    super.key,
    required this.selected,
    required this.onTypeSelected,
    required this.onTransferTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Expense',
            isSelected: selected == TransactionType.expense,
            onTap: () => onTypeSelected(TransactionType.expense),
          ),
          _Tab(
            label: 'Income',
            isSelected: selected == TransactionType.income,
            onTap: () => onTypeSelected(TransactionType.income),
          ),
          _Tab(
            label: 'Transfer',
            isSelected: false,
            onTap: onTransferTap,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? c.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? c.background : c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
