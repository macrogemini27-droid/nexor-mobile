import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/session/session_processor.dart';
import '../../core/session/message_builder.dart';
import '../../core/session/context_manager.dart';
import '../../core/tools/tool_registry.dart';
import '../../core/tools/tools_initializer.dart';
import '../../data/database/app_database.dart';
import 'ssh_connection_provider.dart';
import 'ai_provider_settings_provider.dart';

// Tool Registry Provider
final toolRegistryProvider = Provider<ToolRegistry>((ref) {
  final sshClient = ref.watch(sshClientProvider);
  return ToolsInitializer.initializeTools(sshClient);
});

// Database Provider - Singleton with proper disposal
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});

// Session Processor Provider
final sessionProcessorProvider = Provider<SessionProcessor?>((ref) {
  final aiProvider = ref.watch(currentAIProviderProvider);
  if (aiProvider == null) return null;

  final toolRegistry = ref.watch(toolRegistryProvider);
  final database = ref.watch(databaseProvider);

  return SessionProcessor(
    aiProvider: aiProvider,
    toolRegistry: toolRegistry,
    sessionDao: database.sessionDao,
    messageDao: database.messageDao,
    messageBuilder: MessageBuilder(database.messageDao),
    contextManager: ContextManager(),
  );
});

// Chat State
class ChatState {
  final List<ChatMessage> messages;
  final bool isProcessing;
  final String? error;
  final String? currentStatus;

  const ChatState({
    this.messages = const [],
    this.isProcessing = false,
    this.error,
    this.currentStatus,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isProcessing,
    String? error,
    String? currentStatus,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      currentStatus: currentStatus ?? this.currentStatus,
    );
  }
}

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
  });

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

// Chat Notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final SessionProcessor? _processor;
  final String _sessionId;

  ChatNotifier(this._processor, this._sessionId) : super(const ChatState());

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Check if AI provider is configured
    if (_processor == null) {
      state = state.copyWith(
        error:
            'No AI provider configured. Please set up an API key in settings.',
        isProcessing: false,
      );
      return;
    }

    // Add user message
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isProcessing: true,
      error: null,
    );

    // Create assistant message placeholder
    final assistantMsgId = '${DateTime.now().millisecondsSinceEpoch + 1}';
    final assistantMsg = ChatMessage(
      id: assistantMsgId,
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    state = state.copyWith(
      messages: [...state.messages, assistantMsg],
    );

    // Process message
    try {
      final buffer = StringBuffer();

      await for (final event in _processor.process(
        sessionId: _sessionId,
        userMessage: message,
      )) {
        if (event is TextDeltaEvent) {
          buffer.write(event.text);
          _updateAssistantMessage(assistantMsgId, buffer.toString());
        } else if (event is StatusEvent) {
          state = state.copyWith(currentStatus: event.message);
        } else if (event is ToolStartEvent) {
          state = state.copyWith(
            currentStatus: 'Executing: ${event.toolName}',
          );
        } else if (event is ErrorProcessingEvent) {
          state = state.copyWith(
            error: event.error,
            isProcessing: false,
            currentStatus: null,
          );
          return;
        } else if (event is CompleteEvent) {
          _finalizeAssistantMessage(assistantMsgId);
          state = state.copyWith(
            isProcessing: false,
            currentStatus: null,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isProcessing: false,
        currentStatus: null,
      );
    }
  }

  void _updateAssistantMessage(String messageId, String content) {
    final messages = state.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(content: content);
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: messages);
  }

  void _finalizeAssistantMessage(String messageId) {
    final messages = state.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(isStreaming: false);
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: messages);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearHistory() {
    state = const ChatState();
  }
}

// Chat Provider Factory
final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, sessionId) {
    final processor = ref.watch(sessionProcessorProvider);
    return ChatNotifier(processor, sessionId);
  },
);
