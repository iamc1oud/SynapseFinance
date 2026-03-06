import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ledger/domain/entities/category.dart';
import '../../../ledger/presentation/bloc/category_settings_cubit.dart';
import '../../../ledger/presentation/bloc/category_settings_state.dart';
import '../../../ledger/presentation/pages/create_category_page.dart';
import '../../../ledger/presentation/bloc/create_category_cubit.dart';

// Icon mapping shared with category_selector.dart
IconData _iconForCategory(String icon) {
  switch (icon.toLowerCase()) {
    case 'food':
      return Icons.restaurant;
    case 'coffee':
      return Icons.local_cafe;
    case 'transport':
    case 'car':
      return Icons.directions_car;
    case 'shopping':
      return Icons.shopping_bag;
    case 'rent':
    case 'home':
      return Icons.home;
    case 'gym':
    case 'fitness':
      return Icons.fitness_center;
    case 'salary':
      return Icons.account_balance_wallet;
    case 'work':
      return Icons.work;
    case 'investment':
      return Icons.trending_up;
    case 'entertainment':
      return Icons.movie;
    case 'health':
      return Icons.local_hospital;
    case 'education':
      return Icons.school;
    case 'gift':
      return Icons.card_giftcard;
    case 'travel':
      return Icons.flight;
    case 'phone':
      return Icons.phone_android;
    case 'internet':
      return Icons.wifi;
    case 'groceries':
      return Icons.local_grocery_store;
    case 'savings':
      return Icons.savings;
    case 'cash':
      return Icons.payments;
    case 'freelance':
      return Icons.laptop_mac;
    default:
      return Icons.circle;
  }
}

// Icon background colors to give each category a distinct look
const _iconBgColors = [
  Color(0xFF1B5E20),
  Color(0xFF4A148C),
  Color(0xFF0D47A1),
  Color(0xFFBF360C),
  Color(0xFF006064),
  Color(0xFF880E4F),
  Color(0xFF33691E),
  Color(0xFF1A237E),
];

class CategorySettingsPage extends StatelessWidget {
  final String categoryType; // 'income' or 'expense'

  const CategorySettingsPage({super.key, required this.categoryType});

  String get _title =>
      categoryType == 'income' ? 'Income Categories' : 'Expense Categories';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategorySettingsCubit>()..loadCategories(categoryType),
      child: _CategorySettingsView(
        title: _title,
        categoryType: categoryType,
      ),
    );
  }
}

class _CategorySettingsView extends StatelessWidget {
  final String title;
  final String categoryType;

  const _CategorySettingsView({
    required this.title,
    required this.categoryType,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<CategorySettingsCubit, CategorySettingsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: c.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CategorySettingsStatus.loading) {
            return Center(
              child: CircularProgressIndicator(color: c.primary),
            );
          }

          final cubit = context.read<CategorySettingsCubit>();
          final active = state.filteredActiveCategories;
          final archived = state.filteredArchivedCategories;

          return CustomScrollView(
            slivers: [
              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    onChanged: cubit.updateSearch,
                    style: TextStyle(color: c.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search categories',
                      hintStyle: TextStyle(color: c.textHint),
                      prefixIcon: Icon(Icons.search, color: c.textHint),
                      filled: true,
                      fillColor: c.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.borderFocused),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Add New Category button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToCreateCategory(context),
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      label: const Text(
                        'Add New Category',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: c.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Active categories header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE CATEGORIES',
                        style: TextStyle(
                          color: c.textHint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '${active.length} Total',
                        style: TextStyle(
                          color: c.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Active category list
              active.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No active categories',
                            style: TextStyle(color: c.textHint),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _CategoryCard(
                              category: active[index],
                              colorIndex: index,
                              onArchive: () =>
                                  cubit.archiveCategory(active[index].id),
                            ),
                          ),
                          childCount: active.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Archived categories section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: c.border, height: 1),
                ),
              ),

              SliverToBoxAdapter(
                child: _ArchivedSection(
                  categories: archived,
                  onRestore: cubit.restoreCategory,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _navigateToCreateCategory(BuildContext context) async {
    final cubit = context.read<CategorySettingsCubit>();
    final result = await Navigator.of(context).push<Category>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<CreateCategoryCubit>()
            ..setCategoryType(categoryType),
          child: const CreateCategoryPage(),
        ),
      ),
    );
    if (result != null) {
      cubit.loadCategories(categoryType);
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int colorIndex;
  final VoidCallback onArchive;

  const _CategoryCard({
    required this.category,
    required this.colorIndex,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bgColor = _iconBgColors[colorIndex % _iconBgColors.length];
    return Dismissible(
      key: ValueKey(category.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: c.warning,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.archive_outlined, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmArchive(context),
      onDismissed: (_) => onArchive(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForCategory(category.icon),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: c.textHint, size: 20),
              color: c.surface,
              onSelected: (value) {
                if (value == 'archive') onArchive();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive_outlined, color: c.warning, size: 18),
                      const SizedBox(width: 8),
                      Text('Archive', style: TextStyle(color: c.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmArchive(BuildContext context) {
    final c = context.appColors;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Archive Category', style: TextStyle(color: c.textPrimary)),
        content: Text(
          'Archive "${category.name}"? You can restore it later.',
          style: TextStyle(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Archive', style: TextStyle(color: c.warning)),
          ),
        ],
      ),
    );
  }
}

class _ArchivedSection extends StatefulWidget {
  final List<Category> categories;
  final void Function(int id) onRestore;

  const _ArchivedSection({
    required this.categories,
    required this.onRestore,
  });

  @override
  State<_ArchivedSection> createState() => _ArchivedSectionState();
}

class _ArchivedSectionState extends State<_ArchivedSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Archived Categories',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.categories.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: c.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.categories.length}',
                          style: TextStyle(
                            color: c.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: c.textHint,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.categories.map(
            (category) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _iconForCategory(category.icon),
                        color: c.textHint,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: c.textHint,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onRestore(category.id),
                      style: TextButton.styleFrom(
                        foregroundColor: c.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text(
                        'Restore',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
