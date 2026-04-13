// App Router for NexaTrace System
// This file defines the application routing using go_router

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/admin_auth_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/dashboard_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/super_admin_shell.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/login_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/billing/platform_invoices_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/plans/plans_list_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/plans/create_plan_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/companies/companies_list_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/companies/register_company_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/companies/company_detail_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/transport/transport_wallet_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/transport/transport_marketplace_admin_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/transport/fraud_prevention_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/transport/drivers_admin_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/factory_login_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/factory_dashboard.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/factory_shell.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/bundle_codes/bundle_codes_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/bundle_codes/bundle_code_generate_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/carton_codes/carton_codes_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/carton_codes/carton_code_generate_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/packet_codes/packet_codes_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/packet_codes/packet_code_generate_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/unit_codes/unit_codes_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/unit_codes/unit_code_generate_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/products/products_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/products/create_product_screen.dart';
import 'package:nexatrace_system/core/utils/auth_state.dart';

class AppRouter {
  late final GoRouter router;
  final AdminAuthRepository authRepo;

  AppRouter({required this.authRepo}) {
    if (kDebugMode) {
      debugPrint('APP_ROUTER: Creating router');
    }

    router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,
      redirect: _safeRedirect,
      routes: _routes,
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Go to factory login for factory routes, otherwise super admin login
                  if (state.uri.path.startsWith('/factory')) {
                    context.go('/factory/login');
                  } else {
                    context.go('/login');
                  }
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Safe redirect logic - NEVER makes API calls, only checks local cached state
  /// This is critical to prevent redirect loops and provider not found errors
  Future<String?> _safeRedirect(
      BuildContext context, GoRouterState state) async {
    // CRITICAL: Only run redirect AFTER auth check is complete
    // This prevents the redirect from running before providers are ready
    if (!isAuthCheckCompleted) {
      if (kDebugMode) {
        debugPrint(
            'ROUTER_REDIRECT: Auth check not complete, allowing navigation');
      }
      return null; // Don't redirect, let the current route load
    }

    final path = state.uri.path;
    final isLogin = path == '/login';
    final isRoot = path == '/';

    final isFactoryRoute = path.startsWith('/factory');
    final isFactoryLogin = path == '/factory/login';

    if (kDebugMode) {
      debugPrint(
          'ROUTER_REDIRECT: path=$path, isAuthed=$isAuthenticatedCache, isLogin=$isLogin');
    }

    if (isFactoryRoute) {
      if (!isFactoryAuthenticatedCache && !isFactoryLogin) {
        if (kDebugMode) {
          debugPrint(
              'ROUTER_REDIRECT: Not factory authenticated, redirecting to factory login');
        }
        return '/factory/login';
      }

      if (isFactoryAuthenticatedCache && isFactoryLogin) {
        if (kDebugMode) {
          debugPrint(
              'ROUTER_REDIRECT: Already factory authenticated, redirecting to factory dashboard');
        }
        return '/factory/dashboard';
      }

      return null;
    }

    // Root path redirects based on auth state
    if (isRoot) {
      return isAuthenticatedCache ? '/dashboard' : '/login';
    }

    // Protected routes - require authentication
    if (!isAuthenticatedCache && !isLogin) {
      if (kDebugMode) {
        debugPrint('ROUTER_REDIRECT: Not authenticated, redirecting to login');
      }
      return '/login';
    }

    // Already authenticated and trying to access login - go to dashboard
    if (isAuthenticatedCache && isLogin) {
      if (kDebugMode) {
        debugPrint(
            'ROUTER_REDIRECT: Already authenticated, redirecting to dashboard');
      }
      return '/dashboard';
    }

    // No redirect needed
    return null;
  }

  List<RouteBase> get _routes => [
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const SuperAdminLoginScreen(),
        ),
        GoRoute(
          path: '/factory/login',
          name: 'factory_login',
          builder: (context, state) => const FactoryLoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => SuperAdminShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) =>
                  const SuperAdminDashboardScreen(inShell: true),
            ),
            GoRoute(
              path: '/companies',
              name: 'companies',
              builder: (context, state) =>
                  const CompaniesListScreen(inShell: true),
              routes: [
                GoRoute(
                  path: 'register',
                  name: 'company_register',
                  builder: (context, state) =>
                      const RegisterCompanyScreen(inShell: true),
                ),
                GoRoute(
                  path: ':id',
                  name: 'company_detail',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return CompanyDetailScreen(companyId: id, inShell: true);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/plans',
              name: 'plans',
              builder: (context, state) => const PlansListScreen(inShell: true),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'plan_create',
                  builder: (context, state) =>
                      const CreatePlanScreen(inShell: true),
                ),
              ],
            ),
            GoRoute(
              path: '/billing/invoices',
              name: 'billing_invoices',
              builder: (context, state) => const PlatformInvoicesScreen(),
            ),
            GoRoute(
              path: '/transport/wallet',
              name: 'transport_wallet',
              builder: (context, state) => const TransportWalletAdminScreen(),
            ),
            GoRoute(
              path: '/transport/marketplace',
              name: 'transport_marketplace',
              builder: (context, state) =>
                  const TransportMarketplaceAdminScreen(),
            ),
            GoRoute(
              path: '/transport/drivers',
              name: 'transport_drivers',
              builder: (context, state) => const TransportDriversAdminScreen(),
            ),
            GoRoute(
              path: '/transport/fraud',
              name: 'transport_fraud',
              builder: (context, state) => const FraudPreventionAdminScreen(),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => FactoryShell(child: child),
          routes: [
            GoRoute(
              path: '/factory/dashboard',
              name: 'factory_dashboard',
              builder: (context, state) {
                final factoryId = getFactoryId() ?? '';
                final userId = getUserId() ?? '';
                return FactoryDashboard(
                  factoryId: factoryId,
                  userId: userId,
                );
              },
            ),
            GoRoute(
              path: '/factory/products',
              name: 'factory_products',
              builder: (context, state) => const ProductsListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'factory_products_create',
                  builder: (context, state) => const CreateProductScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/factory/codes/unit',
              name: 'factory_unit_codes',
              builder: (context, state) => const UnitCodesListScreen(),
              routes: [
                GoRoute(
                  path: 'generate',
                  name: 'factory_unit_codes_generate',
                  builder: (context, state) => const UnitCodeGenerateScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/factory/codes/packet',
              name: 'factory_packet_codes',
              builder: (context, state) => const PacketCodesListScreen(),
              routes: [
                GoRoute(
                  path: 'generate',
                  name: 'factory_packet_codes_generate',
                  builder: (context, state) => const PacketCodeGenerateScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/factory/codes/carton',
              name: 'factory_carton_codes',
              builder: (context, state) => const CartonCodesListScreen(),
              routes: [
                GoRoute(
                  path: 'generate',
                  name: 'factory_carton_codes_generate',
                  builder: (context, state) => const CartonCodeGenerateScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/factory/codes/bundle',
              name: 'factory_bundle_codes',
              builder: (context, state) => const BundleCodesListScreen(),
              routes: [
                GoRoute(
                  path: 'generate',
                  name: 'factory_bundle_codes_generate',
                  builder: (context, state) => const BundleCodeGenerateScreen(),
                ),
              ],
            ),
          ],
        ),
      ];

  GoRouter get config => router;

  // Navigation helper methods
  void goToLogin(BuildContext context) => context.go('/login');
  void goToDashboard(BuildContext context) => context.go('/dashboard');
  void goToPlans(BuildContext context) => context.go('/plans');
  void goToCompanies(BuildContext context) => context.go('/companies');
  void goToRegisterCompany(BuildContext context) =>
      context.go('/companies/register');
  void goToCompanyDetail(BuildContext context, String companyId) =>
      context.go('/companies/$companyId');
  void goToFactoryLogin(BuildContext context) => context.go('/factory/login');
  void goToFactoryDashboard(BuildContext context) =>
      context.go('/factory/dashboard');
  void goToCreatePlan(BuildContext context) => context.go('/plans/create');
  void goToEditPlan(BuildContext context,
      {required String planId, Map<String, dynamic>? planData}) {
    // TODO: Navigate to edit plan screen when implemented
    // context.go('/plans/$planId/edit', extra: planData);
  }
  void goToEditCompany(BuildContext context,
      {required String companyId, Map<String, dynamic>? companyData}) {
    // TODO: Navigate to edit company screen when implemented
    // context.go('/companies/$companyId/edit', extra: companyData);
  }
  void goToInvoices(BuildContext context) => context.go('/billing/invoices');
  void goToTransportWallet(BuildContext context) =>
      context.go('/transport/wallet');
  void goToTransportMarketplace(BuildContext context) =>
      context.go('/transport/marketplace');
  void goToTransportDrivers(BuildContext context) =>
      context.go('/transport/drivers');
  void goToTransportFraud(BuildContext context) =>
      context.go('/transport/fraud');

  void pop(BuildContext context) => context.pop();
}
