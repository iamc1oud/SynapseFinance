import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionSuccessPage extends StatefulWidget {
  final Subscription subscription;

  const SubscriptionSuccessPage({super.key, required this.subscription});

  @override
  State<SubscriptionSuccessPage> createState() =>
      _SubscriptionSuccessPageState();
}

class _SubscriptionSuccessPageState extends State<SubscriptionSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final sub = widget.subscription;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated check
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: child,
                  ),
                ),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.primary.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: c.primary,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Success!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your recurring payment has been set up',
                style: TextStyle(fontSize: 15, color: c.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: c.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Name',
                      value: sub.name,
                      color: c,
                    ),
                    if (sub.category != null)
                      _SummaryRow(
                        label: 'Category',
                        value: sub.category!.name,
                        color: c,
                      ),
                    _SummaryRow(
                      label: 'Amount',
                      value: '\$${sub.amount.toStringAsFixed(2)}',
                      color: c,
                      valueColor: c.primary,
                    ),
                    _SummaryRow(
                      label: 'Frequency',
                      value: sub.frequencyLabel,
                      color: c,
                    ),
                    _SummaryRow(
                      label: 'Next Payment',
                      value: dateFormat.format(sub.nextDueDate),
                      color: c,
                    ),
                    _SummaryRow(
                      label: 'Payment Method',
                      value: sub.account.name,
                      color: c,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Done button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: c.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColorScheme color;
  final Color? valueColor;
  final bool isLast;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: color.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? color.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
