import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_list_widget.dart';
import '../widgets/message_input_widget.dart';

class ChatScreen extends ConsumerWidget {
  final String sessionId;

  const ChatScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          if (chatState.isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          if (chatState.currentStatus != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.currentStatus!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Error bar
          if (chatState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      ref.read(chatProvider(sessionId).notifier).clearError();
                    },
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: MessageListWidget(
              messages: chatState.messages,
            ),
          ),

          // Input
          MessageInputWidget(
            onSend: (message) {
              ref.read(chatProvider(sessionId).notifier).sendMessage(message);
            },
            enabled: !chatState.isProcessing,
          ),
        ],
      ),
    );
  }
}
