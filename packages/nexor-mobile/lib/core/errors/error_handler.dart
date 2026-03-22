import 'dart:io';
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
    
    // Timeout errors
    if (error is TimeoutException) {
      return TimeoutException(context ?? 'operation');
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
  
  static AppException _handleSftpError(SftpError error) {
    final msg = error.message.toLowerCase();
    
    // No such file
    if (msg.contains('no such file') || msg.contains('not found')) {
      return FileNotFoundException('unknown');
    }
    
    // Permission denied
    if (msg.contains('permission denied')) {
      return PermissionException('unknown');
    }
    
    // Connection issues
    if (msg.contains('connection') || msg.contains('timeout')) {
      return ConnectionException('SFTP connection failed', details: error.message);
    }
    
    return SftpException('SFTP operation failed', details: error.message);
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
      return TimeoutException('file operation');
    }
    
    return AppException(
      'File system error',
      details: error.message,
      retryable: false,
    );
  }
}
