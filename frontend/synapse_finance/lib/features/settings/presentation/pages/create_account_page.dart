import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../ledger/presentation/bloc/create_account_cubit.dart';
import '../../../ledger/presentation/bloc/create_account_state.dart';
import '../bloc/currency_management_cubit.dart';
import '../bloc/currency_management_state.dart';
import '../constants/fiat_currencies.dart';

const _accountTypes = [
  ('checking', 'Checking'),
  ('savings', 'Savings'),
  ('credit', 'Credit Card'),
  ('cash', 'Cash'),
  ('investment', 'Investment'),
];

const _iconOptions = [
  ('account_balance', Icons.account_balance, 'Bank'),
  ('savings', Icons.savings, 'Savings'),
  ('credit_card', Icons.credit_card, 'Credit'),
  ('cash', Icons.payments, 'Cash'),
  ('investment', Icons.trending_up, 'Invest'),
  ('wallet', Icons.account_balance_wallet, 'Wallet'),
  ('business', Icons.business, 'Business'),
  ('attach_money', Icons.attach_money, 'Money'),
];

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  bool _currencyInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _balanceController = TextEditingController(text: '0.00');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return BlocListener<CurrencyManagementCubit, CurrencyManagementState>(
      listener: (context, currState) {
        if (!_currencyInitialized &&
            currState.mainCurrency != null) {
          _currencyInitialized = true;
          context
              .read<CreateAccountCubit>()
              .setCurrency(currState.mainCurrency!.currency);
        }
      },
      child: BlocConsumer<CreateAccountCubit, CreateAccountState>(
      listener: (context, state) {
        if (state.status == CreateAccountStatus.saved) {
          Navigator.of(context).pop(state.createdAccount);
        }
        if (state.status == CreateAccountStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: c.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateAccountCubit>();
        return Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            backgroundColor: c.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: c.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'New Account',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: state.status == CreateAccountStatus.saving
                    ? null
                    : cubit.save,
                child: state.status == CreateAccountStatus.saving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: c.primary,
                        ),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          color: c.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon preview
                Center(
                  child: _IconPreview(
                    icon: _iconDataFor(state.selectedIcon),
                    label: state.name.isEmpty ? 'Preview' : state.name,
                  ),
                ),
                const SizedBox(height: 28),

                // Account name
                _SectionLabel('Account Name'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  onChanged: cubit.setName,
                  style: TextStyle(color: c.textPrimary),
                  decoration: _inputDecoration(
                    c,
                    hintText: 'e.g. Main Checking, Emergency Fund...',
                  ),
                ),
                const SizedBox(height: 24),

                // Account type
                _SectionLabel('Account Type'),
                const SizedBox(height: 8),
                _AccountTypeSelector(
                  selected: state.accountType,
                  onChanged: cubit.setAccountType,
                ),
                const SizedBox(height: 24),

                // Currency
                _SectionLabel('Currency'),
                const SizedBox(height: 8),
                _CurrencySelector(
                  selected: state.currency,
                  onChanged: cubit.setCurrency,
                ),
                const SizedBox(height: 24),

                // Initial balance
                _SectionLabel('Initial Balance'),
                const SizedBox(height: 8),
                TextField(
                  controller: _balanceController,
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed != null) cubit.setBalance(parsed);
                  },
                  style: TextStyle(color: c.textPrimary),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: _inputDecoration(
                    c,
                    hintText: '0.00',
                    prefixText:
                        '${fiatCurrencies[state.currency]?.$2 ?? '\$'} ',
                  ),
                ),
                const SizedBox(height: 28),

                // Icon picker
                _SectionLabel('Choose Icon'),
                const SizedBox(height: 12),
                _IconGrid(
                  selected: state.selectedIcon,
                  onSelected: cubit.setIcon,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

InputDecoration _inputDecoration(
  AppColorScheme c, {
  required String hintText,
  String? prefixText,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: c.textHint),
    prefixText: prefixText,
    prefixStyle: TextStyle(color: c.textPrimary, fontSize: 16),
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
      borderSide: BorderSide(color: c.borderFocused, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

IconData _iconDataFor(String key) {
  return _iconOptions
      .firstWhere((e) => e.$1 == key, orElse: () => _iconOptions.first)
      .$2;
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Text(
      text,
      style: TextStyle(
        color: c.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _IconPreview extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconPreview({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.primary,
          ),
          child: Icon(icon, size: 32, color: c.background),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: c.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _AccountTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _AccountTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _accountTypes.map((type) {
        final isSelected = selected == type.$1;
        return GestureDetector(
          onTap: () => onChanged(type.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? c.primary : c.surface,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? null
                  : Border.all(color: c.border, width: 1),
            ),
            child: Text(
              type.$2,
              style: TextStyle(
                color: isSelected ? c.background : c.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IconGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _IconGrid({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _iconOptions.length,
      itemBuilder: (context, index) {
        final (key, iconData, label) = _iconOptions[index];
        final isSelected = selected == key;
        return GestureDetector(
          onTap: () => onSelected(key),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? c.primary : c.surfaceLight,
                  border: isSelected
                      ? null
                      : Border.all(color: c.border, width: 1),
                ),
                child: Icon(
                  iconData,
                  size: 22,
                  color: isSelected ? c.background : c.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? c.primary : c.textHint,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CurrencySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    // Get user's configured currencies from CurrencyManagementCubit if available
    final currencyState =
        context.watch<CurrencyManagementCubit>().state;
    final userCurrencies = <String>[];
    if (currencyState.mainCurrency != null) {
      userCurrencies.add(currencyState.mainCurrency!.currency);
    }
    for (final sc in currencyState.subCurrencies) {
      userCurrencies.add(sc.currency);
    }

    // Fallback if no currencies loaded yet
    if (userCurrencies.isEmpty) {
      userCurrencies.add('USD');
    }

    // Ensure selected currency is in the list
    if (!userCurrencies.contains(selected)) {
      userCurrencies.add(selected);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: userCurrencies.map((code) {
        final isSelected = selected == code;
        final info = fiatCurrencies[code];
        final symbol = info?.$2 ?? code;
        return GestureDetector(
          onTap: () => onChanged(code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? c.primary : c.surface,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? null
                  : Border.all(color: c.border, width: 1),
            ),
            child: Text(
              '$code ($symbol)',
              style: TextStyle(
                color: isSelected ? c.background : c.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
