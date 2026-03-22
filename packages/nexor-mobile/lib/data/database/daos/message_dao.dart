import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/messages_table.dart';
import '../tables/message_parts_table.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [Messages, MessageParts])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(AppDatabase db) : super(db);

  // Create a new message
  Future<MessageEntity> createMessage({
    required String id,
    required String sessionId,
    required String role,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final message = MessagesCompanion.insert(
      id: id,
      sessionId: sessionId,
      role: role,
      createdAt: now,
    );
    await into(messages).insert(message);
    final result = await getMessage(id);
    if (result == null) {
      throw Exception('Failed to create message');
    }
    return result;
  }

  // Get a message by ID
  Future<MessageEntity?> getMessage(String id) async {
    try {
      return await (select(messages)..where((m) => m.id.equals(id)))
          .getSingle();
    } catch (e) {
      return null;
    }
  }

  // Get all messages for a session
  Future<List<MessageEntity>> getMessagesForSession(String sessionId) {
    return (select(messages)
          ..where((m) => m.sessionId.equals(sessionId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  // Delete all messages for a session
  Future<int> deleteMessagesForSession(String sessionId) {
    return (delete(messages)..where((m) => m.sessionId.equals(sessionId))).go();
  }

  // Create a message part
  Future<void> createMessagePart({
    required String id,
    required String messageId,
    required String type,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final part = MessagePartsCompanion.insert(
      id: id,
      messageId: messageId,
      type: type,
      content: content,
      metadata: metadata != null
          ? Value(jsonEncode(metadata))
          : const Value.absent(),
    );
    await into(messageParts).insert(part);
  }

  // Get all parts for a message
  Future<List<MessagePartEntity>> getPartsForMessage(String messageId) {
    return (select(messageParts)..where((p) => p.messageId.equals(messageId)))
        .get();
  }

  // Get messages with their parts for a session
  Future<List<MessageWithParts>> getMessagesWithPartsForSession(
      String sessionId) async {
    final msgs = await getMessagesForSession(sessionId);
    final result = <MessageWithParts>[];

    for (final msg in msgs) {
      final parts = await getPartsForMessage(msg.id);
      result.add(MessageWithParts(message: msg, parts: parts));
    }

    return result;
  }

  // Delete all parts for a message
  Future<int> deletePartsForMessage(String messageId) {
    return (delete(messageParts)..where((p) => p.messageId.equals(messageId)))
        .go();
  }

  // Watch messages for a session
  Stream<List<MessageEntity>> watchMessagesForSession(String sessionId) {
    return (select(messages)
          ..where((m) => m.sessionId.equals(sessionId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .watch();
  }
}

// Helper class to hold message with its parts
class MessageWithParts {
  final MessageEntity message;
  final List<MessagePartEntity> parts;

  MessageWithParts({required this.message, required this.parts});
}
