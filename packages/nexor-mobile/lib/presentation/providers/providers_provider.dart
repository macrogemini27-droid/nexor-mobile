import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/ai_provider_factory.dart';
import 'ai_provider_settings_provider.dart';

class Model {
  final String id;
  final String name;
  final String family;
  final String releaseDate;
  final bool attachment;
  final bool reasoning;
  final bool temperature;
  final bool toolCall;
  final ModelCost? cost;
  final ModelLimit limit;
  final List<String>? modalities;
  final String? status;

  const Model({
    required this.id,
    required this.name,
    required this.family,
    required this.releaseDate,
    required this.attachment,
    required this.reasoning,
    required this.temperature,
    required this.toolCall,
    this.cost,
    required this.limit,
    this.modalities,
    this.status,
  });
}

class ModelCost {
  final double input;
  final double output;
  final double? cacheRead;
  final double? cacheWrite;

  const ModelCost({
    required this.input,
    required this.output,
    this.cacheRead,
    this.cacheWrite,
  });
}

class ModelLimit {
  final int context;
  final int? input;
  final int output;

  const ModelLimit({
    required this.context,
    this.input,
    required this.output,
  });
}

class ProviderInfo {
  final String id;
  final String name;
  final String source;
  final List<String> env;
  final Map<String, Model> models;
  final bool isConnected;

  const ProviderInfo({
    required this.id,
    required this.name,
    required this.source,
    required this.env,
    required this.models,
    required this.isConnected,
  });

  ProviderInfo copyWith({
    String? id,
    String? name,
    String? source,
    List<String>? env,
    Map<String, Model>? models,
    bool? isConnected,
  }) {
    return ProviderInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      env: env ?? this.env,
      models: models ?? this.models,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class ProviderListInfo {
  final List<ProviderInfo> all;
  final Map<String, String> default_;
  final List<String> connected;

  const ProviderListInfo({
    required this.all,
    required this.default_,
    required this.connected,
  });

  List<ProviderInfo> get popular {
    const popularIds = [
      'anthropic',
      'openai',
      'google',
      'opencode',
      'openrouter',
      'groq',
      'mistral'
    ];
    return all.where((p) => popularIds.contains(p.id)).toList();
  }

  List<ProviderInfo> get paid {
    return all.where((p) {
      if (!p.isConnected) return false;
      if (p.id == 'opencode') {
        return p.models.values.any((m) => m.cost != null);
      }
      return true;
    }).toList();
  }
}

final _availableProviders = Provider<List<ProviderInfo>>((ref) {
  return [
    ProviderInfo(
      id: 'anthropic',
      name: 'Anthropic',
      source: 'api',
      env: ['ANTHROPIC_API_KEY'],
      isConnected: true,
      models: {
        'claude-3-5-sonnet-20241022': const Model(
          id: 'claude-3-5-sonnet-20241022',
          name: 'Claude 3.5 Sonnet',
          family: 'claude',
          releaseDate: '2024-10-22',
          attachment: true,
          reasoning: true,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 3, output: 15),
          limit: ModelLimit(context: 200000, output: 8192),
          modalities: ['text', 'image', 'video', 'pdf'],
        ),
        'claude-3-5-haiku-20241022': const Model(
          id: 'claude-3-5-haiku-20241022',
          name: 'Claude 3.5 Haiku',
          family: 'claude',
          releaseDate: '2024-10-22',
          attachment: true,
          reasoning: true,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 0.8, output: 4),
          limit: ModelLimit(context: 200000, output: 4096),
          modalities: ['text', 'image', 'video', 'pdf'],
        ),
      },
    ),
    ProviderInfo(
      id: 'openai',
      name: 'OpenAI',
      source: 'api',
      env: ['OPENAI_API_KEY'],
      isConnected: true,
      models: {
        'gpt-4o': const Model(
          id: 'gpt-4o',
          name: 'GPT-4o',
          family: 'gpt',
          releaseDate: '2024-05-13',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 5, output: 15),
          limit: ModelLimit(context: 128000, output: 16384),
          modalities: ['text', 'audio', 'image', 'video', 'pdf'],
        ),
        'gpt-4o-mini': const Model(
          id: 'gpt-4o-mini',
          name: 'GPT-4o Mini',
          family: 'gpt',
          releaseDate: '2024-07-18',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 0.15, output: 0.6),
          limit: ModelLimit(context: 128000, output: 16384),
          modalities: ['text', 'audio', 'image', 'video', 'pdf'],
        ),
      },
    ),
    ProviderInfo(
      id: 'google',
      name: 'Google',
      source: 'api',
      env: ['GOOGLE_API_KEY'],
      isConnected: true,
      models: {
        'gemini-1-5-pro': const Model(
          id: 'gemini-1-5-pro',
          name: 'Gemini 1.5 Pro',
          family: 'gemini',
          releaseDate: '2024-05-14',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 1.25, output: 5),
          limit: ModelLimit(context: 2000000, output: 8192),
          modalities: ['text', 'audio', 'image', 'video', 'pdf'],
        ),
        'gemini-1-5-flash': const Model(
          id: 'gemini-1-5-flash',
          name: 'Gemini 1.5 Flash',
          family: 'gemini',
          releaseDate: '2024-08-01',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 0.075, output: 0.3),
          limit: ModelLimit(context: 1000000, output: 8192),
          modalities: ['text', 'audio', 'image', 'video', 'pdf'],
        ),
      },
    ),
    ProviderInfo(
      id: 'opencode',
      name: 'OpenCode Zen',
      source: 'api',
      env: ['OPENCODE_API_KEY'],
      isConnected: true,
      models: {
        'gpt-5.4': const Model(
          id: 'gpt-5.4',
          name: 'GPT 5.4',
          family: 'gpt',
          releaseDate: '2025-01-01',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 2.5, output: 15),
          limit: ModelLimit(context: 200000, output: 16384),
          modalities: ['text', 'audio', 'image', 'video', 'pdf'],
        ),
        'gpt-5.4-nano': const Model(
          id: 'gpt-5.4-nano',
          name: 'GPT 5.4 Nano',
          family: 'gpt',
          releaseDate: '2025-01-01',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 0.2, output: 1.25),
          limit: ModelLimit(context: 200000, output: 16384),
          modalities: ['text', 'audio', 'image', 'video', 'pdf'],
        ),
        'claude-opus-4-5': const Model(
          id: 'claude-opus-4-5',
          name: 'Claude Opus 4.5',
          family: 'claude',
          releaseDate: '2025-01-01',
          attachment: true,
          reasoning: true,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 5, output: 25),
          limit: ModelLimit(context: 200000, output: 8192),
          modalities: ['text', 'image', 'video', 'pdf'],
        ),
        'claude-sonnet-4-5': const Model(
          id: 'claude-sonnet-4-5',
          name: 'Claude Sonnet 4.5',
          family: 'claude',
          releaseDate: '2025-01-01',
          attachment: true,
          reasoning: true,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 3, output: 15),
          limit: ModelLimit(context: 200000, output: 8192),
          modalities: ['text', 'image', 'video', 'pdf'],
        ),
        'claude-haiku-4-5': const Model(
          id: 'claude-haiku-4-5',
          name: 'Claude Haiku 4.5',
          family: 'claude',
          releaseDate: '2025-01-01',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 1, output: 5),
          limit: ModelLimit(context: 200000, output: 4096),
          modalities: ['text', 'image', 'video', 'pdf'],
        ),
        'gemini-3.1-pro': const Model(
          id: 'gemini-3.1-pro',
          name: 'Gemini 3.1 Pro',
          family: 'gemini',
          releaseDate: '2025-01-01',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 2, output: 12),
          limit: ModelLimit(context: 200000, output: 8192),
          modalities: ['text', 'audio', 'image', 'video', 'pdf'],
        ),
        'big-pickle': const Model(
          id: 'big-pickle',
          name: 'Big Pickle',
          family: 'opencode',
          releaseDate: '2025-01-01',
          attachment: true,
          reasoning: true,
          temperature: true,
          toolCall: true,
          cost: null,
          limit: ModelLimit(context: 200000, output: 8192),
          modalities: ['text', 'image', 'video', 'pdf'],
        ),
        'minimax-m2.5-free': const Model(
          id: 'minimax-m2.5-free',
          name: 'MiniMax M2.5 Free',
          family: 'minimax',
          releaseDate: '2025-01-01',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: null,
          limit: ModelLimit(context: 200000, output: 4096),
          modalities: ['text', 'image'],
        ),
      },
    ),
    ProviderInfo(
      id: 'openrouter',
      name: 'OpenRouter',
      source: 'api',
      env: ['OPENROUTER_API_KEY'],
      isConnected: true,
      models: {
        'google/gemini-2.0-flash-001': const Model(
          id: 'google/gemini-2.0-flash-001',
          name: 'Gemini 2.0 Flash',
          family: 'gemini',
          releaseDate: '2025-01-01',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 0, output: 0),
          limit: ModelLimit(context: 1000000, output: 8192),
          modalities: ['text', 'image', 'video'],
        ),
        'anthropic/claude-3.5-sonnet': const Model(
          id: 'anthropic/claude-3.5-sonnet',
          name: 'Claude 3.5 Sonnet',
          family: 'claude',
          releaseDate: '2024-10-22',
          attachment: true,
          reasoning: true,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 3, output: 15),
          limit: ModelLimit(context: 200000, output: 8192),
          modalities: ['text', 'image', 'video', 'pdf'],
        ),
      },
    ),
    ProviderInfo(
      id: 'groq',
      name: 'Groq',
      source: 'api',
      env: ['GROQ_API_KEY'],
      isConnected: true,
      models: {
        'llama-3.3-70b-versatile': const Model(
          id: 'llama-3.3-70b-versatile',
          name: 'Llama 3.3 70B',
          family: 'llama',
          releaseDate: '2024-12-01',
          attachment: false,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 0, output: 0),
          limit: ModelLimit(context: 8192, output: 4096),
          modalities: ['text'],
        ),
        'llama-3.1-8b-instant': const Model(
          id: 'llama-3.1-8b-instant',
          name: 'Llama 3.1 8B',
          family: 'llama',
          releaseDate: '2024-07-23',
          attachment: false,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 0, output: 0),
          limit: ModelLimit(context: 8192, output: 4096),
          modalities: ['text'],
        ),
      },
    ),
    ProviderInfo(
      id: 'mistral',
      name: 'Mistral',
      source: 'api',
      env: ['MISTRAL_API_KEY'],
      isConnected: true,
      models: {
        'mistral-large-latest': const Model(
          id: 'mistral-large-latest',
          name: 'Mistral Large',
          family: 'mistral',
          releaseDate: '2024-12-01',
          attachment: true,
          reasoning: true,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 2, output: 6),
          limit: ModelLimit(context: 128000, output: 32000),
          modalities: ['text', 'image'],
        ),
        'mistral-small-latest': const Model(
          id: 'mistral-small-latest',
          name: 'Mistral Small',
          family: 'mistral',
          releaseDate: '2024-12-01',
          attachment: true,
          reasoning: false,
          temperature: true,
          toolCall: true,
          cost: ModelCost(input: 0.2, output: 0.6),
          limit: ModelLimit(context: 128000, output: 32000),
          modalities: ['text', 'image'],
        ),
      },
    ),
  ];
});

final providersListProvider = Provider<ProviderListInfo>((ref) {
  final settings = ref.watch(aiProviderSettingsNotifierProvider);
  final available = ref.watch(_availableProviders);

  final connectedIds = <String>[];

  settings.whenData((data) {
    for (final entry in data.apiKeys.entries) {
      if (entry.value != null && entry.value!.isNotEmpty) {
        final providerType = _providerTypeToId(entry.key);
        if (providerType != null) {
          connectedIds.add(providerType);
        }
      }
    }
  });

  final all = available.map((p) {
    return p.copyWith(isConnected: connectedIds.contains(p.id));
  }).toList();

  final connected =
      connectedIds.where((id) => all.any((p) => p.id == id)).toList();

  return ProviderListInfo(
    all: all,
    default_: connected.isNotEmpty ? {'default': connected.first} : {},
    connected: connected,
  );
});

final providersInfoProvider = Provider<ProvidersInfo>((ref) {
  final list = ref.watch(providersListProvider);
  return ProvidersInfo(list);
});

class ProvidersInfo {
  final ProviderListInfo _list;

  ProvidersInfo(this._list);

  List<ProviderInfo> get all => _list.all;
  Map<String, String> get default_ => _list.default_;
  List<String> get connected => _list.connected;

  List<ProviderInfo> get popular => _list.popular;

  List<ProviderInfo> get paid => _list.paid;

  List<ProviderInfo> get connectedProviders {
    final connectedSet = connected.toSet();
    return all.where((p) => connectedSet.contains(p.id)).toList();
  }
}

String? _providerTypeToId(AIProviderType type) {
  switch (type) {
    case AIProviderType.anthropic:
      return 'anthropic';
    case AIProviderType.openai:
      return 'openai';
    case AIProviderType.google:
      return 'google';
    case AIProviderType.opencode:
      return 'opencode';
    case AIProviderType.openrouter:
      return 'openrouter';
    case AIProviderType.groq:
      return 'groq';
    case AIProviderType.mistral:
      return 'mistral';
  }
}
