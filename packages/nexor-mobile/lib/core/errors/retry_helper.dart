import 'dart:developer' as developer;
import 'error_types.dart';

class RetryHelper {
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 1; // Start at 1 for clearer logging
    Duration delay = initialDelay;
    
    while (true) {
      try {
        return await operation();
      } catch (e) {
        final retry = _shouldRetryError(e, shouldRetry);
        
        if (attempt >= maxAttempts || !retry) {
          developer.log('Operation failed after $attempt attempt${attempt > 1 ? 's' : ''}: $e');
          rethrow;
        }
        
        developer.log('Retry attempt $attempt/$maxAttempts after ${delay.inSeconds}s: $e');
        await Future.delayed(delay);
        
        // Exponential backoff with max delay cap
        delay = Duration(milliseconds: (delay.inMilliseconds * 2).clamp(0, maxDelay.inMilliseconds));
        attempt++;
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
