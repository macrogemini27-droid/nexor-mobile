import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ssh/models/ssh_config.dart';
import '../providers/ssh_connection_provider.dart';

class SSHConfigScreen extends ConsumerStatefulWidget {
  const SSHConfigScreen({super.key});

  @override
  ConsumerState<SSHConfigScreen> createState() => _SSHConfigScreenState();
}

class _SSHConfigScreenState extends ConsumerState<SSHConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  SSHAuthType _authType = SSHAuthType.password;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _connect() {
    if (_formKey.currentState!.validate()) {
      final config = SSHConfig(
        host: _hostController.text.trim(),
        port: int.parse(_portController.text.trim()),
        username: _usernameController.text.trim(),
        authType: _authType,
        password: _authType == SSHAuthType.password
            ? _passwordController.text
            : null,
      );

      ref.read(sshConnectionProvider.notifier).connect(config);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(sshConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SSH Connection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Host',
                  hintText: 'example.com or 192.168.1.1',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a host';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a port';
                  }
                  final port = int.tryParse(value);
                  if (port == null || port < 1 || port > 65535) {
                    return 'Please enter a valid port (1-65535)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SegmentedButton<SSHAuthType>(
                segments: const [
                  ButtonSegment(
                    value: SSHAuthType.password,
                    label: Text('Password'),
                    icon: Icon(Icons.password),
                  ),
                  ButtonSegment(
                    value: SSHAuthType.privateKey,
                    label: Text('Private Key'),
                    icon: Icon(Icons.key),
                  ),
                ],
                selected: {_authType},
                onSelectionChanged: (Set<SSHAuthType> newSelection) {
                  setState(() {
                    _authType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_authType == SSHAuthType.password)
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 24),
              connectionState.when(
                data: (session) {
                  if (session?.isConnected ?? false) {
                    return Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connected to ${session!.host}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(sshConnectionProvider.notifier)
                                .disconnect();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Disconnect'),
                        ),
                      ],
                    );
                  }
                  return ElevatedButton(
                    onPressed: _connect,
                    child: const Text('Connect'),
                  );
                },
                loading: () => const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Connecting...'),
                  ],
                ),
                error: (error, stack) => Column(
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connection failed: $error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _connect,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
