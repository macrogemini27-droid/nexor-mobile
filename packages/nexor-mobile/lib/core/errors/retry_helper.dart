import 'dart:developer' as developer;
import 'error_types.dart';

class RetryHelper {
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    
    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        final retry = _shouldRetryError(e, shouldRetry);
        
        if (attempt >= maxAttempts || !retry) {
          developer.log('Operation failed after $attempt attempts: $e');
          rethrow;
        }
        
        developer.log('Retry attempt $attempt/$maxAttempts after ${delay.inSeconds}s: $e');
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }
  
  static bool _shouldRetryError(dynamic error, bool Function(dynamic)? custom) {
    if (custom != null) return custom(error);
    
    // Auto-retry for retryable exceptions
    if (error is AppException) return error.retryable;
    
    return false;
  }
}
