# Error Handling Migration Guide

## Summary of Changes

The file explorer now has comprehensive error handling with:

- ✅ Specific error types for different failure scenarios
- ✅ Automatic retry logic with exponential backoff
- ✅ User-friendly error messages and recovery actions
- ✅ No silent failures - all errors are properly logged and displayed

## Files Modified

### Core Error Framework (New)

- `lib/core/errors/error_types.dart` - Typed exceptions
- `lib/core/errors/error_handler.dart` - System exception converter
- `lib/core/errors/retry_helper.dart` - Retry logic with backoff
- `lib/core/errors/errors.dart` - Export file

### Updated Files

- `lib/core/ssh/sftp_client.dart` - Uses typed exceptions
- `lib/core/ssh/path_validator.dart` - Uses PathValidationException
- `lib/data/repositories/file_repository_impl.dart` - Retry logic + typed errors
- `lib/presentation/widgets/error_display.dart` - Smart error UI (New)
- `lib/presentation/screens/files/file_browser_screen.dart` - Uses ErrorDisplay
- `lib/presentation/screens/files/file_viewer_screen.dart` - Uses ErrorDisplay
- `lib/presentation/screens/files/file_search_screen.dart` - Uses ErrorDisplay

## Error Flow

```
User Action
    ↓
UI Layer (Screen)
    ↓
Provider (Riverpod)
    ↓
Repository (with RetryHelper)
    ↓
SFTP/SSH Client (throws typed exceptions)
    ↓
ErrorHandler.handle() (converts system errors)
    ↓
Back to UI (ErrorDisplay widget)
    ↓
User sees: Message + Retry/Reconnect/Dismiss buttons
```

## Error Types & User Actions

| Error Type              | Retryable | User Action       |
| ----------------------- | --------- | ----------------- |
| NetworkException        | ✅ Yes    | Retry button      |
| ConnectionException     | ✅ Yes    | Retry + Reconnect |
| TimeoutException        | ✅ Yes    | Retry button      |
| SftpException           | ✅ Yes    | Retry button      |
| AuthException           | ❌ No     | Reconnect button  |
| FileNotFoundException   | ❌ No     | Go back           |
| PermissionException     | ❌ No     | Go back           |
| BinaryFileException     | ❌ No     | Go back           |
| PathValidationException | ❌ No     | Go back           |

## Retry Behavior

### Default Settings

- Max attempts: 3
- Initial delay: 1 second
- Backoff: Exponential (1s → 2s → 4s)

### Customization

```dart
await RetryHelper.withRetry(
  operation,
  maxAttempts: 5,
  initialDelay: Duration(milliseconds: 500),
  shouldRetry: (error) => /* custom logic */,
);
```

## Testing

Run the error handling tests:

```bash
cd packages/nexor-mobile
flutter test test/core/errors/error_handling_test.dart
```

## Benefits

### For Users

- Clear error messages explaining what went wrong
- Automatic retry for temporary failures
- Appropriate actions (retry, reconnect, go back)
- No confusing technical jargon

### For Developers

- Type-safe error handling
- Consistent error patterns across the app
- Easy to add new error types
- Comprehensive logging for debugging

### For Operations

- Reduced support tickets (clearer errors)
- Better error tracking and monitoring
- Automatic recovery from transient failures
- Detailed logs for troubleshooting

## Examples

### Before

```dart
try {
  final files = await repository.listFiles(serverId, path);
} catch (e) {
  // Generic error, no retry, unclear message
  throw Exception('Failed to list files: $e');
}
```

### After

```dart
try {
  return await RetryHelper.withRetry(
    () async {
      if (!_sshClient.isConnected) {
        throw ConnectionException('Not connected to SSH server');
      }
      // operation
    },
    maxAttempts: 3,
  );
} catch (e, stack) {
  throw ErrorHandler.handle(e, context: 'listFiles');
}
```

## UI Integration

### Before

```dart
error: (error, stack) => Text('Error: $error'),
```

### After

```dart
error: (error, stack) {
  return ErrorDisplay(
    error: error,
    onRetry: error is AppException && error.retryable
        ? () => ref.invalidate(provider)
        : null,
    onReconnect: error is ConnectionException || error is AuthException
        ? () => context.go('/servers')
        : null,
    onDismiss: () => context.pop(),
  );
},
```

## Future Enhancements

Potential improvements:

- [ ] Error analytics/tracking
- [ ] Offline mode support
- [ ] Circuit breaker pattern
- [ ] Rate limiting
- [ ] Error recovery strategies per error type
- [ ] User preference for retry attempts
