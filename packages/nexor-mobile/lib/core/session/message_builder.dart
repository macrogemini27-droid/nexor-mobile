import 'dart:convert';
import 'dart:developer' as developer;
import '../../data/database/app_database.dart';
import '../../data/database/daos/message_dao.dart';
import '../ai/models/ai_message.dart';

class MessageBuilder {
  final MessageDao _messageDao;

  MessageBuilder(this._messageDao);

  /// Build AI message history from database for a session
  Future<List<AIMessage>> buildHistory(String sessionId) async {
    final messagesWithParts =
        await _messageDao.getMessagesWithPartsForSession(sessionId);

    final aiMessages = <AIMessage>[];

    for (final msgWithParts in messagesWithParts) {
      final role = _parseRole(msgWithParts.message.role);
      final content = <AIMessageContent>[];

      for (final part in msgWithParts.parts) {
        final contentItem = _parseMessagePart(part);
        if (contentItem != null) {
          content.add(contentItem);
        }
      }

      if (content.isNotEmpty) {
        aiMessages.add(AIMessage(
          role: role,
          content: content,
        ));
      }
    }

    return aiMessages;
  }

  AIMessageRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return AIMessageRole.user;
      case 'assistant':
        return AIMessageRole.assistant;
      case 'system':
        return AIMessageRole.system;
      default:
        return AIMessageRole.user;
    }
  }

  AIMessageContent? _parseMessagePart(MessagePartEntity part) {
    switch (part.type) {
      case 'text':
        return AIMessageContent.text(part.content);

      case 'tool_call':
      case 'tool_use':
        // Parse tool use from metadata
        if (part.metadata != null) {
          try {
            final meta = _parseJson(part.metadata!);
            if (meta.isEmpty) {
              throw FormatException('Empty metadata for tool_use part: ${part.id}');
            }
            return AIMessageContent.toolUse(
              meta['id'] as String,
              meta['name'] as String,
              meta['input'] as Map<String, dynamic>,
            );
          } catch (e) {
            developer.log('Failed to parse tool_use metadata: $e');
            return null;
          }
        }
        developer.log('Missing metadata for tool_use part: ${part.id}');
        return null;

      case 'tool_result':
        // Parse tool result from metadata
        if (part.metadata != null) {
          try {
            final meta = _parseJson(part.metadata!);
            if (meta.isEmpty) {
              throw FormatException('Empty metadata for tool_result part: ${part.id}');
            }
            return AIMessageContent.toolResult(
              meta['tool_use_id'] as String,
              part.content,
            );
          } catch (e) {
            developer.log('Failed to parse tool_result metadata: $e');
            return null;
          }
        }
        developer.log('Missing metadata for tool_result part: ${part.id}');
        return null;

      default:
        return null;
    }
  }

  Map<String, dynamic> _parseJson(String jsonString) {
    try {
      final dynamic parsed = jsonDecode(jsonString);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
      developer.log('Parsed JSON is not a Map<String, dynamic>: $parsed');
      return {};
    } catch (e) {
      developer.log('Failed to parse JSON: $e, input: $jsonString');
      return {};
    }
  }
}
