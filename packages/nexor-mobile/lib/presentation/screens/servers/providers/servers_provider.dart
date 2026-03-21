import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/server.dart';
import '../../../../domain/repositories/server_repository.dart';
import '../../../../data/repositories/server_repository_impl.dart';

part 'servers_provider.g.dart';

/// Server repository provider
@riverpod
ServerRepository serverRepository(ServerRepositoryRef ref) {
  return ServerRepositoryImpl();
}

/// Servers list provider
@riverpod
class ServersNotifier extends _$ServersNotifier {
  @override
  Future<List<Server>> build() async {
    final repository = ref.read(serverRepositoryProvider);
    return await repository.getServers();
  }

  /// Add new server
  Future<void> addServer(Server server) async {
    final repository = ref.read(serverRepositoryProvider);
    await repository.addServer(server);
    ref.invalidateSelf();
  }

  /// Update existing server
  Future<void> updateServer(Server server) async {
    final repository = ref.read(serverRepositoryProvider);
    await repository.updateServer(server);
    ref.invalidateSelf();
  }

  /// Delete server
  Future<void> deleteServer(String id) async {
    final repository = ref.read(serverRepositoryProvider);
    await repository.deleteServer(id);
    ref.invalidateSelf();
  }

  /// Update last used timestamp
  Future<void> updateLastUsed(String id) async {
    final repository = ref.read(serverRepositoryProvider);
    await repository.updateLastUsed(id);
    ref.invalidateSelf();
  }

  /// Refresh servers list
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
