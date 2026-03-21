import '../../tools/tool.dart';
import '../../tools/tool_context.dart';
import '../../tools/tool_result.dart';
import '../../ssh/sftp_client.dart';

class ReadTool extends Tool {
  final SFTPClient sftpClient;

  ReadTool(this.sftpClient);

  @override
  String get id => 'read';

  @override
  String get description =>
      'Read a file from the remote server. Returns the file content with line numbers. Supports pagination for large files.';

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {
          'filePath': {
            'type': 'string',
            'description': 'The absolute path to the file to read',
          },
          'offset': {
            'type': 'integer',
            'description':
                'The line number to start reading from (0-indexed). Default is 0.',
          },
          'limit': {
            'type': 'integer',
            'description':
                'The maximum number of lines to read. Default is 2000.',
          },
        },
        'required': ['filePath'],
      };

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> args,
    ToolContext context,
  ) async {
    try {
      final filePath = args['filePath'] as String;
      final offset = (args['offset'] as int?) ?? 0;
      final limit = (args['limit'] as int?) ?? 2000;

      // Check permission
      await context.checkPermission('read', patterns: [filePath]);

      // Read file with pagination
      final result = await sftpClient.readFileWithPagination(
        filePath,
        offset: offset,
        limit: limit,
      );

      // Format with line numbers
      final output = StringBuffer();
      for (int i = 0; i < result.lines.length; i++) {
        final lineNumber = result.startLine + i + 1;
        output.writeln('$lineNumber: ${result.lines[i]}');
      }

      return ToolResult.success(
        title: 'File: $filePath',
        output: output.toString().trim(),
        metadata: {
          'filePath': filePath,
          'totalLines': result.totalLines,
          'startLine': result.startLine,
          'endLine': result.endLine,
          'hasMore': result.hasMore,
        },
      );
    } catch (e, stackTrace) {
      return ToolResult.error(
        title: 'Failed to read file',
        output: 'Error: $e\n\nStack trace:\n$stackTrace',
      );
    }
  }
}
