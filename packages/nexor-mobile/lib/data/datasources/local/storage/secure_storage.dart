import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for sensitive data (passwords)
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Save server password
  static Future<void> savePassword(String serverId, String password) async {
    await _storage.write(
      key: 'server_password_$serverId',
      value: password,
    );
  }

  /// Get server password
  static Future<String?> getPassword(String serverId) async {
    return await _storage.read(key: 'server_password_$serverId');
  }

  /// Delete server password
  static Future<void> deletePassword(String serverId) async {
    await _storage.delete(key: 'server_password_$serverId');
  }

  /// Clear all passwords
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
