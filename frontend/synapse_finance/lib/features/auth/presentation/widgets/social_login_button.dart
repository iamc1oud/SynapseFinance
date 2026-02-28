import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
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
    );
  }

  factory SocialLoginButton.apple({required VoidCallback? onPressed}) {
    return SocialLoginButton(
      text: 'Continue with Apple',
      icon: const Icon(Icons.apple, size: 22),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        side: BorderSide(color: c.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icon, const SizedBox(width: 12), Text(text)],
      ),
    );
  }
}
