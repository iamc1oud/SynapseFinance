import 'package:equatable/equatable.dart';

enum CardStatus { pending, confirmed, ignored, expired }

enum InteractiveCardType {
  transactionConfirm,
  transferConfirm,
  subscriptionConfirm,
  deleteConfirm,
  categoryConfirm,
}

sealed class ChatMessage extends Equatable {
  final String id;
  final DateTime timestamp;

  const ChatMessage({required this.id, required this.timestamp});
}

class UserMessage extends ChatMessage {
  final String text;

  const UserMessage({
    required this.text,
    required super.id,
    required super.timestamp,
  });

  @override
  List<Object?> get props => [id, text, timestamp];
}

class AiTextMessage extends ChatMessage {
  final String text;
  final List<String>? suggestions;

  const AiTextMessage({
    required this.text,
    required super.id,
    required super.timestamp,
    required this.suggestions,
  });

  @override
  List<Object?> get props => [id, text, timestamp, suggestions];
}

class AiThinkingMessage extends ChatMessage {
  final String? thinkingText;
  final bool isComplete;

  const AiThinkingMessage({
    required super.id,
    required super.timestamp,
    this.thinkingText,
    required this.isComplete,
  });

  @override
  List<Object?> get props => [id, thinkingText, isComplete, timestamp];
}

class AiToolCallMessage extends ChatMessage {
  final String toolName;
  final Map<String, dynamic>? arguments;
  final dynamic result;

  const AiToolCallMessage({
    required this.toolName,
    required super.id,
    required super.timestamp,
    this.arguments,
    this.result,
  });

  @override
  List<Object?> get props => [id, toolName, arguments, result, timestamp];
}

class InteractiveCardMessage extends ChatMessage {
  final InteractiveCardType cardType;
  final String toolName;
  final Map<String, dynamic> data;
  final CardStatus status;

  const InteractiveCardMessage({
    required this.cardType,
    required this.toolName,
    required this.data,
    this.status = CardStatus.pending,
    required super.id,
    required super.timestamp,
  });

  InteractiveCardMessage copyWith({CardStatus? status}) {
    return InteractiveCardMessage(
      cardType: cardType,
      toolName: toolName,
      data: data,
      status: status ?? this.status,
      id: id,
      timestamp: timestamp,
    );
  }

  @override
  List<Object?> get props => [id, cardType, toolName, data, status, timestamp];
}
