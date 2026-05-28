// Panel Auth Repository — Multi-panel authentication data layer
//
// Wires the `NexaTraceApiClient` (Dio-based, Setup 1) directly into the
// authentication flow.  Handles login across all 5 endpoints by dispatching
// to the correct backend route based on `UserPanel`.
//
// On successful handshake:
//   1. Stores tokens in flutter_secure_storage
//   2. Parses `driver_type` from the response
//   3. Maps against `EnsureDriverType` routing boundaries (Step 19)
//   4. Returns a `PanelAuthResponse` with full session metadata

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/core/network/api_client_v2.dart';
import 'package:trace_odd/core/network/network_exceptions.dart';

/// Data class returned after successful authentication.
class PanelAuthResponse {
  final UserPanel panel;
  final String token;
  final String userId;
  final String? driverType;
  final String? companyId;
  final String? companyName;
  final Map<String, dynamic> rawUser;

  const PanelAuthResponse({
    required this.panel,
    required this.token,
    required this.userId,
    this.driverType,
    this.companyId,
    this.companyName,
    required this.rawUser,
  });

  /// Whether this user's driver type is valid for the current panel.
  bool get isDriverTypeValid {
    if (driverType == null) return true; // Not a driver
    final allowed = panel.allowedDriverTypes;
    if (allowed.isEmpty) return true; // Panel doesn't restrict driver types
    return allowed.contains(driverType!.toLowerCase());
  }
}

/// Repository that handles login/logout for all 6 panels via Dio.
class PanelAuthRepository {
  final NexaTraceApiClient _client;
  final FlutterSecureStorage _secureStorage;

  PanelAuthRepository({
    required NexaTraceApiClient client,
    required FlutterSecureStorage secureStorage,
  })  : _client = client,
        _secureStorage = secureStorage;

  // ── Login ─────────────────────────────────────────────────

  /// Authenticate against the correct backend endpoint for [panel].
  ///
  /// Route mapping:
  ///   superAdmin  → POST /api/v1/auth/login
  ///   factory     → POST /api/v1/factory/login (or /api/v1/auth/login with factory context)
  ///   marketplace → POST /api/v1/auth/login (reseller/shopkeeper context)
  ///   truckFleet  → POST /api/v1/auth/login (driver context)
  ///   busFleet    → POST /api/v1/auth/login (driver context)
  ///   customer    → POST /api/v1/auth/login
  Future<PanelAuthResponse> login({
    required UserPanel panel,
    required String email,
    required String password,
    bool rememberMe = false,
    String? companyId, // Factory context identifier
  }) async {
    final endpoint = _loginEndpointFor(panel);
    final body = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
      'remember_me': rememberMe,
      if (companyId != null && companyId.isNotEmpty) 'company_id': companyId,
    };

    if (kDebugMode) {
      debugPrint('PANEL_AUTH: Logging into ${panel.label} at $endpoint');
    }

    final response = await _client.post(endpoint, body: body);
    final data = _extractData(response.data);

    // Extract fields — backend returns { data: { token, user: {...} } }
    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('No authentication token received from backend');
    }

    final user = (data['user'] is Map)
        ? Map<String, dynamic>.from(data['user'] as Map)
        : <String, dynamic>{};

    final driverType = user['driver_type']?.toString().toLowerCase();
    final userId = user['id']?.toString() ??
        user['user_id']?.toString() ??
        '';
    final cId = user['company_id']?.toString() ??
        data['company_id']?.toString();
    final cName = user['company_name']?.toString() ??
        data['company_name']?.toString();

    // ── Persist tokens ──────────────────────────────────
    await _persistSession(panel, token, user);

    final authResponse = PanelAuthResponse(
      panel: panel,
      token: token,
      userId: userId,
      driverType: driverType,
      companyId: cId,
      companyName: cName,
      rawUser: user,
    );

    // ── Validate driver type against panel ───────────────
    if (!authResponse.isDriverTypeValid) {
      throw DriverTypeMismatchException(
        actualDriverType: driverType ?? 'unknown',
        requiredDriverType: panel.allowedDriverTypes.join(', '),
        backendMessage:
            'Driver type \'${driverType ?? "unknown"}\' is not authorized '
            'for the ${panel.label} panel.',
      );
    }

    return authResponse;
  }

  // ── Logout ────────────────────────────────────────────────

  Future<void> logout(UserPanel panel) async {
    try {
      await _client.post(_logoutEndpointFor(panel));
    } catch (_) {
      // Even if the API call fails, clear local storage.
    }

    await _secureStorage.delete(key: panel.tokenStorageKey);
    await _secureStorage.delete(key: '${panel.tokenStorageKey}_user');
    await _secureStorage.delete(key: '${panel.tokenStorageKey}_expiry');
    await _secureStorage.delete(key: '${panel.tokenStorageKey}_driver_type');
  }

  // ── Session check ─────────────────────────────────────────

  Future<bool> isAuthenticated(UserPanel panel) async {
    final token = await _secureStorage.read(key: panel.tokenStorageKey);
    final expiryStr = await _secureStorage.read(
      key: '${panel.tokenStorageKey}_expiry',
    );

    if (token == null || expiryStr == null) return false;

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null || expiry.isBefore(DateTime.now())) return false;

    return true;
  }

  Future<String?> getStoredToken(UserPanel panel) async {
    return _secureStorage.read(key: panel.tokenStorageKey);
  }

  /// Returns the stored driver_type for this panel context, or null.
  Future<String?> getStoredDriverType(UserPanel panel) async {
    return _secureStorage.read(key: '${panel.tokenStorageKey}_driver_type');
  }

  // ── Private helpers ───────────────────────────────────────

  String _loginEndpointFor(UserPanel panel) {
    switch (panel) {
      case UserPanel.superAdmin:
        return '/api/v1/auth/login';
      case UserPanel.factory:
        return '/api/v1/factory/login';
      case UserPanel.marketplace:
        return '/api/v1/auth/login'; // Reseller/shopkeeper use main auth
      case UserPanel.truckFleet:
        return '/api/v1/auth/login'; // Driver context
      case UserPanel.busFleet:
        return '/api/v1/auth/login'; // Driver context
      case UserPanel.customer:
        return '/api/v1/auth/login';
    }
  }

  String _logoutEndpointFor(UserPanel panel) {
    switch (panel) {
      case UserPanel.superAdmin:
        return '/api/v1/auth/logout';
      case UserPanel.factory:
        return '/api/v1/factory/logout';
      default:
        return '/api/v1/auth/logout';
    }
  }

  /// Safely extract `data` from a response that may be wrapped.
  Map<String, dynamic> _extractData(dynamic responseBody) {
    if (responseBody == null) return {};
    if (responseBody is Map<String, dynamic>) {
      // Backend wraps in { data: {...} }
      if (responseBody['data'] is Map<String, dynamic>) {
        return responseBody['data'] as Map<String, dynamic>;
      }
      return responseBody;
    }
    return {};
  }

  Future<void> _persistSession(
    UserPanel panel,
    String token,
    Map<String, dynamic> user,
  ) async {
    final storageKey = panel.tokenStorageKey;
    await _secureStorage.write(key: storageKey, value: token);
    await _secureStorage.write(
      key: '${storageKey}_user',
      value: jsonEncode(user),
    );
    await _secureStorage.write(
      key: '${storageKey}_expiry',
      value: DateTime.now()
          .add(const Duration(hours: 24))
          .toIso8601String(),
    );

    final driverType = user['driver_type']?.toString();
    if (driverType != null) {
      await _secureStorage.write(
        key: '${storageKey}_driver_type',
        value: driverType,
      );
    }
  }
}
