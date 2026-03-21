import 'package:equatable/equatable.dart';

/// Server entity - Domain layer
/// Note: Password is NOT stored here - it's stored securely via SecureStorageService
class Server extends Equatable {
  final String id;
  final String name;
  final String host;
  final int port;
  final String? username;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final bool autoConnect;
  final bool useHttps;

  const Server({
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

  /// Get server URL
  String get url => '${useHttps ? 'https' : 'http'}://$host:$port';

  /// Check if server has credentials
  bool get hasCredentials => username != null && username!.isNotEmpty;

  /// Copy with method
  Server copyWith({
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
    return Server(
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

  @override
  List<Object?> get props => [
        id,
        name,
        host,
        port,
        username,
        createdAt,
        lastUsedAt,
        autoConnect,
        useHttps,
      ];
}
