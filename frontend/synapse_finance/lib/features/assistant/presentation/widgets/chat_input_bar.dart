import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'orb_loader.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final ValueChanged<String>? onChanged;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onChanged,
    this.isLoading = false,
  });

  void _submit() {
    final text = controller.text.trim();
    if (text.isNotEmpty && !isLoading) {
      onSend(text);
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(
            top: BorderSide(color: c.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: TextStyle(color: c.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Ask about your finances...',
                  hintStyle: TextStyle(color: c.textHint, fontSize: 15),
                  filled: true,
                  fillColor: c.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _submit(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: OrbLoader(size: 28, color: c.primary),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    color: c.primary,
                    size: 20,
                  ),
                  onPressed: _submit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
