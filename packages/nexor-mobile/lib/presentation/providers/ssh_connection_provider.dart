import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ssh/ssh_client.dart';
import '../../core/ssh/ssh_session.dart';
import '../../core/ssh/models/ssh_config.dart';

// SSH Client Provider - Singleton
final sshClientProvider = Provider<SSHClient>((ref) {
  final client = SSHClient();
  ref.onDispose(() => client.dispose());
  return client;
});

// SSH Session State Provider
final sshSessionProvider = StreamProvider<SSHSession?>((ref) {
  final client = ref.watch(sshClientProvider);
  return client.sessionStream;
});

// Connection State Notifier with caching
class SSHConnectionNotifier extends StateNotifier<AsyncValue<SSHSession?>> {
  final SSHClient _client;
  SSHConfig? _lastConfig;
  DateTime? _lastConnectTime;

  SSHConnectionNotifier(this._client) : super(const AsyncValue.data(null));

  Future<void> connect(SSHConfig config) async {
    // Check if already connected to same server
    if (_client.isConnected && _isSameConfig(config)) {
      // Reuse existing connection
      final session = _client.currentSession;
      if (session != null) {
        state = AsyncValue.data(session);
        return;
      }
    }

    state = const AsyncValue.loading();
    try {
      // Disconnect if connected to different server
      if (_client.isConnected && !_isSameConfig(config)) {
        await _client.disconnect();
      }

      final session = await _client.connectWithRetry(config);
      _lastConfig = config;
      _lastConnectTime = DateTime.now();
      state = AsyncValue.data(session);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  bool _isSameConfig(SSHConfig config) {
    if (_lastConfig == null) return false;
    return _lastConfig!.host == config.host &&
        _lastConfig!.port == config.port &&
        _lastConfig!.username == config.username;
  }

  Future<void> disconnect() async {
    await _client.disconnect();
    _lastConfig = null;
    _lastConnectTime = null;
    state = const AsyncValue.data(null);
  }

  Future<void> reconnect(SSHConfig config) async {
    await disconnect();
    await connect(config);
  }

  bool get isConnected => _client.isConnected;
  
  SSHConfig? get lastConfig => _lastConfig;
}

final sshConnectionProvider =
    StateNotifierProvider<SSHConnectionNotifier, AsyncValue<SSHSession?>>(
        (ref) {
  final client = ref.watch(sshClientProvider);
  return SSHConnectionNotifier(client);
});
