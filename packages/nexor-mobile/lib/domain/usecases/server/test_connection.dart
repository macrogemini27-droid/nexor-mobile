import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../entities/server.dart';
import '../../../core/utils/dio_error_handler.dart';

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

/// Use case: Test server connection
class TestConnection {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  Future<ConnectionTestResult> call(Server server, {String? password}) async {
    final startTime = DateTime.now();

    try {
      developer.log('Testing connection to: ${server.url}');
      developer.log('Username: ${server.username ?? "none"}');
      developer.log('Password provided: ${password != null ? "yes" : "no"}');
      developer.log('HTTPS: ${server.useHttps}');
      
      final options = Options();

      // Add Basic Auth if credentials provided
      if (server.username != null && password != null) {
        final credentials = '${server.username}:$password';
        final encoded = base64Encode(utf8.encode(credentials));
        options.headers = {'Authorization': 'Basic $encoded'};
        developer.log('Basic Auth header added');
      }

      // Try multiple endpoints to test connection
      final endpoints = ['/health', '/', '/api'];
      Response? response;
      String? successEndpoint;
      
      for (final endpoint in endpoints) {
        try {
          developer.log('Trying endpoint: ${server.url}$endpoint');
          response = await _dio.get(
            '${server.url}$endpoint',
            options: options,
          );
          successEndpoint = endpoint;
          developer.log('Success! Endpoint $endpoint returned ${response.statusCode}');
          break; // Success, exit loop
        } catch (e) {
          developer.log('Endpoint $endpoint failed: $e');
          // Try next endpoint
          if (endpoint == endpoints.last) {
            rethrow; // Last endpoint failed, rethrow
          }
        }
      }

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      if (response != null && (response.statusCode == 200 || 
          response.statusCode == 404 || 
          response.statusCode == 403)) {
        // 404/403 acceptable - server is reachable
        developer.log('Connection test PASSED (${response.statusCode}) via $successEndpoint in ${latency}ms');
        return ConnectionTestResult(
          success: true,
          latencyMs: latency,
        );
      } else if (response?.statusCode == 401) {
        developer.log('Connection test FAILED: 401 Unauthorized');
        return ConnectionTestResult(
          success: false,
          errorMessage: 'Authentication failed. Check username and password.',
        );
      } else {
        developer.log('Connection test FAILED: Unexpected status ${response?.statusCode}');
        return ConnectionTestResult(
          success: false,
          errorMessage: 'Server returned status code: ${response?.statusCode}',
        );
      }
    } on DioException catch (e) {
      developer.log('DioException in test connection: ${DioErrorHandler.getDetailedError(e)}');
      final errorMessage = DioErrorHandler.getErrorMessage(e);

      return ConnectionTestResult(
        success: false,
        errorMessage: errorMessage,
      );
    } catch (e, stack) {
      developer.log('Unexpected error in test connection: $e\n$stack');
      return ConnectionTestResult(
        success: false,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }
}
