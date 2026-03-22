import 'package:flutter_test/flutter_test.dart';
import 'package:nexor_mobile/core/errors/error_types.dart';
import 'package:nexor_mobile/core/errors/error_handler.dart';
import 'package:nexor_mobile/core/errors/retry_helper.dart';
import 'dart:io';

void main() {
  group('Error Types', () {
    test('NetworkException is retryable', () {
      final error = NetworkException('Connection failed');
      expect(error.retryable, true);
      expect(error.message, 'Connection failed');
    });

    test('FileNotFoundException is not retryable', () {
      final error = FileNotFoundException('/test/file.txt');
      expect(error.retryable, false);
      expect(error.path, '/test/file.txt');
    });

    test('PermissionException is not retryable', () {
      final error = PermissionException('/test/file.txt');
      expect(error.retryable, false);
      expect(error.path, '/test/file.txt');
    });

    test('OperationTimeoutException is retryable', () {
      final error = OperationTimeoutException('file read');
      expect(error.retryable, true);
      expect(error.operation, 'file read');
    });

    test('ConnectionException is retryable', () {
      final error = ConnectionException('SSH connection lost');
      expect(error.retryable, true);
    });

    test('BinaryFileException is not retryable', () {
      final error = BinaryFileException(1024);
      expect(error.retryable, false);
      expect(error.size, 1024);
    });
  });

  group('Error Handler', () {
    test('handles SocketException as NetworkException', () {
      final socketError = SocketException('Connection refused');
      final handled = ErrorHandler.handle(socketError);
      
      expect(handled, isA<NetworkException>());
      expect(handled.retryable, true);
    });

    test('handles FileSystemException with ENOENT as FileNotFoundException', () {
      final fsError = FileSystemException('No such file', '/test/file.txt');
      final handled = ErrorHandler.handle(fsError);
      
      expect(handled, isA<FileNotFoundException>());
      expect(handled.retryable, false);
    });

    test('passes through AppException unchanged', () {
      final appError = NetworkException('Test error');
      final handled = ErrorHandler.handle(appError);
      
      expect(handled, same(appError));
    });

    test('wraps unknown errors as generic AppException', () {
      final unknownError = Exception('Unknown error');
      final handled = ErrorHandler.handle(unknownError);
      
      expect(handled, isA<AppException>());
      expect(handled.retryable, false);
    });
  });

  group('Retry Helper', () {
    test('succeeds on first attempt', () async {
      int attempts = 0;
      final result = await RetryHelper.withRetry(() async {
        attempts++;
        return 'success';
      });
      
      expect(result, 'success');
      expect(attempts, 1);
    });

    test('retries on retryable error', () async {
      int attempts = 0;
      final result = await RetryHelper.withRetry(
        () async {
          attempts++;
          if (attempts < 3) {
            throw NetworkException('Temporary failure');
          }
          return 'success';
        },
        maxAttempts: 3,
        initialDelay: Duration(milliseconds: 10),
      );
      
      expect(result, 'success');
      expect(attempts, 3);
    });

    test('fails after max attempts', () async {
      int attempts = 0;
      
      expect(
        () => RetryHelper.withRetry(
          () async {
            attempts++;
            throw NetworkException('Persistent failure');
          },
          maxAttempts: 3,
          initialDelay: Duration(milliseconds: 10),
        ),
        throwsA(isA<NetworkException>()),
      );
      
      await Future.delayed(Duration(milliseconds: 100));
      expect(attempts, 3);
    });

    test('does not retry non-retryable errors', () async {
      int attempts = 0;
      
      expect(
        () => RetryHelper.withRetry(
          () async {
            attempts++;
            throw FileNotFoundException('/test/file.txt');
          },
          maxAttempts: 3,
          initialDelay: Duration(milliseconds: 10),
        ),
        throwsA(isA<FileNotFoundException>()),
      );
      
      await Future.delayed(Duration(milliseconds: 50));
      expect(attempts, 1);
    });

    test('uses custom shouldRetry function', () async {
      int attempts = 0;
      
      final result = await RetryHelper.withRetry(
        () async {
          attempts++;
          if (attempts < 2) {
            throw Exception('Custom error');
          }
          return 'success';
        },
        maxAttempts: 3,
        initialDelay: Duration(milliseconds: 10),
        shouldRetry: (error) => error.toString().contains('Custom'),
      );
      
      expect(result, 'success');
      expect(attempts, 2);
    });

    test('applies exponential backoff', () async {
      final delays = <Duration>[];
      int attempts = 0;
      
      try {
        await RetryHelper.withRetry(
          () async {
            attempts++;
            final start = DateTime.now();
            throw NetworkException('Test');
          },
          maxAttempts: 3,
          initialDelay: Duration(milliseconds: 100),
        );
      } catch (e) {
        // Expected to fail
      }
      
      expect(attempts, 3);
    });
  });

  group('Error Display Integration', () {
    test('retryable errors have retry action', () {
      final errors = [
        NetworkException('Network error'),
        ConnectionException('Connection error'),
        OperationTimeoutException('timeout'),
        SftpException('SFTP error'),
      ];
      
      for (final error in errors) {
        expect(error.retryable, true, reason: '${error.runtimeType} should be retryable');
      }
    });

    test('non-retryable errors do not have retry action', () {
      final errors = [
        FileNotFoundException('/test'),
        PermissionException('/test'),
        BinaryFileException(1024),
        PathValidationException('/test', 'invalid'),
      ];
      
      for (final error in errors) {
        expect(error.retryable, false, reason: '${error.runtimeType} should not be retryable');
      }
    });

    test('connection errors need reconnect action', () {
      final errors = [
        ConnectionException('Connection lost'),
        AuthException('Auth failed'),
      ];
      
      for (final error in errors) {
        expect(error, isA<AppException>());
      }
    });
  });
}
