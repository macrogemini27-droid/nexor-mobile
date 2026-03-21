import '../../entities/message_chunk.dart';
import '../../repositories/session_repository.dart';

class SendMessage {
  final SessionRepository _repository;

  SendMessage(this._repository);

  Stream<MessageChunk> call(String sessionId, String content) {
    return _repository.sendMessage(sessionId, content);
  }
}
