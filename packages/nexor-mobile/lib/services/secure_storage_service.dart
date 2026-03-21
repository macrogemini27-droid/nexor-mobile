import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Save server password
  Future<void> savePassword(String serverId, String password) async {
    await _storage.write(
      key: 'server_password_$serverId',
      value: password,
    );
  }

  /// Get server password
  Future<String?> getPassword(String serverId) async {
    return await _storage.read(key: 'server_password_$serverId');
  }

  /// Delete server password
  Future<void> deletePassword(String serverId) async {
    await _storage.delete(key: 'server_password_$serverId');
  }

  /// Clear all passwords
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
