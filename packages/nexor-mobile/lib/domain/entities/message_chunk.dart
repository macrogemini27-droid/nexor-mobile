import 'package:equatable/equatable.dart';

class MessageChunk extends Equatable {
  final String messageId;
  final String sessionId;
  final String content;
  final String? type;
  final Map<String, dynamic>? metadata;

  const MessageChunk({
    required this.messageId,
    required this.sessionId,
    required this.content,
    this.type,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        messageId,
        sessionId,
        content,
        type,
        metadata,
      ];
}
