import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/auth/factory_auth_bloc.dart';
import 'package:nexatrace_system/routes/app_router.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/admin_top_bar.dart';
import 'package:nexatrace_system/shared/widgets/navigation/admin_sidebar.dart';

class FactoryShell extends StatelessWidget {
  final Widget child;

  const FactoryShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 1024;
    final sidebar = AdminSidebar(
      collapsed: false,
      sections: _sections(),
      footerTitle: 'Admin',
      footerSubtitle: null,
    );

    final location = GoRouterState.of(context).uri.toString();
    final title = _titleForLocation(location);
    final crumbs = _breadcrumbsForLocation(location);

    return BlocListener<FactoryAuthBloc, FactoryAuthState>(
      listenWhen: (previous, current) => current is FactoryAuthUnauthenticated,
      listener: (context, state) {
        context.read<AppRouter>().goToFactoryLogin(context);
      },
      child: Scaffold(
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
                        userLabel: 'Admin',
                        onToggleSidebar: () {
                          if (isNarrow) {
                            Scaffold.of(innerContext).openDrawer();
                          }
                        },
                        onLogout: () {
                          innerContext.read<FactoryAuthBloc>().add(
                            FactoryLogoutRequested(),
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
      ),
    );
  }

  List<AdminSidebarSection> _sections() {
    return const [
      AdminSidebarSection(
        title: 'Factory',
        items: [
          AdminSidebarItem(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            route: '/factory/dashboard',
          ),
          AdminSidebarItem(
            label: 'Products',
            icon: Icons.inventory_2_outlined,
            route: '/factory/products',
            children: [
              AdminSidebarItem(
                label: 'Create Product',
                icon: Icons.add_circle_outline,
                route: '/factory/products/create',
              ),
              AdminSidebarItem(
                label: 'Product List',
                icon: Icons.list_alt,
                route: '/factory/products',
              ),
            ],
          ),
          AdminSidebarItem(
            label: 'Orders',
            icon: Icons.receipt_long_outlined,
            route: '/factory/orders',
          ),
        ],
      ),
      AdminSidebarSection(
        title: 'People',
        items: [
          AdminSidebarItem(
            label: 'Store Keepers',
            icon: Icons.people_outline,
            route: '/factory/store-keepers',
            children: [
              AdminSidebarItem(
                label: 'Add Store Keeper',
                icon: Icons.person_add_outlined,
                route: '/factory/store-keepers/create',
              ),
              AdminSidebarItem(
                label: 'View Store Keepers',
                icon: Icons.list_alt,
                route: '/factory/store-keepers',
              ),
            ],
          ),
          AdminSidebarItem(
            label: 'Drivers',
            icon: Icons.delivery_dining,
            route: '/factory/drivers',
            children: [
              AdminSidebarItem(
                label: 'Add Driver',
                icon: Icons.person_add_outlined,
                route: '/factory/drivers/create',
              ),
              AdminSidebarItem(
                label: 'View Drivers',
                icon: Icons.list_alt,
                route: '/factory/drivers',
              ),
              AdminSidebarItem(
                label: 'Driver Dashboard',
                icon: Icons.dashboard_outlined,
                route: '/factory/driver/dashboard',
              ),
            ],
          ),
        ],
      ),
      AdminSidebarSection(
        title: 'Codes',
        items: [
          AdminSidebarItem(
            label: 'Unit',
            icon: Icons.qr_code_2,
            route: '/factory/codes/unit',
            children: [
              AdminSidebarItem(
                label: 'Generate Unit',
                icon: Icons.add_circle_outline,
                route: '/factory/codes/unit/generate',
              ),
              AdminSidebarItem(
                label: 'View Unit List',
                icon: Icons.list_alt,
                route: '/factory/codes/unit',
              ),
            ],
          ),
          AdminSidebarItem(
            label: 'Packet',
            icon: Icons.inventory_2_outlined,
            route: '/factory/codes/packet',
            children: [
              AdminSidebarItem(
                label: 'Generate Packet',
                icon: Icons.add_circle_outline,
                route: '/factory/codes/packet/generate',
              ),
              AdminSidebarItem(
                label: 'View Packet List',
                icon: Icons.list_alt,
                route: '/factory/codes/packet',
              ),
              AdminSidebarItem(
                label: 'Packet Overview',
                icon: Icons.bar_chart_outlined,
                route: '/factory/codes/packet/overview',
              ),
            ],
          ),
          AdminSidebarItem(
            label: 'Carton',
            icon: Icons.all_inbox_outlined,
            route: '/factory/codes/carton',
            children: [
              AdminSidebarItem(
                label: 'Generate Carton',
                icon: Icons.add_circle_outline,
                route: '/factory/codes/carton/generate',
              ),
              AdminSidebarItem(
                label: 'View Carton List',
                icon: Icons.list_alt,
                route: '/factory/codes/carton',
              ),
              AdminSidebarItem(
                label: 'Carton Overview',
                icon: Icons.bar_chart_outlined,
                route: '/factory/codes/carton/overview',
              ),
            ],
          ),
          AdminSidebarItem(
            label: 'Bundles (Orders)',
            icon: Icons.layers_outlined,
            route: '/factory/codes/bundles',
            children: [
              AdminSidebarItem(
                label: 'Create Bundle',
                icon: Icons.add_circle_outline,
                route: '/factory/codes/bundles/pack',
              ),
              AdminSidebarItem(
                label: 'View Bundles',
                icon: Icons.list_alt,
                route: '/factory/codes/bundles',
              ),
            ],
          ),
          AdminSidebarItem(
            label: 'Smart Codes',
            icon: Icons.qr_code_scanner,
            route: '/factory/codes/smart-codes',
            children: [
              AdminSidebarItem(
                label: 'Smart Code List',
                icon: Icons.list_alt,
                route: '/factory/codes/smart-codes',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  String _titleForLocation(String location) {
    if (location.startsWith('/factory/orders')) return 'Orders';
    if (location.startsWith('/factory/products/create')) {
      return 'Create Product';
    }
    if (location.startsWith('/factory/products')) return 'Product List';
    if (location.startsWith('/factory/store-keepers/create'))
      return 'Add Store Keeper';
    if (location.startsWith('/factory/store-keepers')) return 'Store Keepers';

    if (location.startsWith('/factory/driver/scan-receive')) return 'Receive';
    if (location.startsWith('/factory/driver/delivery-scan'))
      return 'Delivery Scan';
    if (location.startsWith('/factory/driver/location-confirm'))
      return 'Location Confirm';
    if (location.startsWith('/factory/driver/pod')) return 'Proof of Delivery';
    if (location.startsWith('/factory/driver/earnings')) return 'Earnings';
    if (location.startsWith('/factory/driver/vehicle')) return 'Vehicle';
    if (location.startsWith('/factory/driver/map-tracking'))
      return 'Map Tracking';
    if (location.startsWith('/factory/driver')) return 'Drivers';
    if (location.startsWith('/factory/codes/unit/generate')) {
      return 'Generate Unit';
    }
    if (location.startsWith('/factory/codes/unit')) return 'View Unit List';

    if (location.startsWith('/factory/codes/packet/generate')) {
      return 'Generate Packet';
    }
    if (location.startsWith('/factory/codes/packet/overview')) {
      return 'Packet Overview';
    }
    if (location.startsWith('/factory/codes/packet')) return 'View Packet List';

    if (location.startsWith('/factory/codes/carton/generate')) {
      return 'Generate Carton';
    }
    if (location.startsWith('/factory/codes/carton/overview')) {
      return 'Carton Overview';
    }
    if (location.startsWith('/factory/codes/carton')) return 'View Carton List';

    if (location.startsWith('/factory/codes/bundles/pack'))
      return 'Create Bundle';
    if (location.startsWith('/factory/codes/bundles')) return 'View Bundles';
    return 'Factory Admin';
  }

  List<String> _breadcrumbsForLocation(String location) {
    if (location.startsWith('/factory/orders')) {
      return const ['Factory', 'Orders'];
    }
    if (location.startsWith('/factory/products/create')) {
      return const ['Factory', 'Products', 'Create Product'];
    }
    if (location.startsWith('/factory/products')) {
      return const ['Factory', 'Products', 'Product List'];
    }
    if (location.startsWith('/factory/store-keepers/create')) {
      return const ['Factory', 'People', 'Store Keepers', 'Add Store Keeper'];
    }
    if (location.startsWith('/factory/store-keepers')) {
      return const ['Factory', 'People', 'Store Keepers'];
    }
    if (location.startsWith('/factory/driver/scan-receive')) {
      return const ['Factory', 'People', 'Drivers', 'Receive'];
    }
    if (location.startsWith('/factory/driver/delivery-scan')) {
      return const ['Factory', 'People', 'Drivers', 'Delivery Scan'];
    }
    if (location.startsWith('/factory/driver/location-confirm')) {
      return const ['Factory', 'People', 'Drivers', 'Location Confirm'];
    }
    if (location.startsWith('/factory/driver/pod')) {
      return const ['Factory', 'People', 'Drivers', 'Proof of Delivery'];
    }
    if (location.startsWith('/factory/driver/earnings')) {
      return const ['Factory', 'People', 'Drivers', 'Earnings'];
    }
    if (location.startsWith('/factory/driver/vehicle')) {
      return const ['Factory', 'People', 'Drivers', 'Vehicle'];
    }
    if (location.startsWith('/factory/driver/map-tracking')) {
      return const ['Factory', 'People', 'Drivers', 'Map Tracking'];
    }
    if (location.startsWith('/factory/driver')) {
      return const ['Factory', 'People', 'Drivers'];
    }
    if (location.startsWith('/factory/codes/unit')) {
      return const ['Factory', 'Codes', 'Unit'];
    }
    if (location.startsWith('/factory/codes/packet/generate')) {
      return const ['Factory', 'Codes', 'Packet', 'Generate Packet'];
    }
    if (location.startsWith('/factory/codes/packet/overview')) {
      return const ['Factory', 'Codes', 'Packet', 'Overview'];
    }
    if (location.startsWith('/factory/codes/packet')) {
      return const ['Factory', 'Codes', 'Packet', 'View Packet List'];
    }
    if (location.startsWith('/factory/codes/carton/generate')) {
      return const ['Factory', 'Codes', 'Carton', 'Generate Carton'];
    }
    if (location.startsWith('/factory/codes/carton/overview')) {
      return const ['Factory', 'Codes', 'Carton', 'Overview'];
    }
    if (location.startsWith('/factory/codes/carton')) {
      return const ['Factory', 'Codes', 'Carton', 'View Carton List'];
    }
    if (location.startsWith('/factory/codes/bundles')) {
      return const ['Factory', 'Codes', 'Bundles'];
    }
    return const ['Factory', 'Dashboard'];
  }
}
