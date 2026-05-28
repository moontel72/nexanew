// File: lib/features/nexa_admin/presentation/widgets/dashboard/recent_activities_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:trace_odd/shared/models/dashboard/dashboard_models.dart';

/// Recent Activities Widget
/// Displays a list of recent activities with timestamps and action types
class RecentActivitiesWidget extends StatelessWidget {
  final List<RecentActivity> activities;
  final Function(RecentActivity)? onActivityTap;
  final VoidCallback? onMarkAllAsRead;
  final bool isLoading;

  const RecentActivitiesWidget({
    super.key,
    required this.activities,
    this.onActivityTap,
    this.onMarkAllAsRead,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (onMarkAllAsRead != null &&
                    activities.isNotEmpty &&
                    !isLoading)
                  TextButton(
                    onPressed: onMarkAllAsRead,
                    child: Text(
                      'Mark All Read',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
            Gap(12.h),

            if (isLoading)
              _buildLoadingState()
            else if (activities.isEmpty)
              _buildEmptyState()
            else
              Column(
                children: [
                  ...activities.map((activity) => _buildActivityItem(activity)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Build individual activity item
  Widget _buildActivityItem(RecentActivity activity) {
    return InkWell(
      onTap: () => onActivityTap?.call(activity),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity icon
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: _getActivityColor(activity.type).withValues(alpha: 0.1),
                
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _getActivityIcon(activity.type),
                color: _getActivityColor(activity.type),
                size: 18.w,
              ),
            ),
            Gap(12.w),

            // Activity details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(4.h),
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12.w,
                        color: Colors.grey[500],
                      ),
                      Gap(4.w),
                      Text(
                        _formatTimeAgo(activity.timestamp),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      Gap(8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _getActivityColor(activity.type).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          _getActivityTypeLabel(activity.type),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: _getActivityColor(activity.type),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action indicator
            if (onActivityTap != null)
              Icon(
                Icons.chevron_right,
                size: 20.w,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon skeleton
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              Gap(12.w),

              // Content skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Gap(8.h),
                    Container(
                      width: double.infinity,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Gap(8.h),
                    Row(
                      children: [
                        Container(
                          width: 60.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        Gap(8.w),
                        Container(
                          width: 50.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron skeleton
              Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none,
            size: 48.w,
            color: Colors.grey[400],
          ),
          Gap(16.h),
          Text(
            'No Recent Activities',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Gap(8.h),
          Text(
            'Activities will appear here as they occur',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get activity icon based on type
  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return Icons.person_add;
      case 'company':
        return Icons.business;
      case 'payment':
        return Icons.payment;
      case 'subscription':
        return Icons.subscriptions;
      case 'code':
        return Icons.qr_code;
      case 'system':
        return Icons.settings;
      case 'alert':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  /// Get activity color based on type
  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return Colors.blue;
      case 'company':
        return Colors.purple;
      case 'payment':
        return Colors.green;
      case 'subscription':
        return Colors.orange;
      case 'code':
        return Colors.teal;
      case 'system':
        return Colors.grey;
      case 'alert':
        return Colors.red;
      case 'success':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  /// Get activity type label
  String _getActivityTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return 'User';
      case 'company':
        return 'Company';
      case 'payment':
        return 'Payment';
      case 'subscription':
        return 'Subscription';
      case 'code':
        return 'Code';
      case 'system':
        return 'System';
      case 'alert':
        return 'Alert';
      case 'success':
        return 'Success';
      default:
        return type;
    }
  }

  /// Format time ago
  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}
