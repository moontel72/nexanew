//lib/driver_delivery/presentation/screens/driver_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver_statistics.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/delivery.dart';
import 'package:nexatrace_system/features/driver_delivery/presentation/bloc/driver_delivery_bloc.dart';
import 'package:nexatrace_system/features/driver_delivery/presentation/widgets/delivery_card.dart';
import 'package:nexatrace_system/features/driver_delivery/presentation/widgets/driver_stats_card.dart';
import 'package:nexatrace_system/features/driver_delivery/presentation/widgets/earnings_summary_card.dart';

/// Driver Dashboard Screen - Main screen for drivers to view deliveries and stats
class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data when screen is initialized
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<DriverDeliveryBloc>().add(const LoadDriverProfile());
    context.read<DriverDeliveryBloc>().add(const LoadTodayDeliveries());
    context.read<DriverDeliveryBloc>().add(const LoadDeliveryStatistics());
    context.read<DriverDeliveryBloc>().add(const LoadDriverEarnings());
  }

  void _refreshData() {
    context.read<DriverDeliveryBloc>().add(const RefreshDeliveries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Driver Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile screen
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: BlocConsumer<DriverDeliveryBloc, DriverDeliveryState>(
        listener: (context, state) {
          // Handle specific state changes if needed
          if (state is DriverDeliveryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildContent(state);
        },
      ),
    );
  }

  Widget _buildContent(DriverDeliveryState state) {
    if (state is DriverDeliveryLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (state is DriverDeliveryError) {
      return ErrorState.generic(
        title: 'Error',
        message: state.message,
        onRetry: _loadInitialData,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Stats Section
            if (state is DriverProfileLoaded || state is StatisticsLoaded)
              _buildStatsSection(state),

            const SizedBox(height: 24),

            // Today's Deliveries Section
            _buildDeliveriesSection(state),

            const SizedBox(height: 24),

            // Earnings Section
            if (state is EarningsLoaded) _buildEarningsSection(state),

            const SizedBox(height: 24),

            // Quick Actions Section
            _buildQuickActionsSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(DriverDeliveryState state) {
    DriverStatistics? statistics;
    Driver? driver;

    if (state is StatisticsLoaded) {
      statistics = state.statistics;
    }
    if (state is DriverProfileLoaded) {
      driver = state.driver;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
          style: TextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        DriverStatsCard(
          statistics: statistics,
          driver: driver,
        ),
      ],
    );
  }

  Widget _buildDeliveriesSection(DriverDeliveryState state) {
    List<Delivery> deliveries = [];
    Delivery? currentDelivery;

    if (state is DeliveriesLoaded) {
      deliveries = state.deliveries;
      currentDelivery = state.currentDelivery;
    } else if (state is SearchResults) {
      deliveries = state.results;
    } else if (state is FilterResults) {
      deliveries = state.results;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Deliveries',
              style: TextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (deliveries.isNotEmpty)
              Text(
                '${deliveries.length} deliveries',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (deliveries.isEmpty)
          _buildEmptyDeliveriesState()
        else
          ...deliveries.map((delivery) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DeliveryCard(
                delivery: delivery,
                isCurrent: currentDelivery?.id == delivery.id,
                onTap: () {
                  // Navigate to delivery details
                  _navigateToDeliveryDetails(delivery.id);
                },
                onStart: delivery.canStart
                    ? () {
                        context
                            .read<DriverDeliveryBloc>()
                            .add(StartDelivery(delivery.id));
                      }
                    : null,
                onComplete: delivery.canComplete
                    ? () {
                        _showDeliveryCompletionDialog(delivery.id);
                      }
                    : null,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEmptyDeliveriesState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No deliveries scheduled for today',
            style: TextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later or contact your manager',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection(DriverDeliveryState state) {
    if (state is! EarningsLoaded) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings Summary',
          style: TextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        EarningsSummaryCard(earnings: state.earnings),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              icon: Icons.location_on,
              label: 'Mark Attendance',
              color: AppColors.primary,
              onTap: () {
                _showMarkAttendanceDialog();
              },
            ),
            _buildQuickActionCard(
              icon: Icons.report_problem,
              label: 'Report Issue',
              color: AppColors.warning,
              onTap: () {
                // Navigate to issue reporting
              },
            ),
            _buildQuickActionCard(
              icon: Icons.directions_car,
              label: 'Vehicle Info',
              color: AppColors.info,
              onTap: () {
                context.read<DriverDeliveryBloc>().add(const LoadVehicleInfo());
                // Navigate to vehicle info
              },
            ),
            _buildQuickActionCard(
              icon: Icons.help_outline,
              label: 'Support',
              color: AppColors.secondary,
              onTap: () {
                // Navigate to support
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDeliveryDetails(String deliveryId) {
    // Navigation logic here
    // Example: Navigator.push(context, DeliveryDetailScreen.route(deliveryId));
  }

  void _showDeliveryCompletionDialog(String deliveryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Delivery'),
        content: const Text(
            'Are you sure you want to mark this delivery as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to completion screen with proof options
              // Example: Navigator.push(context, DeliveryCompletionScreen.route(deliveryId));
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showMarkAttendanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Attendance'),
        content: const Text(
            'This will mark your current location as attendance. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Get current location and mark attendance
              // Example: _markAttendanceWithCurrentLocation();
            },
            child: const Text('Mark Attendance'),
          ),
        ],
      ),
    );
  }
}
