import 'package:hive/hive.dart';
import '../../../domain/entities/session.dart';

part 'session_model.g.dart';

@HiveType(typeId: 2)
class SessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? title;

  @HiveField(2)
  final String directory;

  @HiveField(3)
  final String? agent;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final int messageCount;

  @HiveField(7)
  final String? lastMessage;

  @HiveField(8)
  final String? projectPath;

  SessionModel({
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

  Session toEntity() {
    return Session(
      id: id,
      title: title,
      directory: directory,
      agent: agent,
      createdAt: createdAt,
      updatedAt: updatedAt,
      messageCount: messageCount,
      lastMessage: lastMessage,
      projectPath: projectPath,
    );
  }

  factory SessionModel.fromEntity(Session session) {
    return SessionModel(
      id: session.id,
      title: session.title,
      directory: session.directory,
      agent: session.agent,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      messageCount: session.messageCount,
      lastMessage: session.lastMessage,
      projectPath: session.projectPath,
    );
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      title: json['title'] as String?,
      directory: json['directory'] as String,
      agent: json['agent'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messageCount: json['messageCount'] as int? ?? 0,
      lastMessage: json['lastMessage'] as String?,
      projectPath: json['projectPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'directory': directory,
      'agent': agent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messageCount': messageCount,
      'lastMessage': lastMessage,
      'projectPath': projectPath,
    };
  }
}
