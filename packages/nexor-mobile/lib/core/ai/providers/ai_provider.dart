import '../models/ai_message.dart';
import '../models/ai_stream_event.dart';

abstract class AIProvider {
  /// The name of this AI provider (e.g., "anthropic", "openai", "google")
  String get name;

  /// Stream text generation with tool support
  /// 
  /// [messages] - The conversation history
  /// [tools] - Available tools in JSON schema format
  /// [model] - The model to use (provider-specific)
  /// [maxTokens] - Maximum tokens to generate
  /// [temperature] - Sampling temperature (0.0 to 1.0)
  /// [systemPrompt] - Optional system prompt
  Stream<AIStreamEvent> streamText({
    required List<AIMessage> messages,
    List<Map<String, dynamic>>? tools,
    String? model,
    int? maxTokens,
    double? temperature,
    String? systemPrompt,
  });

  /// Generate text without streaming (convenience method)
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

  /// Validate API key
  Future<bool> validateApiKey(String apiKey);

  /// Get available models for this provider
  List<String> getAvailableModels();

  /// Get default model for this provider
  String getDefaultModel();
}
