// Vehicle Health Card — visual maintenance lifecycle indicator
//
// Shows a vehicle's health status with color-coded progress bars
// for each maintenance threshold. Green = OK, Amber = approaching,
// Red = overdue. Driven by FleetOpsBloc state.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/bloc/fleet_ops_maintenance/fleet_ops_bloc.dart';
import 'package:trace_odd/shared/bloc/fleet_ops_maintenance/fleet_ops_state.dart';
import 'package:trace_odd/shared/models/fleet_maintenance_models.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class VehicleHealthCard extends StatelessWidget {
  final String vehicleId;
  final VoidCallback? onTap;

  const VehicleHealthCard({
    super.key,
    required this.vehicleId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetOpsBloc, FleetOpsState>(
      buildWhen: (prev, next) =>
          prev.vehicleHealth[vehicleId] != next.vehicleHealth[vehicleId] ||
          prev.activeAlerts != next.activeAlerts,
      builder: (ctx, state) {
        final health = state.vehicleHealth[vehicleId];
        if (health == null) return const SizedBox.shrink();

        final vehicleAlerts = state.activeAlerts
            .where((a) => a.vehicleId == vehicleId)
            .toList();
        final criticalCount = vehicleAlerts.where((a) => a.isCritical).length;

        return Card(
          color: const Color(0xFF1B2838),
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: criticalCount > 0
                  ? AppColors.error.withValues(alpha: 0.4)
                  : const Color(0x20FFFFFF),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: criticalCount > 0
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        criticalCount > 0 ? Icons.warning_amber : Icons.check_circle,
                        color: criticalCount > 0 ? AppColors.error : AppColors.success,
                        size: 20,
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(health.vehicleName.isNotEmpty ? health.vehicleName : vehicleId,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('${health.currentOdometerKm.toStringAsFixed(0)} km',
                            style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ]),
                    ),
                    if (criticalCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('$criticalCount due',
                            style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                  ]),
                  const Gap(12),

                  // Maintenance progress bars
                  if (vehicleAlerts.isNotEmpty)
                    ...vehicleAlerts.take(4).map((a) => _AlertBar(alert: a))
                  else
                    _AlertBar(alert: MaintenanceAlert(
                      id: '', vehicleId: vehicleId,
                      type: MaintenanceType.generalInspection,
                      label: 'All clear',
                      severity: GeofenceSeverity.info,
                      currentKm: 0, thresholdKm: 25000, remainingKm: 25000,
                      percentUsed: 0.3, triggeredAt: DateTime.now(),
                    )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AlertBar extends StatelessWidget {
  final MaintenanceAlert alert;
  const _AlertBar({required this.alert});

  Color get _barColor {
    if (alert.percentUsed >= 1.0) return AppColors.error;
    if (alert.percentUsed >= 0.85) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(alert.label,
                style: TextStyle(color: _barColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          Text(
            alert.isOverdue ? 'OVERDUE' : '${alert.remainingKm.toStringAsFixed(0)} km left',
            style: TextStyle(color: _barColor.withValues(alpha: 0.7), fontSize: 10),
          ),
        ]),
        const Gap(3),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: alert.percentUsed.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: const Color(0x20FFFFFF),
            valueColor: AlwaysStoppedAnimation(_barColor),
          ),
        ),
      ]),
    );
  }
}
