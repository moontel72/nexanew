// Factory domain auth cache — the factory panel's OWN cached session.
//
// ── WHY THIS FILE EXISTS (PANEL-SEPARATION-PLAN.md §17.8, step B1) ──────────────────────────────
// `core/utils/auth_state.dart` used to keep `token`, `userId` and `userType` in ONE process-wide bag
// that BOTH auth domains wrote:
//
//   setSuperAdminAuthState(...) -> _tokenCache = token
//   setFactoryAuthState(...)    -> _tokenCache = token
//
// and the factory side read it back as if it were its own (`getFactoryAuthToken()` -> `_tokenCache`).
// So after a super-admin login, a factory billing call sent the *admin's* Bearer token to a factory
// endpoint. `_factoryIdCache` was not overwritten by the admin path, so the request could even pair an
// admin token with a stale factory id. That is the cross-domain credential leak in §17.8.
//
// Factory state now lives here and nowhere else, so:
//   * a super-admin write can no longer reach factory state (and vice versa) — the mixing dies by
//     construction, not by convention, and
//   * `requireToken()` fails loudly instead of returning whatever token happens to be cached.
//
// Consumed by: the factory auth bloc, the factory login screen, the factory billing datasource, the
// unit-code screen, `app_initializer` (cold start) and `app_router` (the `/factory/*` guard). The
// super-admin domain keeps its own state in `core/utils/auth_state.dart`.

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// The factory panel's cached auth session.
///
/// Deliberately NOT called `FactoryAuthState` — that name is already taken by the factory auth bloc's
/// state class (`factory_auth_bloc.dart`).
class FactoryAuthCache {
  FactoryAuthCache._();

  /// Single process-wide instance. The factory panel is one domain; this is its one cache.
  static final FactoryAuthCache instance = FactoryAuthCache._();

  /// Whether a factory session is active. Read by the router's `/factory/*` guard.
  bool isAuthenticated = false;

  /// The factory Bearer token. Never hand this to another domain's endpoint.
  String? token;

  /// The factory user's id.
  String? userId;

  /// The factory user type, e.g. `factory`.
  String? userType;

  /// The factory's company id — sent as `X-Factory-ID` on factory calls.
  String? factoryId;

  /// Record a successful factory login, or a session restored at cold start.
  void set({
    required bool isAuthenticated,
    required String userType,
    required String userId,
    required String token,
    String? factoryId,
  }) {
    this.isAuthenticated = isAuthenticated;
    this.userType = userType;
    this.userId = userId;
    this.token = token;
    this.factoryId = factoryId;
    if (kDebugMode) {
      debugPrint(
        'FACTORY_AUTH_CACHE: set - userType=$userType, userId=$userId, '
        'factoryId=$factoryId',
      );
    }
  }

  /// The factory Bearer token, or a hard failure.
  ///
  /// It throws on purpose: a factory call must never silently fall back to another domain's cached
  /// token. That fallback was the §17.8 leak.
  String requireToken() {
    final value = token;
    if (value == null || value.isEmpty) {
      throw Exception('Factory auth token not found. Please login again.');
    }
    return value;
  }

  /// Clear the factory domain only — a super-admin logout must not do this, and this must not clear
  /// the super-admin token.
  void reset() {
    isAuthenticated = false;
    token = null;
    userId = null;
    userType = null;
    factoryId = null;
    if (kDebugMode) {
      debugPrint('FACTORY_AUTH_CACHE: reset');
    }
  }
}
