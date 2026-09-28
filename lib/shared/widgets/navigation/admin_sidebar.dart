import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/widgets/buttons/missile_3d_button.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/traceodd_brand_tokens.dart';
import 'package:trace_odd/shared/widgets/brand/traceodd_brand.dart';

class AdminSidebarSection {
  final String title;
  final List<AdminSidebarItem> items;
  final Color? color;

  const AdminSidebarSection({
    required this.title,
    required this.items,
    this.color,
  });
}

class AdminSidebarItem {
  final String label;
  final IconData icon;
  final String? route;
  final List<AdminSidebarItem> children;
  final Color? color;

  const AdminSidebarItem({
    required this.label,
    required this.icon,
    this.route,
    this.children = const [],
    this.color,
  });

  bool get hasChildren => children.isNotEmpty;
}

/// Sidebar color palette — matches Sub-Admin spectrum
class _SidebarColors {
  static const Color purple = Color(0xFF7C3AED);
}

class AdminSidebar extends StatelessWidget {
  final bool collapsed;
  final List<AdminSidebarSection> sections;
  final String footerTitle;
  final String? footerSubtitle;

  /// The signed-in tenant's own name (e.g. the factory's registered name). Shown under the platform
  /// brand so whoever is looking at the panel can tell WHICH account they are in. Optional: the
  /// Super Admin panel passes nothing and looks exactly as before.
  final String? companyName;

  const AdminSidebar({
    super.key,
    required this.collapsed,
    required this.sections,
    this.footerTitle = 'Super Admin',
    this.footerSubtitle = 'Platform',
    this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    const expandedWidth = 260.0;
    const collapsedWidth = 60.0;
    final width = collapsed ? collapsedWidth : expandedWidth;
    final location = GoRouterState.of(context).uri.toString();

    return Material(
      color: TraceOddBrandTokens.dark,
      child: SizedBox(
        width: width,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!collapsed)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: const TraceOddBrand(
                    badgeSize: 52,
                    nameSize: 22,
                    nameColor: TraceOddBrandTokens.cream,
                    direction: Axis.horizontal,
                    gap: 12,
                    nameSpacing: 4,
                  ),
                ),
              if (collapsed)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              if (!collapsed && companyName != null && companyName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Text(
                    companyName!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Divider(height: 1, color: Color(0x20FFFFFF)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: [
                    for (final section in sections) ...[
                      if (!collapsed)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 16, 4),
                          child: Text(
                            section.title.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFBDD8DB),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      for (final item in section.items)
                        _PencilTile(
                          collapsed: collapsed,
                          item: item,
                          location: location,
                          sectionColor: section.color,
                        ),
                      const Gap(4),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0x20FFFFFF)),
              if (!collapsed)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.secondary.withValues(
                          alpha: 0.2,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              footerTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            if (footerSubtitle != null)
                              Text(
                                footerSubtitle!,
                                style: const TextStyle(
                                  color: Color(0xFFBDD8DB),
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
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

class _PencilTile extends StatelessWidget {
  final bool collapsed;
  final AdminSidebarItem item;
  final String location;
  final Color? sectionColor;

  const _PencilTile({
    required this.collapsed,
    required this.item,
    required this.location,
    this.sectionColor,
  });

  bool _isSelected(String? route) {
    if (route == null) return false;
    if (location == route) return true;
    if (route == '/dashboard' && location.startsWith('/dashboard')) return true;
    if (route != '/dashboard' && location.startsWith(route)) return true;
    return false;
  }

  bool _isAnyChildSelected() {
    for (final child in item.children) {
      if (child.route != null && location.startsWith(child.route!)) return true;
    }
    return false;
  }

  Color _resolveColor() {
    if (item.color != null) return item.color!;
    if (sectionColor != null) return sectionColor!;
    // Cycle through palette based on label hash for visual variety
    return _SidebarColors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _isSelected(item.route) || _isAnyChildSelected();
    final color = _resolveColor();

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: GestureDetector(
          onTap: item.route != null ? () => context.go(item.route!) : null,
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              color: selected ? Colors.white : const Color(0xFFBDD8DB),
              size: 20,
            ),
          ),
        ),
      );
    }

    if (item.hasChildren) {
      final isExpanded = _isAnyChildSelected();
      return Column(
        children: [
          Missile3DButton(
            label: item.label,
            icon: item.icon,
            color: color,
            // This used to be a literal no-op `onTap: () {}`, so EVERY sidebar entry that has
            // children was dead: it could not navigate, and its children only render when one of
            // them is already the current route (`if (isExpanded)`) - which could never happen.
            // That is why, in the Factory panel, only Dashboard and Orders (the two items without
            // children) were clickable. Navigating to the item's own route is the fix: the parent
            // route IS its list screen, and being on it makes the sub-entries appear.
            onTap: item.route != null ? () => context.go(item.route!) : () {},
            height: 72,
          ),
          if (isExpanded)
            ...item.children.map(
              (c) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Missile3DButton(
                  label: c.label,
                  icon: c.icon,
                  color: c.color ?? color.withAlpha(200),
                  height: 60,
                  onTap: c.route != null ? () => context.go(c.route!) : () {},
                ),
              ),
            ),
        ],
      );
    }

    return Missile3DButton(
      label: item.label,
      icon: item.icon,
      color: color,
      onTap: item.route != null ? () => context.go(item.route!) : () {},
    );
  }
}
