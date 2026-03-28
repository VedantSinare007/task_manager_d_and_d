import 'package:dio/dio.dart';
import 'api_constants.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30), // longer for 2-sec delay
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  factory ApiClient() => _instance ??= ApiClient._();

  Dio get dio => _dio;
}

// Shared singleton
final apiClient = ApiClient().dio;