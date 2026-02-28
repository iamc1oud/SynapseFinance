import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category_transaction_group.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_list_cubit.dart';
import '../bloc/transaction_list_state.dart';

// ─── Icon helpers ─────────────────────────────────────────────────────────────

IconData _iconForKey(String key) {
  const map = {
    'food': Icons.restaurant,
    'coffee': Icons.local_cafe,
    'transport': Icons.directions_car,
    'shopping': Icons.shopping_bag,
    'home': Icons.home,
    'fitness': Icons.fitness_center,
    'health': Icons.local_hospital,
    'education': Icons.school,
    'work': Icons.work,
    'investment': Icons.trending_up,
    'entertainment': Icons.movie,
    'travel': Icons.flight,
    'gift': Icons.card_giftcard,
    'phone': Icons.phone_android,
    'internet': Icons.wifi,
    'electricity': Icons.bolt,
    'water': Icons.water_drop,
    'pet': Icons.pets,
    'book': Icons.book,
    'music': Icons.music_note,
    'game': Icons.sports_esports,
    'beauty': Icons.face,
    'clothes': Icons.checkroom,
    'savings': Icons.savings,
    'cash': Icons.payments,
    'insurance': Icons.security,
    'tax': Icons.account_balance,
    'charity': Icons.volunteer_activism,
    'baby': Icons.child_care,
    'car_repair': Icons.car_repair,
    'groceries': Icons.local_grocery_store,
    'rent': Icons.apartment,
    'salary': Icons.account_balance_wallet,
  };
  return map[key] ?? Icons.circle_outlined;
}

Color _colorForKey(String key) {
  switch (key) {
    case 'food':
    case 'coffee':
    case 'groceries':
      return const Color(0xFFFF8C42);
    case 'transport':
    case 'car_repair':
      return const Color(0xFF4A90D9);
    case 'shopping':
    case 'clothes':
    case 'beauty':
      return const Color(0xFF9B59B6);
    case 'home':
    case 'rent':
      return const Color(0xFF27AE60);
    case 'fitness':
    case 'health':
      return const Color(0xFFE74C3C);
    case 'education':
    case 'work':
    case 'book':
      return const Color(0xFF3498DB);
    case 'entertainment':
    case 'game':
    case 'music':
      return const Color(0xFFE67E22);
    case 'travel':
      return const Color(0xFF1ABC9C);
    case 'electricity':
    case 'water':
    case 'internet':
    case 'phone':
      return const Color(0xFF16A085);
    default:
      return const Color(0xFF4ADE80); // bright green fallback, works both themes
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<TransactionListCubit>().loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return BlocBuilder<TransactionListCubit, TransactionListState>(
      builder: (context, state) {
        final cubit = context.read<TransactionListCubit>();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTitleRow(c)),
            SliverToBoxAdapter(child: _buildDateNavRow(context, state, cubit, c)),
            if (state.viewMode == ViewMode.week)
              SliverToBoxAdapter(child: _buildWeekStrip(state, cubit, c)),
            SliverToBoxAdapter(
              child: Divider(color: c.border, height: 1),
            ),
            SliverToBoxAdapter(child: _buildSearchBar(cubit, c)),
            SliverToBoxAdapter(child: _buildSpendingTotal(state, c)),
            if (!state.aiSuggestionDismissed)
              SliverToBoxAdapter(child: _buildAiCard(state, cubit)),
            if (state.status == TransactionListStatus.loading)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: c.primary),
                ),
              )
            else if (state.status == TransactionListStatus.error)
              SliverFillRemaining(child: _ErrorState(state.errorMessage, cubit))
            else ...[
              const SliverToBoxAdapter(child: _SectionHeader()),
              if (state.filteredGroups.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final group = state.filteredGroups[i];
                    return _CategoryGroupTile(
                      group: group,
                      isExpanded: state.expandedCategoryIds.contains(
                        group.categoryId,
                      ),
                      totalSpending: state.totalSpending,
                      onToggle: () => cubit.toggleCategory(group.categoryId),
                      onAddTransaction: () => context.push('/add-transaction'),
                    );
                  }, childCount: state.filteredGroups.length),
                ),
            ],
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      },
    );
  }

  Widget _buildTitleRow(AppColorScheme c) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Transaction',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: null,
              child: Text(
                'Edit',
                style: TextStyle(color: c.primary, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavRow(
    BuildContext context,
    TransactionListState state,
    TransactionListCubit cubit,
    AppColorScheme c,
  ) {
    final label = DateFormat('MMMM yyyy').format(state.selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: cubit.previousPeriod,
            child: Icon(Icons.chevron_left, color: c.textSecondary, size: 22),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null && context.mounted) {
                cubit.selectDate(picked);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: c.textSecondary, size: 18),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: cubit.nextPeriod,
            child: Icon(Icons.chevron_right, color: c.textSecondary, size: 22),
          ),
          const SizedBox(width: 8),
          _ViewModeToggle(
            viewMode: state.viewMode,
            onChanged: cubit.setViewMode,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip(
    TransactionListState state,
    TransactionListCubit cubit,
    AppColorScheme c,
  ) {
    const dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final weekDays = state.weekDays;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: List.generate(7, (i) {
          final day = weekDays[i];
          final isSelected = day == state.selectedDate;
          final isToday = day == today;
          final isFuture = day.isAfter(today);

          return Expanded(
            child: GestureDetector(
              onTap: isFuture ? null : () => cubit.selectDate(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? c.primary : c.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayNames[i],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? c.background : c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? c.background
                            : isFuture
                            ? c.textHint
                            : isToday
                            ? c.primary
                            : c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar(TransactionListCubit cubit, AppColorScheme c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: cubit.updateSearch,
          style: TextStyle(color: c.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search categories or sub-categories',
            hintStyle: TextStyle(color: c.textHint, fontSize: 13),
            prefixIcon: Icon(Icons.search, color: c.textSecondary, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingTotal(TransactionListState state, AppColorScheme c) {
    final label = state.viewMode == ViewMode.week
        ? DateFormat('MMM d, yyyy').format(state.selectedDate)
        : DateFormat('MMMM yyyy').format(state.selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined, color: c.textSecondary, size: 17),
          const SizedBox(width: 8),
          Text(
            'Spending for $label',
            style: TextStyle(fontSize: 14, color: c.textSecondary),
          ),
          const Spacer(),
          Text(
            '\$${NumberFormat('#,##0.00').format(state.totalSpending)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiCard(TransactionListState state, TransactionListCubit cubit) {
    String suggestion;
    if (state.categoryGroups.isNotEmpty) {
      final top = state.categoryGroups.first;
      final pct = state.totalSpending > 0
          ? (top.total / state.totalSpending * 100).round()
          : 0;
      suggestion =
          'You spent $pct% of your budget on ${top.categoryName}. '
          'Consider setting a weekly limit to stay on track.';
    } else {
      suggestion =
          'Add your first transaction to start receiving personalised spending insights.';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2340),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF1E5090).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1E5090),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI SUGGESTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64B5F6),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: cubit.dismissAiSuggestion,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, color: Colors.white54, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── View mode toggle ─────────────────────────────────────────────────────────

class _ViewModeToggle extends StatelessWidget {
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onChanged;

  const _ViewModeToggle({required this.viewMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            label: 'Week',
            selected: viewMode == ViewMode.week,
            onTap: () => onChanged(ViewMode.week),
          ),
          _ToggleBtn(
            label: 'Month',
            selected: viewMode == ViewMode.month,
            onTap: () => onChanged(ViewMode.month),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? c.background : c.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        'SPENDING BY CATEGORY',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: c.textSecondary,
        ),
      ),
    );
  }
}

// ─── Category group tile ──────────────────────────────────────────────────────

class _CategoryGroupTile extends StatelessWidget {
  final CategoryTransactionGroup group;
  final bool isExpanded;
  final double totalSpending;
  final VoidCallback onToggle;
  final VoidCallback onAddTransaction;

  const _CategoryGroupTile({
    required this.group,
    required this.isExpanded,
    required this.totalSpending,
    required this.onToggle,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final color = _colorForKey(group.categoryIcon);
    final fraction = totalSpending > 0
        ? (group.total / totalSpending).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _iconForKey(group.categoryIcon),
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                group.categoryName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: c.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _RecencyBadge(transactions: group.transactions),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: fraction,
                                    backgroundColor: c.border,
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '\$${NumberFormat('#,##0.##').format(group.total)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: c.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: c.textSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Column(
                      children: [
                        Divider(color: c.border, height: 1, indent: 16, endIndent: 16),
                        ...group.transactions.map(
                          (t) => _TransactionItem(transaction: t),
                        ),
                        InkWell(
                          onTap: onAddTransaction,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, color: c.primary, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Add Transaction',
                                  style: TextStyle(
                                    color: c.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recency badge ────────────────────────────────────────────────────────────

class _RecencyBadge extends StatelessWidget {
  final List<Transaction> transactions;

  const _RecencyBadge({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final mostRecent = transactions
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .reduce((a, b) => a.isAfter(b) ? a : b);

    String? label;
    Color bg;
    if (mostRecent == today) {
      label = 'Today';
      bg = const Color(0xFFB36200);
    } else if (mostRecent == yesterday) {
      label = 'Yesterday';
      bg = const Color(0xFF555555);
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Transaction item ─────────────────────────────────────────────────────────

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final title = transaction.note.isNotEmpty
        ? transaction.note
        : transaction.category?.name ?? 'Transaction';
    final subtitle =
        '\$${NumberFormat('#,##0.##').format(transaction.amount)} at ${transaction.account.name}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: c.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.drag_handle, color: c.textHint, size: 20),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 56, color: c.textHint),
          const SizedBox(height: 16),
          Text(
            'No transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to record a transaction',
            style: TextStyle(fontSize: 14, color: c.textHint),
          ),
        ],
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String? message;
  final TransactionListCubit cubit;

  const _ErrorState(this.message, this.cubit);

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: c.error),
          const SizedBox(height: 12),
          Text(
            message ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary),
          ),
          const SizedBox(height: 20),
          TextButton(onPressed: cubit.loadData, child: const Text('Retry')),
        ],
      ),
    );
  }
}
