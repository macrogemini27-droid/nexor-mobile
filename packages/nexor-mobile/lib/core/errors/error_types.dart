abstract class AppException implements Exception {
  final String message;
  final String? details;
  final bool retryable;
  
  AppException(this.message, {this.details, this.retryable = false});
  
  @override
  String toString() => details != null ? '$message: $details' : message;
}

class NetworkException extends AppException {
  NetworkException(String message, {String? details}) 
      : super(message, details: details, retryable: true);
}

class AuthException extends AppException {
  AuthException(String message, {String? details})
      : super(message, details: details, retryable: false);
}

class FileNotFoundException extends AppException {
  final String path;
  
  FileNotFoundException(this.path)
      : super('File not found: $path', retryable: false);
}

class PermissionException extends AppException {
  final String path;
  
  PermissionException(this.path)
      : super('Permission denied: $path', retryable: false);
}

// Renamed from TimeoutException to avoid collision with dart:async.TimeoutException
class OperationTimeoutException extends AppException {
  final String operation;
  
  OperationTimeoutException(this.operation)
      : super('Operation timed out: $operation', retryable: true);
}

class ConnectionException extends AppException {
  ConnectionException(String message, {String? details})
      : super(message, details: details, retryable: true);
}

class BinaryFileException extends AppException {
  final int size;
  
  BinaryFileException(this.size)
      : super('Binary file cannot be displayed as text', 
          details: 'Size: $size bytes', retryable: false);
}

class PathValidationException extends AppException {
  final String path;
  
  PathValidationException(this.path, String reason)
      : super('Invalid path: $path', details: reason, retryable: false);
}

class SftpException extends AppException {
  SftpException(String message, {String? details})
      : super(message, details: details, retryable: true);
}
