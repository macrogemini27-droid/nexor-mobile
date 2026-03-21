import 'package:dio/dio.dart';
import 'dart:convert';

/// ⚠️ DEPRECATED: This client is for connecting to remote OpenCode servers via REST API.
/// 
/// The current architecture uses SSH/SFTP clients for direct server access (standalone mode).
/// This file is kept for reference or future hybrid mode support.
class ApiClient {
  final Dio _dio;
  final String baseUrl;
  final String? username;
  final String? password;

  ApiClient({
    required this.baseUrl,
    this.username,
    this.password,
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    if (username != null && password != null) {
      final auth = base64Encode(utf8.encode('$username:$password'));
      _dio.options.headers['Authorization'] = 'Basic $auth';
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(path, queryParameters: queryParameters);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Stream<String> postStream(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Accept': 'text/event-stream',
        },
      ),
    );

    if (response.data == null) {
      return;
    }

    await for (final chunk in response.data!.stream) {
      final text = utf8.decode(chunk);
      yield text;
    }
  }
}
