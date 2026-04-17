import 'package:flutter/material.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

/// Filter chip for use in FilterChipRow
class FilterChipData {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final int? count;

  const FilterChipData({
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.count,
  });
}

/// Row of filter chips for filtering lists
class FilterChipRow extends StatefulWidget {
  final List<FilterChipData> chips;
  final String? selectedValue;
  final ValueChanged<String?> onSelectionChanged;
  final bool scrollable;
  final EdgeInsets padding;
  final double spacing;
  final bool showCounts;
  final bool showClearButton;
  final String clearButtonText;

  const FilterChipRow({
    super.key,
    required this.chips,
    this.selectedValue,
    required this.onSelectionChanged,
    this.scrollable = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.spacing = 8,
    this.showCounts = true,
    this.showClearButton = true,
    this.clearButtonText = 'Clear',
  });

  @override
  State<FilterChipRow> createState() => _FilterChipRowState();
}

class _FilterChipRowState extends State<FilterChipRow> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(FilterChipRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      setState(() {
        _selectedValue = widget.selectedValue;
      });
    }
  }

  void _handleChipSelected(String value) {
    setState(() {
      _selectedValue = _selectedValue == value ? null : value;
    });
    widget.onSelectionChanged(_selectedValue);
  }

  void _clearSelection() {
    setState(() {
      _selectedValue = null;
    });
    widget.onSelectionChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final chips = [
      if (widget.scrollable)
        ...widget.chips.map((chip) => _buildFilterChip(chip, context))
      else
        ...widget.chips.map((chip) => Flexible(
              child: _buildFilterChip(chip, context),
            )),
    ];

    final content = widget.scrollable
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...chips,
                if (widget.showClearButton && _selectedValue != null)
                  Padding(
                    padding: EdgeInsets.only(left: widget.spacing),
                    child: _buildClearButton(context),
                  ),
              ],
            ),
          )
        : Wrap(
            spacing: widget.spacing,
            runSpacing: widget.spacing,
            children: [
              ...chips,
              if (widget.showClearButton && _selectedValue != null)
                _buildClearButton(context),
            ],
          );

    return Padding(
      padding: widget.padding,
      child: content,
    );
  }

  Widget _buildFilterChip(FilterChipData chip, BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = _selectedValue == chip.value;
    final chipColor = chip.color ?? theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chip.icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  chip.icon,
                  size: 16,
                  color: isSelected ? Colors.white : chipColor,
                ),
              ),
            Text(chip.label),
            if (widget.showCounts && chip.count != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : chipColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chip.count!.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected ? Colors.white : chipColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => _handleChipSelected(chip.value),
        backgroundColor: Colors.transparent,
        selectedColor: chipColor,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? chipColor : theme.dividerColor,
            width: 1,
          ),
        ),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: _clearSelection,
      icon: const Icon(Icons.clear, size: 16),
      label: Text(widget.clearButtonText),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: theme.dividerColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// Pre-configured filter chips for common code filters
class CodeFilters {
  static List<FilterChipData> statusFilters({
    int? activeCount,
    int? pendingCount,
    int? publishedCount,
    int? deactivatedCount,
  }) {
    return [
      FilterChipData(
        label: 'Active',
        value: 'active',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        count: activeCount,
      ),
      FilterChipData(
        label: 'Pending',
        value: 'pending',
        icon: Icons.pending_outlined,
        color: AppColors.warning,
        count: pendingCount,
      ),
      FilterChipData(
        label: 'Published',
        value: 'published',
        icon: Icons.publish_outlined,
        color: AppColors.info,
        count: publishedCount,
      ),
      FilterChipData(
        label: 'Deactivated',
        value: 'deactivated',
        icon: Icons.block_outlined,
        color: AppColors.error,
        count: deactivatedCount,
      ),
    ];
  }

  static List<FilterChipData> typeFilters({
    int? bundleCount,
    int? cartonCount,
    int? packetCount,
    int? unitCount,
  }) {
    return [
      FilterChipData(
        label: 'Bundle',
        value: 'bundle',
        icon: Icons.layers_outlined,
        color: AppColors.primary,
        count: bundleCount,
      ),
      FilterChipData(
        label: 'Carton',
        value: 'carton',
        icon: Icons.inventory_2_outlined,
        color: AppColors.secondary,
        count: cartonCount,
      ),
      FilterChipData(
        label: 'Packet',
        value: 'packet',
        icon: Icons.inventory_outlined,
        color: AppColors.accent,
        count: packetCount,
      ),
      FilterChipData(
        label: 'Unit',
        value: 'unit',
        icon: Icons.qr_code_outlined,
        color: AppColors.success,
        count: unitCount,
      ),
    ];
  }

  static List<FilterChipData> dateFilters() {
    return [
      FilterChipData(
        label: 'Today',
        value: 'today',
        icon: Icons.today_outlined,
      ),
      FilterChipData(
        label: 'This Week',
        value: 'this_week',
        icon: Icons.calendar_view_week_outlined,
      ),
      FilterChipData(
        label: 'This Month',
        value: 'this_month',
        icon: Icons.calendar_month_outlined,
      ),
      FilterChipData(
        label: 'Last 3 Months',
        value: 'last_3_months',
        icon: Icons.history_outlined,
      ),
    ];
  }
}
