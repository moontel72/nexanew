// Company Filter Sheet for NexaTrace System
// Provides filtering options for companies list

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/buttons/secondary_button.dart';

class CompanyFilterSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;
  final Function() onClearFilters;

  const CompanyFilterSheet({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<CompanyFilterSheet> createState() => _CompanyFilterSheetState();
}

class _CompanyFilterSheetState extends State<CompanyFilterSheet> {
  late Map<String, dynamic> _filters;

  // Filter options
  final List<String> _statusOptions = [
    'all',
    'active',
    'inactive',
    'pending',
    'suspended',
    'verified',
  ];

  final List<String> _industryOptions = [
    'all',
    'technology',
    'manufacturing',
    'retail',
    'healthcare',
    'finance',
    'education',
    'logistics',
    'agriculture',
    'construction',
    'other',
  ];

  final List<String> _sortOptions = [
    'name_asc',
    'name_desc',
    'created_at_desc',
    'created_at_asc',
    'updated_at_desc',
    'updated_at_asc',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Search Filter
          _buildSearchFilter(),
          const SizedBox(height: 20),

          // Status Filter
          _buildStatusFilter(),
          const SizedBox(height: 20),

          // Industry Filter
          _buildIndustryFilter(),
          const SizedBox(height: 20),

          // Sort Options
          _buildSortOptions(),
          const SizedBox(height: 20),

          // Date Range Filter
          _buildDateRangeFilter(),
          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filter Companies',
          style: TextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSearchFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search',
          style: TextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(
            text: _filters['search']?.toString() ?? '',
          ),
          decoration: InputDecoration(
            hintText: 'Search by name, email, or phone',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            _filters['search'] = value.isNotEmpty ? value : null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _statusOptions.map((status) {
            final isSelected = _filters['status'] == status ||
                (_filters['status'] == null && status == 'all');

            return FilterChip(
              label: Text(
                status == 'all' ? 'All' : status.capitalizeFirst,
                style: TextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (status == 'all') {
                    _filters.remove('status');
                  } else {
                    _filters['status'] = selected ? status : null;
                  }
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIndustryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Industry',
          style: TextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _industryOptions.map((industry) {
            final isSelected = _filters['industry'] == industry ||
                (_filters['industry'] == null && industry == 'all');

            return FilterChip(
              label: Text(
                industry == 'all' ? 'All' : industry.capitalizeFirst,
                style: TextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (industry == 'all') {
                    _filters.remove('industry');
                  } else {
                    _filters['industry'] = selected ? industry : null;
                  }
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: TextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _sortOptions.map((sortOption) {
            final isSelected = _filters['sort_by'] == sortOption ||
                (_filters['sort_by'] == null &&
                    sortOption == 'created_at_desc');

            String displayText;
            switch (sortOption) {
              case 'name_asc':
                displayText = 'Name (A-Z)';
                break;
              case 'name_desc':
                displayText = 'Name (Z-A)';
                break;
              case 'created_at_desc':
                displayText = 'Newest First';
                break;
              case 'created_at_asc':
                displayText = 'Oldest First';
                break;
              case 'updated_at_desc':
                displayText = 'Recently Updated';
                break;
              case 'updated_at_asc':
                displayText = 'Least Recently Updated';
                break;
              default:
                displayText = sortOption;
            }

            return FilterChip(
              label: Text(
                displayText,
                style: TextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters['sort_by'] = selected ? sortOption : null;
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: TextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _filters['start_date'] = date.format();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.outline,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _filters['start_date']?.toString() ?? 'Select date',
                            style: TextStyles.bodyMedium.copyWith(
                              color: _filters['start_date'] != null
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To',
                    style: TextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _filters['end_date'] = date.format();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.outline,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _filters['end_date']?.toString() ?? 'Select date',
                            style: TextStyles.bodyMedium.copyWith(
                              color: _filters['end_date'] != null
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_filters['start_date'] != null || _filters['end_date'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SecondaryButton(
              onPressed: () {
                setState(() {
                  _filters.remove('start_date');
                  _filters.remove('end_date');
                });
              },
              text: 'Clear Date Range',
              icon: Icons.clear,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            onPressed: () {
              widget.onClearFilters();
              Navigator.pop(context);
            },
            text: 'Clear All',
            icon: Icons.clear_all,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            onPressed: () {
              widget.onApplyFilters(_filters);
              Navigator.pop(context);
            },
            text: 'Apply Filters',
            icon: Icons.check,
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

extension DateTimeExtension on DateTime {
  String format() {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
