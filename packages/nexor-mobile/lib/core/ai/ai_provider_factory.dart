import 'providers/ai_provider.dart';
import 'providers/anthropic_provider.dart';
import 'providers/openai_provider.dart';
import 'providers/google_provider.dart';
import 'providers/opencode_provider.dart';
import 'providers/openrouter_provider.dart';
import 'providers/groq_provider.dart';
import 'providers/mistral_provider.dart';

enum AIProviderType {
  anthropic,
  openai,
  google,
  opencode,
  openrouter,
  groq,
  mistral,
}

class AIProviderFactory {
  static AIProvider create({
    required AIProviderType type,
    required String apiKey,
  }) {
    switch (type) {
      case AIProviderType.anthropic:
        return AnthropicProvider(apiKey: apiKey);
      case AIProviderType.openai:
        return OpenAIProvider(apiKey: apiKey);
      case AIProviderType.google:
        return GoogleProvider(apiKey: apiKey);
      case AIProviderType.opencode:
        return OpenCodeProvider(apiKey: apiKey);
      case AIProviderType.openrouter:
        return OpenRouterProvider(apiKey: apiKey);
      case AIProviderType.groq:
        return GroqProvider(apiKey: apiKey);
      case AIProviderType.mistral:
        return MistralProvider(apiKey: apiKey);
    }
  }

  static AIProviderType fromString(String name) {
    switch (name.toLowerCase()) {
      case 'anthropic':
        return AIProviderType.anthropic;
      case 'openai':
        return AIProviderType.openai;
      case 'google':
        return AIProviderType.google;
      case 'opencode':
        return AIProviderType.opencode;
      case 'openrouter':
        return AIProviderType.openrouter;
      case 'groq':
        return AIProviderType.groq;
      case 'mistral':
        return AIProviderType.mistral;
      default:
        return AIProviderType.anthropic;
    }
  }

  static String getDisplayName(AIProviderType type) {
    switch (type) {
      case AIProviderType.anthropic:
        return 'Anthropic (Claude)';
      case AIProviderType.openai:
        return 'OpenAI (GPT)';
      case AIProviderType.google:
        return 'Google (Gemini)';
      case AIProviderType.opencode:
        return 'OpenCode Zen';
      case AIProviderType.openrouter:
        return 'OpenRouter';
      case AIProviderType.groq:
        return 'Groq';
      case AIProviderType.mistral:
        return 'Mistral';
    }
  }

  static String getDescription(AIProviderType type) {
    switch (type) {
      case AIProviderType.anthropic:
        return 'Claude 3.5 Sonnet - Best for coding tasks';
      case AIProviderType.openai:
        return 'GPT-4 Turbo - Versatile and powerful';
      case AIProviderType.google:
        return 'Gemini Pro - Fast and efficient';
      case AIProviderType.opencode:
        return 'OpenCode Zen - Curated best models';
      case AIProviderType.openrouter:
        return 'OpenRouter - Unified AI gateway';
      case AIProviderType.groq:
        return 'Groq - Fast inference';
      case AIProviderType.mistral:
        return 'Mistral AI - French AI company';
    }
  }

  static List<AIProviderType> getAllProviders() {
    return AIProviderType.values;
  }
}
