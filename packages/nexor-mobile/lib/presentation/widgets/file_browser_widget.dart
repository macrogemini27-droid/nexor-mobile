import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ssh/sftp_client.dart';
import '../../core/errors/error_types.dart';
import '../providers/ssh_connection_provider.dart';

class FileBrowserWidget extends ConsumerStatefulWidget {
  final String initialPath;
  final Function(String)? onFileSelected;

  const FileBrowserWidget({
    super.key,
    this.initialPath = '.',
    this.onFileSelected,
  });

  @override
  ConsumerState<FileBrowserWidget> createState() => _FileBrowserWidgetState();
}

class _FileBrowserWidgetState extends ConsumerState<FileBrowserWidget> {
  late String _currentPath;
  List<String>? _files;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath;
    _loadDirectory();
  }

  Future<void> _loadDirectory() async {
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
      final files = await sftpClient.listDirectory(_currentPath);

      if (!mounted) return;

      setState(() {
        _files = files;
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

  void _navigateToParent() {
    if (_currentPath == '/' || _currentPath == '.') return;

    final parts = _currentPath.split('/');
    parts.removeLast();
    _currentPath = parts.isEmpty ? '/' : parts.join('/');
    _loadDirectory();
  }

  void _navigateToDirectory(String dirName) {
    if (_currentPath.endsWith('/')) {
      _currentPath = '$_currentPath$dirName';
    } else {
      _currentPath = '$_currentPath/$dirName';
    }
    _loadDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Path bar
        Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateToParent,
                tooltip: 'Go to parent directory',
              ),
              Expanded(
                child: Text(
                  _currentPath,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadDirectory,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // File list
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
                            onPressed: _loadDirectory,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _files == null || _files!.isEmpty
                      ? const Center(child: Text('Empty directory'))
                      : ListView.builder(
                          itemCount: _files!.length,
                          itemBuilder: (context, index) {
                            final file = _files![index];
                            final isDirectory = !file.contains('.');

                            return ListTile(
                              leading: Icon(
                                isDirectory
                                    ? Icons.folder
                                    : Icons.insert_drive_file,
                                color: isDirectory ? Colors.amber : Colors.blue,
                              ),
                              title: Text(file),
                              onTap: () {
                                if (isDirectory) {
                                  _navigateToDirectory(file);
                                } else {
                                  widget.onFileSelected
                                      ?.call('$_currentPath/$file');
                                }
                              },
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
