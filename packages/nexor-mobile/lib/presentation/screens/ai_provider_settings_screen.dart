import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/ai_provider_factory.dart';
import '../providers/ai_provider_settings_provider.dart';
import '../providers/providers_provider.dart';

class AIProviderSettingsScreen extends ConsumerStatefulWidget {
  const AIProviderSettingsScreen({super.key});

  @override
  ConsumerState<AIProviderSettingsScreen> createState() =>
      _AIProviderSettingsScreenState();
}

class _AIProviderSettingsScreenState
    extends ConsumerState<AIProviderSettingsScreen> {
  final Map<AIProviderType, TextEditingController> _apiKeyControllers = {};
  final Map<AIProviderType, bool> _obscureText = {};

  @override
  void initState() {
    super.initState();
    for (final provider in AIProviderType.values) {
      _apiKeyControllers[provider] = TextEditingController();
      _obscureText[provider] = true;
    }
    _loadApiKeys();
  }

  @override
  void dispose() {
    for (final controller in _apiKeyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadApiKeys() async {
    for (final provider in AIProviderType.values) {
      final apiKey = await ref
          .read(aiProviderSettingsNotifierProvider.notifier)
          .getApiKey(provider);
      if (apiKey != null) {
        _apiKeyControllers[provider]?.text = apiKey;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(aiProviderSettingsNotifierProvider);
    final providersInfo = ref.watch(providersInfoProvider);
    final currentProvider = settings.value?.currentProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Provider Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Select AI Provider',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose which AI provider to use for conversations',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ...providersInfo.all.map((provider) {
            final type = _providerIdToType(provider.id);
            if (type == null) return const SizedBox.shrink();
            return _buildProviderCard(
              context,
              provider,
              type,
              isSelected: type == currentProvider,
            );
          }),
          const SizedBox(height: 32),
          Text(
            'API Keys',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure API keys for each provider',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          ...providersInfo.all.map((provider) {
            final type = _providerIdToType(provider.id);
            if (type == null) return const SizedBox.shrink();
            return _buildApiKeyField(context, provider, type);
          }),
        ],
      ),
    );
  }

  AIProviderType? _providerIdToType(String id) {
    switch (id) {
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
        return null;
    }
  }

  Widget _buildProviderCard(
    BuildContext context,
    ProviderInfo provider,
    AIProviderType type, {
    required bool isSelected,
  }) {
    final defaultModel = provider.models.values.isNotEmpty
        ? provider.models.values.first.name
        : 'Unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () => _selectProvider(type),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getProviderIcon(type),
                    size: 32,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              provider.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                            ),
                            if (!provider.isConnected) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Not configured',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Default: $defaultModel',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              if (provider.models.values.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: provider.models.values.map((model) {
                    return Chip(
                      label: Text(
                        model.name,
                        style: const TextStyle(fontSize: 10),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      avatar: model.cost != null
                          ? Icon(Icons.attach_money, size: 12)
                          : null,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiKeyField(
    BuildContext context,
    ProviderInfo provider,
    AIProviderType type,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getProviderIcon(type), size: 16),
              const SizedBox(width: 8),
              Text(
                provider.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (!provider.isConnected) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.warning_amber,
                  size: 14,
                  color: Colors.orange.shade700,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyControllers[type],
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'Enter your API key',
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _obscureText[type]!
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText[type] = !_obscureText[type]!;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () => _saveApiKey(type),
                  ),
                ],
              ),
            ),
            obscureText: _obscureText[type]!,
          ),
        ],
      ),
    );
  }

  IconData _getProviderIcon(AIProviderType provider) {
    switch (provider) {
      case AIProviderType.anthropic:
        return Icons.psychology;
      case AIProviderType.openai:
        return Icons.auto_awesome;
      case AIProviderType.google:
        return Icons.lightbulb;
      case AIProviderType.opencode:
        return Icons.bolt;
      case AIProviderType.openrouter:
        return Icons.route;
      case AIProviderType.groq:
        return Icons.speed;
      case AIProviderType.mistral:
        return Icons.cloud;
    }
  }

  Future<void> _selectProvider(AIProviderType provider) async {
    await ref
        .read(aiProviderSettingsNotifierProvider.notifier)
        .setCurrentProvider(provider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Switched to ${AIProviderFactory.getDisplayName(provider)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveApiKey(AIProviderType provider) async {
    final apiKey = _apiKeyControllers[provider]?.text.trim();
    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an API key'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref
        .read(aiProviderSettingsNotifierProvider.notifier)
        .setApiKey(provider, apiKey);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'API key saved for ${AIProviderFactory.getDisplayName(provider)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
