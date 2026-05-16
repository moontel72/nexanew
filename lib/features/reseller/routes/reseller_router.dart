import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/reseller/presentation/screens/reseller_dashboard_screen.dart';
import 'package:nexatrace_system/features/reseller/presentation/screens/reseller_login_screen.dart';
import 'package:nexatrace_system/features/reseller/presentation/screens/marketplace_home_screen.dart';
import 'package:nexatrace_system/features/reseller/presentation/screens/marketplace_catalog_screen.dart';
import 'package:nexatrace_system/features/reseller/presentation/screens/marketplace_cart_screen.dart';
import 'package:nexatrace_system/features/reseller/presentation/screens/marketplace_order_history_screen.dart';
import 'package:nexatrace_system/features/reseller/presentation/screens/marketplace_order_detail_screen.dart';

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

          // ── Marketplace ──────────────────────────────────────────
          GoRoute(
            path: '/reseller/marketplace',
            builder: (context, state) => const MarketplaceHomeScreen(),
          ),
          GoRoute(
            path: '/reseller/marketplace/catalog',
            builder: (context, state) {
              final factoryId = state.uri.queryParameters['factoryId'] ?? '';
              final factoryName =
                  state.uri.queryParameters['factoryName'] ?? 'Factory';
              return MarketplaceCatalogScreen(
                factoryId: factoryId,
                factoryName: factoryName,
              );
            },
          ),
          GoRoute(
            path: '/reseller/marketplace/cart',
            builder: (context, state) => const MarketplaceCartScreen(),
          ),
          GoRoute(
            path: '/reseller/marketplace/orders',
            builder: (context, state) => const MarketplaceOrderHistoryScreen(),
          ),
          GoRoute(
            path: '/reseller/marketplace/orders/:orderId',
            builder: (context, state) => MarketplaceOrderDetailScreen(
              orderId: state.pathParameters['orderId']!,
            ),
          ),
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Text(state.error?.toString() ?? 'Unknown routing error'),
          ),
        ),
      );
}
