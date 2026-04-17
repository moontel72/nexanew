// Global authentication state for Flutter Web
// This file provides safe access to auth state for router redirects
// without causing provider timing issues

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// Global flags to track auth state for router redirect
/// These ensure redirect only runs AFTER auth state is known
bool _authCheckCompleted = false;
bool _isAuthenticatedCache = false;
bool _isFactoryAuthenticatedCache = false;
String? _userTypeCache;
String? _userIdCache;
String? _factoryIdCache;
String? _tokenCache;

/// Getters for router to check auth state safely
bool get isAuthCheckCompleted => _authCheckCompleted;
bool get isAuthenticatedCache => _isAuthenticatedCache;
bool get isFactoryAuthenticatedCache => _isFactoryAuthenticatedCache;
String? get userTypeCache => _userTypeCache;
String? get userIdCache => _userIdCache;
String? get factoryIdCache => _factoryIdCache;
String? get tokenCache => _tokenCache;

String getFactoryAuthToken() {
  final token = _tokenCache;
  if (token == null || token.isEmpty) {
    throw Exception('Auth token not found. Please login again.');
  }
  return token;
}

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

/// Set factory authenticated cache
void setIsFactoryAuthenticatedCache(bool value) {
  _isFactoryAuthenticatedCache = value;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: isFactoryAuthenticated=$value');
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

/// Set factory ID cache
void setFactoryIdCache(String? value) {
  _factoryIdCache = value;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: factoryId=$value');
  }
}

/// Set token cache
void setTokenCache(String? value) {
  _tokenCache = value;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: token=${value != null ? '***' : 'null'}');
  }
}

/// Set factory authentication state
void setFactoryAuthState({
  required bool isAuthenticated,
  required String userType,
  required String userId,
  required String token,
  String? factoryId,
}) {
  _isFactoryAuthenticatedCache = isAuthenticated;
  _userTypeCache = userType;
  _userIdCache = userId;
  _tokenCache = token;
  _factoryIdCache = factoryId;
  _authCheckCompleted = true;

  if (kDebugMode) {
    debugPrint(
        'AUTH_STATE: Factory auth set - userType=$userType, userId=$userId, factoryId=$factoryId');
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
        'AUTH_STATE: Super admin auth set - userType=$userType, userId=$userId');
  }
}

/// Get user ID (for factory dashboard)
String? getUserId() => _userIdCache;

/// Get factory ID (for factory dashboard)
String? getFactoryId() => _factoryIdCache;

/// Reset auth state (for logout)
void resetAuthState() {
  _authCheckCompleted = false;
  _isAuthenticatedCache = false;
  _isFactoryAuthenticatedCache = false;
  _userTypeCache = null;
  _userIdCache = null;
  _factoryIdCache = null;
  _tokenCache = null;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: Reset all auth state');
  }
}

/// Reset factory auth state only
void resetFactoryAuthState() {
  _isFactoryAuthenticatedCache = false;
  _userTypeCache = null;
  _userIdCache = null;
  _factoryIdCache = null;
  _tokenCache = null;
  if (kDebugMode) {
    debugPrint('AUTH_STATE: Reset factory auth state');
  }
}
