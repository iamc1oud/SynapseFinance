import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ledger/domain/usecases/get_transactions_by_category_usecase.dart';
import '../../../ledger/presentation/bloc/transaction_list_cubit.dart';
import '../../../ledger/presentation/pages/transaction_list_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _tabs = [
    const _AssistantTab(),
    BlocProvider(
      create: (_) => TransactionListCubit(
        getIt<GetTransactionsByCategoryUseCase>(),
      ),
      child: const TransactionListPage(),
    ),
    const _CategoriesTab(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      extendBody: true,
      backgroundColor: c.background,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      floatingActionButton: _currentIndex != 3
          ? FloatingActionButton(
              onPressed: () => context.push('/add-transaction'),
              backgroundColor: c.primary,
              foregroundColor: c.background,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: _FrostedNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─── Frosted glass nav bar ─────────────────────────────────────────────────────

class _FrostedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FrostedNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.chat_bubble_outline_rounded, 'Assistant'),
    (Icons.bar_chart_rounded, 'Insights'),
    (Icons.category_outlined, 'Categories'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.72),
            border: Border(
              top: BorderSide(
                color: c.primary.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: 10,
            left: 8,
            right: 8,
            bottom: bottomInset > 0 ? bottomInset : 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final (icon, label) = _items[i];
              return _NavItem(
                icon: icon,
                label: label,
                isSelected: currentIndex == i,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 40,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isSelected
                    ? c.primary.withValues(alpha: 0.18)
                    : Colors.transparent,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? c.primary : c.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? c.primary : c.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab content ───────────────────────────────────────────────────────────────

class _AssistantTab extends StatelessWidget {
  const _AssistantTab();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 56, color: c.primary),
            const SizedBox(height: 16),
            Text(
              'AI Assistant',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chat to log expenses or get insights',
              style: TextStyle(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 56, color: c.primary),
            const SizedBox(height: 16),
            Text(
              'Manage Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Organise your spending by category',
              style: TextStyle(color: c.textSecondary),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () => context.push('/create-category'),
              icon: Icon(Icons.add_circle_outline, color: c.primary),
              label: Text(
                'New Category',
                style: TextStyle(color: c.primary),
              ),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
