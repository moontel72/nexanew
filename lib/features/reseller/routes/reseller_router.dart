import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/reseller/presentation/screens/reseller_dashboard_screen.dart';
import 'package:nexatrace_system/features/reseller/presentation/screens/reseller_login_screen.dart';

class ResellerRouter {
  final GoRouter config;

  ResellerRouter({required bool isAuthed})
      : config = GoRouter(
          initialLocation: isAuthed ? '/reseller/dashboard' : '/reseller/login',
          routes: [
            GoRoute(
              path: '/reseller/login',
              builder: (context, state) => const ResellerLoginScreen(),
            ),
            GoRoute(
              path: '/reseller/dashboard',
              builder: (context, state) => const ResellerDashboardScreen(),
            ),
          ],
          errorBuilder: (context, state) => Scaffold(
            body: Center(
              child: Text(
                state.error?.toString() ?? 'Unknown routing error',
              ),
            ),
          ),
        );
}

