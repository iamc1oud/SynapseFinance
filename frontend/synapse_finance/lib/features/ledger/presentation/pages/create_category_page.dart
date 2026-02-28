import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/create_category_cubit.dart';
import '../bloc/create_category_state.dart';

// All available icon options: (identifier, IconData, display label)
const _iconOptions = [
  ('food', Icons.restaurant, 'Food'),
  ('coffee', Icons.local_cafe, 'Coffee'),
  ('transport', Icons.directions_car, 'Transport'),
  ('shopping', Icons.shopping_bag, 'Shopping'),
  ('home', Icons.home, 'Home'),
  ('fitness', Icons.fitness_center, 'Gym'),
  ('health', Icons.local_hospital, 'Health'),
  ('education', Icons.school, 'Education'),
  ('work', Icons.work, 'Work'),
  ('investment', Icons.trending_up, 'Invest'),
  ('entertainment', Icons.movie, 'Fun'),
  ('travel', Icons.flight, 'Travel'),
  ('gift', Icons.card_giftcard, 'Gift'),
  ('phone', Icons.phone_android, 'Phone'),
  ('internet', Icons.wifi, 'Internet'),
  ('electricity', Icons.bolt, 'Electric'),
  ('water', Icons.water_drop, 'Water'),
  ('pet', Icons.pets, 'Pets'),
  ('book', Icons.book, 'Books'),
  ('music', Icons.music_note, 'Music'),
  ('game', Icons.sports_esports, 'Games'),
  ('beauty', Icons.face, 'Beauty'),
  ('clothes', Icons.checkroom, 'Clothes'),
  ('savings', Icons.savings, 'Savings'),
  ('cash', Icons.payments, 'Cash'),
  ('insurance', Icons.security, 'Insurance'),
  ('tax', Icons.account_balance, 'Tax'),
  ('charity', Icons.volunteer_activism, 'Charity'),
  ('baby', Icons.child_care, 'Baby'),
  ('car_repair', Icons.car_repair, 'Car Fix'),
  ('groceries', Icons.local_grocery_store, 'Grocery'),
  ('rent', Icons.apartment, 'Rent'),
  ('salary', Icons.account_balance_wallet, 'Salary'),
  ('circle', Icons.circle_outlined, 'Other'),
];

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return BlocConsumer<CreateCategoryCubit, CreateCategoryState>(
      listener: (context, state) {
        if (state.status == CreateCategoryStatus.saved) {
          Navigator.of(context).pop(state.createdCategory);
        }
        if (state.status == CreateCategoryStatus.error &&
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
        final cubit = context.read<CreateCategoryCubit>();
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
              'New Category',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: state.status == CreateCategoryStatus.saving
                    ? null
                    : cubit.save,
                child: state.status == CreateCategoryStatus.saving
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
                _TypeToggle(
                  selected: state.categoryType,
                  onChanged: cubit.setCategoryType,
                ),
                const SizedBox(height: 28),

                Center(
                  child: _IconPreview(
                    icon: _iconDataFor(state.selectedIcon),
                    label: state.name.isEmpty ? 'Preview' : state.name,
                  ),
                ),
                const SizedBox(height: 28),

                _SectionLabel('Category Name'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  onChanged: cubit.setName,
                  style: TextStyle(color: c.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g. Coffee, Rent, Freelance...',
                    hintStyle: TextStyle(color: c.textHint),
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
                      borderSide: BorderSide(
                        color: c.borderFocused,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

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
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

IconData _iconDataFor(String key) {
  return _iconOptions
      .firstWhere((e) => e.$1 == key, orElse: () => _iconOptions.last)
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

class _TypeToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Expense',
            isSelected: selected == 'expense',
            onTap: () => onChanged('expense'),
          ),
          _ToggleOption(
            label: 'Income',
            isSelected: selected == 'income',
            onTap: () => onChanged('income'),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? c.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? c.background : c.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
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
        crossAxisCount: 5,
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
