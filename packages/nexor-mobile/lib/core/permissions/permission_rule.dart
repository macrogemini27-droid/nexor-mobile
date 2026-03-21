import 'package:equatable/equatable.dart';

enum PermissionAction {
  allow,
  deny,
  ask,
}

class PermissionRule extends Equatable {
  final String toolName;
  final List<String> patterns;
  final PermissionAction action;
  final DateTime createdAt;
  final bool isTemporary; // Only for current session

  const PermissionRule({
    required this.toolName,
    required this.patterns,
    required this.action,
    required this.createdAt,
    this.isTemporary = false,
  });

  PermissionRule copyWith({
    String? toolName,
    List<String>? patterns,
    PermissionAction? action,
    DateTime? createdAt,
    bool? isTemporary,
  }) {
    return PermissionRule(
      toolName: toolName ?? this.toolName,
      patterns: patterns ?? this.patterns,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
      isTemporary: isTemporary ?? this.isTemporary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toolName': toolName,
      'patterns': patterns,
      'action': action.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isTemporary': isTemporary,
    };
  }

  factory PermissionRule.fromJson(Map<String, dynamic> json) {
    return PermissionRule(
      toolName: json['toolName'] as String,
      patterns: (json['patterns'] as List).cast<String>(),
      action: PermissionAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => PermissionAction.ask,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      isTemporary: json['isTemporary'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [toolName, patterns, action, createdAt, isTemporary];

  @override
  String toString() {
    return 'PermissionRule(tool: $toolName, action: $action, patterns: $patterns)';
  }
}
