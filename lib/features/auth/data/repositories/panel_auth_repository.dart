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
import 'package:shared_preferences/shared_preferences.dart';
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
  }) : _client = client,
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
    String?
    identifier, // Raw user input (email or phone) — sent as 'identifier'
    Map<String, dynamic> metadata = const {}, // Extra fields merged into body
  }) async {
    final endpoint = _loginEndpointFor(panel);
    final body = <String, dynamic>{
      'password': password,
      'remember_me': rememberMe,
      if (identifier != null && identifier.isNotEmpty)
        'identifier': identifier.trim()
      else
        'email': email.trim().toLowerCase(),
      if (companyId != null && companyId.isNotEmpty) 'company_id': companyId,
      ...metadata,
    };

    if (kDebugMode) {
      debugPrint('PANEL_AUTH: Logging into ${panel.label} at $endpoint');
    }

    final response = await _client.post(endpoint, body: body);
    final data = _extractData(response.data);

    // Extract fields — backend returns { token: "...", data: { user: {...} } }
    // Fleet panels may return { token: "...", data: { id, account_name, ... } }
    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('No authentication token received from backend');
    }

    // User object: new identity spine wraps it in data.user;
    // fleet endpoints place user fields directly inside data.
    final user = (data['user'] is Map)
        ? Map<String, dynamic>.from(data['user'] as Map)
        : (data.containsKey('id') || data.containsKey('account_name'))
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};

    final driverType = user['driver_type']?.toString().toLowerCase();
    final userId = user['id']?.toString() ?? user['user_id']?.toString() ?? '';
    final cId =
        user['company_id']?.toString() ?? data['company_id']?.toString();
    final cName =
        user['company_name']?.toString() ?? data['company_name']?.toString();

    // ── Persist tokens ──────────────────────────────────
    await _persistSession(panel, token, user);

    // ── Fleet metadata → SharedPreferences (dashboard routers read this) ──
    await _persistFleetMetadata(user, metadata);

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
  ///
  /// Backend auth responses use the shape:
  ///   { "token": "...", "data": { "user": {...}, ... } }
  ///
  /// Top-level keys (token, message, etc.) are merged into the nested
  /// `data` object so callers can access everything from a single map.
  Map<String, dynamic> _extractData(dynamic responseBody) {
    if (responseBody == null) return {};
    if (responseBody is Map<String, dynamic>) {
      // Unwrap the nested `data` key if present.
      final nested = responseBody['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(
              responseBody['data'] as Map<String, dynamic>,
            )
          : <String, dynamic>{};

      // Merge top-level keys (token, message, etc.) into the result.
      // Nested values take priority on collision.
      for (final entry in responseBody.entries) {
        if (entry.key != 'data') {
          nested.putIfAbsent(entry.key, () => entry.value);
        }
      }

      return nested.isNotEmpty ? nested : responseBody;
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
      value: DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    );

    final driverType = user['driver_type']?.toString();
    if (driverType != null) {
      await _secureStorage.write(
        key: '${storageKey}_driver_type',
        value: driverType,
      );
    }
  }

  /// Persist fleet routing metadata to SharedPreferences so dashboard
  /// routers (e.g. _BusFleetRouter) can resolve the correct surface.
  Future<void> _persistFleetMetadata(
    Map<String, dynamic> user,
    Map<String, dynamic> metadata,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final fleetRole =
        metadata['fleet_role']?.toString() ??
        user['fleet_role']?.toString();
    if (fleetRole != null && fleetRole.isNotEmpty) {
      await prefs.setString('fleet_role', fleetRole);
    }

    final accountName =
        user['account_name']?.toString() ?? user['display_name']?.toString();
    if (accountName != null && accountName.isNotEmpty) {
      await prefs.setString('bus_owner_name', accountName);
    }

    // Driver / Conductor name for their respective dashboards.
    final driverName =
        user['account_name']?.toString() ?? user['display_name']?.toString();
    if (driverName != null && driverName.isNotEmpty) {
      await prefs.setString('driver_name', driverName);
      await prefs.setString('conductor_name', driverName);
    }
  }
}
