// Dropdown Field Widget for NexaTrace System
// This file contains the dropdown field widget used throughout the application

import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class DropdownField<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;
  final bool isRequired;
  final bool isEnabled;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? fillColor;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final bool showError;
  final bool dense;
  final double? width;
  final double? height;
  final bool showLabel;
  final bool showClearButton;
  final VoidCallback? onClear;

  const DropdownField({
    super.key,
    required this.label,
    this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
    this.isEnabled = true,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = 8,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.fillColor,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.showError = true,
    this.dense = false,
    this.width,
    this.height,
    this.showLabel = true,
    this.showClearButton = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Row(
            children: [
              Text(
                label,
                style: labelStyle ??
                    Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: (labelStyle ?? Theme.of(context).textTheme.labelMedium)
                      ?.copyWith(color: AppColors.error),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: width,
          height: height,
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: isEnabled && !isLoading ? onChanged : null,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: hintStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDisabled,
                      ),
              filled: true,
              fillColor: fillColor ??
                  (isEnabled ? AppColors.white : AppColors.gray100),
              contentPadding: padding,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ?? AppColors.border,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ?? AppColors.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: focusedBorderColor ?? AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: errorBorderColor ?? AppColors.error,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: errorBorderColor ?? AppColors.error,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: AppColors.gray300,
                  width: 1,
                ),
              ),
              prefixIcon: prefixIcon,
              suffixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : showClearButton && value != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: onClear,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      : suffixIcon,
              errorText: showError ? errorText : null,
              errorStyle: errorStyle ??
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
              isDense: dense,
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textDisabled,
                ),
            icon: const Icon(Icons.arrow_drop_down, size: 24),
            iconEnabledColor: AppColors.textPrimary,
            iconDisabledColor: AppColors.textDisabled,
            isExpanded: true,
            isDense: dense,
            dropdownColor: AppColors.white,
            menuMaxHeight: 300,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ],
    );
  }
}

class SearchableDropdownField<T> extends StatefulWidget {
  final String label;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;
  final bool isRequired;
  final bool isEnabled;
  final bool isLoading;
  final String? searchHint;

  const SearchableDropdownField({
    super.key,
    required this.label,
    this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
    this.isEnabled = true,
    this.isLoading = false,
    this.searchHint,
  });

  @override
  State<SearchableDropdownField<T>> createState() => _SearchableDropdownFieldState<T>();
}

class _SearchableDropdownFieldState<T> extends State<SearchableDropdownField<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<DropdownMenuItem<T>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(SearchableDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final text = item.child is Text
              ? (item.child as Text).data?.toLowerCase() ?? ''
              : '';
          return text.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownField<T>(
      label: widget.label,
      hintText: widget.hintText,
      value: widget.value,
      items: _filteredItems,
      onChanged: widget.onChanged,
      validator: widget.validator,
      isRequired: widget.isRequired,
      isEnabled: widget.isEnabled,
      isLoading: widget.isLoading,
      suffixIcon: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(widget.searchHint ?? 'Search'),
              content: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Type to search...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MultiSelectDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final List<T> selectedValues;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<List<T>> onChanged;
  final FormFieldValidator<List<T>>? validator;
  final bool isRequired;

  const MultiSelectDropdownField({
    super.key,
    required this.label,
    this.hintText,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.error,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items.map((item) {
            final isSelected = selectedValues.contains(item.value);
            return FilterChip(
              label: item.child,
              selected: isSelected,
              onSelected: (selected) {
                final newValues = List<T>.from(selectedValues);
                if (selected) {
                  final val = item.value;
                  if (val != null) newValues.add(val);
                } else {
                  newValues.remove(item.value);
                }
                onChanged(newValues);
              },
              selectedColor: AppColors.primary.withAlpha(50),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }
}
