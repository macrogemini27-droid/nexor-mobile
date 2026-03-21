import '../entities/session.dart';
import '../entities/message.dart';
import '../entities/message_chunk.dart';

abstract class SessionRepository {
  Future<List<Session>> getSessions({String? directory});
  
  Future<Session> getSession(String sessionId);
  
  Future<Session> createSession({
    required String directory,
    String? agent,
    String? title,
  });
  
  Future<void> deleteSession(String sessionId);
  
  Future<Session> updateSession(String sessionId, {String? title});
  
  Future<List<Message>> getMessages(String sessionId);
  
  Stream<MessageChunk> sendMessage(String sessionId, String content);
  
  Future<void> sendMessageAsync(String sessionId, String content);
}
