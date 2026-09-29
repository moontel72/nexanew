// Public Marketplace Entrypoint — market.traceodd.com
//
// A standalone Flutter web build that hosts ONLY the public, read-only
// marketplace (MASTER-TASK-LIST item #12): browse every published product with
// its wholesale price and MOQ, and open a factory's storefront.
//
// There is NO login screen and NO token: this app is compiled without the
// panels, and every request it makes is an unauthenticated read of the public
// `/reseller/*` endpoints.
//
// Build:
//   flutter build web --release --target=lib/main_marketplace.dart \
//     --pwa-strategy none

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/marketplace_public/data/marketplace_cart.dart';
import 'package:trace_odd/features/marketplace_public/presentation/pages/marketplace_cart_page.dart';
import 'package:trace_odd/features/marketplace_public/presentation/pages/marketplace_home_page.dart';
import 'package:trace_odd/features/marketplace_public/presentation/pages/marketplace_register_page.dart';
import 'package:trace_odd/features/marketplace_public/presentation/pages/marketplace_storefront_page.dart';
import 'package:trace_odd/features/marketplace_public/theme/marketplace_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) usePathUrlStrategy();
  // Restore a cart the visitor left behind (it survives the register detour).
  MpCart.instance.ensureLoaded();
  runApp(const MarketplaceApp());
}

class MarketplaceApp extends StatelessWidget {
  const MarketplaceApp({super.key});

  GoRouter get _router => GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MarketplaceHomePage(),
      ),
      GoRoute(
        path: '/store/:factoryId',
        name: 'marketplace_storefront',
        builder: (context, state) => MarketplaceStorefrontPage(
          factoryId: state.pathParameters['factoryId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/cart',
        name: 'marketplace_cart',
        builder: (context, state) => const MarketplaceCartPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'marketplace_register',
        builder: (context, state) => const MarketplaceRegisterPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: MpColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Page not found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MpColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to the marketplace'),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trace Odd Marketplace',
      debugShowCheckedModeBanner: false,
      theme: marketplaceTheme(),
      routerConfig: _router,
    );
  }
}
