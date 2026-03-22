import 'package:flutter_test/flutter_test.dart';
import 'package:nexor_mobile/core/ssh/path_validator.dart';

void main() {
  group('PathValidator', () {
    const allowedRoot = '/home/user';

    group('validatePath', () {
      test('accepts valid paths within allowed root', () {
        expect(
          PathValidator.validatePath('/home/user/file.txt', allowedRoot),
          '/home/user/file.txt',
        );
        expect(
          PathValidator.validatePath('/home/user/dir/file.txt', allowedRoot),
          '/home/user/dir/file.txt',
        );
        expect(
          PathValidator.validatePath('/home/user/', allowedRoot),
          '/home/user',
        );
      });

      test('rejects path traversal with ..', () {
        expect(
          () => PathValidator.validatePath('/home/user/../etc/passwd', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('../etc/passwd', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('../../etc/passwd', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('/home/user/..', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('rejects absolute paths outside allowed root', () {
        expect(
          () => PathValidator.validatePath('/etc/shadow', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('/etc/passwd', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('/root/.ssh/id_rsa', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('/var/log/auth.log', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('rejects paths that resolve outside allowed root', () {
        expect(
          () => PathValidator.validatePath('/home/user/../../etc/passwd', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('/home/user/../../../root/.ssh/id_rsa', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('rejects relative paths with traversal', () {
        expect(
          () => PathValidator.validatePath('../../../etc/shadow', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('../../root/.bashrc', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('handles paths with multiple slashes', () {
        expect(
          PathValidator.validatePath('/home/user//file.txt', allowedRoot),
          '/home/user/file.txt',
        );
        expect(
          PathValidator.validatePath('/home/user///dir//file.txt', allowedRoot),
          '/home/user/dir/file.txt',
        );
      });

      test('handles trailing slashes', () {
        expect(
          PathValidator.validatePath('/home/user/dir/', allowedRoot),
          '/home/user/dir',
        );
        expect(
          PathValidator.validatePath('/home/user/dir///', allowedRoot),
          '/home/user/dir',
        );
      });

      test('rejects empty path components with ..', () {
        expect(
          () => PathValidator.validatePath('/home/user/./../etc/passwd', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('accepts root path', () {
        expect(
          PathValidator.validatePath('/home/user', allowedRoot),
          '/home/user',
        );
      });

      test('rejects path exactly at parent of allowed root', () {
        expect(
          () => PathValidator.validatePath('/home', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('handles backslashes (Windows-style paths)', () {
        expect(
          PathValidator.validatePath('/home/user\\file.txt', allowedRoot),
          '/home/user/file.txt',
        );
      });

      test('rejects sophisticated traversal attempts', () {
        // URL encoded ..
        expect(
          () => PathValidator.validatePath('/home/user/%2e%2e/etc/passwd', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        
        // Mixed separators
        expect(
          () => PathValidator.validatePath('/home/user\\..\\etc\\passwd', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });
    });

    group('sanitizePath', () {
      test('normalizes path separators', () {
        expect(
          PathValidator.sanitizePath('home\\user\\file.txt'),
          '/home/user/file.txt',
        );
      });

      test('removes duplicate slashes', () {
        expect(
          PathValidator.sanitizePath('/home//user///file.txt'),
          '/home/user/file.txt',
        );
      });

      test('removes trailing slash', () {
        expect(
          PathValidator.sanitizePath('/home/user/'),
          '/home/user',
        );
      });

      test('handles empty path', () {
        expect(
          PathValidator.sanitizePath(''),
          '/',
        );
      });

      test('preserves root slash', () {
        expect(
          PathValidator.sanitizePath('/'),
          '/',
        );
      });
    });

    group('validatePaths', () {
      test('validates multiple paths', () {
        final paths = [
          '/home/user/file1.txt',
          '/home/user/file2.txt',
          '/home/user/dir/file3.txt',
        ];
        final validated = PathValidator.validatePaths(paths, allowedRoot);
        expect(validated.length, 3);
        expect(validated[0], '/home/user/file1.txt');
        expect(validated[1], '/home/user/file2.txt');
        expect(validated[2], '/home/user/dir/file3.txt');
      });

      test('throws on first invalid path', () {
        final paths = [
          '/home/user/file1.txt',
          '/etc/passwd',
          '/home/user/file2.txt',
        ];
        expect(
          () => PathValidator.validatePaths(paths, allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });
    });

    group('isSafePath', () {
      test('returns true for safe paths', () {
        expect(
          PathValidator.isSafePath('/home/user/file.txt', allowedRoot),
          true,
        );
      });

      test('returns false for unsafe paths', () {
        expect(
          PathValidator.isSafePath('/etc/passwd', allowedRoot),
          false,
        );
        expect(
          PathValidator.isSafePath('../../../etc/shadow', allowedRoot),
          false,
        );
      });
    });

    group('real-world attack scenarios', () {
      test('prevents reading /etc/shadow', () {
        expect(
          () => PathValidator.validatePath('/etc/shadow', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('prevents reading /etc/passwd', () {
        expect(
          () => PathValidator.validatePath('/etc/passwd', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('prevents reading SSH keys', () {
        expect(
          () => PathValidator.validatePath('/root/.ssh/id_rsa', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('/home/user/../../root/.ssh/id_rsa', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('prevents writing to system files', () {
        expect(
          () => PathValidator.validatePath('/etc/crontab', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('/etc/sudoers', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('prevents deleting log files', () {
        expect(
          () => PathValidator.validatePath('/var/log/auth.log', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
        expect(
          () => PathValidator.validatePath('/var/log/syslog', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });

      test('prevents accessing other users home directories', () {
        expect(
          () => PathValidator.validatePath('/home/otheruser/.bashrc', allowedRoot),
          throwsA(isA<SecurityException>()),
        );
      });
    });
  });
}
