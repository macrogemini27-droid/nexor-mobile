import 'dart:io';
import 'dart:async' as async;
import 'dart:developer' as developer;
import 'package:dartssh2/dartssh2.dart';
import 'error_types.dart';

class ErrorHandler {
  /// Convert system exceptions to app exceptions
  static AppException handle(dynamic error, {String? context}) {
    developer.log('Handling error${context != null ? " in $context" : ""}: $error');
    
    if (error is AppException) return error;
    
    // Network errors
    if (error is SocketException) {
      return NetworkException(
        'Network connection failed',
        details: error.message,
      );
    }
    
    // Timeout errors - use qualified name to avoid collision with custom exception
    if (error is async.TimeoutException) {
      return OperationTimeoutException(context ?? 'operation');
    }
    
    // SSH/SFTP errors
    if (error is SftpError) {
      return _handleSftpError(error);
    }
    
    // File system errors
    if (error is FileSystemException) {
      return _handleFileSystemError(error);
    }
    
    // Generic exception
    return AppException(
      'An unexpected error occurred',
      details: error.toString(),
      retryable: false,
    );
  }
  
  static AppException _handleSftpError(SftpError error, {String? path}) {
    final msg = error.message.toLowerCase();
    
    // No such file - preserve path if available
    if (msg.contains('no such file') || msg.contains('not found')) {
      return FileNotFoundException(path ?? _extractPathFromMessage(error.message) ?? 'unknown');
    }
    
    // Permission denied - preserve path if available
    if (msg.contains('permission denied')) {
      return PermissionException(path ?? _extractPathFromMessage(error.message) ?? 'unknown');
    }
    
    // Connection issues
    if (msg.contains('connection') || msg.contains('timeout')) {
      return ConnectionException('SFTP connection failed', details: error.message);
    }
    
    return SftpException('SFTP operation failed', details: error.message);
  }
  
  static String? _extractPathFromMessage(String message) {
    // Try to extract path from common error message patterns
    final patterns = [
      RegExp(r"'([^']+)'"),
      RegExp(r'"([^"]+)"'),
      RegExp(r':\s*(/[^\s]+)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null && match.groupCount > 0) {
        return match.group(1);
      }
    }
    return null;
  }
  
  static AppException _handleFileSystemError(FileSystemException error) {
    final code = error.osError?.errorCode;
    
    // ENOENT (2) - No such file or directory
    if (code == 2) {
      return FileNotFoundException(error.path ?? 'unknown');
    }
    
    // EACCES (13) - Permission denied
    if (code == 13) {
      return PermissionException(error.path ?? 'unknown');
    }
    
    // ETIMEDOUT (110) - Connection timed out
    if (code == 110) {
      return OperationTimeoutException('file operation');
    }
    
    return AppException(
      'File system error',
      details: error.message,
      retryable: false,
    );
  }
}
