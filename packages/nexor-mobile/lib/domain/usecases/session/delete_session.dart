import '../../repositories/session_repository.dart';

class DeleteSession {
  final SessionRepository _repository;

  DeleteSession(this._repository);

  Future<void> call(String sessionId) async {
    return await _repository.deleteSession(sessionId);
  }
}
