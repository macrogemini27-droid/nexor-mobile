import 'package:equatable/equatable.dart';
import '../permissions/permission_service.dart';

class ToolContext extends Equatable {
  final String sessionId;
  final String workingDirectory;
  final Map<String, dynamic> metadata;
  final PermissionService? permissionService;
  final Future<bool> Function()? onPermissionRequest;

  const ToolContext({
    required this.sessionId,
    required this.workingDirectory,
    this.metadata = const {},
    this.permissionService,
    this.onPermissionRequest,
  });

  ToolContext copyWith({
    String? sessionId,
    String? workingDirectory,
    Map<String, dynamic>? metadata,
    PermissionService? permissionService,
    Future<bool> Function()? onPermissionRequest,
  }) {
    return ToolContext(
      sessionId: sessionId ?? this.sessionId,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      metadata: metadata ?? this.metadata,
      permissionService: permissionService ?? this.permissionService,
      onPermissionRequest: onPermissionRequest ?? this.onPermissionRequest,
    );
  }

  // Permission checking method
  Future<void> checkPermission(String toolName, {List<String>? patterns}) async {
    if (permissionService == null || onPermissionRequest == null) {
      // No permission service configured, allow by default
      return;
    }

    final allowed = await permissionService!.checkPermission(
      toolName,
      patterns ?? [],
      onAsk: onPermissionRequest!,
    );

    if (!allowed) {
      throw Exception('Permission denied for tool: $toolName');
    }
  }

  @override
  List<Object?> get props => [
        sessionId,
        workingDirectory,
        metadata,
        permissionService,
        onPermissionRequest,
      ];
}
