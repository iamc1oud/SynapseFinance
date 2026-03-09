import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/constants/fiat_currencies.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/tag.dart';
import '../bloc/add_transfer_cubit.dart';
import '../bloc/add_transfer_state.dart';
import '../widgets/number_pad.dart';

class AddTransferPage extends StatefulWidget {
  const AddTransferPage({super.key});

  @override
  State<AddTransferPage> createState() => _AddTransferPageState();
}

class _AddTransferPageState extends State<AddTransferPage> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    context.read<AddTransferCubit>().loadData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return BlocConsumer<AddTransferCubit, AddTransferState>(
      listener: (context, state) {
        if (state.status == AddTransferStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transfer completed!'),
              backgroundColor: c.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
        if (state.status == AddTransferStatus.error &&
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
        final cubit = context.read<AddTransferCubit>();
        return Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            backgroundColor: c.background,
            leading: TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: c.textSecondary),
              ),
            ),
            leadingWidth: 80,
            title: Text(
              'Manual Transfer',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          resizeToAvoidBottomInset: false,
          body: _buildBody(context, state, cubit, c),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AddTransferState state,
    AddTransferCubit cubit,
    AppColorScheme c,
  ) {
    final amountDisplay = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            'TRANSFER AMOUNT',
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
                fiatCurrencies[state.fromAccount?.currency]?.$2 ?? '\$',
                style: TextStyle(
                  fontSize: 28,
                  color: c.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                state.amountInput == '0' ? '0.00' : state.amountInput,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final accountsSection = state.status == AddTransferStatus.loading
        ? Center(child: CircularProgressIndicator(color: c.primary))
        : Column(
            children: [
              _AccountCard(
                label: 'FROM ACCOUNT',
                account: state.fromAccount,
                accounts: state.accounts,
                icon: Icons.account_balance,
                onSelected: cubit.selectFromAccount,
              ),
              Center(
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.primary,
                  ),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 20,
                    color: c.background,
                  ),
                ),
              ),
              _AccountCard(
                label: 'TO ACCOUNT',
                account: state.toAccount,
                accounts: state.accounts,
                icon: Icons.savings,
                onSelected: cubit.selectToAccount,
              ),
            ],
          );

    final detailsSection = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'DATE',
            value: DateFormat('EEEE, MMM d yyyy').format(state.selectedDate),
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: c.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    onChanged: cubit.updateNote,
                    style: TextStyle(fontSize: 14, color: c.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle: TextStyle(color: c.textHint, fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (state.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'QUICK TAGS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                color: c.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.tags.map((tag) {
                final isSelected = state.selectedTagIds.contains(tag.id);
                return _TagChip(
                  tag: tag,
                  isSelected: isSelected,
                  onTap: () => cubit.toggleTag(tag.id),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );

    final numPad = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: NumberPad(onDigit: cubit.inputDigit, onDelete: cubit.deleteDigit),
    );

    final confirmButton = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed:
              state.status == AddTransferStatus.saving ? null : cubit.confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: c.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: state.status == AddTransferStatus.saving
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.background,
                  ),
                )
              : Text(
                  'Confirm Transfer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: c.background,
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      amountDisplay,
                      accountsSection,
                      const SizedBox(height: 16),
                      detailsSection,
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: c.border),
              SizedBox(
                width: 360,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),
                    numPad,
                    confirmButton,
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    amountDisplay,
                    accountsSection,
                    const SizedBox(height: 16),
                    detailsSection,
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            numPad,
            confirmButton,
          ],
        );
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String label;
  final Account? account;
  final List<Account> accounts;
  final IconData icon;
  final ValueChanged<Account> onSelected;

  const _AccountCard({
    required this.label,
    required this.account,
    required this.accounts,
    required this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: accounts.isEmpty ? null : () => _showAccountPicker(context, c),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: c.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.0,
                      color: c.textHint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account?.name ?? 'Select account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  if (account != null)
                    Text(
                      'Balance: ${account!.formattedBalance}',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: c.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker(BuildContext context, AppColorScheme c) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Select $label',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: c.textPrimary,
              ),
            ),
          ),
          ...accounts.map(
            (a) => ListTile(
              leading: Icon(Icons.account_balance, color: c.primary),
              title: Text(a.name, style: TextStyle(color: c.textPrimary)),
              subtitle: Text(
                a.formattedBalance,
                style: TextStyle(color: c.textSecondary),
              ),
              onTap: () {
                onSelected(a);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.primary.withAlpha(40) : c.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c.primary : Colors.transparent,
          ),
        ),
        child: Text(
          tag.name,
          style: TextStyle(
            color: isSelected ? c.primary : c.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: c.textPrimary,
                  ),
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
