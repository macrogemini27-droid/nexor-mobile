import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'ssh_client.dart' as local;

class SFTPClient {
  final local.SSHClient _sshClient;
  SftpClient? _sftpClient;

  SFTPClient(this._sshClient);

  /// Initialize SFTP session
  Future<void> _ensureConnected() async {
    if (_sftpClient != null) return;

    if (!_sshClient.isConnected) {
      throw Exception('SSH client is not connected');
    }

    final client = _sshClient.client;
    if (client == null) {
      throw Exception('SSH client not available');
    }
    _sftpClient = await client.sftp();
  }

  /// Read file content from remote server
  Future<String> readFile(String filePath) async {
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw Exception('SFTP client not initialized');
      }
      final file = await sftp.open(filePath);
      final content = await file.readBytes();
      await file.close();

      // Try to decode as UTF-8, if fails throw error for binary files
      try {
        return utf8.decode(content, allowMalformed: false);
      } catch (e) {
        // Binary file - return indicator
        throw Exception('Binary file cannot be displayed as text. Size: ${content.length} bytes');
      }
    } catch (e) {
      throw Exception('Failed to read file "$filePath": $e');
    }
  }

  /// Read file with pagination support
  Future<FileReadResult> readFileWithPagination(
    String filePath, {
    int offset = 0,
    int limit = 2000,
  }) async {
    final content = await readFile(filePath);
    final lines = content.split('\n');

    final totalLines = lines.length;
    final start = offset;
    final end = (start + limit).clamp(0, totalLines);
    final selectedLines = lines.sublist(start, end);

    return FileReadResult(
      lines: selectedLines,
      totalLines: totalLines,
      startLine: start,
      endLine: end,
      hasMore: end < totalLines,
    );
  }

  /// Write content to file on remote server
  Future<void> writeFile(String filePath, String content) async {
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw Exception('SFTP client not initialized');
      }
      final file = await sftp.open(
        filePath,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      );

      final bytes = utf8.encode(content);
      await file.writeBytes(Uint8List.fromList(bytes));
      await file.close();
    } catch (e) {
      throw Exception('Failed to write file "$filePath": $e');
    }
  }

  /// Append content to file
  Future<void> appendFile(String filePath, String content) async {
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw Exception('SFTP client not initialized');
      }
      final file = await sftp.open(
        filePath,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.append,
      );

      final bytes = utf8.encode(content);
      await file.writeBytes(Uint8List.fromList(bytes));
      await file.close();
    } catch (e) {
      throw Exception('Failed to append to file "$filePath": $e');
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        return false;
      }
      await sftp.stat(filePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file metadata
  Future<SftpFileMetadata> getFileMetadata(String filePath) async {
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw Exception('SFTP client not initialized');
      }
      final stat = await sftp.stat(filePath);
      return SftpFileMetadata(
        size: stat.size ?? 0,
        modifiedTime: stat.modifyTime != null
            ? DateTime.fromMillisecondsSinceEpoch(stat.modifyTime! * 1000)
            : null,
        isDirectory: stat.isDirectory,
        isFile: stat.isFile,
        permissions: stat.mode?.value ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to get metadata for "$filePath": $e');
    }
  }

  /// List directory contents
  Future<List<String>> listDirectory(String dirPath) async {
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw Exception('SFTP client not initialized');
      }
      final items = await sftp.listdir(dirPath);
      return items.map((item) => item.filename).toList();
    } catch (e) {
      throw Exception('Failed to list directory "$dirPath": $e');
    }
  }

  /// Delete file
  Future<void> deleteFile(String filePath) async {
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw Exception('SFTP client not initialized');
      }
      await sftp.remove(filePath);
    } catch (e) {
      throw Exception('Failed to delete file "$filePath": $e');
    }
  }

  /// Rename/move file
  Future<void> renameFile(String oldPath, String newPath) async {
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw Exception('SFTP client not initialized');
      }
      await sftp.rename(oldPath, newPath);
    } catch (e) {
      throw Exception(
          'Failed to rename file from "$oldPath" to "$newPath": $e');
    }
  }

  /// Close SFTP session
  Future<void> close() async {
    _sftpClient?.close();
    _sftpClient = null;
  }
}

/// Result of file read operation with pagination
class FileReadResult {
  final List<String> lines;
  final int totalLines;
  final int startLine;
  final int endLine;
  final bool hasMore;

  FileReadResult({
    required this.lines,
    required this.totalLines,
    required this.startLine,
    required this.endLine,
    required this.hasMore,
  });
}

/// File metadata information
class SftpFileMetadata {
  final int size;
  final DateTime? modifiedTime;
  final bool isDirectory;
  final bool isFile;
  final int permissions;

  SftpFileMetadata({
    required this.size,
    required this.modifiedTime,
    required this.isDirectory,
    required this.isFile,
    required this.permissions,
  });
}
