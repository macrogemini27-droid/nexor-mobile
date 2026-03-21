import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/enhanced_error_state.dart';
import '../../widgets/common/nexor_app_bar.dart';
import '../../widgets/chat/user_message.dart';
import '../../widgets/chat/ai_message.dart';
import '../../widgets/chat/message_input.dart';
import 'providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const ChatScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  bool _showScrollToBottom = false;
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final isAtBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;

    if (isAtBottom != !_showScrollToBottom) {
      setState(() {
        _showScrollToBottom = !isAtBottom;
        _autoScroll = isAtBottom;
      });
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleSendMessage(String content) {
    ref.read(chatProvider(widget.sessionId).notifier).sendMessage(content);

    // Auto scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _autoScroll) {
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionProvider(widget.sessionId));
    final messagesAsync = ref.watch(chatProvider(widget.sessionId));
    final isStreaming = ref.watch(streamingStateProvider(widget.sessionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: sessionAsync.when(
        data: (session) => NexorAppBar(
          title: session.displayTitle,
          showBackButton: true,
          actions: [
            if (isStreaming)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
            PopupMenuButton<String>(
              icon: Icon(PhosphorIconsRegular.dotsThreeVertical),
              onSelected: (value) async {
                switch (value) {
                  case 'clear':
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear History'),
                        content: const Text(
                          'Are you sure you want to clear all messages in this conversation?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && mounted) {
                      ref
                          .read(chatProvider(widget.sessionId).notifier)
                          .clearHistory();
                    }
                    break;
                  case 'export':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export feature coming soon'),
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.export,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 12),
                      const Text('Export'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.trash,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Clear History',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        loading: () => NexorAppBar(
          title: 'Loading...',
          showBackButton: true,
        ),
        error: (_, __) => NexorAppBar(
          title: 'Error',
          showBackButton: true,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIconsRegular.chatCircle,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send a message to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto scroll when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_autoScroll && _scrollController.hasClients) {
                    _scrollToBottom();
                  }
                });

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isLastMessage = index == messages.length - 1;
                        final isStreamingThisMessage =
                            isStreaming && isLastMessage && message.isAssistant;

                        if (message.isUser) {
                          return UserMessage(message: message);
                        } else {
                          return AIMessage(
                            message: message,
                            isStreaming: isStreamingThisMessage,
                            onRegenerate: () {
                              // FUTURE: Implement message regeneration
                              // This will allow users to regenerate AI responses
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Regenerate feature coming soon'),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                    if (_showScrollToBottom)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          onPressed: _scrollToBottom,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            PhosphorIconsRegular.arrowDown,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) {
                final errorStr = error.toString();
                String userMessage = errorStr;

                if (errorStr.startsWith('Exception: ')) {
                  userMessage = errorStr.substring('Exception: '.length);
                }

                final technicalDetails =
                    'Error: $errorStr\n\nStack Trace:\n$stack';

                return EnhancedErrorState(
                  title: 'Failed to Load Messages',
                  message: userMessage,
                  technicalDetails: technicalDetails,
                  onRetry: () => ref.invalidate(chatProvider(widget.sessionId)),
                );
              },
            ),
          ),
          MessageInput(
            onSend: _handleSendMessage,
            enabled: !isStreaming,
            onAttach: () {
              // FUTURE: Implement file attachment for context
              // This will allow users to attach files to provide context to AI
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File attachment coming soon'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
