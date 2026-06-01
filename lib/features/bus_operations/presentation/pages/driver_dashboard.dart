// Placeholder Driver Dashboard (Bus + Truck)
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.route, size: 64, color: AppColors.primary),
            Gap(16),
            const Text(
              'Active Routes & Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Gap(24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
