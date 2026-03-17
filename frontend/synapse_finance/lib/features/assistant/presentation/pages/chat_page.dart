import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/chat_cubit.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/command_overlay.dart';
import '../widgets/message_bubble.dart';
import '../widgets/thinking_indicator.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  bool _showCommands = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSend(String text) {
    context.read<ChatCubit>().sendMessage(text);
    _textController.clear();
    setState(() => _showCommands = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state.isThinking || state.messages.isNotEmpty) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        if (state.messages.isEmpty && !state.isThinking) {
          return _buildEmptyState(context);
        }
        return Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount:
                        state.messages.length +
                        (state.isThinking ? 1 : 0) +
                        (state.currentAiText.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Streaming text display
                      if (index == state.messages.length &&
                          state.currentAiText.isNotEmpty) {
                        return _StreamingBubble(text: state.currentAiText);
                      }
                      // Thinking indicator
                      if (index >=
                          state.messages.length +
                              (state.currentAiText.isNotEmpty ? 1 : 0)) {
                        return ThinkingIndicator(
                          text: state.currentThinkingText,
                        );
                      }
                      return MessageBubble(
                        message: state.messages[index],
                        onConfirm: (id) =>
                            context.read<ChatCubit>().confirmCard(id),
                        onIgnore: (id) =>
                            context.read<ChatCubit>().ignoreCard(id),
                      );
                    },
                  ),
                  if (_showCommands)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 0,
                      child: CommandOverlay(
                        onCommandSelected: (cmd) {
                          _textController.clear();
                          setState(() => _showCommands = false);
                          context.read<ChatCubit>().sendMessage(
                            cmd.systemPrompt,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            ChatInputBar(
              controller: _textController,
              onSend: _onSend,
              onChanged: (t) {
                setState(() => _showCommands = t.startsWith('/'));
              },
              isLoading: state.isThinking,
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final c = context.appColors;
    return Column(
      children: [
        _buildAppBar(context),
        const Spacer(),
        Icon(Icons.auto_awesome, size: 64, color: c.primary),
        const SizedBox(height: 16),
        Text(
          'How can I help with your finances?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Type '/' to see available commands",
          style: TextStyle(color: c.textSecondary),
        ),
        const SizedBox(height: 24),
        _buildQuickActions(context),
        const Spacer(),
        if (_showCommands)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CommandOverlay(
              onCommandSelected: (cmd) {
                _textController.clear();
                setState(() => _showCommands = false);
                context.read<ChatCubit>().sendMessage(cmd.systemPrompt);
              },
            ),
          ),
        ChatInputBar(
          controller: _textController,
          onSend: _onSend,
          onChanged: (t) {
            setState(() => _showCommands = t.startsWith('/'));
          },
          isLoading: false,
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final c = context.appColors;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: c.primary, size: 24),
            const SizedBox(width: 10),
            Text(
              'Synapse Manager',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final c = context.appColors;
    final actions = [
      ('Show my spending', Icons.analytics_outlined),
      ('List my accounts', Icons.account_balance_outlined),
      ('Add an expense', Icons.add_circle_outline),
      ('Check subscriptions', Icons.autorenew),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: actions
            .map(
              (a) => ActionChip(
                avatar: Icon(a.$2, size: 16, color: c.primary),
                label: Text(
                  a.$1,
                  style: TextStyle(color: c.textPrimary, fontSize: 13),
                ),
                backgroundColor: c.surfaceLight,
                side: BorderSide(color: c.border),
                onPressed: () => _onSend(a.$1),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Streaming text bubble (shown while AI is generating) ────────────────────

class _StreamingBubble extends StatelessWidget {
  final String text;
  const _StreamingBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 48),
        padding: const EdgeInsets.all(12),
        child: Text(text, style: TextStyle(color: c.textPrimary, fontSize: 15)),
      ),
    );
  }
}
