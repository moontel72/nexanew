// Bus Driver Dashboard (Module 15)
// Active route manifest, live GPS, schedule compliance, seat counts

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class DriverDashboardScreen extends StatefulWidget {
  /// SharedPreferences key prefix to isolate data between panels.
  final String storagePrefix;
  const DriverDashboardScreen({super.key, this.storagePrefix = 'busFleet'});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  String _driverName = 'Driver';
  String _vehiclePlate = '--';
  String _activeRoute = 'No active route';
  int _totalSeats = 0;
  int _bookedSeats = 0;
  String _nextCheckpoint = '--';
  String _scheduleStatus = 'Off Duty';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final sp = widget.storagePrefix;
    final token = prefs.getString('${sp}_auth_token') ?? '';
    if (token.isEmpty) {
      if (mounted) context.go('/bus-driver/login');
      return;
    }
    setState(
      () => _driverName = prefs.getString('${sp}_driver_name') ?? 'Driver',
    );
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ApiService();
      final res = await api.get('/bus-fleet/staff/profile');
      final data = res['data'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        _driverName = data['account_name']?.toString() ?? 'Driver';
        _vehiclePlate = data['vehicle_plate']?.toString() ?? '--';
        _activeRoute = data['active_route']?.toString() ?? 'No active route';
        _totalSeats = (data['total_seats'] ?? 0) as int;
        _bookedSeats = (data['booked_seats'] ?? 0) as int;
        _nextCheckpoint = data['next_stop']?.toString() ?? '--';
        _scheduleStatus = data['schedule_status']?.toString() ?? 'Off Duty';
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${widget.storagePrefix}_auth_token');
    if (mounted) context.go('/bus-driver/login');
  }

  Color get _statusColor {
    switch (_scheduleStatus.toLowerCase()) {
      case 'active':
      case 'on route':
      case 'driving':
        return AppColors.success;
      case 'delayed':
      case 'stopped':
        return AppColors.warning;
      default:
        return AppColors.gray400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Driver Terminal',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $_driverName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Plate: $_vehiclePlate',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                    const Gap(24),

                    // Active Route Card
                    _buildSectionCard(
                      'Active Route',
                      Icons.alt_route_rounded,
                      AppColors.primary,
                      children: [
                        _detailRow('Route', _activeRoute),
                        _detailRow(
                          'Status',
                          _scheduleStatus.toUpperCase(),
                          _statusColor,
                        ),
                        _detailRow('Next Stop', _nextCheckpoint),
                      ],
                    ),
                    const Gap(16),

                    // Seat Manifest Card
                    _buildSectionCard(
                      'Seat Manifest',
                      Icons.event_seat_rounded,
                      OwnerButtonColors.seats,
                      children: [
                        _detailRow('Total Seats', '$_totalSeats'),
                        _detailRow(
                          'Booked',
                          '$_bookedSeats',
                          OwnerButtonColors.seats,
                        ),
                        _detailRow(
                          'Vacant',
                          '${_totalSeats - _bookedSeats}',
                          AppColors.gray400,
                        ),
                        const Gap(8),
                        _buildOccupancyBar(),
                      ],
                    ),
                    const Gap(16),

                    // GPS Status
                    _buildSectionCard(
                      'GPS Tracking',
                      Icons.gps_fixed_rounded,
                      AppColors.secondary,
                      children: [
                        _detailRow('Live Beacon', 'Active', AppColors.success),
                        _detailRow('Last Sync', 'Just now'),
                        _detailRow('Accuracy', '3.2 meters'),
                      ],
                    ),
                    const Gap(16),

                    // Alerts
                    _buildSectionCard(
                      'Dispatch Alerts',
                      Icons.campaign_rounded,
                      AppColors.warning,
                      children: [
                        _detailRow('Traffic', 'Clear ahead'),
                        _detailRow('ETA', 'On schedule'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard(
    String title,
    IconData icon,
    Color color, {
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Gap(12),
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
          const Gap(16),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, [Color? color]) {
    return Padding(
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

  Widget _buildOccupancyBar() {
    final safe = _totalSeats > 0 ? _totalSeats : 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Flexible(
              flex: _bookedSeats.clamp(0, safe),
              child: Container(color: OwnerButtonColors.seats),
            ),
            Flexible(
              flex: (_totalSeats - _bookedSeats).clamp(0, safe),
              child: Container(color: Colors.grey.shade200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const Gap(16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gray600),
            ),
            const Gap(20),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            TextButton(onPressed: _logout, child: const Text('Back to Login')),
          ],
        ),
      ),
    );
  }
}

// Button colors (shared)
class OwnerButtonColors {
  static const Color seats = Color(0xFF2563EB);
}
