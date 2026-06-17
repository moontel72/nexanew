// NEXATRACE — LIVE TRANSIT TRACKING (Module 8V)
// =================================================
// Placeholder screen for real-time bus GPS tracking.
// Will integrate: WebSocket bus.{trip_id} → CustomPainter map.
//
// ROUTE: /customer/live-tracking

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class LiveTransitTrackingScreen extends StatelessWidget {
  const LiveTransitTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/customer/home'),
        ),
        title: const Text(
          'Live Bus Tracking',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Map placeholder
          Container(
            height: 280,
            width: double.infinity,
            color: AppColors.primary.withValues(alpha: 0.06),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const Gap(12),
                const Text(
                  'Live GPS Map',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Gap(4),
                Text(
                  'CustomPainter canvas with Haversine ETA\n— zero Google Maps dependency.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Status card
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _infoRow(
                  'WebSocket',
                  'Laravel Reverb :8080',
                  AppColors.success,
                ),
                const Gap(12),
                _infoRow('Channel', 'bus.{trip_id}', AppColors.primary),
                const Gap(12),
                _infoRow(
                  'Protocol',
                  'Pusher (wire-compatible)',
                  AppColors.gray600,
                ),
                const Gap(12),
                _infoRow('ETA Engine', 'Haversine formula', AppColors.gray600),
                const Gap(12),
                _infoRow(
                  'Reconnect',
                  'Exponential backoff (2s–60s)',
                  AppColors.gray600,
                ),
                const Gap(24),
                // API status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                      Gap(10),
                      Expanded(
                        child: Text(
                          'POST /bus-fleet/driver/update-location\nfiring BusLocationUpdated → Reverb',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
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
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
