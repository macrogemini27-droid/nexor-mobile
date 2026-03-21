import 'dart:async';
import 'package:dio/dio.dart';
import '../models/ai_message.dart';
import '../models/ai_stream_event.dart';
import '../streaming/sse_parser.dart';
import 'ai_provider.dart';

class OpenCodeProvider implements AIProvider {
  final String apiKey;
  final Dio _dio;

  static const String _baseUrl = 'https://opencode.ai/zen/v1';
  static const String _defaultModel = 'gpt-5.4';

  static const Map<String, String> _modelEndpoints = {
    'gpt-5': '/responses',
    'gpt-4': '/responses',
    'claude-': '/messages',
    'gemini-': '/models',
  };

  OpenCodeProvider({
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer $apiKey',
      'content-type': 'application/json',
    };
  }

  String _getEndpoint(String? model) {
    final modelId = model ?? _defaultModel;
    for (final entry in _modelEndpoints.entries) {
      if (modelId.contains(entry.key)) {
        return entry.value;
      }
    }
    return '/chat/completions';
  }

  @override
  String get name => 'opencode';

  @override
  Future<String> generateText({
    required List<AIMessage> messages,
    List<Map<String, dynamic>>? tools,
    String? model,
    int? maxTokens,
    double? temperature,
    String? systemPrompt,
  }) async {
    final buffer = StringBuffer();

    await for (final event in streamText(
      messages: messages,
      tools: tools,
      model: model,
      maxTokens: maxTokens,
      temperature: temperature,
      systemPrompt: systemPrompt,
    )) {
      if (event is ContentBlockDeltaEvent && event.text != null) {
        buffer.write(event.text);
      }
    }

    return buffer.toString();
  }

  @override
  Stream<AIStreamEvent> streamText({
    required List<AIMessage> messages,
    List<Map<String, dynamic>>? tools,
    String? model,
    int? maxTokens,
    double? temperature,
    String? systemPrompt,
  }) async* {
    try {
      final endpoint = _getEndpoint(model);
      final formattedMessages = <Map<String, dynamic>>[];

      if (systemPrompt != null) {
        formattedMessages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      }

      formattedMessages.addAll(_formatMessages(messages));

      final body = <String, dynamic>{
        'model': model ?? _defaultModel,
        'messages': formattedMessages,
        'stream': true,
        if (maxTokens != null) 'max_tokens': maxTokens,
        if (temperature != null) 'temperature': temperature,
        if (tools != null && tools.isNotEmpty) 'tools': _formatTools(tools),
      };

      final response = await _dio.post<ResponseBody>(
        endpoint,
        data: body,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'accept': 'text/event-stream',
          },
        ),
      );

      if (response.data == null) {
        yield ErrorEvent(
          error: 'no_response',
          message: 'No response from OpenCode Zen API',
        );
        return;
      }

      await for (final event in SSEParser.parseBytes(response.data!.stream)) {
        final data = event['data'];

        if (data is String && data == '[DONE]') {
          yield const MessageStopEvent(stopReason: 'stop');
          break;
        }

        if (data is Map<String, dynamic>) {
          final streamEvent = _parseEvent(data, endpoint);
          if (streamEvent != null) {
            yield streamEvent;
          }
        }
      }
    } catch (e) {
      yield ErrorEvent(
        error: 'stream_error',
        message: e.toString(),
      );
    }
  }

  AIStreamEvent? _parseEvent(Map<String, dynamic> data, String endpoint) {
    if (endpoint == '/messages') {
      return _parseAnthropicEvent(data);
    } else if (endpoint == '/responses') {
      return _parseOpenAIResponsesEvent(data);
    } else {
      return _parseOpenAIChatEvent(data);
    }
  }

  AIStreamEvent? _parseAnthropicEvent(Map<String, dynamic> data) {
    final eventType = data['type'] as String?;
    if (eventType == null) return null;

    switch (eventType) {
      case 'content_block_delta':
        final delta = data['delta'] as Map<String, dynamic>?;
        if (delta == null) return null;
        final deltaType = delta['type'] as String?;
        return ContentBlockDeltaEvent(
          index: data['index'] as int? ?? 0,
          deltaType: deltaType ?? 'text_delta',
          text: delta['text'] as String?,
          partialJson: delta['partial_json'] as Map<String, dynamic>?,
        );
      case 'message_stop':
        return MessageStopEvent(
          stopReason: data['stop_reason'] ?? 'end_turn',
          usage: data['usage'] ?? {},
        );
      case 'error':
        return ErrorEvent(
          error: data['error']?['type'] ?? 'unknown_error',
          message: data['error']?['message'] as String?,
        );
      default:
        return null;
    }
  }

  AIStreamEvent? _parseOpenAIResponsesEvent(Map<String, dynamic> data) {
    final output = data['output'] as List?;
    if (output == null || output.isEmpty) return null;

    final firstOutput = output[0] as Map<String, dynamic>;
    final content = firstOutput['content'] as List?;

    if (content != null && content.isNotEmpty) {
      for (final item in content) {
        if (item is Map<String, dynamic>) {
          final type = item['type'] as String?;
          if (type == 'output_text') {
            return ContentBlockDeltaEvent(
              index: 0,
              deltaType: 'text_delta',
              text: item['text'] as String?,
            );
          }
        } else if (item is String) {
          return ContentBlockDeltaEvent(
            index: 0,
            deltaType: 'text_delta',
            text: item,
          );
        }
      }
    }

    final finishReason = firstOutput['finish_reason'] as String?;
    if (finishReason != null) {
      return MessageStopEvent(
        stopReason: finishReason,
        usage: data['usage'] as Map<String, dynamic>? ?? {},
      );
    }

    return null;
  }

  AIStreamEvent? _parseOpenAIChatEvent(Map<String, dynamic> data) {
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;

    final choice = choices[0] as Map<String, dynamic>;
    final delta = choice['delta'] as Map<String, dynamic>?;
    if (delta == null) return null;

    if (delta.containsKey('content')) {
      final content = delta['content'] as String?;
      if (content != null && content.isNotEmpty) {
        return ContentBlockDeltaEvent(
          index: 0,
          deltaType: 'text_delta',
          text: content,
        );
      }
    }

    if (delta.containsKey('tool_calls')) {
      final toolCalls = delta['tool_calls'] as List;
      if (toolCalls.isNotEmpty) {
        final toolCall = toolCalls[0] as Map<String, dynamic>;
        final function = toolCall['function'] as Map<String, dynamic>?;
        if (function != null) {
          return ContentBlockDeltaEvent(
            index: toolCall['index'] as int? ?? 0,
            deltaType: 'tool_call',
            partialJson: function,
          );
        }
      }
    }

    final finishReason = choice['finish_reason'] as String?;
    if (finishReason != null) {
      return MessageStopEvent(
        stopReason: finishReason,
        usage: data['usage'] as Map<String, dynamic>? ?? {},
      );
    }

    return null;
  }

  List<Map<String, dynamic>> _formatMessages(List<AIMessage> messages) {
    return messages.map((msg) {
      final content = <dynamic>[];

      for (final part in msg.content) {
        if (part is TextContent) {
          content.add(part.text);
        } else if (part is ToolUseContent) {
          content.add({
            'type': 'tool_call',
            'id': part.id,
            'function': {
              'name': part.name,
              'arguments': part.input.toString(),
            },
          });
        } else if (part is ToolResultContent) {
          content.add({
            'type': 'tool_result',
            'tool_call_id': part.toolUseId,
            'content': part.content,
          });
        }
      }

      return {
        'role': msg.role.name,
        'content': content.length == 1 ? content[0] : content,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _formatTools(List<Map<String, dynamic>> tools) {
    return tools.map((tool) {
      return {
        'type': 'function',
        'function': {
          'name': tool['name'],
          'description': tool['description'],
          'parameters': tool['input_schema'],
        },
      };
    }).toList();
  }

  @override
  Future<bool> validateApiKey(String apiKey) async {
    try {
      final testDio = Dio();
      testDio.options.baseUrl = _baseUrl;
      testDio.options.headers = {
        'Authorization': 'Bearer $apiKey',
        'content-type': 'application/json',
      };

      final response = await testDio.post(
        '/models',
        data: {},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  List<String> getAvailableModels() {
    return [
      'gpt-5.4',
      'gpt-5.4-pro',
      'gpt-5.4-mini',
      'gpt-5.4-nano',
      'gpt-5.3-codex',
      'gpt-5.3-codex-spark',
      'gpt-5.2',
      'gpt-5.2-codex',
      'gpt-5.1',
      'gpt-5.1-codex',
      'gpt-5.1-codex-max',
      'gpt-5.1-codex-mini',
      'gpt-5',
      'gpt-5-codex',
      'gpt-5-nano',
      'claude-opus-4-6',
      'claude-opus-4-5',
      'claude-opus-4-1',
      'claude-sonnet-4-6',
      'claude-sonnet-4-5',
      'claude-sonnet-4',
      'claude-haiku-4-5',
      'claude-3-5-haiku',
      'gemini-3.1-pro',
      'gemini-3-flash',
      'big-pickle',
      'minimax-m2.5',
      'minimax-m2.5-free',
      'glm-5',
      'kimi-k2.5',
      'mimo-v2-flash-free',
      'nemotron-3-super-free',
    ];
  }

  @override
  String getDefaultModel() => _defaultModel;
}
