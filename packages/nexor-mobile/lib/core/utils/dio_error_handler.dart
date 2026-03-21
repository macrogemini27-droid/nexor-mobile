import 'package:dio/dio.dart';

/// Helper class to format DioException errors with detailed messages
class DioErrorHandler {
  /// Get a user-friendly error message from DioException
  static String getErrorMessage(DioException e, {String? context}) {
    final prefix = context != null ? '$context: ' : '';
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '${prefix}Connection timeout. Please check your internet connection and server address.';
      
      case DioExceptionType.sendTimeout:
        return '${prefix}Send timeout. The server is taking too long to respond.';
      
      case DioExceptionType.receiveTimeout:
        return '${prefix}Receive timeout. The server is taking too long to respond.';
      
      case DioExceptionType.badCertificate:
        return '${prefix}SSL certificate error. The server certificate is invalid.';
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        if (statusCode == 401) {
          return '${prefix}Authentication failed. Please check your username and password.';
        } else if (statusCode == 403) {
          return '${prefix}Access denied. You don\'t have permission to access this resource.';
        } else if (statusCode == 404) {
          return '${prefix}Resource not found. The requested endpoint does not exist.';
        } else if (statusCode == 500) {
          return '${prefix}Server error (500). Please try again later.';
        } else if (statusCode != null && statusCode >= 500) {
          return '${prefix}Server error ($statusCode). Please try again later.';
        }
        
        if (responseData is Map && responseData['error'] != null) {
          return '$prefix${responseData['error']}';
        }
        
        return '${prefix}Server returned error: ${statusCode ?? 'unknown'}';
      
      case DioExceptionType.cancel:
        return '${prefix}Request was cancelled.';
      
      case DioExceptionType.connectionError:
        return '${prefix}Cannot connect to server. Please check:\n'
            '• Server address and port are correct\n'
            '• Server is running\n'
            '• Network connection is active';
      
      case DioExceptionType.unknown:
        if (e.error != null) {
          return '${prefix}Connection error: ${e.error}';
        }
        return '${prefix}Unknown error occurred. Please try again.';
    }
  }
  
  /// Get detailed error information for logging
  static String getDetailedError(DioException e) {
    final buffer = StringBuffer();
    buffer.writeln('DioException Details:');
    buffer.writeln('  Type: ${e.type}');
    buffer.writeln('  Message: ${e.message}');
    buffer.writeln('  Error: ${e.error}');
    
    if (e.response != null) {
      buffer.writeln('  Response:');
      buffer.writeln('    Status Code: ${e.response!.statusCode}');
      buffer.writeln('    Status Message: ${e.response!.statusMessage}');
      buffer.writeln('    Data: ${e.response!.data}');
    }
    
    buffer.writeln('  Request:');
    buffer.writeln('    Method: ${e.requestOptions.method}');
    buffer.writeln('    URL: ${e.requestOptions.uri}');
    buffer.writeln('    Headers: ${e.requestOptions.headers}');
    
    return buffer.toString();
  }
}
