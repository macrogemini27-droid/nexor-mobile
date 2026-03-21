import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/session.dart';
import '../../../../domain/repositories/session_repository.dart';
import '../../../../data/repositories/session_repository_impl.dart';
import '../../../../data/repositories/server_repository_impl.dart';
import '../../../../services/secure_storage_service.dart';

part 'conversations_provider.g.dart';

@riverpod
SessionRepository sessionRepository(SessionRepositoryRef ref) {
  return SessionRepositoryImpl(ServerRepositoryImpl(), SecureStorageService());
}

@riverpod
class Conversations extends _$Conversations {
  @override
  Future<List<Session>> build({String? search, String? project}) async {
    final repository = ref.read(sessionRepositoryProvider);
    final sessions = await repository.getSessions(directory: project);

    if (search != null && search.isNotEmpty) {
      return sessions.where((session) {
        final title = session.title?.toLowerCase() ?? '';
        final lastMessage = session.lastMessage?.toLowerCase() ?? '';
        final searchLower = search.toLowerCase();
        return title.contains(searchLower) || lastMessage.contains(searchLower);
      }).toList();
    }

    return sessions;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> delete(String sessionId) async {
    final repository = ref.read(sessionRepositoryProvider);
    await repository.deleteSession(sessionId);
    await refresh();
  }

  Future<Session> create({
    required String directory,
    String? agent,
    String? title,
  }) async {
    final repository = ref.read(sessionRepositoryProvider);
    final session = await repository.createSession(
      directory: directory,
      agent: agent,
      title: title,
    );
    await refresh();
    return session;
  }
}

@riverpod
Future<Session> session(SessionRef ref, String sessionId) async {
  final repository = ref.read(sessionRepositoryProvider);
  return await repository.getSession(sessionId);
}
