import '../../tools/tool.dart';
import '../../tools/tool_context.dart';
import '../../tools/tool_result.dart';
import '../../ssh/sftp_client.dart';

class EditTool extends Tool {
  final SFTPClient sftpClient;

  EditTool(this.sftpClient);

  @override
  String get id => 'edit';

  @override
  String get description =>
      'Edit specific lines in a file on the remote server. Performs exact string replacements on specified lines.';

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {
          'filePath': {
            'type': 'string',
            'description': 'The absolute path to the file to edit',
          },
          'oldString': {
            'type': 'string',
            'description': 'The exact string to find and replace',
          },
          'newString': {
            'type': 'string',
            'description': 'The string to replace it with',
          },
          'replaceAll': {
            'type': 'boolean',
            'description':
                'If true, replace all occurrences. If false, replace only the first occurrence. Default is false.',
          },
        },
        'required': ['filePath', 'oldString', 'newString'],
      };

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> args,
    ToolContext context,
  ) async {
    try {
      final filePath = args['filePath'] as String;
      final oldString = args['oldString'] as String;
      final newString = args['newString'] as String;
      final replaceAll = (args['replaceAll'] as bool?) ?? false;

      // Check permission
      await context.checkPermission('edit', patterns: [filePath]);

      // Read current content
      final content = await sftpClient.readFile(filePath);

      // Perform replacement
      String newContent;
      int replacements;

      if (replaceAll) {
        newContent = content.replaceAll(oldString, newString);
        replacements = oldString.allMatches(content).length;
      } else {
        newContent = content.replaceFirst(oldString, newString);
        replacements = content.contains(oldString) ? 1 : 0;
      }

      if (replacements == 0) {
        return ToolResult.error(
          title: 'Edit failed',
          output: 'Could not find "$oldString" in file $filePath',
        );
      }

      // Write back
      await sftpClient.writeFile(filePath, newContent);

      return ToolResult.success(
        title: 'Edited: $filePath',
        output:
            'Successfully replaced $replacements occurrence(s) of "$oldString" with "$newString"',
        metadata: {
          'filePath': filePath,
          'replacements': replacements,
          'replaceAll': replaceAll,
        },
      );
    } catch (e, stackTrace) {
      return ToolResult.error(
        title: 'Failed to edit file',
        output: 'Error: $e\n\nStack trace:\n$stackTrace',
      );
    }
  }
}
