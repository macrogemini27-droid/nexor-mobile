import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/permissions/permission_rule.dart';
import '../providers/permission_provider.dart';

class PermissionRulesScreen extends ConsumerWidget {
  const PermissionRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(permissionRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _clearAllRules(context, ref),
            tooltip: 'Clear all rules',
          ),
        ],
      ),
      body: rulesAsync.when(
        data: (rules) {
          if (rules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No permission rules',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rules will appear here when you grant permissions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Separate permanent and temporary rules
          final permanentRules = rules.where((r) => !r.isTemporary).toList();
          final sessionRules = rules.where((r) => r.isTemporary).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (sessionRules.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Session Rules (${sessionRules.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        ref.read(permissionNotifierProvider.notifier).clearSessionRules();
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...sessionRules.map((rule) => _buildRuleCard(context, ref, rule)),
                const SizedBox(height: 24),
              ],
              if (permanentRules.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.lock, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Permanent Rules (${permanentRules.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...permanentRules.map((rule) => _buildRuleCard(context, ref, rule)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading rules',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, WidgetRef ref, PermissionRule rule) {
    final actionColor = rule.action == PermissionAction.allow
        ? Colors.green
        : rule.action == PermissionAction.deny
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getToolIcon(rule.toolName), size: 20),
                const SizedBox(width: 8),
                Text(
                  rule.toolName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: actionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: actionColor),
                  ),
                  child: Text(
                    rule.action.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: actionColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteRule(context, ref, rule),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rule.patterns
                    .map((pattern) => Text(
                          pattern,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  rule.isTemporary ? Icons.access_time : Icons.lock,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  rule.isTemporary ? 'Session only' : 'Permanent',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(rule.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getToolIcon(String toolName) {
    switch (toolName) {
      case 'bash':
        return Icons.terminal;
      case 'read':
        return Icons.visibility;
      case 'write':
        return Icons.edit;
      case 'edit':
        return Icons.edit_note;
      case 'glob':
        return Icons.search;
      case 'grep':
        return Icons.find_in_page;
      default:
        return Icons.build;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteRule(
    BuildContext context,
    WidgetRef ref,
    PermissionRule rule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule'),
        content: const Text('Are you sure you want to delete this permission rule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(permissionNotifierProvider.notifier).removeRule(rule);
    }
  }

  Future<void> _clearAllRules(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Rules'),
        content: const Text(
          'Are you sure you want to delete all permission rules? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(permissionNotifierProvider.notifier).clearAllRules();
    }
  }
}
