import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class AdminSidebarSection {
  final String title;
  final List<AdminSidebarItem> items;

  const AdminSidebarSection({required this.title, required this.items});
}

class AdminSidebarItem {
  final String label;
  final IconData icon;
  final String? route;
  final List<AdminSidebarItem> children;

  const AdminSidebarItem({
    required this.label,
    required this.icon,
    this.route,
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;
}

class AdminSidebar extends StatelessWidget {
  final bool collapsed;
  final List<AdminSidebarSection> sections;
  final String footerTitle;
  final String? footerSubtitle;

  const AdminSidebar({
    super.key,
    required this.collapsed,
    required this.sections,
    this.footerTitle = 'Super Admin',
    this.footerSubtitle = 'Platform',
  });

  @override
  Widget build(BuildContext context) {
    const expandedWidth = 268.0;
    const collapsedWidth = 76.0;
    final width = collapsed ? collapsedWidth : expandedWidth;
    final location = GoRouterState.of(context).uri.toString();

    return Material(
      color: AppColors.adminSidebarBackground,
      elevation: 1,
      child: SizedBox(
        width: width,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/logo/traceodd_logo.svg',
                      width: 36,
                      height: 36,
                    ),
                    if (!collapsed) ...[
                      const Gap(10),
                      Expanded(
                        child: Text(
                          'NexaTrace',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.adminSidebarText,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.adminSidebarBorder),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final section in sections) ...[
                      if (!collapsed)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                          child: Text(
                            section.title.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.adminSidebarTextMuted,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                          ),
                        ),
                      for (final item in section.items)
                        _SidebarTile(
                          collapsed: collapsed,
                          item: item,
                          location: location,
                        ),
                      const Gap(6),
                    ],
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.adminSidebarBorder),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    if (!collapsed) ...[
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              footerTitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.adminSidebarText,
                                  ),
                            ),
                            if (footerSubtitle != null)
                              Text(
                                footerSubtitle!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.adminSidebarTextMuted,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final bool collapsed;
  final AdminSidebarItem item;
  final String location;

  const _SidebarTile({
    required this.collapsed,
    required this.item,
    required this.location,
  });

  bool _isSelected(BuildContext context, String? route) {
    final location = this.location;
    if (route == null) return false;
    if (location == route) return true;
    if (route == '/dashboard' && location.startsWith('/dashboard')) return true;
    if (route != '/dashboard' && location.startsWith(route)) return true;
    return false;
  }

  bool _isAnyChildSelected() {
    for (final child in item.children) {
      final route = child.route;
      if (route != null && location.startsWith(route)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _isSelected(context, item.route) || _isAnyChildSelected();
    final bg = selected ? Colors.white.withOpacity(0.10) : Colors.transparent;
    final fg = selected ? AppColors.white : AppColors.adminSidebarText;
    final iconColor = selected ? AppColors.white : AppColors.adminSidebarText;

    if (!collapsed && item.hasChildren) {
      final isExpanded = _isAnyChildSelected();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withOpacity(0.35)
                    : Colors.transparent,
              ),
            ),
            child: ExpansionTile(
              initiallyExpanded: isExpanded,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              collapsedIconColor: iconColor,
              iconColor: iconColor,
              leading: Icon(item.icon, color: iconColor, size: 20),
              title: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: [
                for (final child in item.children)
                  _ChildTile(
                    child: child,
                    selected: child.route != null && location == child.route,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: item.route == null ? null : () => context.go(item.route!),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withOpacity(0.35)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(item.icon, color: iconColor, size: 20),
                if (!collapsed) ...[
                  const Gap(10),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  final AdminSidebarItem child;
  final bool selected;

  const _ChildTile({required this.child, required this.selected});

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.white : AppColors.adminSidebarText;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: child.route == null ? null : () => context.go(child.route!),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withOpacity(0.35)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                child.icon,
                size: 18,
                color: selected ? AppColors.white : AppColors.adminSidebarText,
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  child.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
