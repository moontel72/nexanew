import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class PlanFilterSheet extends StatefulWidget {
  final String? currentType;
  final String? currentStatus;
  final String currentSortBy;
  final String currentSortOrder;
  final Function({
    String? type,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) onApply;

  const PlanFilterSheet({
    super.key,
    this.currentType,
    this.currentStatus,
    required this.currentSortBy,
    required this.currentSortOrder,
    required this.onApply,
  });

  @override
  State<PlanFilterSheet> createState() => _PlanFilterSheetState();
}

class _PlanFilterSheetState extends State<PlanFilterSheet> {
  late String? _selectedType;
  late String? _selectedStatus;
  late String _selectedSortBy;
  late String _selectedSortOrder;

  final List<String> _types = [
    'free',
    'basic',
    'standard',
    'premium',
    'custom'
  ];
  final List<String> _statuses = ['active', 'inactive', 'draft'];
  final Map<String, String> _sortOptions = {
    'created_at': 'Date Created',
    'name': 'Name',
    'price': 'Price',
  };

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentType;
    _selectedStatus = widget.currentStatus;
    _selectedSortBy = widget.currentSortBy;
    _selectedSortOrder = widget.currentSortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Plans',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedType = null;
                    _selectedStatus = null;
                    _selectedSortBy = 'created_at';
                    _selectedSortOrder = 'desc';
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          Gap(20.h),
          Text('Plan Type', style: _labelStyle),
          Gap(8.h),
          _buildTypeSelector(),
          Gap(20.h),
          Text('Status', style: _labelStyle),
          Gap(8.h),
          _buildStatusSelector(),
          Gap(20.h),
          Text('Sort By', style: _labelStyle),
          Gap(8.h),
          _buildSortSelector(),
          Gap(30.h),
          PrimaryButton(
            text: 'Apply Filters',
            onPressed: () {
              widget.onApply(
                type: _selectedType,
                status: _selectedStatus,
                sortBy: _selectedSortBy,
                sortOrder: _selectedSortOrder,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  TextStyle get _labelStyle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      );

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 10.w,
      children: _types.map((type) {
        final isSelected = _selectedType == type;
        return ChoiceChip(
          label: Text(type.toUpperCase()),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedType = selected ? type : null);
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusSelector() {
    return Wrap(
      spacing: 10.w,
      children: _statuses.map((status) {
        final isSelected = _selectedStatus == status;
        return ChoiceChip(
          label: Text(status.toUpperCase()),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedStatus = selected ? status : null);
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSortSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedSortBy,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
      ),
      items: _sortOptions.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedSortBy = value);
      },
    );
  }
}
