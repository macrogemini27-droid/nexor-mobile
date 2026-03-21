import 'package:hive/hive.dart';
import '../../../domain/entities/message.dart';

part 'message_model.g.dart';

@HiveType(typeId: 3)
class MessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final List<MessagePartModel>? parts;

  MessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.parts,
  });

  Message toEntity() {
    return Message(
      id: id,
      sessionId: sessionId,
      role: role,
      content: content,
      createdAt: createdAt,
      parts: parts?.map((p) => p.toEntity()).toList(),
    );
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      sessionId: message.sessionId,
      role: message.role,
      content: message.content,
      createdAt: message.createdAt,
      parts: message.parts?.map((p) => MessagePartModel.fromEntity(p)).toList(),
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      parts: json['parts'] != null
          ? (json['parts'] as List)
              .map((p) => MessagePartModel.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'role': role,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'parts': parts?.map((p) => p.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 4)
class MessagePartModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final Map<String, dynamic>? metadata;

  MessagePartModel({
    required this.id,
    required this.type,
    required this.content,
    this.metadata,
  });

  MessagePart toEntity() {
    return MessagePart(
      id: id,
      type: type,
      content: content,
      metadata: metadata,
    );
  }

  factory MessagePartModel.fromEntity(MessagePart part) {
    return MessagePartModel(
      id: part.id,
      type: part.type,
      content: part.content,
      metadata: part.metadata,
    );
  }

  factory MessagePartModel.fromJson(Map<String, dynamic> json) {
    return MessagePartModel(
      id: json['id'] as String? ?? 'unknown',
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String? ?? '',
      metadata: json['metadata'] is Map<String, dynamic> 
          ? json['metadata'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'metadata': metadata,
    };
  }
}
