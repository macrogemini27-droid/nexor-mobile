import '../../entities/session.dart';
import '../../repositories/session_repository.dart';

class CreateSession {
  final SessionRepository _repository;

  CreateSession(this._repository);

  Future<Session> call({
    required String directory,
    String? agent,
    String? title,
  }) async {
    return await _repository.createSession(
      directory: directory,
      agent: agent,
      title: title,
    );
  }
}
