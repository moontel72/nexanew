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

/// Stat card — compact metric display with label, value, and color accent.
class FleetStatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData? icon;
  const FleetStatCard(
    this.label,
    this.value,
    this.color, {
    super.key,
    this.icon,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6),
      ],
    ),
    child: Column(
      children: [
        if (icon != null) ...[Icon(icon, color: color, size: 20), const Gap(4)],
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
        ),
      ],
    ),
  );
}

/// Colored dot with label — used for legend indicators.
class FleetDot extends StatelessWidget {
  final Color color;
  final String label;
  const FleetDot(this.color, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const Gap(6),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.gray600),
      ),
    ],
  );
}

/// Seat grid — 4-per-row bus seat layout with driver/rear indicators.
class FleetSeatGrid extends StatelessWidget {
  final List<Map<String, dynamic>> seats;
  const FleetSeatGrid({super.key, required this.seats});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              '🚌 DRIVER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const Gap(12),
        ...List.generate((seats.length / 4).ceil(), (row) {
          final start = row * 4;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                ...List.generate(
                  2,
                  (i) => start + i < seats.length
                      ? _FleetSeat(seats[start + i])
                      : const SizedBox(width: 55),
                ),
                const SizedBox(width: 20),
                ...List.generate(
                  2,
                  (i) => start + 2 + i < seats.length
                      ? _FleetSeat(seats[start + 2 + i])
                      : const SizedBox(width: 55),
                ),
              ],
            ),
          );
        }),
        const Gap(12),
        Container(
          width: double.infinity,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              'REAR',
              style: TextStyle(fontSize: 9, color: AppColors.gray500),
            ),
          ),
        ),
      ],
    ),
  );
}

class _FleetSeat extends StatelessWidget {
  final Map<String, dynamic> seat;
  const _FleetSeat(this.seat);
  @override
  Widget build(BuildContext context) {
    final isBooked =
        seat['status']?.toString() == 'booked' || seat['booked'] == true;
    final num =
        seat['number']?.toString() ?? seat['seat_no']?.toString() ?? '?';
    final color = isBooked ? const Color(0xFF2563EB) : Colors.grey.shade300;
    return Expanded(
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isBooked ? color.withValues(alpha: .12) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            num,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
