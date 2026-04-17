import 'package:flutter/material.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/delivery.dart';

/// Delivery Card Widget - Displays delivery information in a card format
class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final bool isCurrent;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.isCurrent = false,
    this.onTap,
    this.onStart,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and priority
              _buildHeader(),
              const SizedBox(height: 12),

              // Delivery information
              _buildDeliveryInfo(),
              const SizedBox(height: 12),

              // Customer information
              _buildCustomerInfo(),
              const SizedBox(height: 12),

              // Timeline
              _buildTimeline(),
              const SizedBox(height: 12),

              // Actions
              if (onStart != null || onComplete != null) _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor()),
          ),
          child: Text(
            _getStatusText(),
            style: TextStyles.labelSmall.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Priority indicator
        if (delivery.priority != DeliveryPriority.normal)
          Row(
            children: [
              Icon(
                Icons.priority_high,
                size: 16,
                color: _getPriorityColor(),
              ),
              const SizedBox(width: 4),
              Text(
                _getPriorityText(),
                style: TextStyles.labelSmall.copyWith(
                  color: _getPriorityColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pickup and delivery addresses
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pickup
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pickup',
                    style: TextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _truncateAddress(delivery.pickupAddress),
                    style: TextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Arrow icon
            Icon(
              Icons.arrow_forward,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            // Delivery
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery',
                    style: TextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _truncateAddress(delivery.deliveryAddress),
                    style: TextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Distance and estimated time
        Row(
          children: [
            if (delivery.distanceKm != null) ...[
              _buildInfoItem(
                icon: Icons.directions,
                text: '${delivery.distanceKm!.toStringAsFixed(1)} km',
              ),
              const SizedBox(width: 16),
            ],
            if (delivery.estimatedDurationMinutes != null) ...[
              _buildInfoItem(
                icon: Icons.access_time,
                text:
                    '${delivery.estimatedDurationMinutes!.toStringAsFixed(0)} min',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (delivery.customerName != null)
                  Text(
                    delivery.customerName!,
                    style: TextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (delivery.customerPhone != null)
                  Text(
                    delivery.customerPhone!,
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (delivery.hasOtpVerification)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'OTP',
                style: TextStyles.labelSmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final isOverdue = delivery.isOverdue;
    final progress = delivery.progressPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Timeline',
              style: TextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (isOverdue)
              Text(
                'Overdue',
                style: TextStyles.labelSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress / 100,
            child: Container(
              decoration: BoxDecoration(
                color: isOverdue ? AppColors.error : AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(delivery.scheduledPickupTime),
              style: TextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${progress.toStringAsFixed(0)}%',
              style: TextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              _formatTime(delivery.scheduledDeliveryTime),
              style: TextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        if (onStart != null && delivery.canStart)
          Expanded(
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start Delivery'),
            ),
          ),
        if (onComplete != null && delivery.canComplete) ...[
          if (onStart != null && delivery.canStart) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('Complete'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (delivery.status) {
      case DeliveryStatus.pending:
        return AppColors.warning;
      case DeliveryStatus.assigned:
        return AppColors.info;
      case DeliveryStatus.accepted:
        return AppColors.info;
      case DeliveryStatus.pickedUp:
        return AppColors.primary;
      case DeliveryStatus.inTransit:
        return AppColors.primary;
      case DeliveryStatus.arrived:
        return AppColors.primary;
      case DeliveryStatus.delivered:
        return AppColors.success;
      case DeliveryStatus.failed:
        return AppColors.error;
      case DeliveryStatus.cancelled:
        return AppColors.textTertiary;
      case DeliveryStatus.returned:
        return AppColors.warning;
    }
  }

  String _getStatusText() {
    switch (delivery.status) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.assigned:
        return 'Assigned';
      case DeliveryStatus.accepted:
        return 'Accepted';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.inTransit:
        return 'In Transit';
      case DeliveryStatus.arrived:
        return 'Arrived';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.failed:
        return 'Failed';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
      case DeliveryStatus.returned:
        return 'Returned';
    }
  }

  Color _getPriorityColor() {
    switch (delivery.priority) {
      case DeliveryPriority.low:
        return AppColors.success;
      case DeliveryPriority.normal:
        return AppColors.info;
      case DeliveryPriority.high:
        return AppColors.warning;
      case DeliveryPriority.urgent:
        return AppColors.error;
    }
  }

  String _getPriorityText() {
    switch (delivery.priority) {
      case DeliveryPriority.low:
        return 'Low';
      case DeliveryPriority.normal:
        return 'Normal';
      case DeliveryPriority.high:
        return 'High';
      case DeliveryPriority.urgent:
        return 'Urgent';
    }
  }

  String _truncateAddress(String address) {
    const maxLength = 40;
    if (address.length <= maxLength) return address;
    return '${address.substring(0, maxLength)}...';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
