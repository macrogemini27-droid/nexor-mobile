import '../../entities/session.dart';
import '../../repositories/session_repository.dart';

class GetSessions {
  final SessionRepository _repository;

  GetSessions(this._repository);

  Future<List<Session>> call({String? directory}) async {
    return await _repository.getSessions(directory: directory);
  }
}
