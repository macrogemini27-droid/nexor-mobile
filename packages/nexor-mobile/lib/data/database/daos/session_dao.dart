import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sessions_table.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [Sessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(AppDatabase db) : super(db);

  // Create a new session
  Future<SessionEntity> createSession({
    required String id,
    required String title,
    String? serverId,
    String? directory,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final session = SessionsCompanion.insert(
      id: id,
      title: title,
      serverId: Value(serverId),
      directory: Value(directory),
      createdAt: now,
      updatedAt: now,
    );
    await into(sessions).insert(session);
    final result = await getSession(id);
    if (result == null) {
      throw Exception('Failed to create session');
    }
    return result;
  }

  // Get a session by ID
  Future<SessionEntity?> getSession(String id) async {
    try {
      return await (select(sessions)..where((s) => s.id.equals(id)))
          .getSingle();
    } catch (e) {
      return null;
    }
  }

  // Get all sessions ordered by updated time
  Future<List<SessionEntity>> getAllSessions() {
    return (select(sessions)..orderBy([(s) => OrderingTerm.desc(s.updatedAt)]))
        .get();
  }

  // Update session
  Future<bool> updateSession(SessionEntity session) {
    return update(sessions).replace(session);
  }

  // Update session timestamp
  Future<void> touchSession(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(sessions)..where((s) => s.id.equals(id)))
        .write(SessionsCompanion(updatedAt: Value(now)));
  }

  // Delete a session
  Future<int> deleteSession(String id) {
    return (delete(sessions)..where((s) => s.id.equals(id))).go();
  }

  // Watch all sessions
  Stream<List<SessionEntity>> watchAllSessions() {
    return (select(sessions)..orderBy([(s) => OrderingTerm.desc(s.updatedAt)]))
        .watch();
  }

  // Watch a specific session
  Stream<SessionEntity?> watchSession(String id) {
    return (select(sessions)..where((s) => s.id.equals(id)))
        .watchSingleOrNull();
  }
}
