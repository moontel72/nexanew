import 'dart:async';
import 'package:flutter/material.dart';

/// Search bar widget with filtering and clear functionality
class SearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onFilterPressed;
  final bool showFilterButton;
  final bool autoFocus;
  final TextEditingController? controller;
  final Duration debounceDuration;
  final bool showClearButton;
  final EdgeInsetsGeometry padding;

  const SearchBar({
    super.key,
    this.hintText = 'Search...',
    required this.onSearchChanged,
    this.onFilterPressed,
    this.showFilterButton = true,
    this.autoFocus = false,
    this.controller,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.showClearButton = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearchChanged(_controller.text);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: widget.padding,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Search icon
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                Icons.search,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
            ),

            // Search field
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _controller,
                  autofocus: widget.autoFocus,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    isDense: true,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.grey[900],
                  ),
                  onChanged: (value) {
                    // Handled by controller listener
                  },
                  onSubmitted: (value) {
                    widget.onSearchChanged(value);
                  },
                ),
              ),
            ),

            // Clear button
            if (_hasText && widget.showClearButton)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  onPressed: _clearSearch,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),

            // Filter button
            if (widget.showFilterButton)
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    size: 18,
                    color: theme.primaryColor,
                  ),
                  onPressed: widget.onFilterPressed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Advanced search bar with additional filtering options
class AdvancedSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final List<FilterOption> filterOptions;
  final ValueChanged<List<String>>? onFiltersChanged;
  final bool showAdvancedFilters;
  final EdgeInsetsGeometry padding;

  const AdvancedSearchBar({
    super.key,
    this.hintText = 'Search...',
    required this.onSearchChanged,
    this.filterOptions = const [],
    this.onFiltersChanged,
    this.showAdvancedFilters = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _selectedFilters = [];
  bool _showFilters = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFilter(String filterValue) {
    setState(() {
      if (_selectedFilters.contains(filterValue)) {
        _selectedFilters.remove(filterValue);
      } else {
        _selectedFilters.add(filterValue);
      }
    });
    widget.onFiltersChanged?.call(_selectedFilters);
  }

  void _toggleFiltersPanel() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Search bar
        SearchBar(
          hintText: widget.hintText,
          onSearchChanged: widget.onSearchChanged,
          controller: _controller,
          showFilterButton: widget.showAdvancedFilters,
          onFilterPressed:
              widget.showAdvancedFilters ? _toggleFiltersPanel : null,
          padding: widget.padding,
        ),

        // Filters panel
        if (_showFilters && widget.filterOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.filterOptions.map((option) {
                      final isSelected =
                          _selectedFilters.contains(option.value);
                      return FilterChip(
                        label: Text(option.label),
                        selected: isSelected,
                        onSelected: (_) => _toggleFilter(option.value),
                        backgroundColor: Colors.transparent,
                        selectedColor: option.color?.withValues(alpha: 0.1) ??
                            theme.primaryColor.withValues(alpha: 0.1),
                        checkmarkColor: option.color ?? theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? option.color ?? theme.primaryColor
                                : theme.dividerColor,
                            width: 1,
                          ),
                        ),
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? option.color ?? theme.primaryColor
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Filter option for advanced search
class FilterOption {
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;

  const FilterOption({
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });
}

/// Search history widget
class SearchHistory extends StatelessWidget {
  final List<String> historyItems;
  final ValueChanged<String> onItemSelected;
  final VoidCallback? onClearHistory;
  final int maxItems;

  const SearchHistory({
    super.key,
    required this.historyItems,
    required this.onItemSelected,
    this.onClearHistory,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = historyItems.take(maxItems).toList();

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onClearHistory != null)
                  TextButton(
                    onPressed: onClearHistory,
                    child: Text(
                      'Clear',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // History items
          ...items.map((item) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onItemSelected(item),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        size: 16,
                        color:
                            theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
