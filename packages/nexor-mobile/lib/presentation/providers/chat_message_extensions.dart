import '../../domain/entities/message.dart';
import 'chat_provider.dart';

extension ChatMessageExtension on ChatMessage {
  Message toMessage(String sessionId) {
    return Message(
      id: id,
      sessionId: sessionId,
      role: role,
      content: content,
      createdAt: timestamp,
    );
  }
}
