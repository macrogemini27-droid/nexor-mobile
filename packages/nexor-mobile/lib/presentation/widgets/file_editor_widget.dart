import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ssh/sftp_client.dart';
import '../../core/errors/error_types.dart';
import '../providers/ssh_connection_provider.dart';

class FileEditorWidget extends ConsumerStatefulWidget {
  final String filePath;
  final Function(String)? onSaved;

  const FileEditorWidget({
    super.key,
    required this.filePath,
    this.onSaved,
  });

  @override
  ConsumerState<FileEditorWidget> createState() => _FileEditorWidgetState();
}

class _FileEditorWidgetState extends ConsumerState<FileEditorWidget> {
  final _contentController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasChanges = false;
  String? _error;
  String? _originalContent;

  @override
  void initState() {
    super.initState();
    _loadFile();
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    final hasChanges = _contentController.text != _originalContent;
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(sshClientProvider);
      if (!client.isConnected) {
        throw ConnectionException('Not connected to SSH server');
      }

      final sftpClient = SFTPClient(client, allowedRoot: '/home');
      final content = await sftpClient.readFile(widget.filePath);

      if (!mounted) return;

      setState(() {
        _originalContent = content;
        _contentController.text = content;
        _hasChanges = false;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFile() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final client = ref.read(sshClientProvider);
      if (!client.isConnected) {
        throw ConnectionException('Not connected to SSH server');
      }

      final sftpClient = SFTPClient(client, allowedRoot: '/home');
      await sftpClient.writeFile(widget.filePath, _contentController.text);

      if (!mounted) return;

      setState(() {
        _originalContent = _contentController.text;
        _hasChanges = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onSaved?.call(_contentController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _revertChanges() {
    if (_originalContent != null) {
      _contentController.text = _originalContent!;
      setState(() {
        _hasChanges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with actions
        Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              const Icon(Icons.edit, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.filePath,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_hasChanges)
                      Text(
                        'Unsaved changes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                            ),
                      ),
                  ],
                ),
              ),
              if (_hasChanges) ...[
                TextButton(
                  onPressed: _revertChanges,
                  child: const Text('Revert'),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: _hasChanges && !_isSaving ? _saveFile : null,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),

        // Editor
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _originalContent == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error: $_error',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadFile,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: null,
                        expands: true,
                      ),
                    ),
        ),
      ],
    );
  }
}
