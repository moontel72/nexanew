// Search Field Widget for NexaTrace System
// This file contains the search field widget used throughout the application

import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class SearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;
  final bool enabled;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool showClearButton;
  final bool showSearchIcon;
  final Duration debounceDuration;

  const SearchField({
    super.key,
    this.hintText = 'Search...',
    required this.onChanged,
    this.onSearch,
    this.onClear,
    this.controller,
    this.autofocus = false,
    this.enabled = true,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.hintStyle,
    this.textStyle,
    this.focusNode,
    this.initialValue,
    this.showClearButton = true,
    this.showSearchIcon = true,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _controller.addListener(_onTextChanged);
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

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged(_controller.text);
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  void _onSearch() {
    widget.onSearch?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor ?? AppColors.gray300,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          if (widget.showSearchIcon) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.search,
                color: widget.iconColor ?? AppColors.gray500,
                size: 20.0,
              ),
            ),
            const SizedBox(width: 8.0),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              style: widget.textStyle ?? TextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.hintStyle ??
                    TextStyles.bodyMedium.copyWith(color: AppColors.gray500),
                border: InputBorder.none,
                contentPadding: widget.padding,
                isDense: true,
              ),
              onSubmitted: (_) => _onSearch(),
              onTapOutside: (_) => _focusNode.unfocus(),
            ),
          ),
          if (widget.showClearButton && _controller.text.isNotEmpty) ...[
            IconButton(
              onPressed: _clearText,
              icon: Icon(
                Icons.clear,
                color: widget.iconColor ?? AppColors.gray500,
                size: 20.0,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40.0,
                minHeight: 40.0,
              ),
            ),
          ],
          if (widget.onSearch != null) ...[
            IconButton(
              onPressed: _onSearch,
              icon: Icon(
                Icons.search,
                color: widget.iconColor ?? AppColors.primary,
                size: 20.0,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40.0,
                minHeight: 40.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Search Field with Filter Button
class SearchFieldWithFilter extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterPressed;
  final TextEditingController? controller;
  final bool autofocus;
  final bool enabled;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool showFilterBadge;
  final int filterCount;

  const SearchFieldWithFilter({
    super.key,
    this.hintText = 'Search...',
    required this.onChanged,
    required this.onFilterPressed,
    this.controller,
    this.autofocus = false,
    this.enabled = true,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.hintStyle,
    this.textStyle,
    this.focusNode,
    this.initialValue,
    this.showFilterBadge = false,
    this.filterCount = 0,
  });

  @override
  State<SearchFieldWithFilter> createState() => _SearchFieldWithFilterState();
}

class _SearchFieldWithFilterState extends State<SearchFieldWithFilter> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _controller.addListener(_onTextChanged);
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

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged(_controller.text);
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor ?? AppColors.gray300,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Icon(
              Icons.search,
              color: widget.iconColor ?? AppColors.gray500,
              size: 20.0,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              style: widget.textStyle ?? TextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.hintStyle ??
                    TextStyles.bodyMedium.copyWith(color: AppColors.gray500),
                border: InputBorder.none,
                contentPadding: widget.padding,
                isDense: true,
              ),
              onTapOutside: (_) => _focusNode.unfocus(),
            ),
          ),
          if (_controller.text.isNotEmpty) ...[
            IconButton(
              onPressed: _clearText,
              icon: Icon(
                Icons.clear,
                color: widget.iconColor ?? AppColors.gray500,
                size: 20.0,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40.0,
                minHeight: 40.0,
              ),
            ),
          ],
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: widget.onFilterPressed,
                icon: Icon(
                  Icons.filter_list,
                  color: widget.iconColor ?? AppColors.primary,
                  size: 20.0,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                  minHeight: 40.0,
                ),
              ),
              if (widget.showFilterBadge && widget.filterCount > 0) ...[
                Positioned(
                  top: -4,
                  right: -4,
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
            ],
          ),
        ],
      ),
    );
  }
}

// Search Field with Suggestions
class SearchFieldWithSuggestions extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSuggestionSelected;
  final List<String> suggestions;
  final TextEditingController? controller;
  final bool autofocus;
  final bool enabled;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final String? initialValue;
  final int maxSuggestions;

  const SearchFieldWithSuggestions({
    super.key,
    this.hintText = 'Search...',
    required this.onChanged,
    this.onSuggestionSelected,
    this.suggestions = const [],
    this.controller,
    this.autofocus = false,
    this.enabled = true,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.hintStyle,
    this.textStyle,
    this.focusNode,
    this.initialValue,
    this.maxSuggestions = 5,
  });

  @override
  State<SearchFieldWithSuggestions> createState() =>
      _SearchFieldWithSuggestionsState();
}

class _SearchFieldWithSuggestionsState
    extends State<SearchFieldWithSuggestions> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  double _overlayWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      widget.onChanged(_controller.text);
      if (_controller.text.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _controller.text.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      _overlayWidth = renderObject.size.width;
    } else {
      _overlayWidth = MediaQuery.of(context).size.width - 32;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, widget.height),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _overlayWidth,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.suggestions.isNotEmpty) ...[
                        ...widget.suggestions.take(widget.maxSuggestions).map(
                              (suggestion) => ListTile(
                                title: Text(suggestion),
                                onTap: () {
                                  _controller.text = suggestion;
                                  widget.onSuggestionSelected?.call(suggestion);
                                  _removeOverlay();
                                  _focusNode.unfocus();
                                },
                              ),
                            ),
                      ] else ...[
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No suggestions found',
                            style: TextStyle(color: AppColors.gray500),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged('');
    _removeOverlay();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? AppColors.gray300,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.search,
                color: widget.iconColor ?? AppColors.gray500,
                size: 20.0,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                style: widget.textStyle ?? TextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: widget.hintStyle ??
                      TextStyles.bodyMedium.copyWith(color: AppColors.gray500),
                  border: InputBorder.none,
                  contentPadding: widget.padding,
                  isDense: true,
                ),
                onTapOutside: (_) {
                  _focusNode.unfocus();
                  _removeOverlay();
                },
              ),
            ),
            if (_controller.text.isNotEmpty) ...[
              IconButton(
                onPressed: _clearText,
                icon: Icon(
                  Icons.clear,
                  color: widget.iconColor ?? AppColors.gray500,
                  size: 20.0,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                  minHeight: 40.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
