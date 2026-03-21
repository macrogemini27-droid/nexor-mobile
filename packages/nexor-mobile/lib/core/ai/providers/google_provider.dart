import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/ai_message.dart';
import '../models/ai_stream_event.dart';
import 'ai_provider.dart';

class GoogleProvider implements AIProvider {
  final String apiKey;
  final Dio _dio;
  
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _defaultModel = 'gemini-pro';

  GoogleProvider({
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
  }

  @override
  String get name => 'google';

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
      final modelName = model ?? _defaultModel;
      
      // Build request body
      final body = {
        'contents': _formatMessages(messages, systemPrompt),
        'generationConfig': {
          if (maxTokens != null) 'maxOutputTokens': maxTokens,
          if (temperature != null) 'temperature': temperature,
        },
        if (tools != null && tools.isNotEmpty) 'tools': _formatTools(tools),
      };

      // Make streaming request
      final response = await _dio.post<ResponseBody>(
        '/models/$modelName:streamGenerateContent?key=$apiKey',
        data: body,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'content-type': 'application/json',
          },
        ),
      );

      if (response.data == null) {
        yield ErrorEvent(
          error: 'no_response',
          message: 'No response from Google API',
        );
        return;
      }

      // Parse streaming JSON responses
      await for (final chunk in response.data!.stream.cast<List<int>>().transform(utf8.decoder)) {
        try {
          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.trim().isEmpty) continue;
            
            final data = jsonDecode(line);
            final streamEvent = _parseEvent(data);
            if (streamEvent != null) {
              yield streamEvent;
            }
          }
        } catch (e) {
          // Skip invalid JSON chunks
        }
      }

      yield const MessageStopEvent(stopReason: 'stop');
    } catch (e) {
      yield ErrorEvent(
        error: 'stream_error',
        message: e.toString(),
      );
    }
  }

  AIStreamEvent? _parseEvent(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final candidate = candidates[0] as Map<String, dynamic>;
    final content = candidate['content'] as Map<String, dynamic>?;
    if (content == null) return null;

    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;

    final part = parts[0] as Map<String, dynamic>;

    // Handle text content
    if (part.containsKey('text')) {
      final text = part['text'] as String?;
      if (text != null && text.isNotEmpty) {
        return ContentBlockDeltaEvent(
          index: 0,
          deltaType: 'text_delta',
          text: text,
        );
      }
    }

    // Handle function calls
    if (part.containsKey('functionCall')) {
      final functionCall = part['functionCall'] as Map<String, dynamic>;
      return ContentBlockDeltaEvent(
        index: 0,
        deltaType: 'tool_call',
        partialJson: functionCall,
      );
    }

    return null;
  }

  List<Map<String, dynamic>> _formatMessages(
    List<AIMessage> messages,
    String? systemPrompt,
  ) {
    final contents = <Map<String, dynamic>>[];

    // Add system prompt as first user message if provided
    if (systemPrompt != null) {
      contents.add({
        'role': 'user',
        'parts': [
          {'text': systemPrompt}
        ],
      });
    }

    for (final msg in messages) {
      final parts = <Map<String, dynamic>>[];

      for (final part in msg.content) {
        if (part is TextContent) {
          parts.add({'text': part.text});
        } else if (part is ToolUseContent) {
          parts.add({
            'functionCall': {
              'name': part.name,
              'args': part.input,
            },
          });
        } else if (part is ToolResultContent) {
          parts.add({
            'functionResponse': {
              'name': 'function_result',
              'response': {'content': part.content},
            },
          });
        }
      }

      contents.add({
        'role': msg.role == AIMessageRole.user ? 'user' : 'model',
        'parts': parts,
      });
    }

    return contents;
  }

  List<Map<String, dynamic>> _formatTools(List<Map<String, dynamic>> tools) {
    return [
      {
        'functionDeclarations': tools.map((tool) {
          return {
            'name': tool['name'],
            'description': tool['description'],
            'parameters': tool['input_schema'],
          };
        }).toList(),
      }
    ];
  }

  @override
  Future<bool> validateApiKey(String apiKey) async {
    try {
      final testDio = Dio();
      testDio.options.baseUrl = _baseUrl;

      final response = await testDio.post(
        '/models/$_defaultModel:generateContent?key=$apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': 'test'}
              ]
            }
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
      'gemini-pro',
      'gemini-pro-vision',
    ];
  }

  @override
  String getDefaultModel() => _defaultModel;
}
