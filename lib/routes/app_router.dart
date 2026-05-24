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
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/billing/invoice_detail_screen.dart'
    as admin_invoice_detail;
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/plans/plans_list_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/plans/create_plan_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/companies/companies_list_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/companies/register_company_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/companies/company_detail_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/companies/add_bus_company_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/companies/bus_companies_list_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/bus_company_login_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/transport/transport_wallet_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/transport/transport_marketplace_admin_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/transport/fraud_prevention_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/transport/drivers_admin_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/reseller_management/reseller_management_list_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/reseller_management/register_reseller_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/factory_login_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/factory_dashboard.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/factory_shell.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/bundle_codes/bundle_codes_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/bundle_codes/bundle_code_generate_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/bundle_codes/bundle_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/bundle_codes/bundle_packing_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/carton_codes/carton_codes_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/carton_codes/carton_codes_overview_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/carton_codes/carton_code_generate_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/packet_codes/packet_codes_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/packet_codes/packet_codes_overview_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/packet_codes/packet_code_generate_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/unit_codes/unit_codes_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/codes/unit_codes/unit_code_generate_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/products/products_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/products/create_product_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/products/edit_product_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/store_keepers/store_keepers_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/store_keepers/create_store_keeper_screen.dart';
import 'package:nexatrace_system/core/utils/auth_state.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/store_keeper_login_screen.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/store_keeper_dashboard.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/scanner_screen.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/linking_screen.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/rack_allocation_screen.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/inventory_screen.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/shift_summary_screen.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/order_selection_screen.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/qr_test_panel_screen.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/store_keeper_history_screen.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/bundle_linking_screen.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/screens/bundle_scan_flow_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/orders/orders_hub_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/orders/order_detail_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/driver_dashboard_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/scan_receive_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/delivery_scan_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/location_confirm_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/proof_delivery_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/earnings_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/vehicle_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/map_tracking_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/expenses_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/payment_history_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/chat_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/maintenance_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/compliance_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/disputes_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/performance_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/settings_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/drivers/drivers_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/drivers/create_driver_screen.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/screens/driver_login_screen.dart';

class AppRouter {
  late final GoRouter router;
  final AdminAuthRepository authRepo;

  AppRouter({required this.authRepo}) {
    if (kDebugMode) {
      debugPrint('APP_ROUTER: Creating router');
    }

    router = GoRouter(
      // No initialLocation — let GoRouter detect the actual browser URL on web.
      // This prevents the redirect from firing on '/' before the real URL is read.
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
              if (state.uri.path.startsWith('/reseller'))
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'The Reseller App is deployed separately.\n'
                    'If you are the server admin, ensure Nginx has\n'
                    'the /reseller/ location block configured.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
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
    BuildContext context,
    GoRouterState state,
  ) async {
    // CRITICAL: Only run redirect AFTER auth check is complete
    // This prevents the redirect from running before providers are ready
    if (!isAuthCheckCompleted) {
      if (kDebugMode) {
        debugPrint(
          'ROUTER_REDIRECT: Auth check not complete, allowing navigation',
        );
      }
      return null; // Don't redirect, let the current route load
    }

    final path = state.uri.path;
    final isLogin = path == '/login';
    final isRoot = path == '/';

    final isFactoryRoute = path.startsWith('/factory');
    final isFactoryLogin = path == '/factory/login';
    final isStoreKeeperRoute = path.startsWith('/factory/store-keeper');

    if (kDebugMode) {
      debugPrint(
        'ROUTER_REDIRECT: path=$path, isAuthed=$isAuthenticatedCache, isLogin=$isLogin',
      );
    }

    if (isFactoryRoute) {
      if (!isFactoryAuthenticatedCache && !isFactoryLogin) {
        if (isStoreKeeperRoute) return null;
        if (kDebugMode) {
          debugPrint(
            'ROUTER_REDIRECT: Not factory authenticated, redirecting to factory login',
          );
        }
        return '/factory/login';
      }

      if (isFactoryAuthenticatedCache && isFactoryLogin) {
        if (kDebugMode) {
          debugPrint(
            'ROUTER_REDIRECT: Already factory authenticated, redirecting to factory dashboard',
          );
        }
        return '/factory/dashboard';
      }

      return null;
    }

    // Root path redirects based on auth state
    // IMPORTANT: Only redirect the EXACT root path '/'
    // Never redirect explicit paths like /factory/store-keeper/login
    if (isRoot || path.isEmpty) {
      if (!kIsWeb) return '/factory/store-keeper/login';
      return isAuthenticatedCache ? '/dashboard' : '/login';
    }

    // ── Public routes that should NEVER be redirected ──────────
    // Store Keeper routes (login, dashboard, scanning, etc.)
    if (path.startsWith('/factory/store-keeper')) return null;
    // Reseller routes — handled by a separate Flutter app at /reseller/
    // If Nginx is misconfigured, these hit the main app; don't redirect them.
    if (path.startsWith('/reseller')) return null;
    // Bus Fleet login — public access for bus company owners
    if (path == '/bus-fleet/login') return null;

    // ── Protected routes - require authentication ─────────────
    // These are admin panel routes that require super admin login
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
          'ROUTER_REDIRECT: Already authenticated, redirecting to dashboard',
        );
      }
      return '/dashboard';
    }

    // No redirect needed
    return null;
  }

  List<RouteBase> get _routes => [
    GoRoute(path: '/', builder: (context, state) => const SizedBox.shrink()),
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
    GoRoute(
      path: '/bus-fleet/login',
      name: 'bus_fleet_login',
      builder: (context, state) => const BusCompanyLoginScreen(),
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
          builder: (context, state) => const CompaniesListScreen(inShell: true),
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
          path: '/bus-companies',
          name: 'bus_companies',
          builder: (context, state) =>
              const BusCompaniesListScreen(inShell: true),
          routes: [
            GoRoute(
              path: 'add',
              name: 'bus_company_add',
              builder: (context, state) =>
                  const AddBusCompanyScreen(inShell: true),
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
          routes: [
            GoRoute(
              path: ':invoiceId',
              name: 'billing_invoice_detail',
              builder: (context, state) {
                final id = state.pathParameters['invoiceId'] ?? '';
                return admin_invoice_detail.InvoiceDetailScreen(invoiceId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/transport/wallet',
          name: 'transport_wallet',
          builder: (context, state) => const TransportWalletAdminScreen(),
        ),
        GoRoute(
          path: '/transport/marketplace',
          name: 'transport_marketplace',
          builder: (context, state) => const TransportMarketplaceAdminScreen(),
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
        GoRoute(
          path: '/resellers',
          name: 'resellers',
          builder: (context, state) =>
              const ResellerManagementListScreen(inShell: true),
          routes: [
            GoRoute(
              path: 'add',
              name: 'reseller_add',
              builder: (context, state) =>
                  const RegisterResellerScreen(inShell: true),
            ),
          ],
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
            return FactoryDashboard(factoryId: factoryId, userId: userId);
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
            GoRoute(
              path: 'edit/:productId',
              name: 'factory_products_edit',
              builder: (context, state) {
                final productId = state.pathParameters['productId'] ?? '';
                return EditProductScreen(productId: productId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/factory/store-keepers',
          name: 'factory_store_keepers',
          builder: (context, state) => const StoreKeepersListScreen(),
          routes: [
            GoRoute(
              path: 'create',
              name: 'factory_store_keepers_create',
              builder: (context, state) => const CreateStoreKeeperScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/factory/drivers',
          name: 'factory_drivers',
          builder: (context, state) => const DriversListScreen(),
          routes: [
            GoRoute(
              path: 'create',
              name: 'factory_drivers_create',
              builder: (context, state) => const CreateDriverScreen(),
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
            GoRoute(
              path: 'overview',
              name: 'factory_packet_codes_overview',
              builder: (context, state) => const PacketCodesOverviewScreen(),
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
            GoRoute(
              path: 'overview',
              name: 'factory_carton_codes_overview',
              builder: (context, state) => const CartonCodesOverviewScreen(),
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
        GoRoute(
          path: '/factory/codes/bundles',
          name: 'factory_bundles',
          builder: (context, state) => const BundleListScreen(),
          routes: [
            GoRoute(
              path: 'pack',
              name: 'factory_bundles_pack',
              builder: (context, state) => const BundlePackingScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/factory/orders',
          name: 'factory_orders',
          builder: (context, state) => const OrdersHubScreen(),
          routes: [
            GoRoute(
              path: ':bundleId',
              name: 'factory_order_detail',
              builder: (context, state) {
                final bundleId = state.pathParameters['bundleId'] ?? '';
                return OrderDetailScreen(bundleId: bundleId);
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/factory/store-keeper/login',
      builder: (context, state) => const StoreKeeperLoginScreen(),
    ),
    GoRoute(
      path: '/factory/driver/login',
      builder: (context, state) => const DriverLoginScreen(),
    ),
    GoRoute(
      path: '/factory/store-keeper/dashboard',
      builder: (context, state) => const StoreKeeperDashboard(),
    ),
    GoRoute(
      path: '/factory/driver/dashboard',
      builder: (context, state) => const FactoryDriverDashboardScreen(),
    ),
    GoRoute(
      path: '/factory/driver/scan-receive',
      builder: (context, state) => const ScanReceiveScreen(),
    ),
    GoRoute(
      path: '/factory/driver/delivery-scan',
      builder: (context, state) => const DeliveryScanScreen(),
    ),
    GoRoute(
      path: '/factory/driver/location-confirm',
      builder: (context, state) => const LocationConfirmScreen(),
    ),
    GoRoute(
      path: '/factory/driver/pod',
      builder: (context, state) => const ProofDeliveryScreen(),
    ),
    GoRoute(
      path: '/factory/driver/earnings',
      builder: (context, state) => const DriverEarningsScreen(),
    ),
    GoRoute(
      path: '/factory/driver/vehicle',
      builder: (context, state) => const DriverVehicleScreen(),
    ),
    GoRoute(
      path: '/factory/driver/map-tracking',
      builder: (context, state) => const DriverMapTrackingScreen(),
    ),
    GoRoute(
      path: '/factory/driver/expenses',
      builder: (context, state) => const DriverExpensesScreen(),
    ),
    GoRoute(
      path: '/factory/driver/payment-history',
      builder: (context, state) => const DriverPaymentHistoryScreen(),
    ),
    GoRoute(
      path: '/factory/driver/chat',
      builder: (context, state) => const DriverChatScreen(),
    ),
    GoRoute(
      path: '/factory/driver/maintenance',
      builder: (context, state) => const DriverMaintenanceScreen(),
    ),
    GoRoute(
      path: '/factory/driver/compliance',
      builder: (context, state) => const DriverComplianceScreen(),
    ),
    GoRoute(
      path: '/factory/driver/disputes',
      builder: (context, state) => const DriverDisputesScreen(),
    ),
    GoRoute(
      path: '/factory/driver/performance',
      builder: (context, state) => const DriverPerformanceScreen(),
    ),
    GoRoute(
      path: '/factory/driver/settings',
      builder: (context, state) => const DriverSettingsScreen(),
    ),
    GoRoute(
      path: '/factory/store-keeper/scanner',
      // returnResult: true → scanner pops with the scanned code so
      // BundleLinkingScreen / BundleScanFlowScreen can receive it.
      builder: (context, state) => const ScannerScreen(returnResult: true),
    ),
    GoRoute(
      path: '/factory/store-keeper/linking',
      builder: (context, state) => const LinkingScreen(),
    ),
    GoRoute(
      path: '/factory/store-keeper/rack',
      builder: (context, state) => const RackAllocationScreen(),
    ),
    GoRoute(
      path: '/factory/store-keeper/inventory',
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(
      path: '/factory/store-keeper/history',
      builder: (context, state) => const StoreKeeperHistoryScreen(),
    ),
    GoRoute(
      path: '/factory/store-keeper/shift-summary',
      builder: (context, state) => const ShiftSummaryScreen(),
    ),
    GoRoute(
      path: '/factory/store-keeper/orders',
      builder: (context, state) => const OrderSelectionScreen(),
    ),
    GoRoute(
      path: '/factory/store-keeper/qr-test-panel',
      builder: (context, state) => const QrTestPanelScreen(),
    ),
    GoRoute(
      path: '/factory/store-keeper/bundle/:bundleId',
      builder: (context, state) {
        final bundleId = state.pathParameters['bundleId'] ?? '';
        final extra = state.extra;
        String? orderRef;
        String? bundleCode;
        if (extra is Map<String, String>) {
          orderRef = extra['orderRef'];
          bundleCode = extra['bundleCode'];
        }
        return BundleLinkingScreen(
          bundleId: bundleId,
          initialOrderRef: orderRef,
          initialBundleCode: bundleCode,
        );
      },
      routes: [
        GoRoute(
          path: 'scan',
          builder: (context, state) {
            final bundleId = state.pathParameters['bundleId'] ?? '';
            return BundleScanFlowScreen(bundleId: bundleId);
          },
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
  void goToEditPlan(
    BuildContext context, {
    required String planId,
    Map<String, dynamic>? planData,
  }) {
    // TODO: Navigate to edit plan screen when implemented
    // context.go('/plans/$planId/edit', extra: planData);
  }
  void goToEditCompany(
    BuildContext context, {
    required String companyId,
    Map<String, dynamic>? companyData,
  }) {
    // TODO: Navigate to edit company screen when implemented
    // context.go('/companies/$companyId/edit', extra: companyData);
  }
  void goToResellers(BuildContext context) => context.go("/resellers");
  void goToAddReseller(BuildContext context) => context.go("/resellers/add");

  void goToInvoices(BuildContext context) => context.go('/billing/invoices');
  void goToTransportWallet(BuildContext context) =>
      context.go('/transport/wallet');
  void goToTransportMarketplace(BuildContext context) =>
      context.go('/transport/marketplace');
  void goToTransportDrivers(BuildContext context) =>
      context.go('/transport/drivers');
  void goToTransportFraud(BuildContext context) =>
      context.go('/transport/fraud');

  void goToBusCompanies(BuildContext context) => context.go('/bus-companies');
  void goToAddBusCompany(BuildContext context) =>
      context.go('/bus-companies/add');
  void goToBusCompanyLogin(BuildContext context) =>
      context.go('/bus-fleet/login');

  void pop(BuildContext context) => context.pop();
}
