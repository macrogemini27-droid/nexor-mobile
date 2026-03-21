import 'package:hive/hive.dart';
import '../../../domain/entities/server.dart';

part 'server_model.g.dart';

/// Server model - Data layer with Hive persistence
/// Note: Password is NOT stored here - it's stored securely via SecureStorageService
@HiveType(typeId: 0)
class ServerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String host;

  @HiveField(3)
  final int port;

  @HiveField(4)
  final String? username;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? lastUsedAt;

  @HiveField(7)
  final bool autoConnect;

  @HiveField(8)
  final bool useHttps;

  ServerModel({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    this.username,
    required this.createdAt,
    this.lastUsedAt,
    this.autoConnect = false,
    this.useHttps = false,
  });

  /// Convert to domain entity
  Server toEntity() {
    return Server(
      id: id,
      name: name,
      host: host,
      port: port,
      username: username,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt,
      autoConnect: autoConnect,
      useHttps: useHttps,
    );
  }

  /// Create from domain entity
  factory ServerModel.fromEntity(Server server) {
    return ServerModel(
      id: server.id,
      name: server.name,
      host: server.host,
      port: server.port,
      username: server.username,
      createdAt: server.createdAt,
      lastUsedAt: server.lastUsedAt,
      autoConnect: server.autoConnect,
      useHttps: server.useHttps,
    );
  }

  /// Copy with method
  ServerModel copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    String? username,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    bool? autoConnect,
    bool? useHttps,
  }) {
    return ServerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      autoConnect: autoConnect ?? this.autoConnect,
      useHttps: useHttps ?? this.useHttps,
    );
  }
}
