import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/session_dao.dart';
import 'chat_provider.dart';

// Session Provider
final sessionProvider = StreamProvider<List<SessionEntity>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.sessionDao.watchAllSessions();
});

// Session Notifier
class SessionNotifier extends StateNotifier<AsyncValue<SessionEntity?>> {
  final SessionDao _sessionDao;
  final Uuid _uuid = const Uuid();

  SessionNotifier(this._sessionDao) : super(const AsyncValue.data(null));

  Future<SessionEntity> createSession({
    required String title,
    String? serverId,
    String? directory,
  }) async {
    state = const AsyncValue.loading();
    try {
      final session = await _sessionDao.createSession(
        id: _uuid.v4(),
        title: title,
        serverId: serverId,
        directory: directory,
      );
      state = AsyncValue.data(session);
      return session;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateSession(SessionEntity session) async {
    try {
      await _sessionDao.updateSession(session);
      state = AsyncValue.data(session);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _sessionDao.deleteSession(sessionId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<SessionEntity> getSession(String sessionId) async {
    try {
      final session = await _sessionDao.getSession(sessionId);
      if (session == null) {
        throw Exception('Session not found: $sessionId');
      }
      state = AsyncValue.data(session);
      return session;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final sessionNotifierProvider =
    StateNotifierProvider<SessionNotifier, AsyncValue<SessionEntity?>>((ref) {
  final database = ref.watch(databaseProvider);
  return SessionNotifier(database.sessionDao);
});

// Current Session Provider
final currentSessionIdProvider = StateProvider<String?>((ref) => null);

final currentSessionProvider = StreamProvider<SessionEntity?>((ref) {
  final sessionId = ref.watch(currentSessionIdProvider);
  if (sessionId == null) return Stream.value(null);

  final database = ref.watch(databaseProvider);
  return database.sessionDao.watchSession(sessionId);
});
