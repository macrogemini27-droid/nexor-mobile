import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/dimensions.dart';
import '../../widgets/common/nexor_app_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/enhanced_error_state.dart';
import '../../widgets/server/server_card.dart';
import '../../widgets/server/server_status_badge.dart';
import '../../../domain/entities/server.dart';
import '../../../domain/usecases/server/test_connection.dart';
import '../../../services/secure_storage_service.dart';
import 'providers/servers_provider.dart';

/// Servers list screen
class ServersListScreen extends ConsumerStatefulWidget {
  const ServersListScreen({super.key});

  @override
  ConsumerState<ServersListScreen> createState() => _ServersListScreenState();
}

class _ServersListScreenState extends ConsumerState<ServersListScreen> {
  final _testConnection = TestConnection();
  final _secureStorage = SecureStorageService();
  final Map<String, ServerStatus> _serverStatuses = {};
  final Set<String> _testingServers = {};

  Future<void> _testServerConnection(Server server) async {
    if (_testingServers.contains(server.id)) return;

    setState(() {
      _testingServers.add(server.id);
      _serverStatuses[server.id] = ServerStatus.connecting;
    });

    try {
      final password = await _secureStorage.getPassword(server.id);
      final result = await _testConnection(server, password: password);

      if (mounted) {
        setState(() {
          _serverStatuses[server.id] =
              result.success ? ServerStatus.online : ServerStatus.offline;
          _testingServers.remove(server.id);
        });

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Connected successfully! Latency: ${result.latencyMs}ms',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Connection failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _serverStatuses[server.id] = ServerStatus.offline;
          _testingServers.remove(server.id);
        });
      }
    }
  }

  Future<void> _deleteServer(Server server) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Server'),
        content: Text('Are you sure you want to delete "${server.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _secureStorage.deletePassword(server.id);
      await ref.read(serversNotifierProvider.notifier).deleteServer(server.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${server.name} deleted')),
        );
      }
    }
  }

  Future<void> _connectToServer(Server server) async {
    await ref.read(serversNotifierProvider.notifier).updateLastUsed(server.id);

    // Test connection first
    final password = await _secureStorage.getPassword(server.id);
    final result = await _testConnection(server, password: password);

    if (!result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Connection failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Connected to ${server.name}! Latency: ${result.latencyMs}ms'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to conversations after successful connection
      context.go('/conversations');
    }
  }

  void _browseFiles(Server server) {
    context.push('/files?serverId=${server.id}');
  }

  @override
  Widget build(BuildContext context) {
    final serversAsync = ref.watch(serversNotifierProvider);

    return Scaffold(
      appBar: const NexorAppBar(
        title: 'Servers',
        showBackButton: false,
      ),
      body: serversAsync.when(
        data: (servers) {
          if (servers.isEmpty) {
            return EmptyState(
              icon: PhosphorIconsRegular.desktop,
              title: 'No Servers',
              message: 'Add your first OpenCode server to get started',
              action: ElevatedButton.icon(
                onPressed: () => context.push('/servers/add'),
                icon: Icon(PhosphorIconsRegular.plus),
                label: const Text('Add Server'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(serversNotifierProvider.notifier).refresh();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.space16),
              itemCount: servers.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppDimensions.space16),
              itemBuilder: (context, index) {
                final server = servers[index];
                final status =
                    _serverStatuses[server.id] ?? ServerStatus.offline;

                return ServerCard(
                  server: server,
                  status: status,
                  onConnect: () => _connectToServer(server),
                  onBrowseFiles: () => _browseFiles(server),
                  onTest: () => _testServerConnection(server),
                  onEdit: () => context.push('/servers/${server.id}/edit'),
                  onDelete: () => _deleteServer(server),
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading servers...'),
        error: (error, stack) {
          final errorStr = error.toString();
          String userMessage = errorStr;

          if (errorStr.startsWith('Exception: ')) {
            userMessage = errorStr.substring('Exception: '.length);
          }

          final technicalDetails = 'Error: $errorStr\n\nStack Trace:\n$stack';

          return EnhancedErrorState(
            title: 'Failed to Load Servers',
            message: userMessage,
            technicalDetails: technicalDetails,
            onRetry: () => ref.invalidate(serversNotifierProvider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/servers/add'),
        child: Icon(PhosphorIconsRegular.plus),
      ),
    );
  }
}
