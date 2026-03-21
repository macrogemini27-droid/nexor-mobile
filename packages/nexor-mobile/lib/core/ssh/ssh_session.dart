import 'package:equatable/equatable.dart';

enum SSHConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class SSHSession extends Equatable {
  final String id;
  final String host;
  final int port;
  final String username;
  final SSHConnectionState state;
  final String? errorMessage;
  final DateTime? connectedAt;
  final DateTime? lastActivityAt;

  const SSHSession({
    required this.id,
    required this.host,
    required this.port,
    required this.username,
    this.state = SSHConnectionState.disconnected,
    this.errorMessage,
    this.connectedAt,
    this.lastActivityAt,
  });

  bool get isConnected => state == SSHConnectionState.connected;
  bool get isConnecting => state == SSHConnectionState.connecting;
  bool get isDisconnected => state == SSHConnectionState.disconnected;
  bool get hasError => state == SSHConnectionState.error;

  SSHSession copyWith({
    String? id,
    String? host,
    int? port,
    String? username,
    SSHConnectionState? state,
    String? errorMessage,
    DateTime? connectedAt,
    DateTime? lastActivityAt,
  }) {
    return SSHSession(
      id: id ?? this.id,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedAt: connectedAt ?? this.connectedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  SSHSession updateState(SSHConnectionState newState, {String? error}) {
    return copyWith(
      state: newState,
      errorMessage: error,
      connectedAt: newState == SSHConnectionState.connected
          ? DateTime.now()
          : connectedAt,
      lastActivityAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        host,
        port,
        username,
        state,
        errorMessage,
        connectedAt,
        lastActivityAt,
      ];

  @override
  String toString() {
    return 'SSHSession(id: $id, host: $host:$port, user: $username, state: $state)';
  }
}
