import 'dart:developer' as developer;
import '../../domain/entities/file_node.dart';
import '../../domain/entities/file_content.dart';
import '../../domain/repositories/file_repository.dart';
import '../../core/ssh/ssh_client.dart';
import '../../core/ssh/sftp_client.dart';

class FileRepositoryImpl implements FileRepository {
  final SSHClient _sshClient;
  final SFTPClient _sftpClient;

  FileRepositoryImpl(this._sshClient, this._sftpClient);

  @override
  Future<List<FileNode>> listFiles(String serverId, String path) async {
    try {
      developer.log('Listing files via SSH command: $path');

      if (!_sshClient.isConnected) {
        throw Exception('Not connected to SSH server. Please connect to the server first from the Servers screen.');
      }

      // Use single ls command to get all metadata at once (fixes N+1 problem)
      // Format: permissions links owner group size month day time/year name
      final normalizedPath = path.endsWith('/') && path != '/' ? path.substring(0, path.length - 1) : path;
      final command = 'ls -la --time-style=+%s "$normalizedPath" 2>/dev/null | tail -n +2';
      final result = await _sshClient.execute(command);

      if (result.exitCode != 0) {
        developer.log('ls command failed: ${result.stderr}');
        throw Exception('Failed to list directory: ${result.stderr}');
      }

      final files = <FileNode>[];
      final lines = result.stdout.split('\n').where((line) => line.trim().isNotEmpty);

      for (final line in lines) {
        try {
          // Parse ls -la output
          // Format: drwxr-xr-x 2 user group 4096 1234567890 filename
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length < 9) continue;

          final permissions = parts[0];
          final sizeStr = parts[4];
          final timestampStr = parts[5];

          // Filename is everything after timestamp (handles spaces in names)
          final nameStartIndex = line.indexOf(timestampStr) + timestampStr.length;
          final name = line.substring(nameStartIndex).trim();

          // Skip . and ..
          if (name == '.' || name == '..') continue;

          final isDirectory = permissions.startsWith('d');
          final size = int.tryParse(sizeStr) ?? 0;
          final timestamp = int.tryParse(timestampStr) ?? 0;
          final modifiedAt = timestamp > 0
              ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
              : DateTime.now();

          final fullPath = path.endsWith('/') ? '$path$name' : '$path/$name';

          files.add(FileNode(
            name: name,
            path: fullPath,
            isDirectory: isDirectory,
            size: size,
            modifiedAt: modifiedAt,
          ));
        } catch (e) {
          developer.log('Warning: Could not parse line: $line - $e');
        }
      }

      // Sort: directories first, then by name
      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      developer.log('Successfully loaded ${files.length} files in one command');
      return files;
    } catch (e, stack) {
      developer.log('Error listing files: $e\n$stack');
      throw Exception('Failed to list files: $e');
    }
  }

  @override
  Future<FileContent> readFile(String serverId, String path) async {
    try {
      developer.log('Reading file via SFTP: $path');
      
      if (!_sshClient.isConnected) {
        throw Exception('Not connected to SSH server. Please connect to the server first from the Servers screen.');
      }

      final content = await _sftpClient.readFile(path);
      final metadata = await _sftpClient.getFileMetadata(path);
      
      // Detect language from file extension
      final extension = path.split('.').last.toLowerCase();
      final language = _detectLanguage(extension);
      
      // Count lines
      final lines = content.split('\n').length;

      return FileContent(
        content: content,
        language: language,
        lines: lines,
        size: metadata.size,
        encoding: 'utf-8',
      );
    } catch (e, stack) {
      developer.log('Error reading file: $e\n$stack');
      throw Exception('Failed to read file: $e');
    }
  }

  String _detectLanguage(String extension) {
    const languageMap = {
      'dart': 'dart',
      'js': 'javascript',
      'ts': 'typescript',
      'py': 'python',
      'java': 'java',
      'kt': 'kotlin',
      'swift': 'swift',
      'go': 'go',
      'rs': 'rust',
      'c': 'c',
      'cpp': 'cpp',
      'h': 'c',
      'hpp': 'cpp',
      'cs': 'csharp',
      'php': 'php',
      'rb': 'ruby',
      'sh': 'bash',
      'bash': 'bash',
      'zsh': 'bash',
      'json': 'json',
      'xml': 'xml',
      'html': 'html',
      'css': 'css',
      'scss': 'scss',
      'yaml': 'yaml',
      'yml': 'yaml',
      'md': 'markdown',
      'sql': 'sql',
    };
    return languageMap[extension] ?? 'plaintext';
  }

  @override
  Future<List<FileNode>> searchFiles(
    String serverId,
    String query, {
    String? directory,
  }) async {
    try {
      developer.log('Searching files via SFTP: $query in ${directory ?? "/"}');

      if (!_sshClient.isConnected) {
        throw Exception('Not connected to SSH server. Please connect to the server first from the Servers screen.');
      }

      final searchDir = directory ?? '/';

      // Use SFTP to recursively search for files (safer than shell commands)
      final files = <FileNode>[];
      await _searchFilesRecursive(searchDir, query.toLowerCase(), files, 0, 100);

      developer.log('Found ${files.length} matching files');
      return files;
    } catch (e, stack) {
      developer.log('Error searching files: $e\n$stack');
      throw Exception('Failed to search files: $e');
    }
  }

  /// Recursively search for files matching query
  Future<void> _searchFilesRecursive(
    String path,
    String query,
    List<FileNode> results,
    int depth,
    int maxResults,
  ) async {
    // Limit recursion depth and result count
    if (depth > 5 || results.length >= maxResults) return;

    try {
      final items = await _sftpClient.listDirectory(path);

      for (final item in items) {
        if (item == '.' || item == '..') continue;
        if (results.length >= maxResults) break;

        final fullPath = path.endsWith('/') ? '$path$item' : '$path/$item';

        try {
          final metadata = await _sftpClient.getFileMetadata(fullPath);

          // Check if filename matches query
          if (item.toLowerCase().contains(query)) {
            results.add(FileNode(
              name: item,
              path: fullPath,
              isDirectory: metadata.isDirectory,
              size: metadata.size,
              modifiedAt: metadata.modifiedTime ?? DateTime.now(),
            ));
          }

          // Recurse into directories
          if (metadata.isDirectory) {
            await _searchFilesRecursive(fullPath, query, results, depth + 1, maxResults);
          }
        } catch (e) {
          developer.log('Warning: Could not access $item: $e');
        }
      }
    } catch (e) {
      developer.log('Warning: Could not list directory $path: $e');
    }
  }

  @override
  Future<List<FileNode>> searchContent(
    String serverId,
    String query, {
    String? directory,
  }) async {
    try {
      developer.log('Searching content via SFTP: $query in ${directory ?? "/"}');

      if (!_sshClient.isConnected) {
        throw Exception('Not connected to SSH server. Please connect to the server first from the Servers screen.');
      }

      final searchDir = directory ?? '/';

      // Use SFTP to recursively search file contents (safer than shell commands)
      final files = <FileNode>[];
      await _searchContentRecursive(searchDir, query.toLowerCase(), files, 0, 100);

      developer.log('Found ${files.length} files with matching content');
      return files;
    } catch (e, stack) {
      developer.log('Error searching content: $e\n$stack');
      throw Exception('Failed to search content: $e');
    }
  }

  /// Recursively search for files containing query in content
  Future<void> _searchContentRecursive(
    String path,
    String query,
    List<FileNode> results,
    int depth,
    int maxResults,
  ) async {
    // Limit recursion depth and result count
    if (depth > 5 || results.length >= maxResults) return;

    try {
      final items = await _sftpClient.listDirectory(path);

      for (final item in items) {
        if (item == '.' || item == '..') continue;
        if (results.length >= maxResults) break;

        final fullPath = path.endsWith('/') ? '$path$item' : '$path/$item';

        try {
          final metadata = await _sftpClient.getFileMetadata(fullPath);

          if (metadata.isDirectory) {
            // Recurse into directories
            await _searchContentRecursive(fullPath, query, results, depth + 1, maxResults);
          } else if (metadata.isFile && metadata.size < 1024 * 1024) {
            // Only search text files smaller than 1MB
            try {
              final content = await _sftpClient.readFile(fullPath);
              if (content.toLowerCase().contains(query)) {
                results.add(FileNode(
                  name: item,
                  path: fullPath,
                  isDirectory: false,
                  size: metadata.size,
                  modifiedAt: metadata.modifiedTime ?? DateTime.now(),
                ));
              }
            } catch (e) {
              // Skip binary files or files that can't be read
              developer.log('Warning: Could not read file $item: $e');
            }
          }
        } catch (e) {
          developer.log('Warning: Could not access $item: $e');
        }
      }
    } catch (e) {
      developer.log('Warning: Could not list directory $path: $e');
    }
  }

  @override
  Future<Map<String, String>> getGitStatus(
    String serverId,
    String directory,
  ) async {
    try {
      developer.log('Getting git status via SSH: $directory');

      if (!_sshClient.isConnected) {
        throw Exception('Not connected to SSH server. Please connect to the server first from the Servers screen.');
      }

      // Execute git status --porcelain
      final result = await _sshClient.execute(
        'git status --porcelain',
        workingDirectory: directory,
      );

      if (result.exitCode != 0) {
        developer.log('Git status failed: ${result.stderr}');
        return {};
      }

      final lines = result.stdout
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final statusMap = <String, String>{};
      for (final line in lines) {
        if (line.length < 3) continue;
        final status = line.substring(0, 2).trim();
        final path = line.substring(3);
        statusMap[path] = status;
      }

      developer.log('Git status: ${statusMap.length} changed files');
      return statusMap;
    } catch (e, stack) {
      developer.log('Error getting git status: $e\n$stack');
      throw Exception('Failed to get git status: $e');
    }
  }
}
