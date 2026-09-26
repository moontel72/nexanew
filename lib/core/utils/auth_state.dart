// Global (super-admin) authentication state for Flutter Web
// This file provides safe access to auth state for router redirects
// without causing provider timing issues
//
// ── Domains: what lives here, and where the others went (PANEL-SEPARATION-PLAN.md §17) ──────────
//   * super-admin / admin — the fields in this file.
//   * factory             — `lib/features/factory/factory_auth_cache.dart` (§17.8 / step B1). This
//                           file used to keep `token`, `userId` and `userType` in one bag that BOTH
//                           domains wrote, so `getFactoryAuthToken()` returned the ADMIN token after
//                           an admin login — a cross-domain credential leak.
//   * sub-admin           — the `sub_admin_token` cache at the bottom of this file.

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// Global flags to track auth state for router redirect
/// These ensure redirect only runs AFTER auth state is known
bool _authCheckCompleted = false;
bool _isAuthenticatedCache = false;
String? _userTypeCache;
String? _userIdCache;
String? _tokenCache;

/// Getters for router to check auth state safely
bool get isAuthCheckCompleted => _authCheckCompleted;
bool get isAuthenticatedCache => _isAuthenticatedCache;
String? get userTypeCache => _userTypeCache;
String? get userIdCache => _userIdCache;
String? get tokenCache => _tokenCache;

String? getAuthToken() => _tokenCache;

/// Set auth check completed
void setAuthCheckCompleted(bool value) {
  _authCheckCompleted = value;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: authCheckCompleted=$value');
  }
}

/// Set authenticated cache
void setIsAuthenticatedCache(bool value) {
  _isAuthenticatedCache = value;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: isAuthenticated=$value');
  }
}

/// Set user type cache
void setUserTypeCache(String? value) {
  _userTypeCache = value;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: userType=$value');
  }
}

/// Set user ID cache
void setUserIdCache(String? value) {
  _userIdCache = value;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: userId=$value');
  }
}

/// Set token cache
void setTokenCache(String? value) {
  _tokenCache = value;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: token=${value != null ? '***' : 'null'}');
  }
}

/// Set super admin authentication state
void setSuperAdminAuthState({
  required bool isAuthenticated,
  required String userType,
  required String userId,
  required String token,
}) {
  _isAuthenticatedCache = isAuthenticated;
  _userTypeCache = userType;
  _userIdCache = userId;
  _tokenCache = token;
  _authCheckCompleted = true;

  if (kDebugMode) {
    debugPrint(
      'AUTH_STATE: Super admin auth set - userType=$userType, userId=$userId',
    );
  }
}

/// Reset auth state (for logout).
///
/// **Super-admin domain only.** It deliberately leaves the factory session (`FactoryAuthCache`) and the
/// sub-admin session (`isSubAdminAuthenticatedCache`) alone: they are independent domains, and a
/// super-admin logout must not sign them out. Before §17.8/B1 this also cleared the factory fields —
/// the reverse half of the same mixing defect.
void resetAuthState() {
  _authCheckCompleted = false;
  _isAuthenticatedCache = false;
  _userTypeCache = null;
  _userIdCache = null;
  _tokenCache = null;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: Reset super-admin auth state');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-admin session (PANEL-SEPARATION-PLAN.md §17 step 5)
//
// The sub-admin panel authenticates with its OWN Bearer token (`sub_admin_token` in
// SharedPreferences). It does NOT use the super-admin or factory flags above. The router now
// guards `/sub-admin/*` with this cache, because `_safeRedirect` must never perform I/O.
//
// Written in three places: at startup from prefs, on sub-admin login, and on sub-admin logout.
//
// NOTE: deliberately NOT cleared by `resetAuthState()`. The two domains are independent, and a
// *super-admin* logout must not bounce a still-valid sub-admin session to its login screen.
// ─────────────────────────────────────────────────────────────────────────────
bool _isSubAdminAuthenticatedCache = false;

bool get isSubAdminAuthenticatedCache => _isSubAdminAuthenticatedCache;

void setSubAdminAuthenticatedCache(bool value) {
  _isSubAdminAuthenticatedCache = value;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: isSubAdminAuthenticated=$value');
  }
}
