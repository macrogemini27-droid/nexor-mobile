import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/message.dart';
import '../../../../core/utils/message_parser.dart';
import 'conversations_provider.dart';

part 'chat_provider.g.dart';

@riverpod
class Chat extends _$Chat {
  @override
  Future<List<Message>> build(String sessionId) async {
    final repository = ref.read(sessionRepositoryProvider);
    return await repository.getMessages(sessionId);
  }

  Future<void> sendMessage(String content) async {
    // Add user message immediately
    final userMessage = Message(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );

    state = AsyncValue.data([...state.value ?? [], userMessage]);

    // Start streaming
    ref.read(streamingStateProvider(sessionId).notifier).setStreaming(true);

    try {
      final repository = ref.read(sessionRepositoryProvider);
      final stream = repository.sendMessage(sessionId, content);

      String aiContent = '';
      String? aiMessageId;

      await for (final chunk in stream) {
        aiContent += chunk.content;
        aiMessageId = chunk.messageId;

        // Parse message parts
        final parts = MessageParser.parse(aiContent);

        final aiMessage = Message(
          id: aiMessageId,
          sessionId: sessionId,
          role: 'assistant',
          content: aiContent,
          createdAt: DateTime.now(),
          parts: parts,
        );

        final messages = [...state.value ?? []];
        final existingIndex = messages.indexWhere((m) => m.id == aiMessageId);

        if (existingIndex >= 0) {
          messages[existingIndex] = aiMessage;
        } else {
          messages.add(aiMessage);
        }

        state = AsyncValue.data(messages.cast<Message>());
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } finally {
      ref.read(streamingStateProvider(sessionId).notifier).setStreaming(false);
    }
  }

  Future<void> sendFile(String filePath) async {
    await sendMessage('Can you help me with this file: $filePath');
  }

  Future<void> clearHistory() async {
    state = const AsyncValue.data([]);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class StreamingState extends _$StreamingState {
  @override
  bool build(String sessionId) => false;

  void setStreaming(bool value) {
    state = value;
  }
}
