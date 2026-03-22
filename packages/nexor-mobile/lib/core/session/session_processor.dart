import 'dart:async';
import 'package:uuid/uuid.dart';
import '../ai/providers/ai_provider.dart';
import '../ai/models/ai_message.dart';
import '../ai/models/ai_stream_event.dart';
import '../tools/tool_registry.dart';
import '../../data/database/daos/session_dao.dart';
import '../../data/database/daos/message_dao.dart';
import 'message_builder.dart';
import 'context_manager.dart';

class SessionProcessor {
  final AIProvider aiProvider;
  final ToolRegistry toolRegistry;
  final SessionDao sessionDao;
  final MessageDao messageDao;
  final MessageBuilder messageBuilder;
  final ContextManager contextManager;
  final Uuid _uuid = const Uuid();

  SessionProcessor({
    required this.aiProvider,
    required this.toolRegistry,
    required this.sessionDao,
    required this.messageDao,
    required this.messageBuilder,
    required this.contextManager,
  });

  /// Process a user message and generate AI response
  Stream<ProcessingEvent> process({
    required String sessionId,
    required String userMessage,
    String? workingDirectory,
  }) async* {
    try {
      // 1. Save user message
      yield ProcessingEvent.status('Saving user message...');
      final userMsgId = _uuid.v4();
      await messageDao.createMessage(
        id: userMsgId,
        sessionId: sessionId,
        role: 'user',
      );
      await messageDao.createMessagePart(
        id: _uuid.v4(),
        messageId: userMsgId,
        type: 'text',
        content: userMessage,
      );

      // 2. Build message history
      yield ProcessingEvent.status('Building context...');
      final history = await messageBuilder.buildHistory(sessionId);

      // Add current user message to history
      history.add(AIMessage.user(userMessage));

      // 3. Create assistant message
      final assistantMsgId = _uuid.v4();
      await messageDao.createMessage(
        id: assistantMsgId,
        sessionId: sessionId,
        role: 'assistant',
      );

      // 4. Stream AI response
      yield ProcessingEvent.status('Generating response...');
      
      final textBuffer = StringBuffer();
      final blocks = <int, Map<String, dynamic>>{};

      await for (final event in aiProvider.streamText(
        messages: history,
        tools: toolRegistry.getToolDefinitions(),
      )) {
        if (event is ContentBlockStartEvent) {
          blocks[event.index] = {
            'type': event.blockType,
            'data': event.data,
          };
          if (event.blockType == 'tool_use') {
            yield ProcessingEvent.toolStart(
              event.data['name'] as String? ?? 'unknown',
            );
          }
        } else if (event is ContentBlockDeltaEvent) {
          if (event.text != null) {
            textBuffer.write(event.text);
            yield ProcessingEvent.textDelta(event.text!);
          } else if (event.partialJson != null) {
            yield ProcessingEvent.status('Executing tool...');
          }
        } else if (event is ContentBlockStopEvent) {
          final block = blocks[event.index];
          if (block != null) {
            if (block['type'] == 'text' && textBuffer.isNotEmpty) {
              await messageDao.createMessagePart(
                id: _uuid.v4(),
                messageId: assistantMsgId,
                type: 'text',
                content: textBuffer.toString(),
              );
              textBuffer.clear();
            } else if (block['type'] == 'tool_use') {
              final data = block['data'] as Map<String, dynamic>;
              await messageDao.createMessagePart(
                id: _uuid.v4(),
                messageId: assistantMsgId,
                type: 'tool_use',
                content: data['name'] as String? ?? '',
                metadata: {
                  'id': data['id'] as String? ?? '',
                  'name': data['name'] as String? ?? '',
                  'input': data['input'] as Map<String, dynamic>? ?? {},
                },
              );
            }
          }
        } else if (event is MessageStopEvent) {
          yield ProcessingEvent.status('Response complete');
        } else if (event is ErrorEvent) {
          yield ProcessingEvent.error(event.message ?? event.error);
        }
      }

      // 5. Update session timestamp
      await sessionDao.touchSession(sessionId);

      yield ProcessingEvent.complete();
    } catch (e, stackTrace) {
      yield ProcessingEvent.error('Error processing message: $e\n$stackTrace');
    }
  }
}

/// Events emitted during session processing
abstract class ProcessingEvent {
  const ProcessingEvent();

  factory ProcessingEvent.status(String message) = StatusEvent;
  factory ProcessingEvent.textDelta(String text) = TextDeltaEvent;
  factory ProcessingEvent.toolStart(String toolName) = ToolStartEvent;
  factory ProcessingEvent.toolResult(String result) = ToolResultEvent;
  factory ProcessingEvent.error(String error) = ErrorProcessingEvent;
  factory ProcessingEvent.complete() = CompleteEvent;
}

class StatusEvent extends ProcessingEvent {
  final String message;
  const StatusEvent(this.message);
}

class TextDeltaEvent extends ProcessingEvent {
  final String text;
  const TextDeltaEvent(this.text);
}

class ToolStartEvent extends ProcessingEvent {
  final String toolName;
  const ToolStartEvent(this.toolName);
}

class ToolResultEvent extends ProcessingEvent {
  final String result;
  const ToolResultEvent(this.result);
}

class ErrorProcessingEvent extends ProcessingEvent {
  final String error;
  const ErrorProcessingEvent(this.error);
}

class CompleteEvent extends ProcessingEvent {
  const CompleteEvent();
}
