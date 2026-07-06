// Customer Super App Hub — BLoC-driven
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/bus_operations/data/repositories/seat_booking_repository.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/customer/customer_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/customer/customer_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/customer/customer_state.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class CustomerSuperAppScreen extends StatelessWidget {
  const CustomerSuperAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerBloc()..add(const LoadPublishedLayouts()),
      child: const _CustomerView(),
    );
  }
}

class _CustomerView extends StatelessWidget {
  const _CustomerView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (ctx, state) {
        final bloc = ctx.read<CustomerBloc>();
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
            index: state.selectedTab,
            children: [
              _TransitHub(
                layouts: state.publishedLayouts,
                status: state.status,
                error: state.error,
              ),
              const _ScanTab(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: state.selectedTab,
            onDestinationSelected: (i) => bloc.add(SwitchTab(i)),
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
      },
    );
  }
}

// ── Transit Hub ────────────────────────────────────────────

class _TransitHub extends StatelessWidget {
  final List<Map<String, dynamic>> layouts;
  final CustomerStatus status;
  final String? error;
  const _TransitHub({required this.layouts, required this.status, this.error});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: .8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.directions_bus_rounded,
                  size: 40,
                  color: Colors.white,
                ),
                Gap(12),
                Text(
                  'Book Your Seat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Gap(4),
                Text(
                  'Browse available buses and pick your seat.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFD9E2EF)),
                ),
              ],
            ),
          ),
          Gap(24),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Gap(12),
          _ActionCard(
            icon: Icons.event_seat_rounded,
            title: 'Find & Book a Seat',
            subtitle: 'Search routes, view seat maps, confirm booking',
            color: const Color(0xFF2563EB),
            onTap: () {},
          ),
          Gap(12),
          _ActionCard(
            icon: Icons.location_on_rounded,
            title: 'Live Bus Tracking',
            subtitle: 'Real-time GPS position, ETA, waypoint progress',
            color: AppColors.secondary,
            onTap: () => context.go('/customer/live-tracking'),
          ),
          Gap(12),
          _ActionCard(
            icon: Icons.receipt_long_rounded,
            title: 'My Tickets',
            subtitle: 'Offline QR vault — board without network',
            color: AppColors.warning,
            onTap: () => context.go('/customer/my-tickets'),
          ),
          Gap(24),
          const Text(
            'Available Buses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Gap(12),
          if (status == CustomerStatus.loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
          if (status == CustomerStatus.error)
            Center(
              child: Text(
                error ?? 'Failed to load',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          if (status == CustomerStatus.loaded && layouts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No buses available right now.',
                  style: TextStyle(color: AppColors.gray500),
                ),
              ),
            ),
          ...layouts.map((l) => _BusCard(layout: l)),
        ],
      ),
    );
  }
}

class _BusCard extends StatelessWidget {
  final Map<String, dynamic> layout;
  const _BusCard({required this.layout});

  @override
  Widget build(BuildContext context) {
    final name = layout['display_name']?.toString() ?? 'Bus';
    final seats = layout['total_seats']?.toString() ?? '—';
    final id = layout['id']?.toString() ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2563EB),
          child: Icon(Icons.directions_bus, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '$seats seats',
          style: const TextStyle(color: AppColors.gray500),
        ),
        trailing: ElevatedButton(
          onPressed: () => context.go('/customer/seat-selection/$id'),
          child: const Text('Book'),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gray400),
        ],
      ),
    ),
  );
}

class _ScanTab extends StatelessWidget {
  const _ScanTab();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.qr_code_scanner, size: 64, color: AppColors.gray400),
        Gap(16),
        Text(
          'Product Authenticity Scan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(8),
        Text(
          'Scan any NexaTrace code to verify.',
          style: TextStyle(color: AppColors.gray500),
        ),
      ],
    ),
  );
}
