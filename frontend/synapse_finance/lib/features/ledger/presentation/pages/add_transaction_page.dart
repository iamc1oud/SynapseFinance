import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../bloc/add_transaction_cubit.dart';
import '../bloc/add_transaction_state.dart';
import '../widgets/category_selector.dart';
import '../widgets/number_pad.dart';
import '../widgets/transaction_type_toggle.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with TickerProviderStateMixin {
  late final TextEditingController _noteController;
  late final AnimationController _checkController;
  late final AnimationController _pulseController;
  late final Animation<double> _checkScale;
  late final Animation<double> _fadeIn;

  bool _showSuccess = false;
  String _savedLabel = '';
  String _savedAmount = '';
  String _savedTitle = '';

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    context.read<AddTransactionCubit>().loadData();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _fadeIn = CurvedAnimation(
      parent: _checkController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _checkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onSaved(AddTransactionState state) {
    HapticFeedback.heavyImpact();
    final isExpense = state.transactionType == TransactionType.expense;
    setState(() {
      _showSuccess = true;
      _savedLabel =
          state.selectedCategory?.name.toUpperCase() ??
          (isExpense ? 'EXPENSE' : 'INCOME');
      _savedAmount = _formatAmount(state.displayAmount);
      _savedTitle = isExpense ? 'Expense Recorded!' : 'Income Recorded!';
    });
    _checkController.forward();
    _pulseController.repeat();
  }

  void _reset() {
    _checkController.reset();
    _pulseController.stop();
    _noteController.clear();
    setState(() => _showSuccess = false);
    context.read<AddTransactionCubit>().reset();
  }

  String _formatAmount(String raw) {
    final value = double.tryParse(raw) ?? 0.0;
    return NumberFormat('#,##0.##').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return BlocConsumer<AddTransactionCubit, AddTransactionState>(
      listener: (context, state) {
        if (state.status == AddTransactionStatus.saved && !_showSuccess) {
          _onSaved(state);
        }
        if (state.status == AddTransactionStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: c.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (_showSuccess) {
          return _SuccessScreen(
            title: _savedTitle,
            label: _savedLabel,
            amount: _savedAmount,
            checkScale: _checkScale,
            fadeIn: _fadeIn,
            pulseController: _pulseController,
            onAddAnother: _reset,
            onDone: () => context.pop(),
          );
        }

        final cubit = context.read<AddTransactionCubit>();
        return Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            backgroundColor: c.background,
            leading: IconButton(
              icon: Icon(Icons.close, color: c.textSecondary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Add Transaction',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              TextButton(
                onPressed: state.status == AddTransactionStatus.saving
                    ? null
                    : cubit.save,
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    color: c.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          resizeToAvoidBottomInset: false,
          body: _buildBody(context, state, cubit, c),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AddTransactionState state,
    AddTransactionCubit cubit,
    AppColorScheme c,
  ) {
    final typeToggle = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TransactionTypeToggle(
        selected: state.transactionType,
        onTypeSelected: cubit.switchType,
        onTransferTap: () => context.push('/add-transfer'),
      ),
    );

    final amountDisplay = _AmountDisplay(amount: state.displayAmount);

    final categorySection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
              if (state.categories.isNotEmpty)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View All',
                    style: TextStyle(color: c.primary, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
        if (state.status == AddTransactionStatus.loading)
          SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator(color: c.primary)),
          )
        else
          CategorySelector(
            categories: state.categories,
            selected: state.selectedCategory,
            onSelected: cubit.selectCategory,
          ),
      ],
    );

    final detailsSection = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'DATE',
            value: DateFormat('EEEE, MMM d, yyyy').format(state.selectedDate),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) cubit.selectDate(date);
            },
          ),
          const SizedBox(height: 8),
          _NoteRow(controller: _noteController, onChanged: cubit.updateNote),
        ],
      ),
    );

    final numPad = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: NumberPad(onDigit: cubit.inputDigit, onDelete: cubit.deleteDigit),
    );

    final saveButton = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed:
              state.status == AddTransactionStatus.saving ? null : cubit.save,
          icon: state.status == AddTransactionStatus.saving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.background,
                  ),
                )
              : Icon(Icons.check_circle, color: c.background),
          label: Text(
            'Save Transaction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: c.background,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: c.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (_, constraints) {
        // Tablet / large screen: side-by-side layout
        if (constraints.maxWidth >= 700) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: scrollable form content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      typeToggle,
                      amountDisplay,
                      categorySection,
                      const SizedBox(height: 8),
                      detailsSection,
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: c.border),
              // Right: fixed-width numpad + save button
              SizedBox(
                width: 360,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),
                    numPad,
                    saveButton,
                  ],
                ),
              ),
            ],
          );
        }

        // Phone / portrait layout — top content scrollable, numpad pinned at bottom
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    typeToggle,
                    amountDisplay,
                    categorySection,
                    const SizedBox(height: 8),
                    detailsSection,
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            numPad,
            saveButton,
          ],
        );
      },
    );
  }
}

// ─── Success screen ────────────────────────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  final String title;
  final String label;
  final String amount;
  final Animation<double> checkScale;
  final Animation<double> fadeIn;
  final AnimationController pulseController;
  final VoidCallback onAddAnother;
  final VoidCallback onDone;

  const _SuccessScreen({
    required this.title,
    required this.label,
    required this.amount,
    required this.checkScale,
    required this.fadeIn,
    required this.pulseController,
    required this.onAddAnother,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ..._buildParticles(c),
                    for (var i = 0; i < 3; i++)
                      _PulseRing(controller: pulseController, delay: i * 0.33),
                    ScaleTransition(
                      scale: checkScale,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.primary,
                          boxShadow: [
                            BoxShadow(
                              color: c.primary.withValues(alpha: 0.45),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: c.background,
                          size: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              FadeTransition(
                opacity: fadeIn,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: c.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              FadeTransition(
                opacity: fadeIn,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.8,
                          color: c.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$$amount',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: c.primary,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              FadeTransition(
                opacity: fadeIn,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onAddAnother,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Add Another',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: c.background,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: onDone,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.textPrimary,
                          side: BorderSide(color: c.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'View Dashboard',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: onDone,
                      icon: Icon(
                        Icons.arrow_back,
                        size: 15,
                        color: c.textSecondary,
                      ),
                      label: Text(
                        'Back to Home',
                        style: TextStyle(color: c.textSecondary, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParticles(AppColorScheme c) {
    const dots = [
      Offset(18, 38),
      Offset(165, 28),
      Offset(12, 130),
      Offset(178, 148),
      Offset(90, 10),
      Offset(148, 176),
    ];
    return dots.map((offset) {
      return Positioned(
        left: offset.dx,
        top: offset.dy,
        child: FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(
            scale: checkScale,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ─── Pulse ring ────────────────────────────────────────────────────────────────

class _PulseRing extends StatelessWidget {
  final AnimationController controller;
  final double delay;

  const _PulseRing({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = (controller.value + (1.0 - delay)) % 1.0;
        final scale = 1.0 + progress * 1.6;
        final opacity = ((1.0 - progress) * 0.38).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: c.primary.withValues(alpha: opacity),
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Form widgets ──────────────────────────────────────────────────────────────

class _AmountDisplay extends StatelessWidget {
  final String amount;

  const _AmountDisplay({required this.amount});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            'AMOUNT',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  fontSize: 32,
                  color: c.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c.textSecondary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.0,
                    color: c.textHint,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: c.textPrimary),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, size: 18, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NoteRow({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.notes, size: 20, color: c.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(fontSize: 14, color: c.textPrimary),
              decoration: InputDecoration(
                hintText: 'What was this for?',
                hintStyle: TextStyle(color: c.textHint, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
