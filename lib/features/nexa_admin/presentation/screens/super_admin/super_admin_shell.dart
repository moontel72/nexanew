import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/auth/admin_auth_event.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/auth/admin_auth_state.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/layout/super_admin_layout_cubit.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/admin_top_bar.dart';
import 'package:nexatrace_system/shared/widgets/navigation/admin_sidebar.dart';

class SuperAdminShell extends StatelessWidget {
  final Widget child;

  const SuperAdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminAuthBloc, AdminAuthState>(
      listener: (context, state) {
        if (state is AdminAuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: BlocBuilder<SuperAdminLayoutCubit, SuperAdminLayoutState>(
        builder: (context, layout) {
          final isNarrow = MediaQuery.of(context).size.width < 1024;
          final sidebar = AdminSidebar(
            collapsed: isNarrow ? false : layout.isSidebarCollapsed,
            sections: _sections(),
          );

          final location = GoRouterState.of(context).uri.toString();
          final title = _titleForLocation(location);
          final crumbs = _breadcrumbsForLocation(location);

          return Scaffold(
            backgroundColor: AppColors.adminContentBackground,
            drawer: isNarrow ? Drawer(child: sidebar) : null,
            body: Row(
              children: [
                if (!isNarrow) sidebar,
                Expanded(
                  child: Column(
                    children: [
                      Builder(
                        builder: (innerContext) {
                          return AdminTopBar(
                            title: title,
                            breadcrumbs: crumbs,
                            onToggleSidebar: () {
                              if (isNarrow) {
                                Scaffold.of(innerContext).openDrawer();
                                return;
                              }
                              innerContext
                                  .read<SuperAdminLayoutCubit>()
                                  .toggleSidebar();
                            },
                            onLogout: () {
                              innerContext.read<AdminAuthBloc>().add(
                                AdminLogoutRequested(),
                              );
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox.expand(child: child),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<AdminSidebarSection> _sections() {
    return const [
      AdminSidebarSection(
        title: 'Overview',
        items: [
          AdminSidebarItem(
            label: 'Command Center',
            icon: Icons.dashboard_outlined,
            route: '/dashboard',
          ),
        ],
      ),
      AdminSidebarSection(
        title: 'Companies',
        items: [
          AdminSidebarItem(
            label: 'View All Companies',
            icon: Icons.apartment,
            route: '/companies',
          ),
          AdminSidebarItem(
            label: 'Create New Company',
            icon: Icons.add_business,
            route: '/companies/register',
          ),
        ],
      ),
      AdminSidebarSection(
        title: 'Bus Fleet',
        items: [
          AdminSidebarItem(
            label: 'View Bus Companies',
            icon: Icons.directions_bus,
            route: '/bus-companies',
          ),
          AdminSidebarItem(
            label: 'Add Bus Company',
            icon: Icons.add_road,
            route: '/bus-companies/add',
          ),
        ],
      ),
      AdminSidebarSection(
        title: 'Goods Fleet',
        items: [
          AdminSidebarItem(
            label: 'View Goods Companies',
            icon: Icons.local_shipping,
            route: '/goods-companies',
          ),
          AdminSidebarItem(
            label: 'Add Goods Company',
            icon: Icons.add_business,
            route: '/goods-companies/add',
          ),
        ],
      ),
      AdminSidebarSection(
        title: 'Subscriptions',
        items: [
          AdminSidebarItem(
            label: 'View All Plans',
            icon: Icons.list_alt,
            route: '/plans',
          ),
          AdminSidebarItem(
            label: 'Create New Plan',
            icon: Icons.add,
            route: '/plans/create',
          ),
          AdminSidebarItem(
            label: 'Platform Invoices',
            icon: Icons.receipt_long,
            route: '/billing/invoices',
          ),
        ],
      ),
      AdminSidebarSection(
        title: 'Resellers',
        items: [
          AdminSidebarItem(
            label: 'View All Resellers',
            icon: Icons.storefront,
            route: '/resellers',
          ),
          AdminSidebarItem(
            label: 'Register Reseller',
            icon: Icons.person_add_alt,
            route: '/resellers/add',
          ),
        ],
      ),
      AdminSidebarSection(
        title: 'Transport',
        items: [
          AdminSidebarItem(
            label: 'Wallet',
            icon: Icons.account_balance_wallet_outlined,
            route: '/transport/wallet',
          ),
          AdminSidebarItem(
            label: 'Loads & Bids',
            icon: Icons.local_shipping_outlined,
            route: '/transport/marketplace',
          ),
          AdminSidebarItem(
            label: 'Drivers',
            icon: Icons.badge_outlined,
            route: '/transport/drivers',
          ),
          AdminSidebarItem(
            label: 'Fraud Prevention',
            icon: Icons.shield_outlined,
            route: '/transport/fraud',
          ),
        ],
      ),
    ];
  }

  String _titleForLocation(String location) {
    if (location.startsWith('/resellers/add')) return 'Register Reseller';
    if (location.startsWith('/resellers')) return 'Reseller Management';
    if (location.startsWith('/companies/register')) return 'Create New Company';
    if (location.startsWith('/companies')) return 'Company Management';
    if (location.startsWith('/bus-companies/add')) return 'Add Bus Company';
    if (location.startsWith('/bus-companies')) return 'Bus Fleet Companies';
    if (location.startsWith('/goods-companies/add')) return 'Add Goods Company';
    if (location.startsWith('/goods-companies')) return 'Goods Logistics Companies';
    if (location.startsWith('/plans/create')) return 'Create New Plan';
    if (location.startsWith('/plans')) return 'Subscription Plans';
    if (location.startsWith('/billing/invoices')) return 'Platform Invoices';
    if (location.startsWith('/transport/wallet')) return 'Transport Wallet';
    if (location.startsWith('/transport/marketplace')) {
      return 'Transport Marketplace';
    }
    if (location.startsWith('/transport/drivers')) return 'Drivers';
    if (location.startsWith('/transport/fraud')) return 'Fraud Prevention';
    return 'Super Admin Dashboard';
  }

  List<String> _breadcrumbsForLocation(String location) {
    if (location.startsWith('/resellers/add')) {
      return const ['Resellers', 'Register Reseller'];
    }
    if (location.startsWith('/resellers')) {
      return const ['Resellers', 'View All Resellers'];
    }
    if (location.startsWith('/companies/register')) {
      return const ['Companies', 'Create New Company'];
    }
    if (location.startsWith('/companies')) {
      return const ['Companies', 'View All Companies'];
    }
    if (location.startsWith('/bus-companies/add')) {
      return const ['Bus Fleet', 'Add Bus Company'];
    }
    if (location.startsWith('/bus-companies')) {
      return const ['Bus Fleet', 'View Bus Companies'];
    }
    if (location.startsWith('/goods-companies/add')) {
      return const ['Goods Fleet', 'Add Goods Company'];
    }
    if (location.startsWith('/goods-companies')) {
      return const ['Goods Fleet', 'View Goods Companies'];
    }
    if (location.startsWith('/plans/create')) {
      return const ['Subscriptions', 'Create New Plan'];
    }
    if (location.startsWith('/plans')) {
      return const ['Subscriptions', 'View All Plans'];
    }
    if (location.startsWith('/billing/invoices')) {
      return const ['Subscriptions', 'Platform Invoices'];
    }
    if (location.startsWith('/transport/wallet')) {
      return const ['Transport', 'Wallet'];
    }
    if (location.startsWith('/transport/marketplace')) {
      return const ['Transport', 'Loads & Bids'];
    }
    if (location.startsWith('/transport/drivers')) {
      return const ['Transport', 'Drivers'];
    }
    if (location.startsWith('/transport/fraud')) {
      return const ['Transport', 'Fraud Prevention'];
    }
    return const ['Overview'];
  }
}
