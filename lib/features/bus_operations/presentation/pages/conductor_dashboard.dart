// Bus Conductor Dashboard (Module 15 — Seat Management)
// Live seat allocation grid: Booked vs Vacant, per-route seat manifest

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class ConductorDashboardScreen extends StatefulWidget {
  const ConductorDashboardScreen({super.key});

  @override
  State<ConductorDashboardScreen> createState() =>
      _ConductorDashboardScreenState();
}

class _ConductorDashboardScreenState extends State<ConductorDashboardScreen> {
  String _conductorName = 'Conductor';
  String _routeName = '--';
  int _totalSeats = 52;
  int _bookedSeats = 0;
  List<Map<String, dynamic>> _seats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isEmpty) {
      if (mounted) context.go('/bus-conductor/login');
      return;
    }
    setState(
      () => _conductorName = prefs.getString('conductor_name') ?? 'Conductor',
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
        _conductorName = data['account_name']?.toString() ?? 'Conductor';
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
    await prefs.remove('auth_token');
    if (mounted) context.go('/bus-conductor/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Conductor Terminal',
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $_conductorName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Route: $_routeName',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                    const Gap(24),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Booked',
                            '$_bookedSeats',
                            const Color(0xFF2563EB),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _statCard(
                            'Vacant',
                            '${_totalSeats - _bookedSeats}',
                            AppColors.gray400,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _statCard(
                            'Total',
                            '$_totalSeats',
                            AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),

                    // Legend
                    Row(
                      children: [
                        _legendDot(const Color(0xFF2563EB), 'Booked'),
                        const Gap(16),
                        _legendDot(Colors.grey.shade300, 'Vacant'),
                      ],
                    ),
                    const Gap(16),

                    // Seat Grid
                    if (_seats.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'No seat data',
                            style: TextStyle(color: AppColors.gray400),
                          ),
                        ),
                      )
                    else
                      _buildSeatGrid(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
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

  Widget _legendDot(Color color, String label) {
    return Row(
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

  Widget _buildSeatGrid() {
    // Arrange seats in rows of 4 (2 left + 2 right with aisle)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          // Bus front
          Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
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
          // Seat rows
          ...List.generate((_seats.length / 4).ceil(), (row) {
            final start = row * 4;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  // Left side (2 seats)
                  ...List.generate(2, (i) {
                    final idx = start + i;
                    if (idx >= _seats.length) return const SizedBox(width: 55);
                    return _seatCell(_seats[idx]);
                  }),
                  // Aisle
                  const SizedBox(width: 20),
                  // Right side (2 seats)
                  ...List.generate(2, (i) {
                    final idx = start + 2 + i;
                    if (idx >= _seats.length) return const SizedBox(width: 55);
                    return _seatCell(_seats[idx]);
                  }),
                ],
              ),
            );
          }),
          const Gap(12),
          // Bus rear
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

  Widget _seatCell(Map<String, dynamic> seat) {
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
          color: isBooked ? color.withValues(alpha: 0.12) : Colors.white,
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
