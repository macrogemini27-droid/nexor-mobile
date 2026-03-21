import 'dart:developer' as developer;
import '../../entities/server.dart';
import '../../../core/ssh/ssh_client.dart';
import '../../../core/ssh/models/ssh_config.dart';

/// Connection test result
class ConnectionTestResult {
  final bool success;
  final String? errorMessage;
  final int? latencyMs;

  ConnectionTestResult({
    required this.success,
    this.errorMessage,
    this.latencyMs,
  });
}

/// Use case: Test server connection via SSH
class TestConnection {
  Future<ConnectionTestResult> call(Server server, {String? password}) async {
    final startTime = DateTime.now();

    try {
      developer.log('Testing SSH connection to: ${server.host}:${server.port}');
      developer.log('Username: ${server.username ?? "root"}');
      developer.log('Password provided: ${password != null ? "yes" : "no"}');
      
      if (password == null || password.isEmpty) {
        return ConnectionTestResult(
          success: false,
          errorMessage: 'Password is required for SSH connection',
        );
      }

      // Create SSH config
      final sshConfig = SSHConfig(
        host: server.host,
        port: server.port,
        username: server.username ?? 'root',
        authType: SSHAuthType.password,
        password: password,
        timeout: const Duration(seconds: 30),
      );

      // Create SSH client and test connection
      final sshClient = SSHClient();
      
      try {
        await sshClient.connect(sshConfig);
        
        if (!sshClient.isConnected) {
          return ConnectionTestResult(
            success: false,
            errorMessage: 'Failed to establish SSH connection',
          );
        }

        // Test a simple command to verify connection works
        final result = await sshClient.execute('echo "test"');
        
        if (result.exitCode != 0) {
          await sshClient.disconnect();
          return ConnectionTestResult(
            success: false,
            errorMessage: 'SSH connected but command execution failed',
          );
        }

        // Disconnect after test
        await sshClient.disconnect();

        final latency = DateTime.now().difference(startTime).inMilliseconds;
        developer.log('SSH connection test successful. Latency: ${latency}ms');

        return ConnectionTestResult(
          success: true,
          latencyMs: latency,
        );
      } catch (e) {
        developer.log('SSH connection error: $e');
        await sshClient.disconnect();
        
        String errorMessage = 'SSH connection failed: $e';
        
        // Provide more specific error messages
        if (e.toString().contains('Authentication')) {
          errorMessage = 'Authentication failed. Please check your username and password.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Connection timeout. Please check the host and port.';
        } else if (e.toString().contains('refused')) {
          errorMessage = 'Connection refused. Make sure SSH server is running on port ${server.port}.';
        } else if (e.toString().contains('host')) {
          errorMessage = 'Cannot reach host. Please check the hostname or IP address.';
        }
        
        return ConnectionTestResult(
          success: false,
          errorMessage: errorMessage,
        );
      }
    } catch (e, stack) {
      developer.log('Error testing SSH connection: $e\n$stack');
      return ConnectionTestResult(
        success: false,
        errorMessage: 'Connection test failed: $e',
      );
    }
  }
}
