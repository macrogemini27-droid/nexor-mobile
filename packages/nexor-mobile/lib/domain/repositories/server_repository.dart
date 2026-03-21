import '../entities/server.dart';

/// Server repository interface - Domain layer
abstract class ServerRepository {
  /// Get all servers
  Future<List<Server>> getServers();

  /// Get server by ID
  Future<Server?> getServerById(String id);

  /// Add new server
  Future<void> addServer(Server server);

  /// Update existing server
  Future<void> updateServer(Server server);

  /// Delete server
  Future<void> deleteServer(String id);

  /// Update last used timestamp
  Future<void> updateLastUsed(String id);

  /// Get auto-connect server
  Future<Server?> getAutoConnectServer();
}
