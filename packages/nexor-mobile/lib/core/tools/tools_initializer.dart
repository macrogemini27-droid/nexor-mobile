import '../tools/tool_registry.dart';
import '../tools/implementations/bash_tool.dart';
import '../tools/implementations/read_tool.dart';
import '../tools/implementations/write_tool.dart';
import '../tools/implementations/edit_tool.dart';
import '../tools/implementations/glob_tool.dart';
import '../tools/implementations/grep_tool.dart';
import '../ssh/ssh_client.dart';
import '../ssh/sftp_client.dart';

/// Initialize and register all available tools
class ToolsInitializer {
  static ToolRegistry initializeTools(SSHClient sshClient) {
    final registry = ToolRegistry();
    final sftpClient = SFTPClient(sshClient, allowedRoot: '/home');

    // Register SSH/Command Tools
    registry.register(BashTool(sshClient));
    registry.register(GlobTool(sshClient));
    registry.register(GrepTool(sshClient));

    // Register File Operation Tools
    registry.register(ReadTool(sftpClient));
    registry.register(WriteTool(sftpClient));
    registry.register(EditTool(sftpClient));

    // ✅ Permission checks are already integrated in all tools via ToolContext.checkPermission()

    return registry;
  }
}
