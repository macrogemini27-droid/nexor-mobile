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
      developer.log('Listing files via SFTP: $path');
      
      if (!_sshClient.isConnected) {
        throw Exception('Not connected to SSH server');
      }

      // Use SFTP to list directory
      final items = await _sftpClient.listDirectory(path);
      final files = <FileNode>[];

      // Get metadata for each item
      for (final item in items) {
        if (item == '.' || item == '..') continue;
        
        final fullPath = path.endsWith('/') ? '$path$item' : '$path/$item';
        try {
          final metadata = await _sftpClient.getFileMetadata(fullPath);
          files.add(FileNode(
            name: item,
            path: fullPath,
            isDirectory: metadata.isDirectory,
            size: metadata.size,
            modifiedAt: metadata.modifiedTime,
          ));
        } catch (e) {
          developer.log('Warning: Could not get metadata for $item: $e');
          // Add without metadata
          files.add(FileNode(
            name: item,
            path: fullPath,
            isDirectory: false,
            size: 0,
            modifiedAt: null,
          ));
        }
      }

      // Sort: directories first, then by name
      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      developer.log('Successfully loaded ${files.length} files');
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
        throw Exception('Not connected to SSH server');
      }

      final content = await _sftpClient.readFile(path);
      final metadata = await _sftpClient.getFileMetadata(path);

      return FileContent(
        path: path,
        content: content,
        size: metadata.size,
        modifiedAt: metadata.modifiedTime,
      );
    } catch (e, stack) {
      developer.log('Error reading file: $e\n$stack');
      throw Exception('Failed to read file: $e');
    }
  }

  @override
  Future<List<FileNode>> searchFiles(
    String serverId,
    String query, {
    String? directory,
  }) async {
    try {
      developer.log('Searching files via SSH: $query in ${directory ?? "/"}');
      
      if (!_sshClient.isConnected) {
        throw Exception('Not connected to SSH server');
      }

      final searchDir = directory ?? '/';
      // Use find command to search for files
      final command = 'find "$searchDir" -type f -name "*$query*" 2>/dev/null | head -100';
      final result = await _sshClient.execute(command);

      if (result.exitCode != 0) {
        developer.log('Find command failed: ${result.stderr}');
        return [];
      }

      final paths = result.stdout
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final files = <FileNode>[];
      for (final path in paths) {
        try {
          final metadata = await _sftpClient.getFileMetadata(path);
          final name = path.split('/').last;
          files.add(FileNode(
            name: name,
            path: path,
            isDirectory: metadata.isDirectory,
            size: metadata.size,
            modifiedAt: metadata.modifiedTime,
          ));
        } catch (e) {
          developer.log('Warning: Could not get metadata for $path: $e');
        }
      }

      developer.log('Found ${files.length} matching files');
      return files;
    } catch (e, stack) {
      developer.log('Error searching files: $e\n$stack');
      throw Exception('Failed to search files: $e');
    }
  }

  @override
  Future<List<FileNode>> searchContent(
    String serverId,
    String query, {
    String? directory,
  }) async {
    try {
      developer.log('Searching content via SSH: $query in ${directory ?? "/"}');
      
      if (!_sshClient.isConnected) {
        throw Exception('Not connected to SSH server');
      }

      final searchDir = directory ?? '/';
      // Use grep to search file contents
      final command = 'grep -rl "$query" "$searchDir" 2>/dev/null | head -100';
      final result = await _sshClient.execute(command);

      if (result.exitCode != 0 && result.exitCode != 1) {
        developer.log('Grep command failed: ${result.stderr}');
        return [];
      }

      final paths = result.stdout
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final files = <FileNode>[];
      for (final path in paths) {
        try {
          final metadata = await _sftpClient.getFileMetadata(path);
          final name = path.split('/').last;
          files.add(FileNode(
            name: name,
            path: path,
            isDirectory: metadata.isDirectory,
            size: metadata.size,
            modifiedAt: metadata.modifiedTime,
          ));
        } catch (e) {
          developer.log('Warning: Could not get metadata for $path: $e');
        }
      }

      developer.log('Found ${files.length} files with matching content');
      return files;
    } catch (e, stack) {
      developer.log('Error searching content: $e\n$stack');
      throw Exception('Failed to search content: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getGitStatus(
    String serverId,
    String directory,
  ) async {
    try {
      developer.log('Getting git status via SSH: $directory');
      
      if (!_sshClient.isConnected) {
        throw Exception('Not connected to SSH server');
      }

      // Execute git status --porcelain
      final result = await _sshClient.execute(
        'git status --porcelain',
        workingDirectory: directory,
      );

      if (result.exitCode != 0) {
        developer.log('Git status failed: ${result.stderr}');
        return {'files': []};
      }

      final lines = result.stdout
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final files = lines.map((line) {
        final status = line.substring(0, 2);
        final path = line.substring(3);
        return {
          'path': path,
          'status': status.trim(),
        };
      }).toList();

      developer.log('Git status: ${files.length} changed files');
      return {'files': files};
    } catch (e, stack) {
      developer.log('Error getting git status: $e\n$stack');
      throw Exception('Failed to get git status: $e');
    }
  }
}
