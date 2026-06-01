// Placeholder Truck Owner Dashboard
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class TruckOwnerDashboardScreen extends StatelessWidget {
  const TruckOwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truck Owner Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_shipping,
              size: 64,
              color: AppColors.primary,
            ),
            Gap(16),
            const Text(
              'Fleet & Freight Overview',
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
