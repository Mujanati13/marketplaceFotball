import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../config/app_config.dart';
import 'hive_service.dart';
import 'logger_service.dart';
import 'api_service.dart';

class HttpService {
  static late Dio _dio;
  static late ApiService _apiService;

  static ApiService get apiService => _apiService;

  static Future<void> init() async {
    _dio = Dio();

    // Base configuration
    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Configure HTTP client for HTTPS certificate handling
    try {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        // Accept certificates for known domains
        client.badCertificateCallback = (cert, host, port) {
          // Accept certificates for your API domain
          if (host == 'footbalmarketplace.albech.me') {
            LoggerService.info(
              'Accepting certificate for known domain: $host:$port',
            );
            return true;
          }
          return false;
        };
        return client;
      };
    } catch (e) {
      LoggerService.error('Failed to configure HTTP client', e);
    }

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());

    // Create API service
    _apiService = ApiService(_dio, baseUrl: AppConfig.apiBaseUrl);
  }

  static void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get current user and add auth token if available
    final user = HiveService.getCurrentUser();
    final token = HiveService.getSetting<String>('access_token');

    if (token != null && user != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh for 401 errors
    if (err.response?.statusCode == 401) {
      final refreshToken = HiveService.getSetting<String>('refresh_token');

      if (refreshToken != null) {
        try {
          // Try to refresh the token
          final dio = Dio();
          dio.options.baseUrl = AppConfig.apiBaseUrl;

          final response = await dio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
          );

          final newAccessToken = response.data['access_token'];

          // Save new token
          await HiveService.saveSetting('access_token', newAccessToken);
          HttpService.updateAuthToken(newAccessToken);

          // Retry the original request
          final clonedRequest = await HttpService._dio.fetch(
            err.requestOptions,
          );
          return handler.resolve(clonedRequest);
        } catch (e) {
          // Refresh failed, clear auth data and redirect to login
          await _clearAuthData();
          LoggerService.error('Token refresh failed', e);
        }
      } else {
        // No refresh token, clear auth data
        await _clearAuthData();
      }
    }

    super.onError(err, handler);
  }

  Future<void> _clearAuthData() async {
    await HiveService.clearCurrentUser();
    await HiveService.deleteSetting('access_token');
    await HiveService.deleteSetting('refresh_token');
    HttpService.removeAuthToken();
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    LoggerService.info('🌐 API Request: ${options.method} ${options.uri}');
    LoggerService.debug('Request Headers: ${options.headers}');
    LoggerService.debug('Request Data: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LoggerService.info(
      '✅ API Response: ${response.statusCode} ${response.requestOptions.path}',
    );
    LoggerService.debug('Response Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.error(
      '❌ API Error: ${err.response?.statusCode} ${err.requestOptions.path}',
    );
    LoggerService.error('Error Type: ${err.type}');
    LoggerService.error('Error Message: ${err.message}');
    LoggerService.error('Error Response: ${err.response?.data}');
    LoggerService.error('Request Data: ${err.requestOptions.data}');
    super.onError(err, handler);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = _parseError(err);
    LoggerService.error('API Error occurred', apiError);

    // Transform DioException to ApiException
    final exception = ApiException(
      message: apiError.message,
      statusCode: apiError.statusCode,
      errors: apiError.errors,
    );

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  ApiError _parseError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 0,
        );

      case DioExceptionType.badResponse:
        final response = err.response;
        if (response != null) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            // Handle both 'message' and 'error' fields from server response
            String errorMessage =
                data['message'] ?? data['error'] ?? 'An error occurred';

            // Add specific handling for common error codes
            if (response.statusCode == 409) {
              errorMessage =
                  data['error'] ??
                  data['message'] ??
                  'Email already registered';
            } else if (response.statusCode == 401) {
              errorMessage =
                  data['error'] ?? data['message'] ?? 'Invalid credentials';
            } else if (response.statusCode == 422) {
              errorMessage =
                  data['error'] ?? data['message'] ?? 'Invalid input data';
            }

            return ApiError(
              message: errorMessage,
              statusCode: response.statusCode ?? 0,
              errors: data['errors'],
            );
          }
        }
        return ApiError(
          message: 'Server error occurred',
          statusCode: response?.statusCode ?? 0,
        );

      case DioExceptionType.cancel:
        return ApiError(message: 'Request was cancelled', statusCode: 0);

      case DioExceptionType.connectionError:
        return ApiError(
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        );

      default:
        return ApiError(message: 'An unexpected error occurred', statusCode: 0);
    }
  }
}

class ApiError {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiError({required this.message, required this.statusCode, this.errors});

  @override
  String toString() {
    return 'ApiError{message: $message, statusCode: $statusCode, errors: $errors}';
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, required this.statusCode, this.errors});

  @override
  String toString() {
    return 'ApiException{message: $message, statusCode: $statusCode, errors: $errors}';
  }

  bool get isNetworkError => statusCode == 0;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;
  bool get isServerError => statusCode >= 500;
}

// Provider for HttpService
final httpServiceProvider = Provider<ApiService>((ref) {
  return HttpService.apiService;
});
