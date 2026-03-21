import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../widgets/common/nexor_app_bar.dart';
import '../../widgets/common/nexor_button.dart';
import '../../widgets/common/nexor_input.dart';
import 'providers/conversations_provider.dart';

class NewConversationScreen extends ConsumerStatefulWidget {
  final String? initialDirectory;
  final String? initialFile;

  const NewConversationScreen({
    super.key,
    this.initialDirectory,
    this.initialFile,
  });

  @override
  ConsumerState<NewConversationScreen> createState() =>
      _NewConversationScreenState();
}

class _NewConversationScreenState
    extends ConsumerState<NewConversationScreen> {
  final _titleController = TextEditingController();
  final _directoryController = TextEditingController();
  String _selectedAgent = 'general';
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDirectory != null) {
      _directoryController.text = widget.initialDirectory!;
    }
    if (widget.initialFile != null) {
      _titleController.text = 'Help with ${widget.initialFile!.split('/').last}';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _directoryController.dispose();
    super.dispose();
  }

  Future<void> _createConversation() async {
    if (_directoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a directory'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final session = await ref.read(conversationsProvider().notifier).create(
            directory: _directoryController.text,
            agent: _selectedAgent,
            title: _titleController.text.isEmpty
                ? null
                : _titleController.text,
          );

      if (mounted) {
        context.go('/chat/${session.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create conversation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NexorAppBar(
        title: 'New Conversation',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NexorInput(
              controller: _titleController,
              hint: 'Enter conversation title',
              prefixIcon: const Icon(PhosphorIconsRegular.textT),
            ),
            const SizedBox(height: 16),
            NexorInput(
              controller: _directoryController,
              hint: 'Select project directory',
              prefixIcon: const Icon(PhosphorIconsRegular.folder),
              readOnly: true,
              onTap: () {
                // FUTURE: Implement directory picker
                // This will allow users to browse and select project directories via SFTP
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Directory picker coming soon'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Agent',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _AgentSelector(
              selectedAgent: _selectedAgent,
              onChanged: (agent) {
                setState(() => _selectedAgent = agent);
              },
            ),
            const SizedBox(height: 24),
            NexorButton(
              onPressed: _isCreating ? null : _createConversation,
              text: _isCreating ? 'Creating...' : 'Create Conversation',
              icon: PhosphorIconsRegular.plus,
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentSelector extends StatelessWidget {
  final String selectedAgent;
  final Function(String) onChanged;

  const _AgentSelector({
    required this.selectedAgent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final agents = [
      {
        'id': 'general',
        'name': 'General',
        'description': 'General purpose coding assistant',
        'icon': PhosphorIconsRegular.robot,
      },
      {
        'id': 'build',
        'name': 'Build',
        'description': 'Specialized in build and deployment',
        'icon': PhosphorIconsRegular.hammer,
      },
      {
        'id': 'explore',
        'name': 'Explore',
        'description': 'Code exploration and analysis',
        'icon': PhosphorIconsRegular.magnifyingGlass,
      },
    ];

    return Column(
      children: agents.map((agent) {
        final isSelected = selectedAgent == agent['id'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(agent['id'] as String),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      agent['icon'] as IconData,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent['name'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          agent['description'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      PhosphorIconsFill.checkCircle,
                      color: AppColors.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
