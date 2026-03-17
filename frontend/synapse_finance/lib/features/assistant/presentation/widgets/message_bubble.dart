import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';
import 'interactive_cards/transaction_confirm_card.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String>? onConfirm;
  final ValueChanged<String>? onIgnore;

  const MessageBubble({
    super.key,
    required this.message,
    this.onConfirm,
    this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    return switch (message) {
      UserMessage(:final text) => _UserBubble(text: text),
      AiTextMessage(:final text, :final suggestions) =>
        _AiBubble(text: text, suggestions: suggestions),
      AiThinkingMessage(:final thinkingText) =>
        _ThinkingBubble(text: thinkingText),
      AiToolCallMessage(:final toolName) =>
        _ToolCallBubble(toolName: toolName),
      InteractiveCardMessage() => TransactionConfirmCard(
          card: message as InteractiveCardMessage,
          onConfirm: () => onConfirm?.call(message.id),
          onIgnore: () => onIgnore?.call(message.id),
        ),
    };
  }
}

// ─── User Bubble ─────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: c.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(color: c.textPrimary, fontSize: 15),
        ),
      ),
    );
  }
}

// ─── AI Text Bubble ──────────────────────────────────────────────────────────

class _AiBubble extends StatelessWidget {
  final String text;
  final List<String>? suggestions;
  const _AiBubble({required this.text, this.suggestions});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 48),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: c.textPrimary, fontSize: 15),
                h1: TextStyle(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                h2: TextStyle(
                    color: c.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                code: TextStyle(
                  color: c.primary,
                  backgroundColor: c.surfaceLight,
                  fontSize: 13,
                ),
                codeblockDecoration: BoxDecoration(
                  color: c.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (suggestions != null && suggestions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: suggestions!
                    .map((s) => ActionChip(
                          label: Text(s,
                              style: TextStyle(
                                  color: c.primary, fontSize: 12)),
                          backgroundColor: c.primary.withValues(alpha: 0.1),
                          side: BorderSide(
                              color: c.primary.withValues(alpha: 0.3)),
                          onPressed: () {},
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Thinking Bubble ─────────────────────────────────────────────────────────

class _ThinkingBubble extends StatelessWidget {
  final String? text;
  const _ThinkingBubble({this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 64),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text ?? 'Thinking...',
          style: TextStyle(
            color: c.textHint,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

// ─── Tool Call Bubble ────────────────────────────────────────────────────────

class _ToolCallBubble extends StatelessWidget {
  final String toolName;
  const _ToolCallBubble({required this.toolName});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final displayName = toolName.replaceAll('_', ' ');
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: c.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build_outlined, size: 14, color: c.primary),
            const SizedBox(width: 6),
            Text(
              'Using $displayName...',
              style: TextStyle(color: c.primary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
