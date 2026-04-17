// Search App Bar Widget for NexaTrace System
// This file contains the search app bar widget used throughout the application

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClearSearch;
  final bool showBackButton;
  final bool showSearchIcon;
  final bool showClearButton;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double elevation;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final List<Widget>? actions;
  final double preferredHeight;

  const SearchAppBar({
    super.key,
    this.title,
    this.hintText = 'Search...',
    required this.onSearchChanged,
    this.onBackPressed,
    this.onSearchSubmitted,
    this.onClearSearch,
    this.showBackButton = true,
    this.showSearchIcon = true,
    this.showClearButton = true,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.elevation = 0,
    this.controller,
    this.focusNode,
    this.autofocus = true,
    this.actions,
    this.preferredHeight = 56.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isSearching = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onSearchChanged(_controller.text);
  }

  void _onFocusChanged() {
    setState(() {
      _isSearching = _focusNode.hasFocus;
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClearSearch?.call();
    _focusNode.requestFocus();
  }

  void _submitSearch() {
    _focusNode.unfocus();
    widget.onSearchSubmitted?.call();
  }

  void _onBackPressed() {
    if (_isSearching) {
      _focusNode.unfocus();
      _controller.clear();
    } else {
      widget.onBackPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final backgroundColor = widget.backgroundColor ??
        (isDarkMode ? AppColors.gray900 : AppColors.white);
    final textColor = widget.textColor ??
        (isDarkMode ? AppColors.white : AppColors.textPrimary);
    final iconColor =
        widget.iconColor ?? (isDarkMode ? AppColors.white : AppColors.gray600);
    final hintColor = isDarkMode ? AppColors.gray400 : AppColors.gray500;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: widget.elevation,
      leading: widget.showBackButton
          ? IconButton(
              icon: Icon(
                _isSearching ? Icons.arrow_back : Icons.arrow_back_ios,
                color: iconColor,
              ),
              onPressed: _onBackPressed,
            )
          : null,
      title: _buildSearchField(
        context,
        backgroundColor,
        textColor,
        hintColor,
        iconColor,
        isDarkMode,
      ),
      actions: [
        if (_hasText && widget.showClearButton)
          IconButton(
            icon: Icon(Icons.clear, color: iconColor),
            onPressed: _clearSearch,
          ),
        ...?widget.actions,
      ],
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    Color backgroundColor,
    Color textColor,
    Color hintColor,
    Color iconColor,
    bool isDarkMode,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gray800 : AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (widget.showSearchIcon)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.search, size: 20, color: hintColor),
            ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              style: TextStyles.bodyMedium.copyWith(color: textColor),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyles.bodyMedium.copyWith(color: hintColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: (_) => _submitSearch(),
              onTapOutside: (_) => _focusNode.unfocus(),
            ),
          ),
        ],
      ),
    );
  }
}

// Search App Bar with filter
class SearchAppBarWithFilter extends StatefulWidget
    implements PreferredSizeWidget {
  final String? title;
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double elevation;
  final bool showFilterBadge;
  final int filterCount;
  final double preferredHeight;

  const SearchAppBarWithFilter({
    super.key,
    this.title,
    this.hintText = 'Search...',
    required this.onSearchChanged,
    required this.onFilterPressed,
    this.onBackPressed,
    this.showBackButton = true,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.elevation = 0,
    this.showFilterBadge = false,
    this.filterCount = 0,
    this.preferredHeight = 56.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

  @override
  State<SearchAppBarWithFilter> createState() => _SearchAppBarWithFilterState();
}

class _SearchAppBarWithFilterState extends State<SearchAppBarWithFilter> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(() {
      widget.onSearchChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final backgroundColor = widget.backgroundColor ??
        (isDarkMode ? AppColors.gray900 : AppColors.white);
    final textColor = widget.textColor ??
        (isDarkMode ? AppColors.white : AppColors.textPrimary);
    final iconColor =
        widget.iconColor ?? (isDarkMode ? AppColors.white : AppColors.gray600);
    final hintColor = isDarkMode ? AppColors.gray400 : AppColors.gray500;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: widget.elevation,
      leading: widget.showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: iconColor),
              onPressed: widget.onBackPressed,
            )
          : null,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.gray800 : AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.search, size: 20, color: hintColor),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                style: TextStyles.bodyMedium.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyles.bodyMedium.copyWith(color: hintColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onTapOutside: (_) => _focusNode.unfocus(),
              ),
            ),
            if (_controller.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, size: 20, color: hintColor),
                onPressed: _clearSearch,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(Icons.filter_list, color: iconColor),
              onPressed: widget.onFilterPressed,
            ),
            if (widget.showFilterBadge && widget.filterCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.filterCount > 9
                        ? '9+'
                        : widget.filterCount.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// Search App Bar with tabs
class SearchAppBarWithTabs extends StatefulWidget
    implements PreferredSizeWidget {
  final String? title;
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final List<String> tabs;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? tabColor;
  final Color? selectedTabColor;
  final Color? indicatorColor;
  final double elevation;
  final double preferredHeight;

  const SearchAppBarWithTabs({
    super.key,
    this.title,
    this.hintText = 'Search...',
    required this.onSearchChanged,
    required this.tabs,
    required this.selectedTabIndex,
    required this.onTabChanged,
    this.onBackPressed,
    this.showBackButton = true,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.tabColor,
    this.selectedTabColor,
    this.indicatorColor,
    this.elevation = 0,
    this.preferredHeight = 104.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

  @override
  State<SearchAppBarWithTabs> createState() => _SearchAppBarWithTabsState();
}

class _SearchAppBarWithTabsState extends State<SearchAppBarWithTabs> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(() {
      widget.onSearchChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final backgroundColor = widget.backgroundColor ??
        (isDarkMode ? AppColors.gray900 : AppColors.white);
    final textColor = widget.textColor ??
        (isDarkMode ? AppColors.white : AppColors.textPrimary);
    final iconColor =
        widget.iconColor ?? (isDarkMode ? AppColors.white : AppColors.gray600);
    final hintColor = isDarkMode ? AppColors.gray400 : AppColors.gray500;
    final tabColor =
        widget.tabColor ?? (isDarkMode ? AppColors.gray400 : AppColors.gray600);
    final selectedTabColor = widget.selectedTabColor ?? AppColors.primary;
    final indicatorColor = widget.indicatorColor ?? AppColors.primary;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: widget.elevation,
      leading: widget.showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: iconColor),
              onPressed: widget.onBackPressed,
            )
          : null,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.gray800 : AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.search, size: 20, color: hintColor),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                style: TextStyles.bodyMedium.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyles.bodyMedium.copyWith(color: hintColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onTapOutside: (_) => _focusNode.unfocus(),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: backgroundColor,
          child: TabBar(
            tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
            indicatorColor: indicatorColor,
            labelColor: selectedTabColor,
            unselectedLabelColor: tabColor,
            onTap: widget.onTabChanged,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            labelStyle: TextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyles.bodyMedium,
          ),
        ),
      ),
    );
  }
}
