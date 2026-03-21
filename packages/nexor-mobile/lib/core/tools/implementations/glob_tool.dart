import '../../tools/tool.dart';
import '../../tools/tool_context.dart';
import '../../tools/tool_result.dart';
import '../../ssh/ssh_client.dart';

class GlobTool extends Tool {
  final SSHClient sshClient;

  GlobTool(this.sshClient);

  @override
  String get id => 'glob';

  @override
  String get description =>
      'Search for files matching a pattern on the remote server. Uses find command with glob patterns.';

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {
          'pattern': {
            'type': 'string',
            'description':
                'The glob pattern to match files (e.g., "*.dart", "**/*.js")',
          },
          'path': {
            'type': 'string',
            'description':
                'The directory to search in. Defaults to current working directory.',
          },
        },
        'required': ['pattern'],
      };

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> args,
    ToolContext context,
  ) async {
    try {
      final pattern = args['pattern'] as String;
      final searchPath = args['path'] as String? ?? '.';

      // Build find command
      final command = 'find "$searchPath" -name "$pattern" -type f 2>/dev/null';

      // Execute via SSH
      final result = await sshClient.execute(
        command,
        workingDirectory: context.workingDirectory,
      );

      if (result.isSuccess) {
        final files = result.stdout
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();

        return ToolResult.success(
          title: 'Files matching: $pattern',
          output: files.isEmpty
              ? 'No files found matching pattern "$pattern"'
              : files.join('\n'),
          metadata: {
            'pattern': pattern,
            'searchPath': searchPath,
            'fileCount': files.length,
          },
        );
      } else {
        return ToolResult.error(
          title: 'Glob search failed',
          output: result.stderr.isNotEmpty ? result.stderr : result.stdout,
          exitCode: result.exitCode,
        );
      }
    } catch (e, stackTrace) {
      return ToolResult.error(
        title: 'Failed to search files',
        output: 'Error: $e\n\nStack trace:\n$stackTrace',
      );
    }
  }
}
