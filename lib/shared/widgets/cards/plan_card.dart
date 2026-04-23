import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexatrace_system/shared/models/subscription/plan_model.dart';
import 'package:nexatrace_system/shared/models/subscription/plan_type.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/utils/extensions.dart';
import 'package:nexatrace_system/core/utils/date_utils.dart' as date_utils;

class PlanCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final EdgeInsetsGeometry? margin;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final limits = plan.limits;

    String compactInt(dynamic value) {
      final n = value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
      if (n == null) return '-';
      if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
      if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
      return n.toString();
    }

    final units = compactInt(limits['monthly_unit_codes']);
    final drivers = compactInt(plan.userLimits.drivers);
    final stores = compactInt(plan.userLimits.storeKeepers);

    return Card(
      margin: margin ?? EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          plan.type.name.capitalizeFirst,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _getPlanTypeColor(plan.type.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildPlanStatus(context, plan.status),
                      if (onEdit != null ||
                          onDelete != null ||
                          onToggleStatus != null) ...[
                        SizedBox(width: 8.w),
                        _buildActionMenu(context),
                      ],
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Plan Details
              Row(
                children: [
                  _buildDetailItem(
                    icon: Icons.attach_money,
                    label: 'Price',
                    value: _formatPrice(plan),
                  ),
                  SizedBox(width: 12.w),
                  _buildDetailItem(
                    icon: Icons.calendar_today,
                    label: 'Billing',
                    value: plan.billingCycle.capitalizeFirst,
                  ),
                  SizedBox(width: 12.w),
                  _buildDetailItem(
                    icon: Icons.people,
                    label: 'Companies',
                    value: '0', // This would come from API
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Plan Features Preview
              if (plan.features.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  'Key Features:',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: plan.features
                      .take(3)
                      .map(
                        (feature) => Chip(
                          label: Text(
                            feature.name,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: AppColors.primary.withAlpha(25),
                          labelPadding: EdgeInsets.symmetric(horizontal: 6.w),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                ),
              ],

              SizedBox(height: 12.h),

              // Quick Info (Limits)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Units: $units | Drivers: $drivers | Store Keepers: $stores',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Plan Footer with Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created ${date_utils.DateUtils.formatDateForDisplay(plan.createdAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Row(
                    children: [
                      if (plan.isFeatured)
                        Icon(Icons.star, size: 14.w, color: AppColors.warning),
                      if (plan.isFeatured) SizedBox(width: 4.w),
                      if (plan.isPopular)
                        Icon(
                          Icons.trending_up,
                          size: 14.w,
                          color: AppColors.success,
                        ),
                    ],
                  ),
                ],
              ),

              // Action Buttons Row
              if (onEdit != null ||
                  onDelete != null ||
                  onToggleStatus != null) ...[
                SizedBox(height: 12.h),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanStatus(BuildContext context, PlanStatus status) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case PlanStatus.active:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case PlanStatus.inactive:
        statusColor = AppColors.error;
        statusIcon = Icons.pause_circle;
        break;
      case PlanStatus.archived:
        statusColor = AppColors.warning;
        statusIcon = Icons.archive;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withAlpha(75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12.w, color: statusColor),
          SizedBox(width: 4.w),
          Text(
            status.name.capitalizeFirst,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.w, color: AppColors.textTertiary),
              SizedBox(width: 4.w),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getPlanTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'free':
        return AppColors.info;
      case 'basic':
        return AppColors.success;
      case 'standard':
        return AppColors.primary;
      case 'premium':
        return AppColors.warning;
      case 'custom':
        return AppColors.codePublished;
      default:
        return AppColors.textTertiary;
    }
  }

  String _formatPrice(Plan plan) {
    final cycle = plan.billingCycle.toLowerCase();
    double price;
    if (cycle == 'yearly') {
      price = plan.yearlyPrice;
    } else {
      price = plan.monthlyPrice;
    }

    String suffix;
    switch (cycle) {
      case 'monthly':
        suffix = '/mo';
        break;
      case 'quarterly':
        suffix = '/qtr';
        break;
      case 'yearly':
        suffix = '/yr';
        break;
      case 'one_time':
        suffix = '';
        break;
      default:
        suffix = '/${plan.billingCycle}';
    }

    return '\$${price.toStringAsFixed(2)}$suffix';
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, size: 18.w, color: AppColors.textTertiary),
      itemBuilder: (context) => [
        if (onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18.w, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text('Edit Plan'),
              ],
            ),
          ),
        if (onToggleStatus != null)
          PopupMenuItem(
            value: 'toggle_status',
            child: Row(
              children: [
                Icon(
                  plan.status == PlanStatus.active
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  size: 18.w,
                  color: plan.status == PlanStatus.active
                      ? AppColors.warning
                      : AppColors.success,
                ),
                SizedBox(width: 8.w),
                Text(plan.status == PlanStatus.active
                    ? 'Deactivate'
                    : 'Activate'),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18.w, color: AppColors.error),
                SizedBox(width: 8.w),
                Text('Delete Plan'),
              ],
            ),
          ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'toggle_status':
            onToggleStatus?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (onEdit != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 14.w),
                  SizedBox(width: 6.w),
                  Text(
                    'Edit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (onEdit != null && (onDelete != null || onToggleStatus != null))
          SizedBox(width: 8.w),
        if (onToggleStatus != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onToggleStatus,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    plan.status == PlanStatus.active
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    size: 14.w,
                    color: plan.status == PlanStatus.active
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    plan.status == PlanStatus.active
                        ? 'Deactivate'
                        : 'Activate',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: plan.status == PlanStatus.active
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (onToggleStatus != null && onDelete != null) SizedBox(width: 8.w),
        if (onDelete != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                side: BorderSide(color: AppColors.error.withAlpha(128)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete, size: 14.w, color: AppColors.error),
                  SizedBox(width: 6.w),
                  Text(
                    'Delete',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
