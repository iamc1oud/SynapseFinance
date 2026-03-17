import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isThinking;
  final String? currentThinkingText;
  final String currentAiText;
  final String? error;
  final String sessionId;

  const ChatState({
    this.messages = const [],
    this.isThinking = false,
    this.currentThinkingText,
    this.currentAiText = '',
    this.error,
    this.sessionId = '',
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
    String? currentThinkingText,
    String? currentAiText,
    String? error,
    String? sessionId,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isThinking: isThinking ?? this.isThinking,
        currentThinkingText: currentThinkingText ?? this.currentThinkingText,
        currentAiText: currentAiText ?? this.currentAiText,
        error: error,
        sessionId: sessionId ?? this.sessionId,
      );

  @override
  List<Object?> get props => [
        messages,
        isThinking,
        currentThinkingText,
        currentAiText,
        error,
        sessionId,
      ];
}
