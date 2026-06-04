// API Client for NexaTrace System
// This file handles all HTTP requests to the Laravel backend

import 'dart:convert';
import 'dart:io' show SocketException;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    // Immediately set the header so the next API call doesn't wait for
    // a SharedPreferences round-trip (prevents race-condition 401s on web)
    _headers['Authorization'] = 'Bearer $token';
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

      final isFactoryEndpoint =
          normalizedPath.contains('/factory/') ||
          normalizedPath.contains('/codes/');

      if (isFactoryEndpoint) {
        token = prefs.getString('factory_auth_token');
      }

      token ??= prefs.getString(AppConstants.authTokenKey);
    } else {
      token = prefs.getString(AppConstants.authTokenKey);
    }

    if (token != null && token.trim().isNotEmpty) {
      _headers['Authorization'] = 'Bearer $token';
    }
    // Do NOT remove the header here — setAuthToken may have already
    // injected it directly to avoid a SharedPreferences race on web.
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

  Future<Uint8List> getBytes(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    try {
      if (requiresAuth) {
        await _initializeHeaders(endpoint: endpoint);
      }

      final requestHeaders = {..._headers, if (headers != null) ...headers};

      requestHeaders['Accept'] =
          requestHeaders['Accept'] ??
          'application/pdf,application/octet-stream,*/*';

      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final uri = Uri.parse(normalizedEndpoint).replace(
        queryParameters: (queryParams ?? queryParameters)?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      final response = await _makeCustomRequest(
        'GET',
        uri,
        headers: requestHeaders,
      ).timeout(const Duration(seconds: 30));

      if (response.isRedirect) {
        final location = response.headers['location'];
        throw RedirectException(
          'GET request was redirected. This may indicate authentication failed.',
          location: location,
          originalMethod: 'GET',
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.bodyBytes.isEmpty) {
          throw Exception('Empty response body for $endpoint');
        }
        return response.bodyBytes;
      }

      _handleErrorResponse(
        response.statusCode,
        response.body,
        'Download failed',
      );
      throw Exception('Failed to download bytes');
    } catch (error) {
      throw _handleError(error);
    }
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

  // Upload file (works on both web and native)
  Future<dynamic> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    Uint8List? fileBytes,
    String? fileName,
    bool requiresAuth = true,
  }) async {
    try {
      if (requiresAuth) {
        await _initializeHeaders(endpoint: endpoint);
      }

      final requestHeaders = {..._headers, if (headers != null) ...headers};
      requestHeaders['Accept'] = 'application/json';

      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final uri = Uri.parse(normalizedEndpoint);
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(requestHeaders);

      // On web, use bytes; on native, use file path
      if (kIsWeb && fileBytes != null) {
        final name = fileName ?? 'upload';
        request.files.add(
          http.MultipartFile.fromBytes(fieldName, fileBytes, filename: name),
        );
      } else {
        final file = await http.MultipartFile.fromPath(fieldName, filePath);
        request.files.add(file);
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

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
          response = await _makeCustomRequest(
            'GET',
            uri,
            headers: requestHeaders,
          ).timeout(const Duration(seconds: 30));
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

      // Wave 2 — TokenVersionGuard: handle transparent token_stale refresh
      if (response.statusCode == 401 &&
          requiresAuth &&
          retryCount == 0 &&
          endpoint != '/api/v1/auth/refresh' &&
          endpoint != '/factory/auth/refresh' &&
          endpoint != '/api/v1/auth/login' &&
          endpoint != '/factory/auth/login') {
        final refreshed = await _handleTokenStaleIfNeeded(response);
        if (refreshed) {
          await _initializeHeaders(endpoint: endpoint);
          return await _makeRequest(
            method,
            endpoint,
            body: body,
            queryParams: queryParams,
            requiresAuth: requiresAuth,
            retryCount: retryCount + 1,
          );
        }
      }

      return _handleResponse(response);
    } catch (error, stackTrace) {
      ErrorLogger.error(
        'API Request Failed: $method $endpoint',
        error,
        stackTrace,
      );
      ErrorLogger.debug(
        'API Request Failed Details: Method: $method - Endpoint: $endpoint - Auth: $requiresAuth - Retry: $retryCount - Error: ${error.toString()}',
      );

      if (error is UnauthorizedException &&
          requiresAuth &&
          retryCount == 0 &&
          endpoint != ApiEndpoints.refreshToken &&
          endpoint != '/factory/auth/refresh' &&
          endpoint != ApiEndpoints.login &&
          endpoint != '/factory/auth/login' &&
          endpoint != '/api/v1/auth/refresh' &&
          endpoint != '/api/v1/auth/login') {
        try {
          await refreshToken(originalEndpoint: endpoint);
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

    // If the endpoint already starts with /api/, strip the overlapping
    // /api prefix from the base URL to avoid double-prefix like
    // http://host/api/v1/api/v1/auth/refresh
    if (endpoint.startsWith('/api/')) {
      final apiIndex = normalizedBaseUrl.indexOf('/api/');
      if (apiIndex != -1) {
        return '${normalizedBaseUrl.substring(0, apiIndex)}$endpoint';
      }
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
      // Extract server error detail before throwing
      String? serverDetail;
      try {
        final errBody = jsonDecode(responseBody);
        if (errBody is Map) {
          serverDetail =
              errBody['message']?.toString() ?? errBody['error']?.toString();
          // Laravel debug mode may include file/line in 'exception' key
          if (serverDetail == null && errBody['exception'] is String) {
            serverDetail = errBody['exception'];
          }
          // Laravel validation errors may be under 'errors'
          if (serverDetail == null && errBody['errors'] is Map) {
            final errs = errBody['errors'] as Map;
            serverDetail = errs.values
                .map((v) => v is List ? v.first.toString() : v.toString())
                .join('; ');
          }
        }
      } catch (_) {}

      final effectiveMessage = serverDetail ?? 'HTTP Error $statusCode';
      _handleErrorResponse(statusCode, responseBody, effectiveMessage);
    }
  }

  // Handle error response
  void _handleErrorResponse(
    int statusCode,
    String responseBody,
    String fallbackMessage,
  ) {
    Map<String, dynamic>? errorResponse;

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        errorResponse = decoded;
      }
    } catch (e) {
      // If response is not JSON, use raw response as message
    }

    final message =
        errorResponse?['message']?.toString() ??
        errorResponse?['error']?.toString() ??
        fallbackMessage;

    // ── Safe error-map extraction (guards against non-Map types) ──
    Map<String, String>? _safeExtractErrors(dynamic errorsNode) {
      if (errorsNode == null) return null;
      if (errorsNode is Map) {
        final map = <String, String>{};
        for (final entry in errorsNode.entries) {
          final key = entry.key.toString();
          final val = entry.value;
          if (val is List) {
            map[key] = val.map((e) => e.toString()).join(', ');
          } else {
            map[key] = val.toString();
          }
        }
        return map;
      }
      // Fallback: wrap the entire payload as a single "general" error
      return {'general': errorsNode.toString()};
    }

    switch (statusCode) {
      case 400:
        final errors = _safeExtractErrors(errorResponse?['errors']);
        if (errors != null) throw ValidationException(errors);
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
        final errors = _safeExtractErrors(errorResponse?['errors']);
        if (errors != null) throw ValidationException(errors);
        throw UnprocessableEntityException(message);
      case 429:
        throw RateLimitException(message);
      case 423:
        final data = (errorResponse?['data'] is Map)
            ? (errorResponse?['data'] as Map).cast<String, dynamic>()
            : <String, dynamic>{};
        final invoice = (data['invoice'] is Map)
            ? (data['invoice'] as Map).cast<String, dynamic>()
            : <String, dynamic>{};
        final invoiceId =
            (invoice['id'] ??
                    data['invoice_id'] ??
                    errorResponse?['invoice_id'])
                ?.toString()
                .trim();
        throw LockedException(
          message: 'Please pay the invoice to unlock download',
          invoiceId: (invoiceId == null || invoiceId.isEmpty)
              ? 'unknown'
              : invoiceId,
        );
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

  // ═══════════════════════════════════════════════════════════
  // Wave 2 — Unified Global Auth (Section 10.1.5)
  // Accepts any identifier: phone, email, CNIC, passport.
  // ═══════════════════════════════════════════════════════════

  /// Legacy login kept for backward compat — delegates to unifiedLogin.
  Future<Map<String, dynamic>> login(String email, String password) async {
    return unifiedLogin(identifier: email, password: password);
  }

  /// Unified login accepting any claim type with optional fleet context.
  Future<Map<String, dynamic>> unifiedLogin({
    required String identifier,
    String? claimType,
    required String password,
    String? fleetRole,
    String? fleetType,
  }) async {
    final body = <String, dynamic>{
      'identifier': identifier,
      'password': password,
    };
    if (claimType != null) body['claim_type'] = claimType;
    if (fleetRole != null) body['fleet_role'] = fleetRole;
    if (fleetType != null) body['fleet_type'] = fleetType;

    final response = await post(
      '/api/v1/auth/login',
      body: body,
      requiresAuth: false,
    );

    final token = response is Map
        ? (response['token'] ??
              (response['data'] is Map ? response['data']['token'] : null))
        : null;

    if (token != null) {
      await _setAuthToken(token.toString());
      final grantsVersion = response is Map
          ? (response['data'] is Map
                ? response['data']['grants_version']
                : null)
          : null;
      if (grantsVersion != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('grants_version', grantsVersion as int);
      }
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

  // Refresh token — uses unified /api/v1/auth/refresh for Wave 2
  Future<void> refreshToken({String? originalEndpoint}) async {
    final isFactory =
        originalEndpoint != null &&
        (originalEndpoint.contains('/factory/') ||
            originalEndpoint.contains('/codes/'));

    final refreshEndpoint = isFactory
        ? '/factory/auth/refresh'
        : '/api/v1/auth/refresh';

    try {
      final response = await post(refreshEndpoint, requiresAuth: isFactory);

      final token = response is Map
          ? (response['token'] ??
                (response['data'] is Map ? response['data']['token'] : null))
          : null;

      if (token != null) {
        if (isFactory) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('factory_auth_token', token.toString());
        } else {
          await _setAuthToken(token.toString());
          // Update grants_version after refresh
          final grantsVersion = response is Map
              ? (response['grants_version'] ??
                    (response['data'] is Map
                        ? response['data']['grants_version']
                        : null))
              : null;
          if (grantsVersion != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('grants_version', grantsVersion as int);
          }
        }
      }
    } catch (_) {
      if (isFactory) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('factory_auth_token');
      } else {
        await _clearAuthToken();
      }
      rethrow;
    }
  }

  /// Wave 2 — TokenVersionGuard: check if 401 is due to stale token version.
  /// Returns true if token was refreshed and caller should retry.
  Future<bool> _handleTokenStaleIfNeeded(http.Response response) async {
    if (response.statusCode != 401) return false;

    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['reason'] == 'token_stale') {
        await refreshToken();
        return true;
      }
    } catch (_) {
      // Not JSON or not token_stale — let normal error handling take over
    }
    return false;
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Get current user — Wave 2 unified /api/v1/auth/me
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await get('/api/v1/auth/me');
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
