import '../app_database.dart';
import '../../../domain/entities/session.dart';

extension SessionEntityExtension on SessionEntity {
  Session toSession({int messageCount = 0, String? lastMessage}) {
    return Session(
      id: id,
      title: title,
      directory: directory ?? '',
      agent: null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      messageCount: messageCount,
      lastMessage: lastMessage,
      projectPath: directory,
    );
  }
}
