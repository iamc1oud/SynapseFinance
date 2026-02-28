import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class NumberPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;

  const NumberPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: [
        _PadButton(label: '1', onTap: () => onDigit('1')),
        _PadButton(label: '2', onTap: () => onDigit('2')),
        _PadButton(label: '3', onTap: () => onDigit('3')),
        _PadButton(label: '4', onTap: () => onDigit('4')),
        _PadButton(label: '5', onTap: () => onDigit('5')),
        _PadButton(label: '6', onTap: () => onDigit('6')),
        _PadButton(label: '7', onTap: () => onDigit('7')),
        _PadButton(label: '8', onTap: () => onDigit('8')),
        _PadButton(label: '9', onTap: () => onDigit('9')),
        _PadButton(label: '.', onTap: () => onDigit('.')),
        _PadButton(label: '0', onTap: () => onDigit('0')),
        _DeleteButton(onTap: onDelete),
      ],
    );
  }
}

class _PadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: const Center(
        child: Icon(
          Icons.backspace_outlined,
          size: 26,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
