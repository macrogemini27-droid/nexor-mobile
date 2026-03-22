# Error Handling Framework

Comprehensive error handling system for the file explorer with automatic retry logic, specific error types, and user-friendly error displays.

## Architecture

### Error Types (`error_types.dart`)

All application errors extend `AppException` with:

- `message`: User-friendly error message
- `details`: Technical details (optional)
- `retryable`: Whether the operation can be retried

**Available Error Types:**

- `NetworkException` - Network connectivity issues (retryable)
- `ConnectionException` - SSH/SFTP connection failures (retryable)
- `AuthException` - Authentication failures (not retryable, needs reconnect)
- `TimeoutException` - Operation timeouts (retryable)
- `SftpException` - SFTP operation failures (retryable)
- `FileNotFoundException` - File not found (not retryable)
- `PermissionException` - Permission denied (not retryable)
- `BinaryFileException` - Binary file cannot be displayed (not retryable)
- `PathValidationException` - Invalid path (not retryable)

### Error Handler (`error_handler.dart`)

Converts system exceptions to typed `AppException`:

```dart
try {
  // operation
} catch (e) {
  throw ErrorHandler.handle(e, context: 'operation name');
}
```

Handles:

- `SocketException` → `NetworkException`
- `TimeoutException` → `TimeoutException`
- `FileSystemException` → `FileNotFoundException` or `PermissionException`
- `SftpError` → Specific error based on message

### Retry Helper (`retry_helper.dart`)

Automatic retry with exponential backoff:

```dart
final result = await RetryHelper.withRetry(
  () async {
    // operation that might fail
  },
  maxAttempts: 3,
  initialDelay: Duration(seconds: 1),
);
```

Features:

- Exponential backoff (1s, 2s, 4s, ...)
- Auto-retry for retryable errors
- Custom retry logic via `shouldRetry` callback

## Usage

### In Repositories

```dart
@override
Future<List<FileNode>> listFiles(String serverId, String path) async {
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
}
```

### In SFTP Client

```dart
Future<String> readFile(String filePath) async {
  try {
    // operation
  } on TimeoutException {
    throw TimeoutException('file read');
  } catch (e) {
    throw ErrorHandler.handle(e, context: 'readFile');
  }
}
```

### In UI (Screens)

```dart
filesAsync.when(
  data: (files) => /* display files */,
  loading: () => LoadingIndicator(),
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
);
```

## Error Display Widget

The `ErrorDisplay` widget automatically:

- Shows appropriate icon and message for each error type
- Displays retry button for retryable errors
- Shows reconnect button for connection/auth errors
- Provides dismiss/go back action
- Includes technical details when available

## Benefits

1. **User Experience**
   - Clear, actionable error messages
   - Automatic retry for transient failures
   - Appropriate recovery actions

2. **Developer Experience**
   - Type-safe error handling
   - Consistent error patterns
   - Easy to add new error types

3. **Reliability**
   - Automatic retry with backoff
   - No silent failures
   - Comprehensive error logging

4. **Maintainability**
   - Centralized error handling
   - Reusable across the app
   - Easy to test

## Testing

Run tests:

```bash
flutter test test/core/errors/error_handling_test.dart
```

Tests cover:

- Error type properties
- Error handler conversions
- Retry logic and backoff
- Integration scenarios
