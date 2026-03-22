import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ssh/sftp_client.dart';
import '../../core/errors/error_types.dart';
import '../providers/ssh_connection_provider.dart';

class FileViewerWidget extends ConsumerStatefulWidget {
  final String filePath;

  const FileViewerWidget({
    super.key,
    required this.filePath,
  });

  @override
  ConsumerState<FileViewerWidget> createState() => _FileViewerWidgetState();
}

class _FileViewerWidgetState extends ConsumerState<FileViewerWidget> {
  String? _content;
  bool _isLoading = false;
  String? _error;
  int _currentOffset = 0;
  final int _pageSize = 1000;
  int _totalLines = 0;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile({int offset = 0}) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentOffset = offset;
    });

    try {
      final client = ref.read(sshClientProvider);
      if (!client.isConnected) {
        throw ConnectionException('Not connected to SSH server');
      }

      final sftpClient = SFTPClient(client, allowedRoot: '/home');
      final result = await sftpClient.readFileWithPagination(
        widget.filePath,
        offset: offset,
        limit: _pageSize,
      );

      if (!mounted) return;

      final buffer = StringBuffer();
      for (int i = 0; i < result.lines.length; i++) {
        final lineNumber = result.startLine + i + 1;
        buffer.writeln('$lineNumber: ${result.lines[i]}');
      }

      setState(() {
        _content = buffer.toString();
        _totalLines = result.totalLines;
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

  void _loadNextPage() {
    if (_currentOffset + _pageSize < _totalLines) {
      _loadFile(offset: _currentOffset + _pageSize);
    }
  }

  void _loadPreviousPage() {
    if (_currentOffset > 0) {
      _loadFile(offset: (_currentOffset - _pageSize).clamp(0, _totalLines));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.filePath,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_totalLines > 0)
                Text(
                  'Lines: $_totalLines',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),

        // Pagination controls
        if (_totalLines > _pageSize)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _currentOffset > 0 ? _loadPreviousPage : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                Text(
                  'Lines ${_currentOffset + 1} - ${(_currentOffset + _pageSize).clamp(0, _totalLines)} of $_totalLines',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextButton.icon(
                  onPressed: _currentOffset + _pageSize < _totalLines
                      ? _loadNextPage
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
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
                            onPressed: () => _loadFile(offset: _currentOffset),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _content ?? '',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
