import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/ai_provider_factory.dart';
import '../providers/providers_provider.dart';
import '../providers/ai_provider_settings_provider.dart';

class ProviderSelectorWidget extends ConsumerWidget {
  final AIProviderType? currentProvider;
  final Function(AIProviderType) onProviderChanged;

  const ProviderSelectorWidget({
    super.key,
    this.currentProvider,
    required this.onProviderChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(providersInfoProvider);
    final settings = ref.watch(aiProviderSettingsNotifierProvider);

    final selectedProvider =
        currentProvider ?? settings.valueOrNull?.currentProvider;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AIProviderType>(
          value: selectedProvider,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: providers.all
              .map((provider) {
                final type = _providerIdToType(provider.id);
                if (type == null) return null;
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getProviderIcon(type), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        provider.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (!provider.isConnected) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.warning_amber,
                            size: 12, color: Colors.orange.shade700),
                      ],
                    ],
                  ),
                );
              })
              .whereType<DropdownMenuItem<AIProviderType>>()
              .toList(),
          onChanged: (provider) {
            if (provider != null) {
              onProviderChanged(provider);
            }
          },
        ),
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
}
