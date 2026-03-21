import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final DateTime createdAt;
  final List<MessagePart>? parts;

  const Message({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.parts,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  Message copyWith({
    String? id,
    String? sessionId,
    String? role,
    String? content,
    DateTime? createdAt,
    List<MessagePart>? parts,
  }) {
    return Message(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      parts: parts ?? this.parts,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        role,
        content,
        createdAt,
        parts,
      ];
}

class MessagePart extends Equatable {
  final String id;
  final String type;
  final String content;
  final Map<String, dynamic>? metadata;

  const MessagePart({
    required this.id,
    required this.type,
    required this.content,
    this.metadata,
  });

  bool get isText => type == 'text';
  bool get isCode => type == 'code';
  bool get isDiff => type == 'diff';
  bool get isToolUse => type == 'tool_use';

  String? get language => metadata?['language'] as String?;
  String? get fileName => metadata?['fileName'] as String?;

  @override
  List<Object?> get props => [id, type, content, metadata];
}
