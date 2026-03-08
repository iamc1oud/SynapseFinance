import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../ledger/domain/entities/account.dart';
import '../../../ledger/domain/entities/category.dart';
import '../../../settings/domain/entities/sub_currency.dart';
import '../bloc/add_subscription_cubit.dart';
import '../bloc/add_subscription_state.dart';

class AddSubscriptionPage extends StatefulWidget {
  const AddSubscriptionPage({super.key});

  @override
  State<AddSubscriptionPage> createState() => _AddSubscriptionPageState();
}

class _AddSubscriptionPageState extends State<AddSubscriptionPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _customDaysController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _customDaysController = TextEditingController();
    context.read<AddSubscriptionCubit>().loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _customDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return BlocConsumer<AddSubscriptionCubit, AddSubscriptionState>(
      listener: (context, state) async {
        if (state.status == AddSubscriptionStatus.saved &&
            state.savedSubscription != null) {
          final result = await context.push<bool>(
            '/subscription-success',
            extra: state.savedSubscription,
          );
          if (context.mounted) {
            context.pop(result ?? true);
          }
          return;
        }
        if (state.status == AddSubscriptionStatus.error &&
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
        final cubit = context.read<AddSubscriptionCubit>();
        final isSaving = state.status == AddSubscriptionStatus.saving;
        final isLoading = state.status == AddSubscriptionStatus.loading;

        return Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            title: Text(
              'Add Recurring',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: c.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: c.textPrimary),
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator(color: c.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      _buildLabel(c, 'Transaction Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        c,
                        controller: _nameController,
                        hint: 'e.g. Netflix, Gym, Rent',
                        onChanged: cubit.setName,
                      ),

                      const SizedBox(height: 20),

                      // Amount + Currency
                      _buildLabel(c, 'Amount'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              c,
                              controller: _amountController,
                              hint: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              onChanged: cubit.setAmount,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _CurrencyChip(
                            currency: state.currency,
                            color: c,
                            onTap: state.availableCurrencies.length > 1
                                ? () => _showCurrencyPicker(
                                      context,
                                      c,
                                      currencies: state.availableCurrencies,
                                      selected: state.currency,
                                      onSelected: cubit.setCurrency,
                                    )
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Category
                      _buildLabel(c, 'Category'),
                      const SizedBox(height: 8),
                      _CategoryPicker(
                        categories: state.categories,
                        selected: state.selectedCategory,
                        onSelected: cubit.selectCategory,
                      ),

                      const SizedBox(height: 20),

                      // Frequency
                      _buildLabel(c, 'Frequency'),
                      const SizedBox(height: 8),
                      _FrequencySelector(
                        selected: state.frequency,
                        onSelected: cubit.setFrequency,
                      ),

                      // Custom interval
                      if (state.frequency == 'custom') ...[
                        const SizedBox(height: 12),
                        _buildTextField(
                          c,
                          controller: _customDaysController,
                          hint: 'Interval in days',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (val) {
                            final days = int.tryParse(val);
                            if (days != null && days > 0) {
                              cubit.setCustomIntervalDays(days);
                            }
                          },
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Start Date
                      _buildLabel(c, 'Start Date'),
                      const SizedBox(height: 8),
                      _DatePickerTile(
                        date: state.startDate,
                        onPicked: (d) {
                          if (d != null) cubit.setStartDate(d);
                        },
                      ),

                      const SizedBox(height: 20),

                      // End Date (optional)
                      _buildLabel(c, 'End Date (optional)'),
                      const SizedBox(height: 8),
                      _DatePickerTile(
                        date: state.endDate,
                        hint: 'No end date',
                        onPicked: cubit.setEndDate,
                      ),

                      const SizedBox(height: 20),

                      // Payment Method
                      _buildLabel(c, 'Payment Method'),
                      const SizedBox(height: 8),
                      _AccountPicker(
                        accounts: state.accounts,
                        selected: state.selectedAccount,
                        onSelected: cubit.selectAccount,
                      ),

                      const SizedBox(height: 20),

                      // Reminders
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: c.border.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Reminders',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: c.textPrimary,
                                  ),
                                ),
                                Switch.adaptive(
                                  value: state.reminderEnabled,
                                  onChanged: cubit.setReminderEnabled,
                                  activeThumbColor: c.primary,
                                  activeTrackColor:
                                      c.primary.withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                            if (state.reminderEnabled) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Remind me',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _DaysBeforeDropdown(
                                    value: state.reminderDaysBefore,
                                    onChanged: cubit.setReminderDaysBefore,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'day(s) before',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Note
                      _buildLabel(c, 'Note'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        c,
                        controller: _noteController,
                        hint: 'Optional note',
                        onChanged: cubit.setNote,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : cubit.save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.primary,
                            foregroundColor: c.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            disabledBackgroundColor:
                                c.primary.withValues(alpha: 0.4),
                          ),
                          child: isSaving
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: c.background,
                                  ),
                                )
                              : const Text(
                                  'Save Recurring',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildLabel(AppColorScheme c, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c.textSecondary,
      ),
    );
  }

  Widget _buildTextField(
    AppColorScheme c, {
    required TextEditingController controller,
    required String hint,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(color: c.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textHint),
        filled: true,
        fillColor: c.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Frequency chips ──────────────────────────────────────────────────────────

class _FrequencySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _FrequencySelector({
    required this.selected,
    required this.onSelected,
  });

  static const _options = [
    ('monthly', 'Monthly'),
    ('weekly', 'Weekly'),
    ('yearly', 'Yearly'),
    ('custom', 'Custom'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((opt) {
        final isSelected = selected == opt.$1;
        return ChoiceChip(
          label: Text(opt.$2),
          selected: isSelected,
          onSelected: (_) => onSelected(opt.$1),
          selectedColor: c.primary.withValues(alpha: 0.2),
          backgroundColor: c.surface,
          side: BorderSide(
            color: isSelected ? c.primary : c.border.withValues(alpha: 0.5),
          ),
          labelStyle: TextStyle(
            color: isSelected ? c.primary : c.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}

// ─── Currency chip ────────────────────────────────────────────────────────────

class _CurrencyChip extends StatelessWidget {
  final String currency;
  final AppColorScheme color;
  final VoidCallback? onTap;

  const _CurrencyChip({required this.currency, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
        currency,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color.textPrimary,
        ),
      ),
          if (onTap != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.arrow_drop_down, size: 18, color: color.textSecondary),
            ),
        ],
      ),
      ),
    );
  }
}

void _showCurrencyPicker(
  BuildContext context,
  AppColorScheme c, {
  required List<SubCurrency> currencies,
  required String selected,
  required ValueChanged<String> onSelected,
}) {
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
            'Select Currency',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: c.textPrimary,
            ),
          ),
        ),
        ...currencies.map(
          (sc) => ListTile(
            leading: Icon(Icons.currency_exchange, color: c.primary),
            title: Text(sc.currency, style: TextStyle(color: c.textPrimary)),
            subtitle: sc.isMain
                ? Text('Main currency', style: TextStyle(color: c.textSecondary, fontSize: 12))
                : null,
            trailing: sc.currency == selected
                ? Icon(Icons.check_circle, color: c.primary, size: 20)
                : null,
            onTap: () {
              onSelected(sc.currency);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    ),
  );
}

// ─── Category picker ──────────────────────────────────────────────────────────

class _CategoryPicker extends StatelessWidget {
  final List<Category> categories;
  final Category? selected;
  final ValueChanged<Category?> onSelected;

  const _CategoryPicker({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected?.name ?? 'Select category',
                style: TextStyle(
                  fontSize: 15,
                  color: selected != null ? c.textPrimary : c.textHint,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: c.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final c = context.appColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Select Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.close, color: c.textSecondary),
            title: Text('None', style: TextStyle(color: c.textSecondary)),
            onTap: () {
              onSelected(null);
              Navigator.pop(ctx);
            },
          ),
          ...categories.map(
            (cat) => ListTile(
              leading: Icon(Icons.circle, size: 12, color: c.primary),
              title: Text(cat.name, style: TextStyle(color: c.textPrimary)),
              trailing: selected?.id == cat.id
                  ? Icon(Icons.check, color: c.primary)
                  : null,
              onTap: () {
                onSelected(cat);
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Account picker ───────────────────────────────────────────────────────────

class _AccountPicker extends StatelessWidget {
  final List<Account> accounts;
  final Account? selected;
  final ValueChanged<Account> onSelected;

  const _AccountPicker({
    required this.accounts,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected?.name ?? 'Select account',
                style: TextStyle(
                  fontSize: 15,
                  color: selected != null ? c.textPrimary : c.textHint,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: c.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final c = context.appColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
          ),
          ...accounts.map(
            (acc) => ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined,
                  color: c.primary),
              title: Text(acc.name, style: TextStyle(color: c.textPrimary)),
              subtitle: Text(
                acc.formattedBalance,
                style: TextStyle(color: c.textSecondary, fontSize: 12),
              ),
              trailing: selected?.id == acc.id
                  ? Icon(Icons.check, color: c.primary)
                  : null,
              onTap: () {
                onSelected(acc);
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date picker tile ─────────────────────────────────────────────────────────

class _DatePickerTile extends StatelessWidget {
  final DateTime? date;
  final String? hint;
  final ValueChanged<DateTime?> onPicked;

  const _DatePickerTile({
    this.date,
    this.hint,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2040),
          builder: (ctx, child) {
            final brightness = Theme.of(ctx).brightness;
            final scheme = brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: c.primary,
                    onPrimary: c.background,
                    surface: c.surface,
                    onSurface: c.textPrimary,
                  )
                : ColorScheme.light(
                    primary: c.primary,
                    onPrimary: Colors.white,
                    surface: c.surface,
                    onSurface: c.textPrimary,
                  );
            return Theme(
              data: Theme.of(ctx).copyWith(colorScheme: scheme),
              child: child!,
            );
          },
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: c.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('MMM d, yyyy').format(date!)
                    : (hint ?? 'Select date'),
                style: TextStyle(
                  fontSize: 15,
                  color: date != null ? c.textPrimary : c.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Days before dropdown ─────────────────────────────────────────────────────

class _DaysBeforeDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _DaysBeforeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: c.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          dropdownColor: c.surface,
          style: TextStyle(color: c.textPrimary, fontSize: 14),
          items: [1, 2, 3, 5, 7]
              .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
