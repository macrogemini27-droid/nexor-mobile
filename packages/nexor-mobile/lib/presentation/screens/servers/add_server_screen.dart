import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/nexor_app_bar.dart';
import '../../widgets/common/nexor_input.dart';
import '../../widgets/common/nexor_button.dart';
import '../../../domain/entities/server.dart';
import '../../../domain/usecases/server/test_connection.dart';
import '../../../services/secure_storage_service.dart';
import 'providers/servers_provider.dart';

/// Add/Edit server screen
class AddServerScreen extends ConsumerStatefulWidget {
  final String? serverId;

  const AddServerScreen({
    super.key,
    this.serverId,
  });

  @override
  ConsumerState<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends ConsumerState<AddServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController(text: 'root');
  final _passwordController = TextEditingController();
  final _testConnection = TestConnection();
  final _secureStorage = SecureStorageService();

  bool _autoConnect = false;
  bool _useHttps = false;
  bool _isTesting = false;
  bool _isSaving = false;
  bool _obscurePassword = true;
  Server? _existingServer;

  @override
  void initState() {
    super.initState();
    _loadServerData();
  }

  Future<void> _loadServerData() async {
    if (widget.serverId != null) {
      final servers = await ref.read(serversNotifierProvider.future);
      try {
        _existingServer = servers.firstWhere((s) => s.id == widget.serverId);
      } catch (e) {
        // Server not found, ignore
        return;
      }

      if (_existingServer != null) {
        _nameController.text = _existingServer!.name;
        _hostController.text = _existingServer!.host;
        _portController.text = _existingServer!.port.toString();
        _usernameController.text = _existingServer!.username ?? 'opencode';
        _autoConnect = _existingServer!.autoConnect;
        _useHttps = _existingServer!.useHttps;

        final password = await _secureStorage.getPassword(_existingServer!.id);
        if (password != null) {
          _passwordController.text = password;
        }

        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testConnectionHandler() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isTesting = true);

    try {
      final server = Server(
        id: 'test',
        name: _nameController.text.trim(),
        host: _hostController.text.trim(),
        port: int.parse(_portController.text.trim()),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        createdAt: DateTime.now(),
        useHttps: _useHttps,
      );

      final password = _passwordController.text.isEmpty
          ? null
          : _passwordController.text;

      final result = await _testConnection(server, password: password);

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Connection successful! Latency: ${result.latencyMs}ms',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Connection failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  Future<void> _saveServer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final serverId = _existingServer?.id ?? const Uuid().v4();

      final server = Server(
        id: serverId,
        name: _nameController.text.trim(),
        host: _hostController.text.trim(),
        port: int.parse(_portController.text.trim()),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        createdAt: _existingServer?.createdAt ?? DateTime.now(),
        lastUsedAt: _existingServer?.lastUsedAt,
        autoConnect: _autoConnect,
        useHttps: _useHttps,
      );

      // Save password if provided
      if (_passwordController.text.isNotEmpty) {
        await _secureStorage.savePassword(serverId, _passwordController.text);
      }

      // Add or update server
      if (_existingServer != null) {
        await ref.read(serversNotifierProvider.notifier).updateServer(server);
      } else {
        await ref.read(serversNotifierProvider.notifier).addServer(server);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _existingServer != null
                  ? 'Server updated successfully'
                  : 'Server added successfully',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving server: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingServer != null;

    return Scaffold(
      appBar: NexorAppBar(
        title: isEditing ? 'Edit Server' : 'Add Server',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.space16),
          children: [
            NexorInput(
              label: 'Server Name',
              hint: 'My OpenCode Server',
              controller: _nameController,
              validator: ServerValidator.validateName,
              prefixIcon: Icon(PhosphorIconsRegular.desktop),
            ),
            const SizedBox(height: AppDimensions.space16),
            NexorInput(
              label: 'Host',
              hint: 'example.com or 192.168.1.100',
              controller: _hostController,
              validator: ServerValidator.validateHost,
              keyboardType: TextInputType.url,
              prefixIcon: Icon(PhosphorIconsRegular.globe),
            ),
            const SizedBox(height: AppDimensions.space16),
            NexorInput(
              label: 'Port',
              hint: '4096',
              controller: _portController,
              validator: ServerValidator.validatePort,
              keyboardType: TextInputType.number,
              prefixIcon: Icon(PhosphorIconsRegular.plugsConnected),
            ),
            const SizedBox(height: AppDimensions.space16),
            NexorInput(
              label: 'Username (Optional)',
              hint: 'opencode',
              controller: _usernameController,
              validator: ServerValidator.validateUsername,
              prefixIcon: Icon(PhosphorIconsRegular.user),
            ),
            const SizedBox(height: AppDimensions.space16),
            NexorInput(
              label: 'Password (Optional)',
              hint: 'Enter password',
              controller: _passwordController,
              validator: ServerValidator.validatePassword,
              obscureText: _obscurePassword,
              prefixIcon: Icon(PhosphorIconsRegular.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? PhosphorIconsRegular.eye
                      : PhosphorIconsRegular.eyeSlash,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            SwitchListTile(
              title: const Text('Use HTTPS'),
              subtitle: const Text('Enable secure connection (SSL/TLS)'),
              value: _useHttps,
              onChanged: (value) {
                setState(() => _useHttps = value);
              },
            ),
            SwitchListTile(
              title: const Text('Auto Connect'),
              subtitle: const Text('Connect automatically on app start'),
              value: _autoConnect,
              onChanged: (value) {
                setState(() => _autoConnect = value);
              },
            ),
            const SizedBox(height: AppDimensions.space32),
            NexorButton(
              text: 'Test Connection',
              onPressed: _isTesting || _isSaving ? null : _testConnectionHandler,
              variant: NexorButtonVariant.secondary,
              isLoading: _isTesting,
              isFullWidth: true,
              icon: PhosphorIconsRegular.pulse,
            ),
            const SizedBox(height: AppDimensions.space16),
            NexorButton(
              text: isEditing ? 'Update Server' : 'Add Server',
              onPressed: _isTesting || _isSaving ? null : _saveServer,
              isLoading: _isSaving,
              isFullWidth: true,
              icon: PhosphorIconsRegular.check,
            ),
          ],
        ),
      ),
    );
  }
}
