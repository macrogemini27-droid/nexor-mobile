import 'package:flutter_test/flutter_test.dart';
import 'package:nexor/core/utils/validators.dart';

void main() {
  group('ServerValidator', () {
    group('validateName', () {
      test('should return error for empty name', () {
        expect(ServerValidator.validateName(''), isNotNull);
        expect(ServerValidator.validateName(null), isNotNull);
      });

      test('should return error for name less than 3 characters', () {
        expect(ServerValidator.validateName('ab'), isNotNull);
      });

      test('should return error for name more than 50 characters', () {
        expect(
          ServerValidator.validateName('a' * 51),
          isNotNull,
        );
      });

      test('should return null for valid name', () {
        expect(ServerValidator.validateName('My Server'), isNull);
        expect(ServerValidator.validateName('abc'), isNull);
        expect(ServerValidator.validateName('a' * 50), isNull);
      });
    });

    group('validateHost', () {
      test('should return error for empty host', () {
        expect(ServerValidator.validateHost(''), isNotNull);
        expect(ServerValidator.validateHost(null), isNotNull);
      });

      test('should return null for valid IP address', () {
        expect(ServerValidator.validateHost('192.168.1.1'), isNull);
        expect(ServerValidator.validateHost('10.0.0.1'), isNull);
      });

      test('should return null for valid domain', () {
        expect(ServerValidator.validateHost('example.com'), isNull);
        expect(ServerValidator.validateHost('sub.example.com'), isNull);
      });

      test('should return null for localhost', () {
        expect(ServerValidator.validateHost('localhost'), isNull);
      });

      test('should return error for invalid host', () {
        expect(ServerValidator.validateHost('invalid'), isNotNull);
        expect(ServerValidator.validateHost('256.256.256.256'), isNotNull);
      });
    });

    group('validatePort', () {
      test('should return error for empty port', () {
        expect(ServerValidator.validatePort(''), isNotNull);
        expect(ServerValidator.validatePort(null), isNotNull);
      });

      test('should return error for non-numeric port', () {
        expect(ServerValidator.validatePort('abc'), isNotNull);
      });

      test('should return error for port out of range', () {
        expect(ServerValidator.validatePort('0'), isNotNull);
        expect(ServerValidator.validatePort('65536'), isNotNull);
      });

      test('should return null for valid port', () {
        expect(ServerValidator.validatePort('1'), isNull);
        expect(ServerValidator.validatePort('4096'), isNull);
        expect(ServerValidator.validatePort('65535'), isNull);
      });
    });

    group('validateUsername', () {
      test('should return null for empty username (optional)', () {
        expect(ServerValidator.validateUsername(''), isNull);
        expect(ServerValidator.validateUsername(null), isNull);
      });

      test('should return error for username more than 50 characters', () {
        expect(ServerValidator.validateUsername('a' * 51), isNotNull);
      });

      test('should return null for valid username', () {
        expect(ServerValidator.validateUsername('opencode'), isNull);
        expect(ServerValidator.validateUsername('a' * 50), isNull);
      });
    });

    group('validatePassword', () {
      test('should return null for empty password (optional)', () {
        expect(ServerValidator.validatePassword(''), isNull);
        expect(ServerValidator.validatePassword(null), isNull);
      });

      test('should return error for password more than 100 characters', () {
        expect(ServerValidator.validatePassword('a' * 101), isNotNull);
      });

      test('should return null for valid password', () {
        expect(ServerValidator.validatePassword('password123'), isNull);
        expect(ServerValidator.validatePassword('a' * 100), isNull);
      });
    });
  });
}
