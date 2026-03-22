import 'dart:async' as async;
import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'ssh_client.dart' as local;
import 'path_validator.dart';
import '../errors/error_types.dart';
import '../errors/error_handler.dart';

class SFTPClient {
  final local.SSHClient _sshClient;
  final String allowedRoot;
  final Duration timeout;
  SftpClient? _sftpClient;

  SFTPClient(
    this._sshClient, {
    required this.allowedRoot,
    this.timeout = const Duration(seconds: 30),
  });

  /// Initialize SFTP session
  Future<void> _ensureConnected() async {
    if (_sftpClient != null) return;

    if (!_sshClient.isConnected) {
      throw ConnectionException('SSH client is not connected');
    }

    final client = _sshClient.client;
    if (client == null) {
      throw ConnectionException('SSH client not available');
    }
    
    try {
      _sftpClient = await client.sftp().timeout(timeout);
    } on async.TimeoutException {
      throw OperationTimeoutException('SFTP connection');
    } catch (e) {
      throw ErrorHandler.handle(e, context: 'SFTP connection');
    }
  }

  /// Read file content from remote server
  Future<String> readFile(String filePath) async {
    final validated = PathValidator.validatePath(filePath, allowedRoot);
    await _ensureConnected();

    final sftp = _sftpClient;
    if (sftp == null) {
      throw SftpException('SFTP client not initialized');
    }

    SftpFile? file;
    try {
      file = await sftp.open(validated).timeout(timeout);
      final content = await file.readBytes().timeout(timeout);

      // Try to decode as UTF-8, if fails throw error for binary files
      try {
        return utf8.decode(content, allowMalformed: false);
      } catch (e) {
        throw BinaryFileException(content.length);
      }
    } on async.TimeoutException {
      throw OperationTimeoutException('file read');
    } catch (e) {
      throw ErrorHandler.handle(e, context: 'readFile');
    } finally {
      await file?.close();
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
    final validated = PathValidator.validatePath(filePath, allowedRoot);
    await _ensureConnected();

    final sftp = _sftpClient;
    if (sftp == null) {
      throw SftpException('SFTP client not initialized');
    }

    SftpFile? file;
    try {
      file = await sftp.open(
        validated,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      ).timeout(timeout);

      final bytes = utf8.encode(content);
      await file.writeBytes(Uint8List.fromList(bytes)).timeout(timeout);
    } on async.TimeoutException {
      throw OperationTimeoutException('file write');
    } catch (e) {
      throw ErrorHandler.handle(e, context: 'writeFile');
    } finally {
      await file?.close();
    }
  }

  /// Append content to file
  Future<void> appendFile(String filePath, String content) async {
    final validated = PathValidator.validatePath(filePath, allowedRoot);
    await _ensureConnected();

    final sftp = _sftpClient;
    if (sftp == null) {
      throw SftpException('SFTP client not initialized');
    }

    SftpFile? file;
    try {
      file = await sftp.open(
        validated,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.append,
      ).timeout(timeout);

      final bytes = utf8.encode(content);
      await file.writeBytes(Uint8List.fromList(bytes)).timeout(timeout);
    } on async.TimeoutException {
      throw OperationTimeoutException('file append');
    } catch (e) {
      throw ErrorHandler.handle(e, context: 'appendFile');
    } finally {
      await file?.close();
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
      await sftp.stat(filePath).timeout(timeout);
      return true;
    } on async.TimeoutException {
      // Only swallow timeout - could indicate network issues but not file existence
      throw OperationTimeoutException('file stat');
    } catch (e) {
      // Only return false for "not found" errors, throw others
      final handler = ErrorHandler.handle(e, context: 'fileExists');
      if (handler is FileNotFoundException) {
        return false;
      }
      throw handler;
    }
  }

  /// Get file metadata
  Future<SftpFileMetadata> getFileMetadata(String filePath) async {
    final validated = PathValidator.validatePath(filePath, allowedRoot);
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw SftpException('SFTP client not initialized');
      }
      final stat = await sftp.stat(validated).timeout(timeout);
      return SftpFileMetadata(
        size: stat.size ?? 0,
        modifiedTime: stat.modifyTime != null
            ? DateTime.fromMillisecondsSinceEpoch(stat.modifyTime! * 1000)
            : null,
        isDirectory: stat.isDirectory,
        isFile: stat.isFile,
        permissions: stat.mode?.value ?? 0,
      );
    } on async.TimeoutException {
      throw OperationTimeoutException('get metadata');
    } catch (e) {
      throw ErrorHandler.handle(e, context: 'getFileMetadata');
    }
  }

  /// List directory contents
  Future<List<String>> listDirectory(String dirPath) async {
    final validated = PathValidator.validatePath(dirPath, allowedRoot);
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw SftpException('SFTP client not initialized');
      }
      final items = await sftp.listdir(validated).timeout(timeout);
      return items.map((item) => item.filename).toList();
    } on async.TimeoutException {
      throw OperationTimeoutException('list directory');
    } catch (e) {
      throw ErrorHandler.handle(e, context: 'listDirectory');
    }
  }

  /// Delete file
  Future<void> deleteFile(String filePath) async {
    final validated = PathValidator.validatePath(filePath, allowedRoot);
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw SftpException('SFTP client not initialized');
      }
      await sftp.remove(validated).timeout(timeout);
    } on async.TimeoutException {
      throw OperationTimeoutException('file delete');
    } catch (e) {
      throw ErrorHandler.handle(e, context: 'deleteFile');
    }
  }

  /// Rename/move file
  Future<void> renameFile(String oldPath, String newPath) async {
    final validatedOld = PathValidator.validatePath(oldPath, allowedRoot);
    final validatedNew = PathValidator.validatePath(newPath, allowedRoot);
    await _ensureConnected();

    try {
      final sftp = _sftpClient;
      if (sftp == null) {
        throw SftpException('SFTP client not initialized');
      }
      await sftp.rename(validatedOld, validatedNew).timeout(timeout);
    } on async.TimeoutException {
      throw OperationTimeoutException('file rename');
    } catch (e) {
      throw ErrorHandler.handle(e, context: 'renameFile');
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
