import 'package:flutter/material.dart';

class PermissionDialog extends StatefulWidget {
  final String toolName;
  final List<String> patterns;
  final bool isDangerous;

  const PermissionDialog({
    super.key,
    required this.toolName,
    required this.patterns,
    this.isDangerous = false,
  });

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  bool _rememberChoice = false;
  bool _applyToSession = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.isDangerous ? Icons.warning : Icons.security,
            color: widget.isDangerous ? Colors.orange : Colors.blue,
          ),
          const SizedBox(width: 8),
          const Text('Permission Required'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isDangerous)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This operation is potentially dangerous!',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'The AI wants to execute:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getToolIcon(widget.toolName),
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.toolName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...widget.patterns.map((pattern) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        pattern,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _applyToSession,
            onChanged: (value) {
              setState(() {
                _applyToSession = value ?? false;
                if (_applyToSession) {
                  _rememberChoice = false;
                }
              });
            },
            title: const Text('Allow for this session'),
            subtitle: const Text('Permission will be reset when app restarts'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          CheckboxListTile(
            value: _rememberChoice,
            onChanged: (value) {
              setState(() {
                _rememberChoice = value ?? false;
                if (_rememberChoice) {
                  _applyToSession = false;
                }
              });
            },
            title: const Text('Always allow'),
            subtitle: const Text('Permission will be saved permanently'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop({
            'allowed': false,
            'remember': false,
            'session': false,
          }),
          child: const Text('Deny'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop({
            'allowed': true,
            'remember': _rememberChoice,
            'session': _applyToSession,
          }),
          child: const Text('Allow'),
        ),
      ],
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
}
