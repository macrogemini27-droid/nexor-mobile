import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../domain/entities/file_node.dart';
import '../../domain/entities/file_content.dart';
import '../../domain/repositories/file_repository.dart';
import '../../domain/repositories/server_repository.dart';
import '../datasources/remote/api_client.dart';
import '../models/file/file_node_model.dart';
import '../models/file/file_content_model.dart';
import '../../services/secure_storage_service.dart';
import '../../core/utils/dio_error_handler.dart';

class FileRepositoryImpl implements FileRepository {
  final ServerRepository _serverRepository;
  final SecureStorageService _secureStorage;

  FileRepositoryImpl(this._serverRepository, [SecureStorageService? secureStorage])
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

  @override
  Future<List<FileNode>> listFiles(String serverId, String path) async {
    try {
      developer.log('Listing files for server: $serverId, path: $path');
      final client = await _getApiClient(serverId);
      developer.log('API client created, making request to /file');
      
      final response = await client.get(
        '/file',
        queryParameters: {'path': path},
      );

      developer.log('Response received: ${response.statusCode}');
      final data = response.data;
      
      if (data is Map<String, dynamic> && data['files'] is List) {
        final files = (data['files'] as List)
            .map((json) => FileNodeModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();

        // Sort: directories first, then by name
        files.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

        developer.log('Successfully loaded ${files.length} files');
        return files;
      }

      developer.log('Warning: Response data format unexpected');
      return [];
    } on DioException catch (e) {
      developer.log('DioException in listFiles: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to list files'));
    } catch (e, stack) {
      developer.log('Unexpected error in listFiles: $e\n$stack');
      throw Exception('Failed to list files: $e');
    }
  }

  @override
  Future<FileContent> readFile(String serverId, String path) async {
    try {
      developer.log('Reading file: $path from server: $serverId');
      final client = await _getApiClient(serverId);
      final response = await client.get(
        '/file/content',
        queryParameters: {'path': path},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final model = FileContentModel.fromJson(data);
        return model.toEntity();
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      developer.log('DioException in readFile: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to read file'));
    } catch (e, stack) {
      developer.log('Unexpected error in readFile: $e\n$stack');
      throw Exception('Failed to read file: $e');
    }
  }

  @override
  Future<List<FileNode>> searchFiles(String serverId, String query) async {
    try {
      final client = await _getApiClient(serverId);
      final response = await client.get(
        '/find/file',
        queryParameters: {'query': query},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .map((json) => FileNodeModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
      }

      return [];
    } on DioException catch (e) {
      developer.log('DioException in searchFiles: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to search files'));
    }
  }

  @override
  Future<List<FileNode>> searchContent(String serverId, String pattern) async {
    try {
      final client = await _getApiClient(serverId);
      final response = await client.get(
        '/find',
        queryParameters: {'pattern': pattern},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .map((json) => FileNodeModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
      }

      return [];
    } on DioException catch (e) {
      developer.log('DioException in searchContent: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to search content'));
    }
  }

  @override
  Future<Map<String, String>> getGitStatus(String serverId, String path) async {
    try {
      final client = await _getApiClient(serverId);
      final response = await client.get(
        '/file/status',
        queryParameters: {'path': path},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['files'] is Map) {
        return Map<String, String>.from(data['files'] as Map);
      }

      return {};
    } on DioException catch (e) {
      developer.log('DioException in getGitStatus: ${DioErrorHandler.getDetailedError(e)}');
      throw Exception(DioErrorHandler.getErrorMessage(e, context: 'Failed to get git status'));
    }
  }
}
