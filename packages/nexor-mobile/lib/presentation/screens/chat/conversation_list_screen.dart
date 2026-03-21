import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/enhanced_error_state.dart';
import '../../widgets/common/nexor_app_bar.dart';
import '../../widgets/common/nexor_button.dart';
import '../../widgets/chat/conversation_card.dart';
import '../../providers/session_provider.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NexorAppBar(
        title: 'Conversations',
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.arrowClockwise()),
            onPressed: () {
              ref.invalidate(sessionProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return EmptyState(
              icon: PhosphorIcons.chatCircle(),
              title: 'No conversations yet',
              message: 'Start a new conversation to get started',
              action: NexorButton(
                label: 'New Conversation',
                onPressed: () => context.push('/chat/new'),
                icon: PhosphorIcons.plus(),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ConversationCard(
                session: session,
                onTap: () => context.push('/chat/${session.id}'),
                onDelete: () async {
                  await ref.read(sessionNotifierProvider.notifier).deleteSession(session.id);
                },
              );
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => EnhancedErrorState(
          error: error,
          stackTrace: stack,
          onRetry: () => ref.invalidate(sessionProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat/new'),
        backgroundColor: AppColors.primary,
        child: PhosphorIcon(PhosphorIcons.plus(), color: Colors.white),
      ),
    );
  }

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  String _searchQuery = '';
  String? _selectedProject;

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(
      conversationsProvider(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        project: _selectedProject,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NexorAppBar(
        title: 'Conversations',
        actions: [
          IconButton(
            onPressed: () {
              // FUTURE: Implement search/filter dialog
              // This will allow filtering conversations by project, date, or tags
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search & Filter'),
                  content: const Text('Search and filter features coming soon'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(PhosphorIconsRegular.magnifyingGlass),
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return EmptyState(
              icon: PhosphorIconsRegular.chatCircle,
              title: 'No Conversations',
              message: 'Start a new conversation to get help with your code',
              action: NexorButton(
                text: 'New Conversation',
                onPressed: () => context.push('/chat/new'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(conversationsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final session = conversations[index];
                return ConversationCard(
                  session: session,
                  onTap: () => context.push('/chat/${session.id}'),
                  onDelete: () {
                    ref
                        .read(conversationsProvider().notifier)
                        .delete(session.id);
                  },
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) {
          final errorStr = error.toString();
          String userMessage = errorStr;

          if (errorStr.startsWith('Exception: ')) {
            userMessage = errorStr.substring('Exception: '.length);
          }

          final technicalDetails = 'Error: $errorStr\n\nStack Trace:\n$stack';
          return EnhancedErrorState(
            title: 'Failed to Load Conversations',
            message: userMessage,
            technicalDetails: technicalDetails,
            onRetry: () => ref.invalidate(conversationsProvider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat/new'),
        backgroundColor: AppColors.primary,
        child: Icon(
          PhosphorIconsRegular.plus,
          color: Colors.white,
        ),
      ),
    );
  }
}
