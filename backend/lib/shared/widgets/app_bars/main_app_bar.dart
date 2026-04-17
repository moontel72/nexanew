//lib/shared/widgets/app_bars/main_app_bar.dart
// Main App Bar Widget for NexaTrace System
// This file contains the main app bar widget used throughout the application

import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final bool centerTitle;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;
  final double leadingWidth;
  final bool automaticallyImplyLeading;

  const MainAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 2,
    this.centerTitle = true,
    this.flexibleSpace,
    this.bottom,
    this.toolbarHeight = kToolbarHeight,
    this.leadingWidth = 56,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyles.heading6.copyWith(
          color: titleColor ?? AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: _buildLeading(context),
      actions: actions,
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: elevation,
      centerTitle: centerTitle,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }

    return null;
  }
}

// App bar with search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;
  final bool showClearButton;
  final Duration debounceDuration;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const SearchAppBar({
    super.key,
    this.hintText = 'Search...',
    required this.onSearchChanged,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.elevation = 2,
    this.showClearButton = true,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.controller,
    this.focusNode,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearchChanged(_controller.text);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor ?? AppColors.primary,
      elevation: widget.elevation,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyles.bodyMedium.copyWith(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          suffixIcon: widget.showClearButton && _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                    color: AppColors.white,
                  ),
                  onPressed: _clearSearch,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : null,
        ),
        cursorColor: AppColors.white,
        autofocus: true,
      ),
      actions: widget.actions,
    );
  }
}

// App bar with tabs
class TabbedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> tabs;
  final TabController? tabController;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double elevation;
  final bool isScrollable;
  final EdgeInsetsGeometry labelPadding;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  const TabbedAppBar({
    super.key,
    required this.title,
    required this.tabs,
    this.tabController,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.indicatorColor,
    this.elevation = 2,
    this.isScrollable = false,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.labelStyle,
    this.unselectedLabelStyle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyles.heading6.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: elevation,
      bottom: TabBar(
        controller: tabController,
        tabs: tabs,
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? AppColors.white,
        labelColor: AppColors.white,
        unselectedLabelColor: Colors.white70,
        labelPadding: labelPadding,
        labelStyle: labelStyle ??
            TextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: unselectedLabelStyle ??
            TextStyles.bodyMedium.copyWith(color: Colors.white70),
      ),
    );
  }
}

// App bar with user profile
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String? userEmail;
  final String? userAvatar;
  final VoidCallback? onProfileTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;

  const ProfileAppBar({
    super.key,
    required this.userName,
    this.userEmail,
    this.userAvatar,
    this.onProfileTap,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.elevation = 2,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: GestureDetector(
        onTap: onProfileTap,
        child: Row(
          children: [
            // User avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                image: userAvatar != null
                    ? DecorationImage(
                        image: NetworkImage(userAvatar!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: userAvatar == null
                  ? Icon(Icons.person, color: AppColors.primary, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            // User info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userName,
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (userEmail != null)
                  Text(
                    userEmail!,
                    style: TextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: actions,
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: elevation,
    );
  }
}

// App bar with factory selection
class FactoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String factoryName;
  final String? factoryLogo;
  final VoidCallback? onFactoryTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;

  const FactoryAppBar({
    super.key,
    required this.factoryName,
    this.factoryLogo,
    this.onFactoryTap,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.elevation = 2,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: GestureDetector(
        onTap: onFactoryTap,
        child: Row(
          children: [
            // Factory logo
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(6),
                image: factoryLogo != null
                    ? DecorationImage(
                        image: NetworkImage(factoryLogo!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: factoryLogo == null
                  ? Icon(Icons.factory, color: AppColors.primary, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            // Factory name
            Text(
              factoryName,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      actions: actions,
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: elevation,
    );
  }
}

// App bar with notification badge
class NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;

  const NotificationAppBar({
    super.key,
    required this.title,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.elevation = 2,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final notificationAction = notificationCount > 0
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: AppColors.white),
                onPressed: onNotificationTap,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 9 ? '9+' : notificationCount.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          )
        : IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.white),
            onPressed: onNotificationTap,
          );

    final allActions = [notificationAction, ...?actions];

    return AppBar(
      title: Text(
        title,
        style: TextStyles.heading6.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: allActions,
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: elevation,
      centerTitle: centerTitle,
    );
  }
}
