// Router Integration — Panel-aware GoRouter extensions
//
// Provides the `/access-denied` GoRoute and a composable panel-aware
// redirect function that enforces route authorization.  These are
// spread into the existing AppRouter WITHOUT modifying app_router.dart.
//
// Integration:
//   // In AppRouter._routes getter:
//   List<RouteBase> get _routes => [
//     ...existing routes...,
//     RouterIntegration.accessDeniedRoute,  // ← ADD
//   ];
//
//   // In GoRouter constructor:
//   GoRouter(
//     redirect: (context, state) async {
//       final guard = await RouterIntegration.panelAwareRedirect(context, state);
//       if (guard != null) return guard;
//       return _safeRedirect(context, state);
//     },
//   );

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/core/navigation/route_guard_middleware.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_bloc.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_state.dart';

class RouterIntegration {
  RouterIntegration._();

  /// The `/access-denied` security overlay route (Setup 3).
  static GoRoute get deniedRoute => accessDeniedRoute;

  /// Panel-aware redirect that evaluates the active PanelAuthBloc state
  /// and enforces route isolation.  Returns a redirect path or null.
  static Future<String?> panelAwareRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final path = state.uri.path;

    // Always allow public endpoints.
    if (path == '/access-denied' ||
        path == '/login' ||
        path == '/factory/login' ||
        path == '/factory/store-keeper/login' ||
        path == '/reseller/login' ||
        path == '/driver/login') {
      return null;
    }

    // Check PanelAccessGuard flag (set by interceptor/bloc on mismatch).
    if (PanelAccessGuard.isAccessDenied) {
      return '/access-denied';
    }

    // Evaluate active panel session against target route.
    try {
      final authState = context.read<PanelAuthBloc>().state;
      if (authState is PanelAuthAuthenticated) {
        final panel = authState.response.panel;
        final allowedPrefixes = _routePrefixesFor(panel);
        final isAllowed = allowedPrefixes.any((p) => path.startsWith(p));
        if (!isAllowed && path != '/') {
          PanelAccessGuard.flagDenied(
            panel: panel,
            actualType: authState.response.driverType ?? 'none',
            requiredType: panel.allowedDriverTypes.join(','),
          );
          return '/access-denied';
        }
      }
    } catch (_) {
      // Bloc not yet available — allow navigation.
    }

    return null;
  }

  /// Returns the set of Flutter route prefixes a panel is authorized to access.
  static List<String> _routePrefixesFor(UserPanel panel) => switch (panel) {
    UserPanel.superAdmin => [
      '/dashboard',
      '/companies',
      '/plans',
      '/billing',
      '/transport',
      '/resellers',
      '/super-admin',
      '/admin',
      '/login',
    ],
    UserPanel.factory => ['/factory', '/driver'],
    UserPanel.marketplace => ['/reseller', '/marketplace'],
    UserPanel.truckFleet => ['/truck-fleet', '/driver'],
    UserPanel.busFleet => ['/bus-fleet', '/driver'],
    UserPanel.customer => ['/consumer'],
  };
}
