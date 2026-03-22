import 'dart:async';
import 'package:dartssh2/dartssh2.dart' as dartssh2;
import 'models/ssh_config.dart';
import 'models/command_result.dart';
import 'ssh_session.dart';

class SSHClient {
  dartssh2.SSHClient? _client;
  SSHSession? _session;
  final StreamController<SSHSession> _sessionController =
      StreamController<SSHSession>.broadcast();

  Stream<SSHSession> get sessionStream => _sessionController.stream;
  SSHSession? get currentSession => _session;
  bool get isConnected => _session?.isConnected ?? false;

  // Expose client for SFTP
  dartssh2.SSHClient? get client => _client;

  /// Connect to SSH server with the given configuration
  Future<SSHSession> connect(SSHConfig config) async {
    try {
      // Update state to connecting
      _session = SSHSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        host: config.host,
        port: config.port,
        username: config.username,
        state: SSHConnectionState.connecting,
      );
      if (_session != null) {
        _sessionController.add(_session!);
      }

      // Create socket connection
      final socket = await dartssh2.SSHSocket.connect(
        config.host,
        config.port,
        timeout: config.timeout,
      );

      // Authenticate based on auth type
      if (config.authType == SSHAuthType.password) {
        _client = dartssh2.SSHClient(
          socket,
          username: config.username,
          onPasswordRequest: () => config.password ?? '',
        );
      } else if (config.authType == SSHAuthType.privateKey) {
        _client = dartssh2.SSHClient(
          socket,
          username: config.username,
          identities: [
            ...dartssh2.SSHKeyPair.fromPem(config.privateKey ?? ''),
          ],
        );
      }

      // Wait for authentication to complete
      if (_client == null) {
        throw Exception('SSH client not initialized');
      }
      await _client!.authenticated;

      // Update state to connected
      if (_session != null) {
        _session = _session!.updateState(SSHConnectionState.connected);
        _sessionController.add(_session!);
        return _session!;
      }
      throw Exception('Session not initialized after connection');
    } catch (e) {
      // Update state to error
      _session = _session?.updateState(
            SSHConnectionState.error,
            error: e.toString(),
          ) ??
          SSHSession(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            host: config.host,
            port: config.port,
            username: config.username,
            state: SSHConnectionState.error,
            errorMessage: e.toString(),
          );
      if (_session != null) {
        _sessionController.add(_session!);
      }
      rethrow;
    }
  }

  /// Connect with retry logic and exponential backoff
  Future<SSHSession> connectWithRetry(
    SSHConfig config, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await connect(config);
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }

        // Update state to reconnecting
        _session = _session?.updateState(
          SSHConnectionState.reconnecting,
          error: 'Retry attempt $attempt/$maxRetries: $e',
        );
        if (_session != null) {
          _sessionController.add(_session!);
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }

    throw Exception('Failed to connect after $maxRetries attempts');
  }

  /// Escape a shell argument by wrapping in single quotes and escaping internal quotes
  /// This prevents command injection by ensuring special characters are treated literally
  String escapeShellArgument(String arg) {
    // Replace each single quote with '\'' (end quote, escaped quote, start quote)
    final escaped = arg.replaceAll("'", "'\\''");
    // Wrap in single quotes
    return "'$escaped'";
  }

  /// Execute a command on the remote server
  Future<CommandResult> execute(
    String command, {
    String? workingDirectory,
    Duration? timeout,
  }) async {
    if (command.isEmpty) {
      throw ArgumentError('Command cannot be empty');
    }

    if (_client == null || !isConnected) {
      throw Exception('Not connected to SSH server');
    }

    final startTime = DateTime.now();
    final effectiveTimeout = timeout ?? const Duration(seconds: 30);

    try {
      // Build command with proper shell escaping
      final fullCommand = workingDirectory != null
          ? 'cd ${escapeShellArgument(workingDirectory)} && $command'
          : command;

      // Execute command with timeout
      final result = await _client!.run(fullCommand).timeout(effectiveTimeout);

      final executionTime = DateTime.now().difference(startTime);

      // Update last activity time
      if (_session != null) {
        _session = _session!.copyWith(lastActivityAt: DateTime.now());
        _sessionController.add(_session!);
      }

      return CommandResult(
        stdout: String.fromCharCodes(result),
        stderr: '',
        exitCode: 0,
        executionTime: executionTime,
      );
    } on TimeoutException {
      final executionTime = DateTime.now().difference(startTime);
      return CommandResult(
        stdout: '',
        stderr: 'Command execution timed out after ${effectiveTimeout.inSeconds}s',
        exitCode: 124,
        executionTime: executionTime,
      );
    } catch (e) {
      final executionTime = DateTime.now().difference(startTime);
      return CommandResult(
        stdout: '',
        stderr: e.toString(),
        exitCode: 1,
        executionTime: executionTime,
      );
    }
  }

  /// Disconnect from SSH server
  Future<void> disconnect() async {
    try {
      _client?.close();
      _client = null;

      if (_session != null) {
        _session = _session!.updateState(SSHConnectionState.disconnected);
        _sessionController.add(_session!);
      }
    } catch (e) {
      // Ignore disconnect errors
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _sessionController.close();
  }
}
