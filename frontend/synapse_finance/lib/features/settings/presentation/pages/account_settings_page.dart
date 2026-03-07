import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ledger/domain/entities/account.dart';
import '../../../ledger/presentation/bloc/account_settings_cubit.dart';
import '../../../ledger/presentation/bloc/account_settings_state.dart';
import '../../../ledger/presentation/bloc/create_account_cubit.dart';
import 'create_account_page.dart';

IconData _iconForAccount(String icon) {
  switch (icon.toLowerCase()) {
    case 'account_balance':
      return Icons.account_balance;
    case 'savings':
      return Icons.savings;
    case 'credit_card':
      return Icons.credit_card;
    case 'payments':
    case 'cash':
      return Icons.payments;
    case 'trending_up':
    case 'investment':
      return Icons.trending_up;
    case 'wallet':
      return Icons.account_balance_wallet;
    case 'business':
      return Icons.business;
    case 'attach_money':
      return Icons.attach_money;
    default:
      return Icons.account_balance;
  }
}

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

String _accountTypeLabel(String type) {
  switch (type) {
    case 'checking':
      return 'Checking';
    case 'savings':
      return 'Savings';
    case 'credit':
      return 'Credit Card';
    case 'cash':
      return 'Cash';
    case 'investment':
      return 'Investment';
    default:
      return type;
  }
}

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AccountSettingsCubit>()..loadAccounts(),
      child: const _AccountSettingsView(),
    );
  }
}

class _AccountSettingsView extends StatelessWidget {
  const _AccountSettingsView();

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
          'Account Settings',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<AccountSettingsCubit, AccountSettingsState>(
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
          if (state.status == AccountSettingsStatus.loading) {
            return Center(
              child: CircularProgressIndicator(color: c.primary),
            );
          }

          final cubit = context.read<AccountSettingsCubit>();
          final active = state.filteredActiveAccounts;
          final archived = state.filteredArchivedAccounts;

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
                      hintText: 'Search accounts',
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

              // Add New Account button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToCreateAccount(context),
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      label: const Text(
                        'Add New Account',
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

              // Active accounts header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE ACCOUNTS',
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

              // Active account list
              active.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No active accounts',
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
                            child: _AccountCard(
                              account: active[index],
                              colorIndex: index,
                              onArchive: () =>
                                  cubit.archiveAccount(active[index].id),
                              onRename: (newName) =>
                                  cubit.updateAccount(
                                    id: active[index].id,
                                    name: newName,
                                  ),
                            ),
                          ),
                          childCount: active.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Archived accounts section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: c.border, height: 1),
                ),
              ),

              SliverToBoxAdapter(
                child: _ArchivedSection(
                  accounts: archived,
                  onRestore: cubit.restoreAccount,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _navigateToCreateAccount(BuildContext context) async {
    final cubit = context.read<AccountSettingsCubit>();
    final result = await Navigator.of(context).push<Account>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<CreateAccountCubit>(),
          child: const CreateAccountPage(),
        ),
      ),
    );
    if (result != null) {
      cubit.loadAccounts();
    }
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final int colorIndex;
  final VoidCallback onArchive;
  final ValueChanged<String> onRename;

  const _AccountCard({
    required this.account,
    required this.colorIndex,
    required this.onArchive,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bgColor = _iconBgColors[colorIndex % _iconBgColors.length];
    return Dismissible(
      key: ValueKey(account.id),
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
                _iconForAccount(account.icon),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_accountTypeLabel(account.accountType)} · ${account.formattedBalance}',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: c.textHint, size: 20),
              color: c.surface,
              onSelected: (value) {
                if (value == 'archive') onArchive();
                if (value == 'edit') _showRenameDialog(context);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: c.primary, size: 18),
                      const SizedBox(width: 8),
                      Text('Rename', style: TextStyle(color: c.textPrimary)),
                    ],
                  ),
                ),
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
        title: Text('Archive Account', style: TextStyle(color: c.textPrimary)),
        content: Text(
          'Archive "${account.name}"? You can restore it later.',
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

  void _showRenameDialog(BuildContext context) {
    final c = context.appColors;
    final controller = TextEditingController(text: account.name);
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Rename Account', style: TextStyle(color: c.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: 'Account name',
            hintStyle: TextStyle(color: c.textHint),
            filled: true,
            fillColor: c.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.borderFocused),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              Navigator.of(ctx).pop(newName);
            },
            child: Text('Save', style: TextStyle(color: c.primary)),
          ),
        ],
      ),
    ).then((newName) {
      if (newName != null && newName.isNotEmpty && newName != account.name) {
        onRename(newName);
      }
    });
  }
}

class _ArchivedSection extends StatefulWidget {
  final List<Account> accounts;
  final void Function(int id) onRestore;

  const _ArchivedSection({
    required this.accounts,
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
                  'Archived Accounts',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.accounts.isNotEmpty)
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
                          '${widget.accounts.length}',
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
          ...widget.accounts.map(
            (account) => Padding(
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
                        _iconForAccount(account.icon),
                        color: c.textHint,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: TextStyle(
                              color: c.textHint,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _accountTypeLabel(account.accountType),
                            style: TextStyle(
                              color: c.textHint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onRestore(account.id),
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
