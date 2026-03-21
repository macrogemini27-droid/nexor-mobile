import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/servers/servers_list_screen.dart';
import '../screens/servers/add_server_screen.dart';
import '../screens/files/file_browser_screen.dart';
import '../screens/files/file_viewer_screen.dart';
import '../screens/files/file_search_screen.dart';
import '../screens/chat/conversation_list_screen.dart';
import '../screens/chat/new_conversation_screen.dart';
import '../screens/chat/chat_screen.dart';

/// App router configuration
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ServersListScreen(),
    ),
    GoRoute(
      path: '/servers/add',
      builder: (context, state) => const AddServerScreen(),
    ),
    GoRoute(
      path: '/servers/:id/edit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AddServerScreen(serverId: id);
      },
    ),
    GoRoute(
      path: '/files',
      builder: (context, state) {
        final serverId = state.uri.queryParameters['serverId'];
        if (serverId == null) {
          return const Scaffold(
            body: Center(child: Text('Missing serverId parameter')),
          );
        }
        final path = state.uri.queryParameters['path'];
        return FileBrowserScreen(
          serverId: serverId,
          initialPath: path,
        );
      },
    ),
    GoRoute(
      path: '/files/viewer',
      builder: (context, state) {
        final serverId = state.uri.queryParameters['serverId'];
        final path = state.uri.queryParameters['path'];
        if (serverId == null || path == null) {
          return const Scaffold(
            body: Center(child: Text('Missing required parameters')),
          );
        }
        return FileViewerScreen(
          serverId: serverId,
          filePath: path,
        );
      },
    ),
    GoRoute(
      path: '/files/search',
      builder: (context, state) {
        final serverId = state.uri.queryParameters['serverId'];
        if (serverId == null) {
          return const Scaffold(
            body: Center(child: Text('Missing serverId parameter')),
          );
        }
        return FileSearchScreen(serverId: serverId);
      },
    ),
    GoRoute(
      path: '/conversations',
      builder: (context, state) => const ConversationListScreen(),
    ),
    GoRoute(
      path: '/chat/new',
      builder: (context, state) {
        final directory = state.uri.queryParameters['directory'];
        final file = state.uri.queryParameters['file'];
        return NewConversationScreen(
          initialDirectory: directory,
          initialFile: file,
        );
      },
    ),
    GoRoute(
      path: '/chat/:sessionId',
      builder: (context, state) {
        final sessionId = state.pathParameters['sessionId']!;
        return ChatScreen(sessionId: sessionId);
      },
    ),
  ],
);
