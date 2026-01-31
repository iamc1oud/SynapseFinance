import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  factory SocialLoginButton.google({required VoidCallback? onPressed}) {
    return SocialLoginButton(
      text: 'Continue with Google',
      icon: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            'G',
            style: TextStyle(
              color: Colors.red.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      onPressed: onPressed,
      backgroundColor: AppColors.surface,
      textColor: AppColors.textPrimary,
    );
  }

  factory SocialLoginButton.apple({required VoidCallback? onPressed}) {
    return SocialLoginButton(
      text: 'Continue with Apple',
      icon: const Text(
        'i0S',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      onPressed: onPressed,
      backgroundColor: AppColors.surface,
      textColor: AppColors.textPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icon, const SizedBox(width: 12), Text(text)],
      ),
    );
  }
}
