import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://134.199.204.218:5005/api/v1';  // শুধু এখানে URL

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // GET
  static Future<Response> get(
      String endpoint, {
        Map<String, dynamic>? queryParams,
      }) async {
    return await _dio.get(
      endpoint,
      queryParameters: queryParams,
    );
  }

  // POST
  static Future<Response> post(
      String endpoint, {
        required Map<String, dynamic> body,
      }) async {
    return await _dio.post(
      endpoint,
      data: body,
    );
  }

  // PUT
  static Future<Response> put(
      String endpoint, {
        required Map<String, dynamic> body,
      }) async {
    return await _dio.put(
      endpoint,
      data: body,
    );
  }

  // DELETE
  static Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }
}