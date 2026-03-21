import '../../tools/tool.dart';
import '../../tools/tool_context.dart';
import '../../tools/tool_result.dart';
import '../../ssh/sftp_client.dart';

class WriteTool extends Tool {
  final SFTPClient sftpClient;

  WriteTool(this.sftpClient);

  @override
  String get id => 'write';

  @override
  String get description =>
      'Write content to a file on the remote server. Creates the file if it doesn\'t exist, or overwrites it if it does.';

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {
          'filePath': {
            'type': 'string',
            'description': 'The absolute path to the file to write',
          },
          'content': {
            'type': 'string',
            'description': 'The content to write to the file',
          },
        },
        'required': ['filePath', 'content'],
      };

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> args,
    ToolContext context,
  ) async {
    try {
      final filePath = args['filePath'] as String;
      final content = args['content'] as String;

      // Check permission
      await context.checkPermission('write', patterns: [filePath]);

      // Write file
      await sftpClient.writeFile(filePath, content);

      final lines = content.split('\n').length;

      return ToolResult.success(
        title: 'Written: $filePath',
        output: 'Successfully wrote $lines lines to $filePath',
        metadata: {
          'filePath': filePath,
          'lines': lines,
          'bytes': content.length,
        },
      );
    } catch (e, stackTrace) {
      return ToolResult.error(
        title: 'Failed to write file',
        output: 'Error: $e\n\nStack trace:\n$stackTrace',
      );
    }
  }
}
