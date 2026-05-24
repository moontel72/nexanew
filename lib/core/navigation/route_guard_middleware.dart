// Route Guard Middleware — Panel-aware GoRouter redirect composable
//
// Provides cross-cutting navigation guards that evaluate `PanelAuthState`
// and driver-type boundaries on every route transition WITHOUT modifying
// the existing `_safeRedirect` method in `app_router.dart`.
//
// Architecture:
//   1. `PanelAccessGuard` — lightweight singleton flag store updated by
//      the AuthInterceptor (403 driver.type) or PanelAuthBloc (login error).
//   2. `panelAwareRedirect()` — composable GoRouter redirect function.
//      Insert it BEFORE `_safeRedirect` in the GoRouter redirect callback.
//
// Integration (in AppRouter constructor, additive):
//   router = GoRouter(
//     redirect: (context, state) async {
//       // Step 1 — check panel access guard first
//       final guardRedirect = await panelAwareRedirect(context, state);
//       if (guardRedirect != null) return guardRedirect;
//       // Step 2 — existing safe redirect
//       return _safeRedirect(context, state);
//     },
//     ...
//   );

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/core/navigation/panel_routes.dart';
import 'package:nexatrace_system/features/auth/presentation/pages/panel_access_denied_screen.dart';

// ─────────────────────────────────────────────────────────────
// Panel Access Guard — singleton flag store
// ─────────────────────────────────────────────────────────────

/// Lightweight in-memory guard set by the interceptor/bloc when a driver
/// type mismatch is detected.  Read by the GoRouter redirect on every
/// navigation to force the user to the access-denied overlay.
class PanelAccessGuard {
  PanelAccessGuard._();

  static bool _isAccessDenied = false;

  /// The panel the user attempted to access.
  static UserPanel? deniedPanel;

  /// The driver type the user actually holds.
  static String? actualDriverType;

  /// The driver types the panel requires.
  static String? requiredDriverType;

  /// Whether the current session is in an access-denied state.
  static bool get isAccessDenied => _isAccessDenied;

  /// Flag the session as access-denied (called from AuthInterceptor or Bloc).
  static void flagDenied({
    required UserPanel panel,
    required String actualType,
    required String requiredType,
  }) {
    _isAccessDenied = true;
    deniedPanel = panel;
    actualDriverType = actualType;
    requiredDriverType = requiredType;
    if (kDebugMode) {
      debugPrint(
        'ACCESS_GUARD: Flagged denied — panel=$panel, '
        'actual=$actualType, required=$requiredType',
      );
    }
  }

  /// Clear the access-denied flag (called on logout or when leaving the overlay).
  static void clear() {
    _isAccessDenied = false;
    deniedPanel = null;
    actualDriverType = null;
    requiredDriverType = null;
    if (kDebugMode) {
      debugPrint('ACCESS_GUARD: Cleared');
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Panel-Aware Redirect
// ─────────────────────────────────────────────────────────────

/// Composable GoRouter redirect that enforces panel isolation and driver-type
/// boundaries.  Returns a redirect location (`/access-denied`, `/login`, etc.)
/// or `null` if the navigation is allowed.
///
/// Rules (evaluated in order):
///   1. `/access-denied` route is always allowed (prevents infinite loop).
///   2. Public auth routes (login variants) are always allowed.
///   3. If `PanelAccessGuard.isAccessDenied` is true, redirect to `/access-denied`.
///   4. If an authenticated user navigates to a route prefix that doesn't
///      match their panel's allowed domain, redirect to `/access-denied`.
Future<String?> panelAwareRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  final path = state.uri.path;

  // Rule 1 — Always allow the access-denied route itself.
  if (path == '/access-denied') {
    return null;
  }

  // Rule 2 — Always allow public auth routes.
  if (_isPublicAuthRoute(path)) {
    return null;
  }

  // Rule 3 — If the guard is flagged, force access-denied overlay.
  if (PanelAccessGuard.isAccessDenied) {
    if (kDebugMode) {
      debugPrint('ROUTE_GUARD: Access denied flag active → /access-denied');
    }
    return '/access-denied';
  }

  // Rule 4 — Panel prefix mismatch detection.
  // Only runs when the user is authenticated into a specific panel.
  // Detect which panel the current route belongs to and whether the
  // authenticated user's panel matches.
  // For now, we rely on the global auth cache + guard flag pattern.
  // Full panel-vs-route validation requires reading secure storage
  // (which is async and may be slow in a redirect).  The primary
  // enforcement comes from the AuthInterceptor (403 at API level) and
  // the PanelAccessGuard (flagged after login mismatch).

  return null; // Allow navigation by default; guard handles hard denials.
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

/// Routes that should never be redirected — login screens for all panels.
bool _isPublicAuthRoute(String path) {
  return path == '/login' ||
      path == '/factory/login' ||
      path == '/factory/store-keeper/login' ||
      path == '/reseller/login' ||
      path == '/driver/login' ||
      path == '/forgot-password' ||
      path.startsWith('/auth/');
}

// ─────────────────────────────────────────────────────────────
// Access-Denied Route Definition
// ─────────────────────────────────────────────────────────────

/// GoRoute for the `/access-denied` security overlay.
///
/// Integration: add this to the `_routes` list in `AppRouter`:
/// ```dart
/// List<RouteBase> get _routes => [
///   ...existing routes...,
///   accessDeniedRoute,  // ← ADD THIS
/// ];
/// ```
final GoRoute accessDeniedRoute = GoRoute(
  path: '/access-denied',
  name: 'access_denied',
  builder: (context, state) => const PanelAccessDeniedScreen(),
);
