import '../../entities/session.dart';
import '../../repositories/session_repository.dart';

class GetSession {
  final SessionRepository _repository;

  GetSession(this._repository);

  Future<Session> call(String sessionId) async {
    return await _repository.getSession(sessionId);
  }
}
