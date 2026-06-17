// NEXATRACE — CUSTOMER SUPER APP HUB (Module 8V)
// ==================================================
// Unified 2-in-1 customer terminal: Product Authenticity
// Scan + Live Bus Transit (seat booking, tracking, QR tickets).
//
// ROUTE: /customer/home

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class CustomerSuperAppScreen extends StatefulWidget {
  const CustomerSuperAppScreen({super.key});

  @override
  State<CustomerSuperAppScreen> createState() => _CustomerSuperAppScreenState();
}

class _CustomerSuperAppScreenState extends State<CustomerSuperAppScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'NexaTrace Transit',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: const [_TransitHubTab(), _AuthenticityScanTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (i) => setState(() => _selectedTab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_bus_rounded),
            selectedIcon: Icon(Icons.directions_bus),
            label: 'Transit',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Transit Hub Tab
// ─────────────────────────────────────────────────────────────

class _TransitHubTab extends StatelessWidget {
  const _TransitHubTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.directions_bus_rounded,
                  size: 40,
                  color: Colors.white,
                ),
                const Gap(12),
                const Text(
                  'Book Your Seat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Gap(4),
                Text(
                  'Search routes, pick a seat, and board with a digital QR ticket.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(12),

          _actionCard(
            context,
            icon: Icons.event_seat_rounded,
            title: 'Find & Book a Seat',
            subtitle: 'Search routes, view seat maps, confirm booking',
            color: const Color(0xFF2563EB),
            onTap: () => context.go('/customer/seat-selection/default'),
          ),
          const Gap(12),

          _actionCard(
            context,
            icon: Icons.location_on_rounded,
            title: 'Live Bus Tracking',
            subtitle: 'Real-time GPS position, ETA, waypoint progress',
            color: AppColors.secondary,
            onTap: () => context.go('/customer/live-tracking'),
          ),
          const Gap(12),

          _actionCard(
            context,
            icon: Icons.receipt_long_rounded,
            title: 'My Tickets',
            subtitle: 'Offline QR vault — board without network',
            color: AppColors.warning,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket vault — coming soon')),
              );
            },
          ),

          const Gap(24),

          // Recent Searches placeholder
          const Text(
            'Recent Routes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gray200),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: AppColors.gray400,
                ),
                Gap(8),
                Text(
                  'Search for a route to get started',
                  style: TextStyle(color: AppColors.gray500, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Authenticity Scan Tab (placeholder)
// ─────────────────────────────────────────────────────────────

class _AuthenticityScanTab extends StatelessWidget {
  const _AuthenticityScanTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const Gap(20),
            const Text(
              'Product Authenticity Scanner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(8),
            const Text(
              'Scan any NexaTrace QR code to verify\nproduct authenticity and trace its journey.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.gray500),
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera scanner — coming soon')),
                );
              },
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Open Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
