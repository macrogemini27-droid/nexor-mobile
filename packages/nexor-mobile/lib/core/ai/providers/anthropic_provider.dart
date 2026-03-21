import 'dart:async';
import 'package:dio/dio.dart';
import '../models/ai_message.dart';
import '../models/ai_stream_event.dart';
import '../streaming/sse_parser.dart';
import 'ai_provider.dart';

class AnthropicProvider implements AIProvider {
  final String apiKey;
  final Dio _dio;

  static const String _baseUrl = 'https://api.anthropic.com/v1';
  static const String _defaultModel = 'claude-3-5-sonnet-20241022';
  static const int _defaultMaxTokens = 4096;

  AnthropicProvider({
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    };
  }

  @override
  String get name => 'anthropic';

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
      // Build request body
      final body = {
        'model': model ?? _defaultModel,
        'max_tokens': maxTokens ?? _defaultMaxTokens,
        'messages': _formatMessages(messages),
        'stream': true,
        if (temperature != null) 'temperature': temperature,
        if (systemPrompt != null) 'system': systemPrompt,
        if (tools != null && tools.isNotEmpty) 'tools': tools,
      };

      // Make streaming request
      final response = await _dio.post<ResponseBody>(
        '/messages',
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
          message: 'No response from Anthropic API',
        );
        return;
      }

      // Parse SSE stream
      await for (final event in SSEParser.parseBytes(response.data!.stream)) {
        final eventType = event['type'] as String?;
        if (eventType == null) continue;

        final data = event['data'] as Map<String, dynamic>?;
        if (data == null) continue;

        // Parse and yield appropriate event
        final streamEvent = _parseEvent(eventType, data);
        if (streamEvent != null) {
          yield streamEvent;
        }
      }
    } catch (e) {
      yield ErrorEvent(
        error: 'stream_error',
        message: e.toString(),
      );
    }
  }

  AIStreamEvent? _parseEvent(String eventType, Map<String, dynamic> data) {
    switch (eventType) {
      case 'message_start':
        return MessageStartEvent(
          messageId: data['message']?['id'] ?? '',
          metadata: data['message'] ?? {},
        );

      case 'content_block_start':
        final index = data['index'] as int;
        final contentBlock = data['content_block'] as Map<String, dynamic>;
        return ContentBlockStartEvent(
          index: index,
          blockType: contentBlock['type'] as String,
          data: contentBlock,
        );

      case 'content_block_delta':
        final index = data['index'] as int;
        final delta = data['delta'] as Map<String, dynamic>;
        final deltaType = delta['type'] as String;

        return ContentBlockDeltaEvent(
          index: index,
          deltaType: deltaType,
          text: delta['text'] as String?,
          partialJson: delta['partial_json'] as Map<String, dynamic>?,
        );

      case 'content_block_stop':
        return ContentBlockStopEvent(
          index: data['index'] as int,
        );

      case 'message_delta':
        // Message delta contains stop_reason and usage
        return null; // We'll handle this in message_stop

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

  List<Map<String, dynamic>> _formatMessages(List<AIMessage> messages) {
    return messages
        .where((msg) => msg.role != AIMessageRole.system)
        .map((msg) => msg.toJson())
        .toList();
  }

  @override
  Future<bool> validateApiKey(String apiKey) async {
    try {
      final testDio = Dio();
      testDio.options.baseUrl = _baseUrl;
      testDio.options.headers = {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      };

      final response = await testDio.post(
        '/messages',
        data: {
          'model': _defaultModel,
          'max_tokens': 10,
          'messages': [
            {'role': 'user', 'content': 'test'}
          ],
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  List<String> getAvailableModels() {
    return [
      'claude-3-5-sonnet-20241022',
      'claude-3-5-haiku-20241022',
      'claude-3-opus-20240229',
      'claude-3-sonnet-20240229',
      'claude-3-haiku-20240307',
    ];
  }

  @override
  String getDefaultModel() => _defaultModel;
}
