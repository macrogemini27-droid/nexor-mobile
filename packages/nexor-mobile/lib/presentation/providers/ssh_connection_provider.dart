import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ssh/ssh_client.dart';
import '../../core/ssh/ssh_session.dart';
import '../../core/ssh/models/ssh_config.dart';

// SSH Client Provider
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

// Connection State Notifier
class SSHConnectionNotifier extends StateNotifier<AsyncValue<SSHSession?>> {
  final SSHClient _client;

  SSHConnectionNotifier(this._client) : super(const AsyncValue.data(null));

  Future<void> connect(SSHConfig config) async {
    state = const AsyncValue.loading();
    try {
      final session = await _client.connectWithRetry(config);
      state = AsyncValue.data(session);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> disconnect() async {
    await _client.disconnect();
    state = const AsyncValue.data(null);
  }

  Future<void> reconnect(SSHConfig config) async {
    await disconnect();
    await connect(config);
  }
}

final sshConnectionProvider =
    StateNotifierProvider<SSHConnectionNotifier, AsyncValue<SSHSession?>>(
        (ref) {
  final client = ref.watch(sshClientProvider);
  return SSHConnectionNotifier(client);
});
