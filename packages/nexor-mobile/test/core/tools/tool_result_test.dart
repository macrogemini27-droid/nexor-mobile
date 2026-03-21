import 'package:flutter_test/flutter_test.dart';
import 'package:nexor/core/tools/tool_result.dart';

void main() {
  group('ToolResult', () {
    group('Success Results', () {
      test('should create success result with all fields', () {
        final result = ToolResult.success(
          title: 'Test Success',
          output: 'Test output',
          metadata: {'key': 'value'},
        );

        expect(result.isSuccess, isTrue);
        expect(result.title, 'Test Success');
        expect(result.output, 'Test output');
        expect(result.exitCode, 0);
        expect(result.metadata, {'key': 'value'});
      });

      test('should create success result with minimal fields', () {
        final result = ToolResult.success(
          title: 'Success',
          output: 'Done',
        );

        expect(result.isSuccess, isTrue);
        expect(result.title, 'Success');
        expect(result.output, 'Done');
        expect(result.exitCode, 0);
        expect(result.metadata, isNull);
      });

      test('should have exit code 0 for success', () {
        final result = ToolResult.success(
          title: 'Success',
          output: 'Done',
        );

        expect(result.exitCode, 0);
      });
    });

    group('Error Results', () {
      test('should create error result with all fields', () {
        final result = ToolResult.error(
          title: 'Test Error',
          output: 'Error details',
          exitCode: 1,
          metadata: {'error': 'details'},
        );

        expect(result.isSuccess, isFalse);
        expect(result.title, 'Test Error');
        expect(result.output, 'Error details');
        expect(result.exitCode, 1);
        expect(result.metadata, {'error': 'details'});
      });

      test('should create error result with minimal fields', () {
        final result = ToolResult.error(
          title: 'Error',
          output: 'Failed',
        );

        expect(result.isSuccess, isFalse);
        expect(result.title, 'Error');
        expect(result.output, 'Failed');
        expect(result.exitCode, 1);
        expect(result.metadata, isNull);
      });

      test('should have non-zero exit code for error', () {
        final result = ToolResult.error(
          title: 'Error',
          output: 'Failed',
          exitCode: 127,
        );

        expect(result.exitCode, 127);
        expect(result.isSuccess, isFalse);
      });

      test('should default to exit code 1 for error', () {
        final result = ToolResult.error(
          title: 'Error',
          output: 'Failed',
        );

        expect(result.exitCode, 1);
      });
    });

    group('Metadata', () {
      test('should store complex metadata', () {
        final result = ToolResult.success(
          title: 'Success',
          output: 'Done',
          metadata: {
            'command': 'ls -la',
            'executionTime': 123,
            'files': ['file1.txt', 'file2.txt'],
            'nested': {
              'key': 'value',
            },
          },
        );

        expect(result.metadata['command'], 'ls -la');
        expect(result.metadata['executionTime'], 123);
        expect(result.metadata['files'], isA<List>());
        expect(result.metadata['nested'], isA<Map>());
      });

      test('should handle null metadata', () {
        final result = ToolResult.success(
          title: 'Success',
          output: 'Done',
        );

        expect(result.metadata, isNull);
      });

      test('should handle empty metadata', () {
        final result = ToolResult.success(
          title: 'Success',
          output: 'Done',
          metadata: {},
        );

        expect(result.metadata, isEmpty);
      });
    });

    group('Output Handling', () {
      test('should handle empty output', () {
        final result = ToolResult.success(
          title: 'Success',
          output: '',
        );

        expect(result.output, isEmpty);
      });

      test('should handle multiline output', () {
        final output = '''
Line 1
Line 2
Line 3
''';
        final result = ToolResult.success(
          title: 'Success',
          output: output,
        );

        expect(result.output, contains('Line 1'));
        expect(result.output, contains('Line 2'));
        expect(result.output, contains('Line 3'));
      });

      test('should handle special characters in output', () {
        final result = ToolResult.success(
          title: 'Success',
          output: 'Special chars: \n\t\r\$\'"',
        );

        expect(result.output, contains('\n'));
        expect(result.output, contains('\t'));
        expect(result.output, contains('\$'));
      });
    });

    group('Title Handling', () {
      test('should handle empty title', () {
        final result = ToolResult.success(
          title: '',
          output: 'Output',
        );

        expect(result.title, isEmpty);
      });

      test('should handle long title', () {
        final longTitle = 'A' * 1000;
        final result = ToolResult.success(
          title: longTitle,
          output: 'Output',
        );

        expect(result.title.length, 1000);
      });
    });

    group('Equality', () {
      test('should be equal with same values', () {
        final result1 = ToolResult.success(
          title: 'Success',
          output: 'Done',
        );

        final result2 = ToolResult.success(
          title: 'Success',
          output: 'Done',
        );

        expect(result1.title, result2.title);
        expect(result1.output, result2.output);
        expect(result1.isSuccess, result2.isSuccess);
        expect(result1.exitCode, result2.exitCode);
      });

      test('should be different with different values', () {
        final result1 = ToolResult.success(
          title: 'Success',
          output: 'Done',
        );

        final result2 = ToolResult.error(
          title: 'Error',
          output: 'Failed',
        );

        expect(result1.isSuccess, isNot(result2.isSuccess));
        expect(result1.title, isNot(result2.title));
      });
    });
  });
}
