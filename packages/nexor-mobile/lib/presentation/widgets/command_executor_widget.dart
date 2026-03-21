import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ssh/models/command_result.dart';
import '../providers/ssh_connection_provider.dart';

class CommandExecutorWidget extends ConsumerStatefulWidget {
  const CommandExecutorWidget({super.key});

  @override
  ConsumerState<CommandExecutorWidget> createState() =>
      _CommandExecutorWidgetState();
}

class _CommandExecutorWidgetState
    extends ConsumerState<CommandExecutorWidget> {
  final _commandController = TextEditingController();
  final _outputController = TextEditingController();
  bool _isExecuting = false;

  @override
  void dispose() {
    _commandController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  Future<void> _executeCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;

    final client = ref.read(sshClientProvider);
    if (!client.isConnected) {
      _showError('Not connected to SSH server');
      return;
    }

    setState(() {
      _isExecuting = true;
      _outputController.text = 'Executing: $command\n\n';
    });

    try {
      final result = await client.execute(command);
      
      setState(() {
        _outputController.text = _formatResult(result);
        _isExecuting = false;
      });
    } catch (e) {
      setState(() {
        _outputController.text = 'Error: $e';
        _isExecuting = false;
      });
    }
  }

  String _formatResult(CommandResult result) {
    final buffer = StringBuffer();
    buffer.writeln('Command: ${_commandController.text}');
    buffer.writeln('Exit Code: ${result.exitCode}');
    buffer.writeln('Execution Time: ${result.executionTime.inMilliseconds}ms');
    buffer.writeln('---');
    
    if (result.stdout.isNotEmpty) {
      buffer.writeln('STDOUT:');
      buffer.writeln(result.stdout);
    }
    
    if (result.stderr.isNotEmpty) {
      buffer.writeln('\nSTDERR:');
      buffer.writeln(result.stderr);
    }
    
    return buffer.toString();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(sshConnectionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Connection Status Indicator
        connectionState.when(
          data: (session) {
            if (session?.isConnected ?? false) {
              return Container(
                padding: const EdgeInsets.all(8),
                color: Colors.green.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Connected to ${session!.host}:${session.port}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange.withOpacity(0.1),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Not connected',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            );
          },
          loading: () => Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue.withOpacity(0.1),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Connecting...'),
              ],
            ),
          ),
          error: (error, _) => Container(
            padding: const EdgeInsets.all(8),
            color: Colors.red.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Command Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commandController,
                decoration: const InputDecoration(
                  labelText: 'Command',
                  hintText: 'ls -la',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.terminal),
                ),
                onSubmitted: (_) => _executeCommand(),
                enabled: !_isExecuting,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _isExecuting ? null : _executeCommand,
              icon: _isExecuting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: const Text('Execute'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Output Display
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
              color: Colors.black87,
            ),
            child: TextField(
              controller: _outputController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.white,
                fontSize: 12,
              ),
              maxLines: null,
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }
}
