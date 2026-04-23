// API Client for NexaTrace System
// This file handles all HTTP requests to the Laravel backend

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import '../errors/error_logger.dart';

class ApiClient {
  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // HTTP client with custom request method to disable redirects
  final http.Client _client = http.Client();

  // Custom request method that disables redirects
  Future<http.Response> _makeCustomRequest(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final request = http.Request(method, uri);

    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List<int>) {
        request.bodyBytes = body;
      } else if (body is Map) {
        request.body = jsonEncode(body);
      }
    }

    // Disable redirects to prevent POST -> GET conversion
    request.followRedirects = false;
    request.maxRedirects = 0;

    final streamedResponse = await _client.send(request);
    return await http.Response.fromStream(streamedResponse);
  }

  // Headers
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };

  // Get auth token
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.authTokenKey);
  }

  // Set auth token
  Future<void> _setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.authTokenKey, token);
  }

  Future<void> setAuthToken(String token) async {
    await _setAuthToken(token);
  }

  Future<void> clearAuthToken() async {
    await _clearAuthToken();
    _headers.remove('Authorization');
  }

  // Clear auth token
  Future<void> _clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
  }

  // Initialize headers with auth token
  Future<void> _initializeHeaders({String? endpoint}) async {
    final prefs = await SharedPreferences.getInstance();

    String? token;
    if (endpoint != null) {
      final path = endpoint.contains('://')
          ? (Uri.tryParse(endpoint)?.path ?? endpoint)
          : endpoint;
      final normalizedPath = path.startsWith('/') ? path : '/$path';

      final isFactoryEndpoint = normalizedPath.startsWith('/factory/') ||
          normalizedPath.startsWith('/codes/');

      if (isFactoryEndpoint) {
        token = prefs.getString('factory_auth_token');
      }

      token ??= prefs.getString(AppConstants.authTokenKey);
    } else {
      token = prefs.getString(AppConstants.authTokenKey);
    }

    if (token != null && token.trim().isNotEmpty) {
      _headers['Authorization'] = 'Bearer $token';
    } else {
      _headers.remove('Authorization');
    }
  }

  // Make GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _makeRequest(
      'GET',
      endpoint,
      queryParams: queryParams ?? queryParameters,
      extraHeaders: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Make POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _makeRequest(
      'POST',
      endpoint,
      body: body ?? data,
      queryParams: queryParams ?? queryParameters,
      extraHeaders: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Make PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _makeRequest(
      'PUT',
      endpoint,
      body: body ?? data,
      queryParams: queryParams ?? queryParameters,
      extraHeaders: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Make PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _makeRequest(
      'PATCH',
      endpoint,
      body: body ?? data,
      queryParams: queryParams ?? queryParameters,
      extraHeaders: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Make DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _makeRequest(
      'DELETE',
      endpoint,
      body: body ?? data,
      queryParams: queryParams ?? queryParameters,
      extraHeaders: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Upload file
  Future<dynamic> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    try {
      if (requiresAuth) {
        await _initializeHeaders(endpoint: endpoint);
      }

      final requestHeaders = {
        ..._headers,
        if (headers != null) ...headers,
      };

      requestHeaders['Accept'] = 'application/json';

      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final uri = Uri.parse(normalizedEndpoint);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(requestHeaders);

      // Add file
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (error, stackTrace) {
      ErrorLogger.apiError(
        _normalizeEndpoint(endpoint),
        0,
        'File upload failed',
        error,
        stackTrace,
      );
      throw _handleError(error);
    }
  }

  // Make HTTP request
  Future<dynamic> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? extraHeaders,
    bool requiresAuth = true,
    int retryCount = 0,
  }) async {
    try {
      if (requiresAuth) {
        await _initializeHeaders(endpoint: endpoint);
      }

      final requestHeaders = {
        ..._headers,
        if (extraHeaders != null) ...extraHeaders,
      };

      requestHeaders['Accept'] = 'application/json';

      final normalizedEndpoint = _normalizeEndpoint(endpoint);

      final uri = Uri.parse(normalizedEndpoint).replace(
        queryParameters: queryParams?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      // Log request details for debugging
      ErrorLogger.debug(
        'API Request: $method $endpoint - Normalized: $normalizedEndpoint - URI: ${uri.toString()} - Auth: $requiresAuth - Has Body: ${body != null}',
      );

      http.Response response;

      // Use custom request method to disable redirects
      switch (method) {
        case 'GET':
          response = await _makeCustomRequest('GET', uri, headers: requestHeaders)
              .timeout(const Duration(seconds: 30));
          break;
        case 'POST':
          response = await _makeCustomRequest(
            'POST',
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await _makeCustomRequest(
            'PUT',
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 30));
          break;
        case 'PATCH':
          response = await _makeCustomRequest(
            'PATCH',
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await _makeCustomRequest(
            'DELETE',
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 30));
          break;
        default:
          throw ArgumentError('Invalid HTTP method: $method');
      }

      // Log response details for debugging
      ErrorLogger.debug(
        'API Response: $method $endpoint - Status: ${response.statusCode} - Redirect: ${response.isRedirect} - Location: ${response.headers['location']}',
      );

      // Handle redirects manually
      if (response.isRedirect) {
        final location = response.headers['location'];
        ErrorLogger.warning(
          'API Redirect Detected: $method $endpoint - Status: ${response.statusCode} - Location: $location - Original URI: ${uri.toString()}',
        );

        // For POST requests that get redirected, we need to handle this specially
        if (method == 'POST' && location != null) {
          throw RedirectException(
            'POST request was redirected. This may cause issues with authentication.',
            location: location,
            originalMethod: method,
          );
        }
      }

      return _handleResponse(response);
    } catch (error, stackTrace) {
      ErrorLogger.error('API Request Failed: $method $endpoint', error, stackTrace);
      ErrorLogger.debug(
        'API Request Failed Details: Method: $method - Endpoint: $endpoint - Auth: $requiresAuth - Retry: $retryCount - Error: ${error.toString()}',
      );

      if (error is UnauthorizedException &&
          requiresAuth &&
          retryCount == 0 &&
          endpoint != ApiEndpoints.refreshToken &&
          endpoint != ApiEndpoints.login) {
        try {
          await refreshToken();
          await _initializeHeaders(endpoint: endpoint);
          return await _makeRequest(
            method,
            endpoint,
            body: body,
            queryParams: queryParams,
            requiresAuth: requiresAuth,
            retryCount: retryCount + 1,
          );
        } catch (_) {
          throw error;
        }
      }

      ErrorLogger.apiError(
        _normalizeEndpoint(endpoint),
        0,
        'Request failed',
        error,
        stackTrace,
      );
      throw _handleError(error);
    }
  }

  // Normalize endpoint URL
  String _normalizeEndpoint(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }

    final baseUrl = ApiEndpoints.baseUrl;
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    if (endpoint.startsWith('/api/') && normalizedBaseUrl.endsWith('/api')) {
      return '$normalizedBaseUrl${endpoint.substring(4)}';
    }

    if (endpoint.startsWith('/')) {
      return '$normalizedBaseUrl$endpoint';
    }

    return '$normalizedBaseUrl/$endpoint';
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    ErrorLogger.debug(
      'API Response - Status: $statusCode',
      'Body: ${responseBody.length > 500 ? '${responseBody.substring(0, 500)}...' : responseBody}',
    );

    if (statusCode >= 200 && statusCode < 300) {
      if (responseBody.isEmpty) {
        return null;
      }

      try {
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse;
      } catch (e) {
        throw FormatException('Invalid JSON response: ${e.toString()}');
      }
    } else {
      _handleErrorResponse(statusCode, responseBody);
    }
  }

  // Handle error response
  void _handleErrorResponse(int statusCode, String responseBody) {
    Map<String, dynamic>? errorResponse;

    try {
      errorResponse = jsonDecode(responseBody);
    } catch (e) {
      // If response is not JSON, use raw response
    }

    final message = errorResponse?['message']?.toString() ??
        errorResponse?['error']?.toString() ??
        'HTTP Error $statusCode';

    switch (statusCode) {
      case 400:
        if (errorResponse?['errors'] != null) {
          final errors = Map<String, String>.from(
            (errorResponse!['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                value is List ? value.join(', ') : value.toString(),
              ),
            ),
          );
          throw ValidationException(errors);
        }
        throw BadRequestException(message);
      case 401:
        throw UnauthorizedException(message);
      case 403:
        throw ForbiddenException(message);
      case 404:
        throw NotFoundException(message);
      case 409:
        throw ConflictException(message);
      case 422:
        if (errorResponse?['errors'] != null) {
          final errors = Map<String, String>.from(
            (errorResponse!['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                value is List ? value.join(', ') : value.toString(),
              ),
            ),
          );
          throw ValidationException(errors);
        }
        throw UnprocessableEntityException(message);
      case 429:
        throw RateLimitException(message);
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException(message, statusCode, errorResponse);
      default:
        throw HttpException(message, statusCode);
    }
  }

  // Handle general errors
  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return NoInternetException();
    } else if (error is http.ClientException) {
      return NetworkException(error.message);
    } else if (error is TimeoutException) {
      return TimeoutException();
    } else if (error is FormatException) {
      return FormatException(error.message);
    } else if (error is Exception) {
      return error;
    } else {
      return Exception('Unknown error: $error');
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );

    final token = response is Map
        ? (response['token'] ??
            (response['data'] is Map ? response['data']['token'] : null))
        : null;

    if (token != null) {
      await _setAuthToken(token.toString());
    }

    return response;
  }

  // Logout
  Future<void> logout() async {
    try {
      await post(ApiEndpoints.logout);
    } finally {
      await _clearAuthToken();
    }
  }

  // Refresh token
  Future<void> refreshToken() async {
    final response = await post(ApiEndpoints.refreshToken, requiresAuth: false);

    final token = response is Map
        ? (response['token'] ??
            (response['data'] is Map ? response['data']['token'] : null))
        : null;

    if (token != null) {
      await _setAuthToken(token.toString());
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Get current user
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await get('${ApiEndpoints.baseUrl}/user');
  }

  // Factory methods
  Future<List<dynamic>> getFactories() async {
    return await get(ApiEndpoints.factories);
  }

  Future<Map<String, dynamic>> getFactoryById(String id) async {
    return await get(ApiEndpoints.factoryById.replaceFirst('{id}', id));
  }

  // Code generation methods
  Future<Map<String, dynamic>> generateBundleCodes(
    Map<String, dynamic> data,
  ) async {
    return await post(ApiEndpoints.generateBundleCodes, body: data);
  }

  Future<Map<String, dynamic>> generateCartonCodes(
    Map<String, dynamic> data,
  ) async {
    return await post(ApiEndpoints.generateCartonCodes, body: data);
  }

  Future<Map<String, dynamic>> generatePacketCodes(
    Map<String, dynamic> data,
  ) async {
    return await post(ApiEndpoints.generatePacketCodes, body: data);
  }

  Future<Map<String, dynamic>> generateUnitCodes(
    Map<String, dynamic> data,
  ) async {
    return await post(ApiEndpoints.generateUnitCodes, body: data);
  }

  // Product methods
  Future<List<dynamic>> getProducts() async {
    return await get(ApiEndpoints.products);
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    return await post(ApiEndpoints.products, body: data);
  }

  Future<Map<String, dynamic>> linkCodesToProduct(
    String productId,
    List<String> codeIds,
  ) async {
    return await post(
      ApiEndpoints.linkCodesToProduct.replaceFirst('{id}', productId),
      body: {'code_ids': codeIds},
    );
  }

  Future<Map<String, dynamic>> publishProductCodes(String productId) async {
    return await post(
      ApiEndpoints.publishProductCodes.replaceFirst('{id}', productId),
    );
  }

  // Clean up
  void dispose() {
    _client.close();
  }
}

// Additional exception classes
class BadRequestException extends AppException {
  const BadRequestException([String? message])
      : super(message ?? 'Bad request');
}

class ForbiddenException extends AppException {
  const ForbiddenException([String? message]) : super(message ?? 'Forbidden');
}

class NotFoundException extends AppException {
  const NotFoundException([String? message]) : super(message ?? 'Not found');
}

class ConflictException extends AppException {
  const ConflictException([String? message]) : super(message ?? 'Conflict');
}

class UnprocessableEntityException extends AppException {
  const UnprocessableEntityException([String? message])
      : super(message ?? 'Unprocessable entity');
}

class RateLimitException extends AppException {
  const RateLimitException([String? message])
      : super(message ?? 'Rate limit exceeded');
}

class HttpException extends AppException {
  final int statusCode;

  const HttpException(super.message, this.statusCode);
}
