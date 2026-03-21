import '../../domain/entities/server.dart';
import '../../domain/repositories/server_repository.dart';
import '../datasources/local/database/app_database.dart';
import '../models/server/server_model.dart';

/// Server repository implementation
class ServerRepositoryImpl implements ServerRepository {
  @override
  Future<List<Server>> getServers() async {
    final box = HiveDatabase.serversBox;
    final models = box.values.cast<ServerModel>().toList();
    
    // Sort by last used (most recent first), then by created date
    models.sort((a, b) {
      if (a.lastUsedAt != null && b.lastUsedAt != null) {
        return b.lastUsedAt!.compareTo(a.lastUsedAt!);
      } else if (a.lastUsedAt != null) {
        return -1;
      } else if (b.lastUsedAt != null) {
        return 1;
      } else {
        return b.createdAt.compareTo(a.createdAt);
      }
    });
    
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Server?> getServerById(String id) async {
    final box = HiveDatabase.serversBox;
    final model = box.get(id);
    return model?.toEntity();
  }

  @override
  Future<void> addServer(Server server) async {
    final box = HiveDatabase.serversBox;
    final model = ServerModel.fromEntity(server);
    await box.put(server.id, model);
  }

  @override
  Future<void> updateServer(Server server) async {
    final box = HiveDatabase.serversBox;
    final model = ServerModel.fromEntity(server);
    await box.put(server.id, model);
  }

  @override
  Future<void> deleteServer(String id) async {
    final box = HiveDatabase.serversBox;
    await box.delete(id);
  }

  @override
  Future<void> updateLastUsed(String id) async {
    final server = await getServerById(id);
    if (server != null) {
      final updated = server.copyWith(lastUsedAt: DateTime.now());
      await updateServer(updated);
    }
  }

  @override
  Future<Server?> getAutoConnectServer() async {
    final servers = await getServers();
    try {
      return servers.firstWhere((server) => server.autoConnect);
    } catch (e) {
      return null;
    }
  }
}
