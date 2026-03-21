import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final String? title;
  final String directory;
  final String? agent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final String? lastMessage;
  final String? projectPath;

  const Session({
    required this.id,
    this.title,
    required this.directory,
    this.agent,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.lastMessage,
    this.projectPath,
  });

  String get displayTitle => title ?? 'New Conversation';

  Session copyWith({
    String? id,
    String? title,
    String? directory,
    String? agent,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    String? lastMessage,
    String? projectPath,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      directory: directory ?? this.directory,
      agent: agent ?? this.agent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      lastMessage: lastMessage ?? this.lastMessage,
      projectPath: projectPath ?? this.projectPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        directory,
        agent,
        createdAt,
        updatedAt,
        messageCount,
        lastMessage,
        projectPath,
      ];
}
