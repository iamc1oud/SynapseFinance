import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../tools/tool_registry.dart';

// ─── Response chunk types ────────────────────────────────────────────────────

sealed class AiResponseChunk {}

class AiTextChunk extends AiResponseChunk {
  final String text;
  AiTextChunk({required this.text});
}

class AiToolCallChunk extends AiResponseChunk {
  final String toolCallId;
  final String toolName;
  final Map<String, dynamic> arguments;
  AiToolCallChunk({
    required this.toolCallId,
    required this.toolName,
    required this.arguments,
  });
}

class AiDoneChunk extends AiResponseChunk {}

// ─── AI Service ──────────────────────────────────────────────────────────────

@lazySingleton
class AiService {
  final Dio _dio;
  final ToolRegistry _toolRegistry;

  String _baseUrl = 'http://192.168.1.15:11434/v1';
  String _model = 'llama3.1:8b';
  String? _apiKey;

  AiService(this._toolRegistry)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

  void configure({required String baseUrl, String? model, String? apiKey}) {
    _baseUrl = baseUrl;
    if (model != null) _model = model;
    _apiKey = apiKey;
  }

  String get baseUrl => _baseUrl;
  String get model => _model;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
  };

  /// Stream response from Ollama via SSE.
  Stream<AiResponseChunk> sendMessage({
    required List<Map<String, dynamic>> messages,
    required String systemPrompt,
  }) async* {
    final body = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
      'tools': _toolRegistry.getToolSchemas(),
      'stream': true,
    };

    final response = await _dio.post<ResponseBody>(
      '$_baseUrl/chat/completions',
      data: jsonEncode(body),
      options: Options(responseType: ResponseType.stream, headers: _headers),
    );

    yield* _parseSSEStream(response.data!);
  }

  /// Non-streaming call (for tool result follow-ups).
  Future<Map<String, dynamic>> sendMessageSync({
    required List<Map<String, dynamic>> messages,
    required String systemPrompt,
  }) async {
    final body = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
      'tools': _toolRegistry.getToolSchemas(),
      'stream': false,
    };

    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/chat/completions',
      data: jsonEncode(body),
      options: Options(headers: _headers),
    );
    return response.data!;
  }

  Stream<AiResponseChunk> _parseSSEStream(ResponseBody body) async* {
    final lineBuffer = StringBuffer();
    final toolArgBuffers = <int, StringBuffer>{};
    final toolCallIds = <int, String>{};
    final toolCallNames = <int, String>{};

    await for (final bytes in body.stream) {
      lineBuffer.write(utf8.decode(bytes));
      final raw = lineBuffer.toString();
      final lines = raw.split('\n');
      lineBuffer.clear();

      // Keep incomplete last line in buffer
      if (!raw.endsWith('\n')) {
        lineBuffer.write(lines.removeLast());
      }

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith(':')) continue;
        if (!trimmed.startsWith('data: ')) continue;

        final data = trimmed.substring(6);
        if (data == '[DONE]') {
          // Flush any pending tool calls
          yield* _flushToolCalls(toolCallIds, toolCallNames, toolArgBuffers);
          yield AiDoneChunk();
          return;
        }

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List?;
          if (choices == null || choices.isEmpty) continue;

          final choice = choices[0] as Map<String, dynamic>;
          final delta = choice['delta'] as Map<String, dynamic>?;
          if (delta == null) continue;

          // Text content
          if (delta.containsKey('content') && delta['content'] != null) {
            yield AiTextChunk(text: delta['content'] as String);
          }

          // Tool calls (streamed incrementally)
          final toolCalls = delta['tool_calls'] as List?;
          if (toolCalls != null) {
            for (final tc in toolCalls) {
              final tcMap = tc as Map<String, dynamic>;
              final idx = tcMap['index'] as int? ?? 0;
              final fn = tcMap['function'] as Map<String, dynamic>?;
              if (fn == null) continue;

              // First chunk has id and name
              if (tcMap.containsKey('id') && tcMap['id'] != null) {
                toolCallIds[idx] = tcMap['id'] as String;
                toolCallNames[idx] = fn['name'] as String;
                toolArgBuffers[idx] = StringBuffer();
              }

              // Accumulate arguments
              if (fn.containsKey('arguments')) {
                toolArgBuffers[idx]?.write(fn['arguments'] as String);
              }
            }
          }

          // Check for finish_reason
          final finish = choice['finish_reason'];
          if (finish == 'tool_calls' || finish == 'stop') {
            yield* _flushToolCalls(toolCallIds, toolCallNames, toolArgBuffers);
            if (finish == 'stop') {
              yield AiDoneChunk();
              return;
            }
          }
        } catch (_) {
          // Skip malformed chunks
        }
      }
    }
  }

  Stream<AiResponseChunk> _flushToolCalls(
    Map<int, String> ids,
    Map<int, String> names,
    Map<int, StringBuffer> argBuffers,
  ) async* {
    for (final idx in ids.keys) {
      final argsStr = argBuffers[idx]?.toString() ?? '{}';
      Map<String, dynamic> args = {};
      try {
        args = jsonDecode(argsStr) as Map<String, dynamic>;
      } catch (_) {}
      yield AiToolCallChunk(
        toolCallId: ids[idx]!,
        toolName: names[idx]!,
        arguments: args,
      );
    }
    ids.clear();
    names.clear();
    argBuffers.clear();
  }
}
