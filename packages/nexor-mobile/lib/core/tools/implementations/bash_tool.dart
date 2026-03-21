import '../../tools/tool.dart';
import '../../tools/tool_context.dart';
import '../../tools/tool_result.dart';
import '../../ssh/ssh_client.dart';

class BashTool extends Tool {
  final SSHClient sshClient;

  BashTool(this.sshClient);

  @override
  String get id => 'bash';

  @override
  String get description =>
      'Execute bash commands on the remote server. Use this to run shell commands, navigate directories, check file contents, run scripts, etc.';

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {
          'command': {
            'type': 'string',
            'description':
                'The bash command to execute on the remote server. Can be any valid shell command.',
          },
          'description': {
            'type': 'string',
            'description':
                'A brief description of what this command does (for logging purposes).',
          },
        },
        'required': ['command'],
      };

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> args,
    ToolContext context,
  ) async {
    try {
      final command = args['command'] as String;
      final description = args['description'] as String?;

      // Check permission (will be implemented in Phase 7)
      await context.checkPermission('bash', patterns: [command]);

      // Execute command via SSH
      final result = await sshClient.execute(
        command,
        workingDirectory: context.workingDirectory,
      );

      // Format output
      final output = StringBuffer();
      if (result.stdout.isNotEmpty) {
        output.writeln(result.stdout);
      }
      if (result.stderr.isNotEmpty) {
        output.writeln('STDERR:');
        output.writeln(result.stderr);
      }

      final title = description ?? 'Command: $command';

      if (result.isSuccess) {
        return ToolResult.success(
          title: title,
          output: output.toString().trim(),
          metadata: {
            'command': command,
            'exitCode': result.exitCode,
            'executionTime': result.executionTime.inMilliseconds,
          },
        );
      } else {
        return ToolResult.error(
          title: title,
          output: output.toString().trim(),
          exitCode: result.exitCode,
          metadata: {
            'command': command,
            'executionTime': result.executionTime.inMilliseconds,
          },
        );
      }
    } catch (e, stackTrace) {
      return ToolResult.error(
        title: 'Command execution failed',
        output: 'Error: $e\n\nStack trace:\n$stackTrace',
      );
    }
  }
}
