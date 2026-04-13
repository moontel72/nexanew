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
    final sidebar = AdminSidebar(collapsed: false, sections: _sections());

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
                        }
                      },
                      onLogout: () async {
                        innerContext.read<FactoryAuthBloc>().add(
                          FactoryLogoutRequested(),
                        );
                        innerContext.read<AppRouter>().goToFactoryLogin(
                          innerContext,
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
            ],
          ),
          AdminSidebarItem(
            label: 'Bundle',
            icon: Icons.layers_outlined,
            route: '/factory/codes/bundle',
            children: [
              AdminSidebarItem(
                label: 'Generate Bundle',
                icon: Icons.add_circle_outline,
                route: '/factory/codes/bundle/generate',
              ),
              AdminSidebarItem(
                label: 'View Bundle List',
                icon: Icons.list_alt,
                route: '/factory/codes/bundle',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  String _titleForLocation(String location) {
    if (location.startsWith('/factory/products')) return 'Products';
    if (location.startsWith('/factory/codes/unit/generate')) {
      return 'Generate Unit';
    }
    if (location.startsWith('/factory/codes/unit')) return 'View Unit List';

    if (location.startsWith('/factory/codes/packet/generate')) {
      return 'Generate Packet';
    }
    if (location.startsWith('/factory/codes/packet')) return 'View Packet List';

    if (location.startsWith('/factory/codes/carton/generate')) {
      return 'Generate Carton';
    }
    if (location.startsWith('/factory/codes/carton')) return 'View Carton List';

    if (location.startsWith('/factory/codes/bundle/generate')) {
      return 'Generate Bundle';
    }
    if (location.startsWith('/factory/codes/bundle')) return 'View Bundle List';
    return 'Factory Admin';
  }

  List<String> _breadcrumbsForLocation(String location) {
    if (location.startsWith('/factory/products')) {
      return const ['Factory', 'Products'];
    }
    if (location.startsWith('/factory/codes/unit')) {
      return const ['Factory', 'Codes', 'Unit'];
    }
    if (location.startsWith('/factory/codes/packet')) {
      return const ['Factory', 'Codes', 'Packet'];
    }
    if (location.startsWith('/factory/codes/carton')) {
      return const ['Factory', 'Codes', 'Carton'];
    }
    if (location.startsWith('/factory/codes/bundle')) {
      return const ['Factory', 'Codes', 'Bundle'];
    }
    return const ['Factory', 'Dashboard'];
  }
}
