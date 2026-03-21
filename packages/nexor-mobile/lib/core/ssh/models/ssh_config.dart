import 'package:equatable/equatable.dart';

enum SSHAuthType {
  password,
  privateKey,
}

class SSHConfig extends Equatable {
  final String host;
  final int port;
  final String username;
  final SSHAuthType authType;
  final String? password;
  final String? privateKey;
  final String? passphrase;
  final Duration timeout;

  const SSHConfig({
    required this.host,
    this.port = 22,
    required this.username,
    required this.authType,
    this.password,
    this.privateKey,
    this.passphrase,
    this.timeout = const Duration(seconds: 30),
  });

  SSHConfig copyWith({
    String? host,
    int? port,
    String? username,
    SSHAuthType? authType,
    String? password,
    String? privateKey,
    String? passphrase,
    Duration? timeout,
  }) {
    return SSHConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      password: password ?? this.password,
      privateKey: privateKey ?? this.privateKey,
      passphrase: passphrase ?? this.passphrase,
      timeout: timeout ?? this.timeout,
    );
  }

  @override
  List<Object?> get props => [
        host,
        port,
        username,
        authType,
        password,
        privateKey,
        passphrase,
        timeout,
      ];
}
