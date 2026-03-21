import '../../../domain/entities/message_chunk.dart';

class MessageChunkModel {
  final String messageId;
  final String sessionId;
  final String content;
  final String? type;
  final Map<String, dynamic>? metadata;

  MessageChunkModel({
    required this.messageId,
    required this.sessionId,
    required this.content,
    this.type,
    this.metadata,
  });

  MessageChunk toEntity() {
    return MessageChunk(
      messageId: messageId,
      sessionId: sessionId,
      content: content,
      type: type,
      metadata: metadata,
    );
  }

  factory MessageChunkModel.fromJson(Map<String, dynamic> json) {
    return MessageChunkModel(
      messageId: json['messageId'] as String? ?? 
                 json['id'] as String? ?? 
                 'unknown-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: json['sessionId'] as String? ?? '',
      content: json['content'] as String? ?? json['delta'] as String? ?? '',
      type: json['type'] as String?,
      metadata: json['metadata'] is Map<String, dynamic> 
          ? json['metadata'] as Map<String, dynamic>
          : null,
    );
  }
}
