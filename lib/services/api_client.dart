import 'dart:io';
import 'package:dio/dio.dart';
import 'constants.dart';
import 'token_manager.dart';
import 'network_result.dart';
import '../models/api_responses.dart';

/// ApiClient - Dio-based HTTP client with auth interceptor.
/// Matches ApiClient.kt from the Android project.
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final TokenManager _tokenManager = TokenManager.getInstance();

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout:
          Duration(seconds: Constants.connectTimeoutSeconds),
      receiveTimeout:
          Duration(seconds: Constants.readTimeoutSeconds),
      sendTimeout:
          Duration(seconds: Constants.writeTimeoutSeconds),
    ));

    // Auth interceptor - adds Bearer token to all requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenManager.getToken();
        if (token != null) {
          options.headers[Constants.authorizationHeader] =
              '${Constants.bearerPrefix}$token';
        }
        return handler.next(options);
      },
    ));

    // Logging interceptor
    if (Constants.enableNetworkLogs) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  static ApiClient getInstance() {
    _instance ??= ApiClient._();
    return _instance!;
  }

  /// Reset the client (used on logout)
  static void reset() {
    _instance = null;
  }

  Dio get dio => _dio;

  /// Safe API call wrapper - matches safeApiCall from ApiClient.kt.
  /// Wraps Dio calls and returns NetworkResult with proper error handling.
  Future<NetworkResult<T>> safeApiCall<T>(
    Future<Response> Function() apiCall,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await apiCall();
      final data = parser(response.data);
      return Success(data);
    } on DioException catch (e) {
      // Try to parse error body for message (matches Kotlin errorBody parsing)
      if (e.response != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map<String, dynamic>) {
            final errorResponse = ErrorResponse.fromJson(errorData);
            final message = errorResponse.message ??
                errorResponse.error ??
                Constants.errorUnknown;
            return NetworkError(message, e.response!.statusCode);
          }
        } catch (_) {
          // Fall through to default error handling
        }

        // Handle specific HTTP status codes
        if (e.response!.statusCode == 401) {
          return NetworkError(
              Constants.errorUnauthorized, 401);
        }
        return NetworkError(
          e.response!.statusMessage ?? Constants.errorUnknown,
          e.response!.statusCode,
        );
      }

      // Handle connection errors (matches Kotlin exception handling)
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return NetworkError(Constants.errorServerUnreachable);
      }

      if (e.error is SocketException) {
        return NetworkError(Constants.errorNoInternet);
      }

      return NetworkError(
          e.message ?? Constants.errorUnknown);
    } catch (e) {
      return NetworkError(Constants.errorUnknown);
    }
  }
}
