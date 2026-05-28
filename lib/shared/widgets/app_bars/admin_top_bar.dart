import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class AdminTopBar extends StatelessWidget {
  final String title;
  final List<String> breadcrumbs;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onLogout;
  final String userLabel;

  const AdminTopBar({
    super.key,
    required this.title,
    required this.breadcrumbs,
    this.onToggleSidebar,
    this.onLogout,
    this.userLabel = 'Super Admin',
  });

  @override
  Widget build(BuildContext context) {
    final showSearch = MediaQuery.of(context).size.width >= 1100;

    return Material(
      color: AppColors.surface,
      elevation: 1,
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: onToggleSidebar,
                icon: const Icon(Icons.menu),
                tooltip: 'Menu',
              ),
              const Gap(8),
              Expanded(
                child: _Breadcrumbs(
                  title: title,
                  breadcrumbs: breadcrumbs,
                ),
              ),
              const Gap(12),
              if (showSearch)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360, minWidth: 220),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search companies, plans, loads, trips…',
                      isDense: true,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  tooltip: 'Search',
                ),
              const Gap(12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
                tooltip: 'Notifications',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    onLogout?.call();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'account',
                    child: Text('Account'),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Text('Sign out'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        userLabel,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Gap(6),
                      const Icon(Icons.expand_more),
                    ],
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

class _Breadcrumbs extends StatelessWidget {
  final String title;
  final List<String> breadcrumbs;

  const _Breadcrumbs({required this.title, required this.breadcrumbs});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (breadcrumbs.isNotEmpty)
          Text(
            breadcrumbs.join(' / '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }
}

