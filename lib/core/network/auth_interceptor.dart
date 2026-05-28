// Auth Interceptor — Dio interceptor for NexaTrace 26-step backend
//
// Handles three critical status anomalies per the architecture spec:
//   1. 403 — Driver type mismatch (EnsureDriverType middleware, Step 19)
//   2. 422 — AI Chat Guard violation (AIChatLeakFilter middleware, Step 25)
//   3. 422 — Cup of Tea penalty / Anti-fraud velocity block
//
// Also performs automatic Bearer token injection via flutter_secure_storage
// and delegates 401 token refresh cycles to the provided onTokenExpired callback.
//
// Design: all side-effects (navigation, stream blocking) are delegated
// through callbacks so the interceptor remains a pure Dart class with no
// Flutter dependency — testable and reusable.

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trace_odd/core/network/network_exceptions.dart';
import 'package:trace_odd/core/errors/app_exceptions.dart';

/// Callback invoked when the backend signals a 401 and a token refresh
/// should be attempted.  Return a fresh access-token string or null to
/// force a logout.
typedef TokenRefreshCallback = Future<String?> Function();

/// Callback invoked when a driver.type mismatch 403 is detected.
/// Receives the full [DriverTypeMismatchException] so the UI layer can
/// render the appropriate access-denied overlay.
typedef DriverTypeMismatchCallback = void Function(
  DriverTypeMismatchException exception,
);

/// Callback invoked when an AI Chat Guard 422 violation is detected.
/// Receives the [AIChatGuardViolationException] so the chat UI can
/// freeze the input stream and show the masked payload.
typedef AIChatGuardViolationCallback = void Function(
  AIChatGuardViolationException exception,
);

/// Callback invoked when a Cup of Tea penalty is applied (422).
typedef CupOfTeaPenaltyCallback = void Function(
  CupOfTeaPenaltyException exception,
);

/// Callback invoked when the anti-fraud velocity check blocks a cash-out (422).
typedef AntiFraudVelocityCallback = void Function(
  AntiFraudVelocityException exception,
);

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final TokenRefreshCallback? _onTokenExpired;
  final DriverTypeMismatchCallback? _onDriverTypeMismatch;
  final AIChatGuardViolationCallback? _onAIChatGuardViolation;
  final CupOfTeaPenaltyCallback? _onCupOfTeaPenalty;
  final AntiFraudVelocityCallback? _onAntiFraudVelocity;

  /// Storage keys for token retrieval.
  static const String _authTokenKey = 'auth_token';
  static const String _factoryAuthTokenKey = 'factory_auth_token';

  /// Whether token refresh is currently in-flight (prevents thundering herd).
  bool _isRefreshing = false;

  /// Queued requests waiting for the token refresh to complete.
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
  _pendingRequests = [];

  AuthInterceptor({
    required FlutterSecureStorage secureStorage,
    TokenRefreshCallback? onTokenExpired,
    DriverTypeMismatchCallback? onDriverTypeMismatch,
    AIChatGuardViolationCallback? onAIChatGuardViolation,
    CupOfTeaPenaltyCallback? onCupOfTeaPenalty,
    AntiFraudVelocityCallback? onAntiFraudVelocity,
  }) : _secureStorage = secureStorage,
       _onTokenExpired = onTokenExpired,
       _onDriverTypeMismatch = onDriverTypeMismatch,
       _onAIChatGuardViolation = onAIChatGuardViolation,
       _onCupOfTeaPenalty = onCupOfTeaPenalty,
       _onAntiFraudVelocity = onAntiFraudVelocity;

  // ──────────────────────────────────────────────────────────
  // Request — inject Bearer token
  // ──────────────────────────────────────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth injection for login / register / refresh endpoints.
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await _resolveToken(options.path);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Ensure standard headers.
    options.headers['Accept'] = 'application/json';
    options.headers['X-Requested-With'] = 'XMLHttpRequest';

    handler.next(options);
  }

  // ──────────────────────────────────────────────────────────
  // Error — classify and delegate backend anomalies
  // ──────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    // ── 401 — token expired → attempt refresh ────────────────
    if (statusCode == 401 && _onTokenExpired != null) {
      await _handleTokenRefresh(err, handler);
      return;
    }

    // ── 403 — driver.type mismatch ───────────────────────────
    if (statusCode == 403) {
      final body = _tryDecodeBody(err.response?.data);
      final message = body?['message']?.toString() ?? '';

      if (_isDriverTypeMismatch(message)) {
        final exception = _parseDriverTypeMismatch(message, body);
        _onDriverTypeMismatch?.call(exception);
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: exception,
            type: DioExceptionType.badResponse,
          ),
        );
      }

      // Generic 403 — let caller handle.
      return handler.next(err);
    }

    // ── 422 — AI Chat Guard / Cup of Tea / Anti-Fraud ────────
    if (statusCode == 422) {
      final body = _tryDecodeBody(err.response?.data);
      final message = body?['message']?.toString() ?? '';
      final errors = _extractValidationErrors(body);

      // 422a — AI Chat Guard violation (contact info leak)
      if (_isAIChatGuardViolation(message, body)) {
        final exception = _parseAIChatGuardViolation(message, body, errors);
        _onAIChatGuardViolation?.call(exception);
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: exception,
            type: DioExceptionType.badResponse,
          ),
        );
      }

      // 422b — Cup of Tea penalty
      if (_isCupOfTeaPenalty(message, body)) {
        final exception = _parseCupOfTeaPenalty(message, body, errors);
        _onCupOfTeaPenalty?.call(exception);
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: exception,
            type: DioExceptionType.badResponse,
          ),
        );
      }

      // 422c — Anti-Fraud velocity block
      if (_isAntiFraudBlock(message, body)) {
        final exception = _parseAntiFraudBlock(message, body, errors);
        _onAntiFraudVelocity?.call(exception);
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: exception,
            type: DioExceptionType.badResponse,
          ),
        );
      }

      // Generic 422 validation — let caller handle.
      return handler.next(err);
    }

    // ── All other errors — pass through ──────────────────────
    handler.next(err);
  }

  // ──────────────────────────────────────────────────────────
  // Token resolution
  // ──────────────────────────────────────────────────────────

  /// Picks the correct token based on the request path.
  /// Factory-scoped routes use the factory auth token; everything else
  /// uses the main auth token.
  Future<String?> _resolveToken(String path) async {
    final normalized = path.startsWith('/') ? path : '/$path';

    final isFactoryRoute = normalized.contains('/factory/') ||
        normalized.contains('/codes/') ||
        normalized.contains('/production/');

    if (isFactoryRoute) {
      return await _secureStorage.read(key: _factoryAuthTokenKey);
    }
    return await _secureStorage.read(key: _authTokenKey);
  }

  /// Whether the given path is an auth endpoint that should NOT receive
  /// a Bearer token.
  bool _isAuthEndpoint(String path) {
    final lower = path.toLowerCase();
    return lower.contains('/auth/login') ||
        lower.contains('/auth/register') ||
        lower.contains('/auth/refresh') ||
        lower.contains('/auth/forgot-password') ||
        lower.contains('/auth/reset-password') ||
        lower.contains('/factory/login');
  }

  // ──────────────────────────────────────────────────────────
  // Token refresh cycle
  // ──────────────────────────────────────────────────────────

  Future<void> _handleTokenRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isRefreshing) {
      // Queue this request — it will be retried after refresh completes.
      _pendingRequests.add((
        options: err.requestOptions,
        handler: handler,
      ));
      return;
    }

    _isRefreshing = true;
    try {
      final newToken = await _onTokenExpired?.call();
      if (newToken != null && newToken.isNotEmpty) {
        // Update stored token.
        await _secureStorage.write(key: _authTokenKey, value: newToken);

        // Retry the original request with the new token.
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';

        // Resolve the Dio instance through the request options.
        final dio = Dio();
        try {
          final response = await dio.fetch(opts);
          handler.resolve(response);
        } on DioException catch (retryErr) {
          handler.next(retryErr);
        }

        // Retry all queued requests.
        for (final pending in _pendingRequests) {
          final pendingOpts = pending.options;
          pendingOpts.headers['Authorization'] = 'Bearer $newToken';
          try {
            final response = await dio.fetch(pendingOpts);
            pending.handler.resolve(response);
          } on DioException catch (queuedErr) {
            pending.handler.next(queuedErr);
          }
        }
      } else {
        // Refresh failed — reject all.
        handler.next(err);
        for (final pending in _pendingRequests) {
          pending.handler.next(
            DioException(
              requestOptions: pending.options,
              error: const TokenExpiredException(),
              type: DioExceptionType.badResponse,
            ),
          );
        }
      }
    } catch (_) {
      handler.next(err);
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  // ──────────────────────────────────────────────────────────
  // 403 — Driver type mismatch detection
  // ──────────────────────────────────────────────────────────

  static const List<String> _driverTypeMismatchPhrases = [
    'Driver type',
    'driver type',
    'not authorized',
    'is not authorized',
    'Allowed:',
  ];

  bool _isDriverTypeMismatch(String message) {
    return _driverTypeMismatchPhrases
        .every((phrase) => message.contains(phrase));
  }

  DriverTypeMismatchException _parseDriverTypeMismatch(
    String message,
    Map<String, dynamic>? body,
  ) {
    // Extract driver type from message pattern:
    // "Driver type 'factory' is not authorized. Allowed: truck, bus"
    final typePattern = RegExp(r"Driver type '(\w+)'");
    final allowedPattern = RegExp(r"Allowed:\s*(.+)");

    final actualType = typePattern.firstMatch(message)?.group(1) ?? 'unknown';
    final requiredType =
        allowedPattern.firstMatch(message)?.group(1)?.trim() ?? 'unknown';

    return DriverTypeMismatchException(
      actualDriverType: actualType,
      requiredDriverType: requiredType,
      backendMessage: message,
    );
  }

  // ──────────────────────────────────────────────────────────
  // 422 — AI Chat Guard detection
  // ──────────────────────────────────────────────────────────

  static const List<String> _chatGuardPhrases = [
    'Message blocked',
    'contact information',
    'NexaTrace policy',
    'violates',
  ];

  bool _isAIChatGuardViolation(
    String message,
    Map<String, dynamic>? body,
  ) {
    if (_chatGuardPhrases.every((p) => message.contains(p))) return true;
    // Also check for 'detected_pattern' key in body.
    if (body?['detected_pattern'] != null) return true;
    if (body?['leak_type'] != null) return true;
    return false;
  }

  AIChatGuardViolationException _parseAIChatGuardViolation(
    String message,
    Map<String, dynamic>? body,
    Map<String, String> errors,
  ) {
    return AIChatGuardViolationException(
      detectedPattern:
          body?['detected_pattern']?.toString() ?? 'unknown_pattern',
      maskedPayload:
          body?['masked_payload']?.toString() ?? '[REDACTED]',
      leakType: body?['leak_type']?.toString() ?? 'unknown',
      errors: errors,
    );
  }

  // ──────────────────────────────────────────────────────────
  // 422 — Cup of Tea penalty detection
  // ──────────────────────────────────────────────────────────

  bool _isCupOfTeaPenalty(
    String message,
    Map<String, dynamic>? body,
  ) {
    final lower = message.toLowerCase();
    if (lower.contains('cup of tea') || lower.contains('penalty')) return true;
    if (body?['penalty_amount'] != null) return true;
    return false;
  }

  CupOfTeaPenaltyException _parseCupOfTeaPenalty(
    String message,
    Map<String, dynamic>? body,
    Map<String, String> errors,
  ) {
    final failedBids = (body?['failed_bid_count'] as num?)?.toInt() ?? 2;
    final penalty =
        (body?['penalty_amount'] as num?)?.toDouble() ?? 50.0;

    return CupOfTeaPenaltyException(
      failedBidCount: failedBids,
      penaltyAmount: penalty,
    );
  }

  // ──────────────────────────────────────────────────────────
  // 422 — Anti-Fraud velocity block detection
  // ──────────────────────────────────────────────────────────

  bool _isAntiFraudBlock(
    String message,
    Map<String, dynamic>? body,
  ) {
    final lower = message.toLowerCase();
    if (lower.contains('cash-out blocked') ||
        lower.contains('usage') && lower.contains('70%')) return true;
    if (body?['usage_ratio'] != null) return true;
    return false;
  }

  AntiFraudVelocityException _parseAntiFraudBlock(
    String message,
    Map<String, dynamic>? body,
    Map<String, String> errors,
  ) {
    final ratio = (body?['usage_ratio'] as num?)?.toDouble() ?? 0.0;
    return AntiFraudVelocityException(
      usageRatio: ratio,
      errors: errors,
    );
  }

  // ──────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────

  /// Safe JSON decode — returns null on any failure.
  Map<String, dynamic>? _tryDecodeBody(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return null;
  }

  /// Extract validation errors map from a 422 body.
  Map<String, String> _extractValidationErrors(Map<String, dynamic>? body) {
    if (body == null || body['errors'] == null) return {};
    final raw = body['errors'];
    if (raw is Map) {
      return raw.map<String, String>(
        (k, v) => MapEntry(
          k.toString(),
          v is List ? v.join(', ') : v.toString(),
        ),
      );
    }
    return {};
  }
}
