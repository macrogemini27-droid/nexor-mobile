import 'dart:async';
import 'package:dio/dio.dart';
import '../models/ai_message.dart';
import '../models/ai_stream_event.dart';
import '../streaming/sse_parser.dart';
import 'ai_provider.dart';

class GroqProvider implements AIProvider {
  final String apiKey;
  final Dio _dio;

  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _defaultModel = 'llama-3.3-70b-versatile';

  GroqProvider({
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
  }

  @override
  String get name => 'groq';

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
        '/chat/completions',
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
          message: 'No response from Groq API',
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
          final streamEvent = _parseEvent(data);
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

  AIStreamEvent? _parseEvent(Map<String, dynamic> data) {
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
        'Content-Type': 'application/json',
      };

      final response = await testDio.get('/models');

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  List<String> getAvailableModels() {
    return [
      'llama-3.3-70b-versatile',
      'llama-3.3-70b-instruct',
      'llama-3.1-70b-versatile',
      'llama-3.1-8b-instant',
      'llama-3-70b-8192',
      'llama-3-8b-8192',
      'mixtral-8x7b-32768',
      'gemma2-9b-it',
    ];
  }

  @override
  String getDefaultModel() => _defaultModel;
}
