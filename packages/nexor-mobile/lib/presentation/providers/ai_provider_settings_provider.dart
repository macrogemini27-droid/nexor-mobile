import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/ai/ai_provider_factory.dart';
import '../../core/ai/providers/ai_provider.dart';

// AI Provider Settings State
class AIProviderSettings {
  final AIProviderType currentProvider;
  final Map<AIProviderType, String?> apiKeys;

  const AIProviderSettings({
    required this.currentProvider,
    required this.apiKeys,
  });

  AIProviderSettings copyWith({
    AIProviderType? currentProvider,
    Map<AIProviderType, String?>? apiKeys,
  }) {
    return AIProviderSettings(
      currentProvider: currentProvider ?? this.currentProvider,
      apiKeys: apiKeys ?? this.apiKeys,
    );
  }
}

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// AI Provider Settings Notifier
class AIProviderSettingsNotifier
    extends StateNotifier<AsyncValue<AIProviderSettings>> {
  final FlutterSecureStorage _storage;

  static const String _currentProviderKey = 'current_ai_provider';
  static const String _apiKeyPrefix = 'api_key_';

  AIProviderSettingsNotifier(this._storage)
      : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Load current provider
      final providerName = await _storage.read(key: _currentProviderKey);
      final currentProvider = providerName != null
          ? AIProviderFactory.fromString(providerName)
          : AIProviderType.anthropic;

      // Load API keys
      final apiKeys = <AIProviderType, String?>{};
      for (final provider in AIProviderType.values) {
        final key = '$_apiKeyPrefix${provider.name}';
        apiKeys[provider] = await _storage.read(key: key);
      }

      state = AsyncValue.data(AIProviderSettings(
        currentProvider: currentProvider,
        apiKeys: apiKeys,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> setCurrentProvider(AIProviderType provider) async {
    try {
      await _storage.write(key: _currentProviderKey, value: provider.name);
      
      final currentSettings = state.value;
      if (currentSettings != null) {
        state = AsyncValue.data(
          currentSettings.copyWith(currentProvider: provider),
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> setApiKey(AIProviderType provider, String apiKey) async {
    try {
      final key = '$_apiKeyPrefix${provider.name}';
      await _storage.write(key: key, value: apiKey);

      final currentSettings = state.value;
      if (currentSettings != null) {
        final newApiKeys = Map<AIProviderType, String?>.from(currentSettings.apiKeys);
        newApiKeys[provider] = apiKey;
        
        state = AsyncValue.data(
          currentSettings.copyWith(apiKeys: newApiKeys),
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<String?> getApiKey(AIProviderType provider) async {
    final key = '$_apiKeyPrefix${provider.name}';
    return await _storage.read(key: key);
  }

  Future<void> clearApiKey(AIProviderType provider) async {
    try {
      final key = '$_apiKeyPrefix${provider.name}';
      await _storage.delete(key: key);

      final currentSettings = state.value;
      if (currentSettings != null) {
        final newApiKeys = Map<AIProviderType, String?>.from(currentSettings.apiKeys);
        newApiKeys[provider] = null;
        
        state = AsyncValue.data(
          currentSettings.copyWith(apiKeys: newApiKeys),
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final aiProviderSettingsNotifierProvider = StateNotifierProvider<
    AIProviderSettingsNotifier, AsyncValue<AIProviderSettings>>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AIProviderSettingsNotifier(storage);
});

// Current AI Provider Instance
final currentAIProviderProvider = Provider<AIProvider?>((ref) {
  final settings = ref.watch(aiProviderSettingsNotifierProvider);
  
  return settings.when(
    data: (data) {
      final apiKey = data.apiKeys[data.currentProvider];
      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }
      
      return AIProviderFactory.create(
        type: data.currentProvider,
        apiKey: apiKey,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
