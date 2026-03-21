import '../../entities/message.dart';
import '../../repositories/session_repository.dart';

class GetMessages {
  final SessionRepository _repository;

  GetMessages(this._repository);

  Future<List<Message>> call(String sessionId) async {
    return await _repository.getMessages(sessionId);
  }
}
