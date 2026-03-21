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
import '../../../data/database/extensions/session_extensions.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
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
                text: 'New Conversation',
                onPressed: () => context.push('/chat/new'),
                icon: PhosphorIcons.plus(),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final sessionEntity = sessions[index];
              final session = sessionEntity.toSession();
              return ConversationCard(
                session: session,
                onTap: () => context.push('/chat/${session.id}'),
                onDelete: () async {
                  await ref
                      .read(sessionNotifierProvider.notifier)
                      .deleteSession(session.id);
                },
              );
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => EnhancedErrorState(
          title: 'Failed to Load Conversations',
          message: error.toString(),
          technicalDetails: 'Error: $error\n\nStack Trace:\n$stack',
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
}
