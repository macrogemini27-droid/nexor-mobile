import '../../tools/tool.dart';
import '../../tools/tool_context.dart';
import '../../tools/tool_result.dart';
import '../../ssh/ssh_client.dart';

class GrepTool extends Tool {
  final SSHClient sshClient;

  GrepTool(this.sshClient);

  @override
  String get id => 'grep';

  @override
  String get description =>
      'Search for text patterns in files on the remote server. Uses grep command with regex support.';

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {
          'pattern': {
            'type': 'string',
            'description':
                'The regex pattern to search for in file contents',
          },
          'include': {
            'type': 'string',
            'description':
                'File pattern to include in search (e.g., "*.dart", "*.{js,ts}")',
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
      final include = args['include'] as String?;
      final searchPath = args['path'] as String? ?? '.';

      // Build grep command
      var command = 'grep -rn "$pattern" "$searchPath"';
      if (include != null) {
        command += ' --include="$include"';
      }
      command += ' 2>/dev/null';

      // Execute via SSH
      final result = await sshClient.execute(
        command,
        workingDirectory: context.workingDirectory,
      );

      // grep returns exit code 1 when no matches found, which is not an error
      if (result.exitCode == 0 || result.exitCode == 1) {
        final matches = result.stdout
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();

        return ToolResult.success(
          title: 'Search results: $pattern',
          output: matches.isEmpty
              ? 'No matches found for pattern "$pattern"'
              : matches.join('\n'),
          metadata: {
            'pattern': pattern,
            'include': include,
            'searchPath': searchPath,
            'matchCount': matches.length,
          },
        );
      } else {
        return ToolResult.error(
          title: 'Grep search failed',
          output: result.stderr.isNotEmpty ? result.stderr : result.stdout,
          exitCode: result.exitCode,
        );
      }
    } catch (e, stackTrace) {
      return ToolResult.error(
        title: 'Failed to search content',
        output: 'Error: $e\n\nStack trace:\n$stackTrace',
      );
    }
  }
}
