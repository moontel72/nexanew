// Shared Fleet Widgets — reusable cards, error views, occupancy bars
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Section card with icon header — used by driver/conductor dashboards.
class FleetSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  const FleetSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Gap(12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Gap(16),
        ...children,
      ],
    ),
  );
}

/// Error view with retry button — used by all fleet dashboards.
class FleetErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const FleetErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          Gap(16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gray600),
          ),
          Gap(20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

/// Seat occupancy progress bar — visual booked/vacant ratio.
class FleetOccupancyBar extends StatelessWidget {
  final int total, booked;
  const FleetOccupancyBar({
    super.key,
    required this.total,
    required this.booked,
  });

  @override
  Widget build(BuildContext context) {
    final safe = total > 0 ? total : 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Flexible(
              flex: booked.clamp(0, safe),
              child: Container(color: const Color(0xFF2563EB)),
            ),
            Flexible(
              flex: (total - booked).clamp(0, safe),
              child: Container(color: Colors.grey.shade200),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple detail row: label on left, value on right.
class FleetDetailRow extends StatelessWidget {
  final String label, value;
  final Color? color;
  const FleetDetailRow(this.label, this.value, [this.color]);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.gray500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}
