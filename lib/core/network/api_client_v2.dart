// API Client v2 — Dio-based network engine for NexaTrace 6-panel backend
//
// This is an ADDITIVE layer.  The existing `ApiClient` (lib/core/services/api_client.dart)
// which uses the `http` package remains untouched.  This client wraps Dio and provides:
//
//   • Centralised panel-aware base URL construction
//   • AuthInterceptor integration for 403/422 anomaly handling
//   • Token refresh cycle via flutter_secure_storage
//   • Offline sync uuid-idempotency gating (Step 10)
//   • 30-second timeout matching the existing ApiConfig
//
// Usage:
//   final client = NexaTraceApiClient.instance;
//   final response = await client.get('/marketplace/catalog/search', queryParams: {'q': 'rice'});
//   final response = await client.post('/factory/production/batches', body: {...});

import 'package:dio/dio.dart';
import 'package:trace_odd/core/network/auth_interceptor.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/core/services/web_safe_storage.dart';

/// Singleton Dio wrapper configured for the NexaTrace backend.
class NexaTraceApiClient {
  static NexaTraceApiClient? _instance;

  late final Dio _dio;
  late AuthInterceptor _authInterceptor;
  late final WebSafeStorage _storage;

  /// Stored callbacks so they survive interceptor rebuilds.
  TokenRefreshCallback? _onTokenExpired;
  DriverTypeMismatchCallback? _onDriverTypeMismatch;
  AIChatGuardViolationCallback? _onAIChatGuardViolation;
  CupOfTeaPenaltyCallback? _onCupOfTeaPenalty;
  AntiFraudVelocityCallback? _onAntiFraudVelocity;

  // ── Callback setters (public so AppInitializer can wire them) ──

  set onTokenExpired(TokenRefreshCallback? cb) {
    _onTokenExpired = cb;
    _rebuildInterceptor();
  }

  set onDriverTypeMismatch(DriverTypeMismatchCallback? cb) {
    _onDriverTypeMismatch = cb;
    _rebuildInterceptor();
  }

  set onAIChatGuardViolation(AIChatGuardViolationCallback? cb) {
    _onAIChatGuardViolation = cb;
    _rebuildInterceptor();
  }

  set onCupOfTeaPenalty(CupOfTeaPenaltyCallback? cb) {
    _onCupOfTeaPenalty = cb;
    _rebuildInterceptor();
  }

  set onAntiFraudVelocity(AntiFraudVelocityCallback? cb) {
    _onAntiFraudVelocity = cb;
    _rebuildInterceptor();
  }

  // ── Singleton access ──────────────────────────────────────

  factory NexaTraceApiClient({
    required WebSafeStorage storage,
    TokenRefreshCallback? onTokenExpired,
    DriverTypeMismatchCallback? onDriverTypeMismatch,
    AIChatGuardViolationCallback? onAIChatGuardViolation,
    CupOfTeaPenaltyCallback? onCupOfTeaPenalty,
    AntiFraudVelocityCallback? onAntiFraudVelocity,
  }) {
    _instance ??= NexaTraceApiClient._internal(
      storage: storage,
      onTokenExpired: onTokenExpired,
      onDriverTypeMismatch: onDriverTypeMismatch,
      onAIChatGuardViolation: onAIChatGuardViolation,
      onCupOfTeaPenalty: onCupOfTeaPenalty,
      onAntiFraudVelocity: onAntiFraudVelocity,
    );
    return _instance!;
  }

  static NexaTraceApiClient get instance {
    if (_instance == null) {
      throw StateError(
        'NexaTraceApiClient not initialized. '
        'Call NexaTraceApiClient(storage: ...) first.',
      );
    }
    return _instance!;
  }

  NexaTraceApiClient._internal({
    required WebSafeStorage storage,
    TokenRefreshCallback? onTokenExpired,
    DriverTypeMismatchCallback? onDriverTypeMismatch,
    AIChatGuardViolationCallback? onAIChatGuardViolation,
    CupOfTeaPenaltyCallback? onCupOfTeaPenalty,
    AntiFraudVelocityCallback? onAntiFraudVelocity,
  }) {
    _storage = storage;
    _onTokenExpired = onTokenExpired;
    _onDriverTypeMismatch = onDriverTypeMismatch;
    _onAIChatGuardViolation = onAIChatGuardViolation;
    _onCupOfTeaPenalty = onCupOfTeaPenalty;
    _onAntiFraudVelocity = onAntiFraudVelocity;

    _authInterceptor = AuthInterceptor(
      storage: storage,
      onTokenExpired: onTokenExpired,
      onDriverTypeMismatch: onDriverTypeMismatch,
      onAIChatGuardViolation: onAIChatGuardViolation,
      onCupOfTeaPenalty: onCupOfTeaPenalty,
      onAntiFraudVelocity: onAntiFraudVelocity,
    );

    _dio = _createDio(_authInterceptor);
  }

  // ── Dio factory ───────────────────────────────────────────

  Dio _createDio(AuthInterceptor interceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: PanelRouteConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        validateStatus: (status) {
          // Only 2xx is success → 4xx/5xx trigger onError in interceptor.
          return status != null && status >= 200 && status < 300;
        },
      ),
    );

    dio.interceptors.add(interceptor);

    // Optional: logging interceptor for debug builds.
    // dio.interceptors.add(LogInterceptor(
    //   requestBody: true,
    //   responseBody: true,
    // ));

    return dio;
  }

  void _rebuildInterceptor() {
    final dioBaseOpts = _dio.options;
    // Remove old interceptor and add a new one with updated callbacks.
    _dio.interceptors.remove(_authInterceptor);
    _authInterceptor = AuthInterceptor(
      storage: _storage,
      onTokenExpired: _onTokenExpired,
      onDriverTypeMismatch: _onDriverTypeMismatch,
      onAIChatGuardViolation: _onAIChatGuardViolation,
      onCupOfTeaPenalty: _onCupOfTeaPenalty,
      onAntiFraudVelocity: _onAntiFraudVelocity,
    );
    _dio.interceptors.add(_authInterceptor);
  }

  // ── Public HTTP methods ───────────────────────────────────

  /// GET request with optional query parameters.
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParams,
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// POST request with JSON body.
  Future<Response<dynamic>> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: body,
      queryParameters: queryParams,
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// PUT request with JSON body.
  Future<Response<dynamic>> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: body,
      queryParameters: queryParams,
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// PATCH request with JSON body.
  Future<Response<dynamic>> patch(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: body,
      queryParameters: queryParams,
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// DELETE request.
  Future<Response<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      queryParameters: queryParams,
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// Multipart file upload.
  Future<Response<dynamic>> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, String>? extraFields,
    CancelToken? cancelToken,
    void Function(int, int)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (extraFields != null) ...extraFields,
    });

    return _dio.post(
      path,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onProgress,
    );
  }

  /// Raw Dio instance — use only when custom configuration is needed.
  Dio get dio => _dio;

  /// Dispose the underlying HTTP client.
  void dispose() {
    _dio.close();
    _instance = null;
  }
}
