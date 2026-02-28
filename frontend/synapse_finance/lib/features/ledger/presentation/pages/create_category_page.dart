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
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateCategoryCubit>();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'New Category',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed:
                    state.status == CreateCategoryStatus.saving ? null : cubit.save,
                child: state.status == CreateCategoryStatus.saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: AppColors.primary,
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
                // Type toggle
                _TypeToggle(
                  selected: state.categoryType,
                  onChanged: cubit.setCategoryType,
                ),
                const SizedBox(height: 28),

                // Preview circle with selected icon
                Center(
                  child: _IconPreview(
                    icon: _iconDataFor(state.selectedIcon),
                    label: state.name.isEmpty ? 'Preview' : state.name,
                  ),
                ),
                const SizedBox(height: 28),

                // Name field
                _SectionLabel('Category Name'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  onChanged: cubit.setName,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g. Coffee, Rent, Freelance...',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderFocused,
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
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

IconData _iconDataFor(String key) {
  return _iconOptions
      .firstWhere(
        (e) => e.$1 == key,
        orElse: () => _iconOptions.last,
      )
      .$2;
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
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
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.background : AppColors.textSecondary,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Icon(icon, size: 32, color: AppColors.background),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
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
                  color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.border, width: 1),
                ),
                child: Icon(
                  iconData,
                  size: 22,
                  color: isSelected
                      ? AppColors.background
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
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
