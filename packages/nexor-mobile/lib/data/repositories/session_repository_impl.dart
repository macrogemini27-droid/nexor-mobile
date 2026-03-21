import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../domain/entities/session.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_chunk.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/server_repository.dart';
import '../datasources/remote/api_client.dart';
import '../models/session/session_model.dart';
import '../models/session/message_model.dart';
import '../models/session/message_chunk_model.dart';
import '../../services/secure_storage_service.dart';
import '../../core/utils/dio_error_handler.dart';

/// ⚠️ DEPRECATED: This implementation connects to a remote OpenCode server via REST API.
/// 
/// The current architecture uses SessionProcessor with embedded OpenCode logic (standalone mode).
/// This file is kept for reference or future hybrid mode support.
/// 
/// For standalone mode, use:
/// - SessionProcessor (lib/core/session/session_processor.dart)
/// - Drift DAOs (lib/data/database/daos/)
/// - SSH/SFTP clients (lib/core/ssh/)
class SessionRepositoryImpl implements SessionRepository {
  final ServerRepository _serverRepository;
  final SecureStorageService _secureStorage;

  SessionRepositoryImpl(this._serverRepository, [SecureStorageService? secureStorage])
      : _secureStorage = secureStorage ?? SecureStorageService();

  Future<ApiClient> _getApiClient(String serverId) async {
    developer.log('Getting API client for server: $serverId');
    final server = await _serverRepository.getServerById(serverId);
    if (server == null) {
      developer.log('ERROR: Server not found: $serverId');
      throw Exception('Server not found');
    }

    // Use server.url which respects HTTPS setting
    final baseUrl = server.url;
    developer.log('Server URL: $baseUrl');
    
    // Get password from SecureStorage
    final password = await _secureStorage.getPassword(serverId);
    developer.log('Password retrieved: ${password != null ? "yes" : "no"}');
    developer.log('Username: ${server.username ?? "none"}');

    return ApiClient(
      baseUrl: baseUrl,
      username: server.username,
      password: password,
    );
  }

  /// Get the default server (auto-connect or first available)
  Future<String?> _getDefaultServerId() async {
    final servers = await _serverRepository.getServers();
    if (servers.isEmpty) return null;
    
    // Try auto-connect server first
    final autoConnect = servers.where((s) => s.autoConnect).firstOrNull;
    if (autoConnect != null) return autoConnect.id;
    
    return servers.first.id;
  }

  @override
  Future<List<Session>> getSessions({String? directory}) async {
    try {
      final serverId = await _getDefaultServerId();
      if (serverId == null) return [];

      final client = await _getApiClient(serverId);
      final response = await client.get(
        '/session',
        queryParameters: {
          if (directory != null) 'directory': directory,
          'roots': true,
          'limit': 100,
        },
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((json) => SessionModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
      }

      return [];
    } on DioException catch (e) {
      developer.log('DioException in getSessions: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to get sessions'));
    } catch (e, stack) {
      developer.log('Unexpected error in getSessions: $e\n$stack');
      throw Exception('Failed to get sessions: $e');
    }
  }

  @override
  Future<Session> getSession(String sessionId) async {
    try {
      final serverId = await _getDefaultServerId();
      if (serverId == null) {
        throw Exception('No server available');
      }

      final client = await _getApiClient(serverId);
      final response = await client.get('/session/$sessionId');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return SessionModel.fromJson(data).toEntity();
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      developer.log('DioException in getSession: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to get session'));
    }
  }

  @override
  Future<Session> createSession({
    required String directory,
    String? agent,
    String? title,
  }) async {
    try {
      final serverId = await _getDefaultServerId();
      if (serverId == null) {
        throw Exception('No server available');
      }

      final client = await _getApiClient(serverId);
      final response = await client.post(
        '/session',
        data: {
          'directory': directory,
          if (agent != null) 'agent': agent,
          if (title != null) 'title': title,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return SessionModel.fromJson(data).toEntity();
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      developer.log('DioException in createSession: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to create session'));
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      final serverId = await _getDefaultServerId();
      if (serverId == null) {
        throw Exception('No server available');
      }

      final client = await _getApiClient(serverId);
      await client.delete('/session/$sessionId');
    } on DioException catch (e) {
      developer.log('DioException in deleteSession: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to delete session'));
    }
  }

  @override
  Future<Session> updateSession(String sessionId, {String? title}) async {
    try {
      final serverId = await _getDefaultServerId();
      if (serverId == null) {
        throw Exception('No server available');
      }

      final client = await _getApiClient(serverId);
      final response = await client.patch(
        '/session/$sessionId',
        data: {
          if (title != null) 'title': title,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return SessionModel.fromJson(data).toEntity();
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      developer.log('DioException in updateSession: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to update session'));
    }
  }

  @override
  Future<List<Message>> getMessages(String sessionId) async {
    try {
      final serverId = await _getDefaultServerId();
      if (serverId == null) {
        throw Exception('No server available');
      }

      final client = await _getApiClient(serverId);
      final response = await client.get('/session/$sessionId/message');

      final data = response.data;
      if (data is List) {
        return data
            .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
      }

      return [];
    } on DioException catch (e) {
      developer.log('DioException in getMessages: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to get messages'));
    }
  }

  @override
  Stream<MessageChunk> sendMessage(String sessionId, String content) async* {
    try {
      final serverId = await _getDefaultServerId();
      if (serverId == null) {
        throw Exception('No server available');
      }

      final client = await _getApiClient(serverId);
      final stream = client.postStream(
        '/session/$sessionId/message',
        data: {'content': content},
      );

      await for (final text in stream) {
        // Parse JSON lines
        for (final line in text.split('\n')) {
          if (line.trim().isEmpty) continue;

          try {
            final json = jsonDecode(line);
            yield MessageChunkModel.fromJson(json as Map<String, dynamic>)
                .toEntity();
          } catch (e) {
            // Skip invalid JSON
            continue;
          }
        }
      }
    } on DioException catch (e) {
      developer.log('DioException in sendMessage: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to send message'));
    }
  }

  @override
  Future<void> sendMessageAsync(String sessionId, String content) async {
    try {
      final serverId = await _getDefaultServerId();
      if (serverId == null) {
        throw Exception('No server available');
      }

      final client = await _getApiClient(serverId);
      await client.post(
        '/session/$sessionId/prompt_async',
        data: {'content': content},
      );
    } on DioException catch (e) {
      developer.log('DioException in sendMessageAsync: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to send async message'));
    }
  }
}
