import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/ai_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../tools/tool_executor.dart';
import '../../tools/tool_registry.dart';
import 'chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  final AiService _aiService;
  final ToolRegistry _toolRegistry;
  final ToolExecutor _toolExecutor;
  final _uuid = const Uuid();
  static const _maxIterations = 5;

  /// Conversation history in OpenAI format for Ollama.
  final List<Map<String, dynamic>> _messageHistory = [];

  /// Cached context for system prompt (fetched once on first message).
  String _accountsContext = '';
  String _categoriesContext = '';
  String _currencyContext = '';
  bool _contextLoaded = false;

  ChatCubit(this._aiService, this._toolRegistry, this._toolExecutor)
    : super(const ChatState());

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final userMsg = UserMessage(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      text: text,
    );
    _addMessage(userMsg);
    _messageHistory.add({'role': 'user', 'content': text});
    emit(state.copyWith(isThinking: true, currentAiText: ''));

    try {
      await _loadContextIfNeeded();
      await _runAgenticLoop(0);
    } on DioException catch (e) {
      _addMessage(
        AiTextMessage(
          id: _uuid.v4(),
          timestamp: DateTime.now(),
          text: _handleDioError(e),
          suggestions: null,
        ),
      );
    } catch (e) {
      _addMessage(
        AiTextMessage(
          id: _uuid.v4(),
          timestamp: DateTime.now(),
          text: 'Something went wrong: ${e.toString()}',
          suggestions: null,
        ),
      );
    } finally {
      emit(state.copyWith(isThinking: false));
    }
  }

  Future<void> confirmCard(String messageId) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final card = state.messages[idx] as InteractiveCardMessage;
    if (card.status != CardStatus.pending) return;

    try {
      await _toolExecutor.execute(card.toolName, card.data);
      final updated = card.copyWith(status: CardStatus.confirmed);
      final msgs = List<ChatMessage>.from(state.messages);
      msgs[idx] = updated;
      msgs.add(
        AiTextMessage(
          id: _uuid.v4(),
          timestamp: DateTime.now(),
          text: 'Done! Transaction recorded successfully.',
          suggestions: null,
        ),
      );
      emit(state.copyWith(messages: msgs));
    } catch (e) {
      emit(state.copyWith(error: 'Failed: ${e.toString()}'));
    }
  }

  Future<void> ignoreCard(String messageId) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final card = state.messages[idx] as InteractiveCardMessage;
    final updated = card.copyWith(status: CardStatus.ignored);
    final msgs = List<ChatMessage>.from(state.messages);
    msgs[idx] = updated;
    emit(state.copyWith(messages: msgs));
  }

  void clearError() => emit(state.copyWith(error: null));

  // ─── Agentic Loop ─────────────────────────────────────────────────────────

  Future<void> _runAgenticLoop(int iteration) async {
    if (iteration >= _maxIterations) {
      _addMessage(
        AiTextMessage(
          id: _uuid.v4(),
          timestamp: DateTime.now(),
          text: 'Reached processing limit. Please try rephrasing.',
          suggestions: null,
        ),
      );
      return;
    }

    final systemPrompt = _buildSystemPrompt();
    String textBuffer = '';
    final pendingToolCalls = <_PendingToolCall>[];

    await for (final chunk in _aiService.sendMessage(
      messages: _messageHistory,
      systemPrompt: systemPrompt,
    )) {
      switch (chunk) {
        case AiTextChunk(:final text):
          textBuffer += text;
          emit(state.copyWith(currentAiText: textBuffer));

        case AiToolCallChunk(
          :final toolCallId,
          :final toolName,
          :final arguments,
        ):
          if (_toolRegistry.isMutation(toolName)) {
            // Show interactive card — don't execute
            final cardType = _getCardType(toolName);
            _addMessage(
              InteractiveCardMessage(
                id: _uuid.v4(),
                timestamp: DateTime.now(),
                cardType: cardType,
                toolName: toolName,
                data: arguments,
              ),
            );
          } else {
            pendingToolCalls.add(
              _PendingToolCall(
                id: toolCallId,
                name: toolName,
                arguments: arguments,
              ),
            );
          }

        case AiDoneChunk():
          break;
      }
    }

    // Finalize streamed text
    if (textBuffer.isNotEmpty) {
      _addMessage(
        AiTextMessage(
          id: _uuid.v4(),
          timestamp: DateTime.now(),
          text: textBuffer,
          suggestions: null,
        ),
      );
      _messageHistory.add({'role': 'assistant', 'content': textBuffer});
      emit(state.copyWith(currentAiText: ''));
    }

    // Execute read-only tool calls and continue the loop
    if (pendingToolCalls.isNotEmpty) {
      _messageHistory.add({
        'role': 'assistant',
        'tool_calls': pendingToolCalls
            .map(
              (tc) => {
                'id': tc.id,
                'type': 'function',
                'function': {
                  'name': tc.name,
                  'arguments': jsonEncode(tc.arguments),
                },
              },
            )
            .toList(),
      });

      for (final tc in pendingToolCalls) {
        _addMessage(
          AiToolCallMessage(
            id: _uuid.v4(),
            timestamp: DateTime.now(),
            toolName: tc.name,
            arguments: tc.arguments,
          ),
        );

        try {
          final result = await _toolExecutor.execute(tc.name, tc.arguments);
          _messageHistory.add({
            'role': 'tool',
            'tool_call_id': tc.id,
            'content': jsonEncode(result),
          });
        } catch (e) {
          _messageHistory.add({
            'role': 'tool',
            'tool_call_id': tc.id,
            'content': jsonEncode({'error': e.toString()}),
          });
        }
      }

      // Continue loop so the LLM can summarize tool results
      await _runAgenticLoop(iteration + 1);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _addMessage(ChatMessage msg) {
    emit(state.copyWith(messages: [...state.messages, msg]));
  }

  InteractiveCardType _getCardType(String toolName) => switch (toolName) {
    'create_expense' ||
    'create_income' => InteractiveCardType.transactionConfirm,
    'create_transfer' => InteractiveCardType.transferConfirm,
    'delete_transaction' => InteractiveCardType.deleteConfirm,
    _ => InteractiveCardType.transactionConfirm,
  };

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Cannot connect to Ollama at ${_aiService.baseUrl}. '
          'Make sure Ollama is running (ollama serve).';
    } else if (e.response?.statusCode == 404) {
      return 'Model "${_aiService.model}" not found. '
          'Pull it first: ollama pull ${_aiService.model}';
    }
    return 'Ollama error: ${e.message}';
  }

  Future<void> _loadContextIfNeeded() async {
    if (_contextLoaded) return;
    try {
      final accountsResult = await _toolExecutor.execute('list_accounts', {});
      final accounts = accountsResult['accounts'] as List;
      _accountsContext = accounts
          .map(
            (a) =>
                '- ${a['name']} (ID: ${a['id']}, type: ${a['account_type']}, balance: ${a['balance']} ${a['currency']})',
          )
          .join('\n');

      final categoriesResult = await _toolExecutor.execute(
        'list_categories',
        {},
      );
      final categories = categoriesResult['categories'] as List;
      _categoriesContext = categories
          .map(
            (c) =>
                '- ${c['name']} (ID: ${c['id']}, type: ${c['category_type']})',
          )
          .join('\n');

      final currencyResult = await _toolExecutor.execute(
        'get_currency_info',
        {},
      );
      final currencies = currencyResult['currencies'] as List;
      final primary = currencies.firstWhere(
        (c) => c['is_main'] == true,
        orElse: () => currencies.first,
      );
      final symbol = _currencySymbol(primary['currency'] as String);
      _currencyContext =
          'Primary currency: ${primary['currency']} (symbol: $symbol)\n'
          'IMPORTANT: Always use "$symbol" when displaying amounts — NEVER use \$ unless the primary currency is USD.\n'
          'All currencies: ${currencies.map((c) => '${c['currency']}${c['is_main'] == true ? ' (primary)' : ' (rate: ${c['exchange_rate']})'}').join(', ')}';
    } catch (_) {
      // Non-fatal — the LLM can still use tools to fetch this info
    }
    _contextLoaded = true;
  }

  String _buildSystemPrompt() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final buffer = StringBuffer(
      '''You are an AI finance assistant for Synapse Finance.
You help users manage their money through natural language.

CURRENT DATE: $today
''',
    );

    if (_currencyContext.isNotEmpty) {
      buffer.writeln('\n$_currencyContext');
    }

    if (_accountsContext.isNotEmpty) {
      buffer.writeln('\nUSER ACCOUNTS:\n$_accountsContext');
    }

    if (_categoriesContext.isNotEmpty) {
      buffer.writeln('\nCATEGORIES:\n$_categoriesContext');
    }

    buffer.write(
      '''
RULES:
1. For ANY action that creates, modifies, or deletes data, use the appropriate tool. Never describe the action in text only.
2. Before calling a mutation tool, ensure ALL required fields are known. If any are missing, ASK the user — refer to accounts and categories by NAME, not ID.
3. For read-only queries, call the tool and summarize results in a friendly, concise way.
4. ALWAYS format amounts using the user's primary currency symbol (from context above). NEVER use \$ unless the user's primary currency is USD. For example, if the primary currency is INR, write ₹500 not \$500.
5. If the user asks about something outside personal finance, politely redirect.
6. Keep responses concise and helpful.
7. When multiple accounts exist, clarify which one to use by showing account names.
8. Use the account/category IDs from the context above when calling tools — do NOT ask the user for IDs.
9. You can call MULTIPLE tools in a single response. When a query needs data from different filters (e.g. expenses AND income), call the tool once for each filter in the SAME response using parallel tool calls. Do NOT call a tool once and try to answer with incomplete data.''',
    );

    return buffer.toString();
  }

  static String _currencySymbol(String code) => switch (code.toUpperCase()) {
    'INR' => '₹',
    'USD' => '\$',
    'EUR' => '€',
    'GBP' => '£',
    'JPY' => '¥',
    'CNY' => '¥',
    'KRW' => '₩',
    'RUB' => '₽',
    'TRY' => '₺',
    'BRL' => 'R\$',
    'AUD' || 'CAD' || 'NZD' || 'SGD' || 'HKD' => '\$',
    'THB' => '฿',
    'IDR' => 'Rp',
    'MYR' => 'RM',
    'PHP' => '₱',
    'VND' => '₫',
    'ZAR' => 'R',
    'SEK' || 'NOK' || 'DKK' || 'ISK' => 'kr',
    'CHF' => 'CHF',
    'PLN' => 'zł',
    'CZK' => 'Kč',
    'HUF' => 'Ft',
    'AED' => 'د.إ',
    'SAR' => '﷼',
    _ => code,
  };
}

class _PendingToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;

  _PendingToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });
}
