import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/chat_message.dart';

class TransactionConfirmCard extends StatelessWidget {
  final InteractiveCardMessage card;
  final VoidCallback onConfirm;
  final VoidCallback onIgnore;

  const TransactionConfirmCard({
    super.key,
    required this.card,
    required this.onConfirm,
    required this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final data = card.data;
    final isPending = card.status == CardStatus.pending;
    final isConfirmed = card.status == CardStatus.confirmed;
    final isIgnored = card.status == CardStatus.ignored;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: c.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConfirmed
              ? c.success
              : isIgnored
                  ? c.textHint
                  : c.border,
          width: isConfirmed ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getIcon(),
                      size: 18,
                      color: _getIconColor(c),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTitle(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: c.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                _StatusBadge(status: card.status),
              ],
            ),

            Divider(color: c.border, height: 20),

            // Amount
            if (data['amount'] != null)
              _DetailRow(
                label: 'Amount',
                value: '${data['amount']}',
                colors: c,
              ),

            // Account info
            if (data['account_id'] != null)
              _DetailRow(
                label: 'Account',
                value: 'Account #${data['account_id']}',
                colors: c,
              ),

            // Transfer accounts
            if (data['from_account_id'] != null)
              _DetailRow(
                label: 'From',
                value: 'Account #${data['from_account_id']}',
                colors: c,
              ),
            if (data['to_account_id'] != null)
              _DetailRow(
                label: 'To',
                value: 'Account #${data['to_account_id']}',
                colors: c,
              ),

            // Category
            if (data['category_id'] != null)
              _DetailRow(
                label: 'Category',
                value: 'Category #${data['category_id']}',
                colors: c,
              ),

            // Note
            if (data['note'] != null &&
                (data['note'] as String).isNotEmpty)
              _DetailRow(
                label: 'Note',
                value: data['note'] as String,
                colors: c,
              ),

            // Date
            if (data['date'] != null)
              _DetailRow(
                label: 'Date',
                value: data['date'] as String,
                colors: c,
              ),

            const SizedBox(height: 12),

            // Action buttons
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: c.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onIgnore,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.textSecondary,
                        side: BorderSide(color: c.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Ignore'),
                    ),
                  ),
                ],
              ),

            if (isConfirmed)
              Row(
                children: [
                  Icon(Icons.check_circle, color: c.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Added successfully',
                    style: TextStyle(color: c.success, fontSize: 13),
                  ),
                ],
              ),

            if (isIgnored)
              Row(
                children: [
                  Icon(Icons.cancel_outlined, color: c.textHint, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Ignored',
                    style: TextStyle(color: c.textHint, fontSize: 13),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() => switch (card.cardType) {
        InteractiveCardType.transactionConfirm =>
          card.toolName == 'create_income'
              ? Icons.arrow_downward
              : Icons.arrow_upward,
        InteractiveCardType.transferConfirm => Icons.swap_horiz,
        InteractiveCardType.deleteConfirm => Icons.delete_outline,
        InteractiveCardType.subscriptionConfirm => Icons.autorenew,
      };

  Color _getIconColor(AppColorScheme c) => switch (card.cardType) {
        InteractiveCardType.transactionConfirm =>
          card.toolName == 'create_income' ? c.success : c.warning,
        InteractiveCardType.transferConfirm => c.primary,
        InteractiveCardType.deleteConfirm => c.error,
        InteractiveCardType.subscriptionConfirm => c.primary,
      };

  String _getTitle() => switch (card.toolName) {
        'create_expense' => 'New Expense',
        'create_income' => 'New Income',
        'create_transfer' => 'New Transfer',
        'delete_transaction' => 'Delete Transaction',
        _ => 'Confirm Action',
      };
}

// ─── Status Badge ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final CardStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final (label, color) = switch (status) {
      CardStatus.pending => ('Pending', c.warning),
      CardStatus.confirmed => ('Confirmed', c.success),
      CardStatus.ignored => ('Ignored', c.textHint),
      CardStatus.expired => ('Expired', c.textHint),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Detail Row ──────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColorScheme colors;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
