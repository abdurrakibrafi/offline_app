import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class ApiClient {
  static const String baseUrl = 'http://10.10.10.4:5005/api/v1';
  static String? _accessToken;

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NjM2ZmE4YzY4MmM2YTY4ODUyZDMyMCIsImVtYWlsIjoiYWJkdXJyYWtpYnJhZmk0NjlAZ21haWwuY29tIiwicm9sZSI6IlVTRVIiLCJpYXQiOjE3NzQ1MDU3ODksImV4cCI6MTc3NTM2OTc4OX0.n2qCKbdJIi6h1UsvJjepczFg3WoHPT6hJoY1BwSYnC0',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('--- REQUEST ---');
          print('URL: ${options.baseUrl}${options.path}');
          print('Headers: ${options.headers}');
          print('Body: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('--- RESPONSE ---');
          print('Status: ${response.statusCode}');
          print('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('--- ERROR ---');
          print('Status: ${error.response?.statusCode}');
          print('Message: ${error.response?.data}');

          // Error message বের করো
          final message = _extractError(error);

          // Global snackbar দেখাও
          snackbarKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );

          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  // Server error message বের করো
  static String _extractError(DioException e) {
    try {
      final data = e.response?.data;
      if (data == null) return 'কোনো সমস্যা হয়েছে';

      if (data['errorSources'] != null) {
        final errors = data['errorSources'] as List;
        if (errors.isNotEmpty) {
          return errors.first['message'] ??
              data['message'] ??
              'Validation error';
        }
      }

      return data['message'] ?? 'কোনো সমস্যা হয়েছে';
    } catch (_) {
      return 'কোনো সমস্যা হয়েছে';
    }
  }

  static void setToken(String token) {
    _accessToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('Token set: Bearer $token');
  }

  static void clearToken() {
    _accessToken = null;
    _dio.options.headers.remove('Authorization');
  }

  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    return await _dio.get(endpoint, queryParameters: queryParams);
  }

  static Future<Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    return await _dio.post(endpoint, data: body);
  }

  static Future<Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    return await _dio.put(endpoint, data: body);
  }

  static Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }
}
