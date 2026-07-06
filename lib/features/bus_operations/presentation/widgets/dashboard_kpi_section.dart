// Dashboard KPI Section — shared telemetry cards for fleet/owner dashboards
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// A single KPI metric card.
class DashboardKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2A3A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A3A4A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              Gap(10.h),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Gap(4.h),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF667788), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row of 3 KPI cards: Drivers, Conductors, Vehicles.
class DashboardKpiSection extends StatelessWidget {
  final int driverCount;
  final int conductorCount;
  final int layoutCount;
  final VoidCallback? onDriversTap;
  final VoidCallback? onConductorsTap;
  final VoidCallback? onLayoutsTap;

  const DashboardKpiSection({
    super.key,
    required this.driverCount,
    required this.conductorCount,
    required this.layoutCount,
    this.onDriversTap,
    this.onConductorsTap,
    this.onLayoutsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DashboardKpiCard(
          label: 'Drivers',
          value: '$driverCount',
          icon: Icons.badge,
          color: const Color(0xFF00B4D8),
          onTap: onDriversTap,
        ),
        SizedBox(width: 12.w),
        DashboardKpiCard(
          label: 'Conductors',
          value: '$conductorCount',
          icon: Icons.group,
          color: const Color(0xFF7C3AED),
          onTap: onConductorsTap,
        ),
        SizedBox(width: 12.w),
        DashboardKpiCard(
          label: 'Vehicles',
          value: '$layoutCount',
          icon: Icons.directions_bus,
          color: const Color(0xFF2563EB),
          onTap: onLayoutsTap,
        ),
      ],
    );
  }
}
