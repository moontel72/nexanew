// Bus Fleet Dashboard — Company owner's home after login
// Module 13 + 14: Bus Admin Panel + Bus Owners App
// Uses bus-fleet scoped endpoints to avoid 403 Forbidden from admin routes

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/company/bus_company_model.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/auth/admin_auth_event.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/auth/admin_auth_state.dart';
import 'package:nexatrace_system/shared/models/company/company_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class BusFleetDashboardScreen extends StatefulWidget {
  final String? companyId;

  const BusFleetDashboardScreen({super.key, this.companyId});

  @override
  State<BusFleetDashboardScreen> createState() =>
      _BusFleetDashboardScreenState();
}

class _BusFleetDashboardScreenState extends State<BusFleetDashboardScreen> {
  Company? _company;
  String? _error;
  bool _isLoading = true;
  bool _forbidden = false;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _forbidden = false;
    });

    try {
      final api = ApiService();

      // Call bus-fleet scoped profile endpoint (NOT admin/companies)
      final response = await api.get('/bus-fleet/profile');

      if (!mounted) return;

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null || !(data['is_bus_fleet'] == true)) {
        setState(() {
          _error = 'No bus fleet company found for this account';
          _isLoading = false;
        });
        return;
      }

      final companyJson = data['company'] as Map<String, dynamic>?;
      if (companyJson == null) {
        setState(() {
          _error = 'Company data not available';
          _isLoading = false;
        });
        return;
      }

      try {
        final company = Company.fromJson(companyJson);
        setState(() {
          _company = company;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _error = 'Failed to parse company data: $e';
          _isLoading = false;
        });
      }
    } catch (e) {
      final msg = e.toString();
      if (mounted) {
        if (msg.contains('403') ||
            msg.contains('Forbidden') ||
            msg.contains('401') ||
            msg.contains('Unauthorized')) {
          setState(() {
            _forbidden = true;
            _error = 'Access denied. Please login again.';
            _isLoading = false;
          });
        } else if (msg.contains('404')) {
          setState(() {
            _error = 'No bus fleet company found. Contact your super admin.';
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = msg;
            _isLoading = false;
          });
        }
      }
    }
  }

  void _logout() {
    context.read<AdminAuthBloc>().add(AdminLogoutRequested());
    context.go('/bus-fleet/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_company?.name ?? 'Bus Fleet Dashboard'),
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadCompany,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ── Loading ─────────────────────────────────────────
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ── 403 Forbidden — graceful fallback ──────────────
    if (_forbidden) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield, size: 64, color: AppColors.warning),
              SizedBox(height: 16.h),
              Text(
                'Permission Required',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _error ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadCompany,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  SizedBox(width: 12.w),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // ── Generic error ──────────────────────────────────
    if (_error != null || _company == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                _error ?? 'Could not load company data',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _loadCompany,
                    child: const Text('Retry'),
                  ),
                  SizedBox(width: 12.w),
                  OutlinedButton(
                    onPressed: _logout,
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // ── Company loaded — show dashboard ────────────────
    final c = _company!;
    final fleet = c.fleetSize;
    final routes = c.activeRoutes;
    final owner = c.busOwnerName;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerCard(c),
          SizedBox(height: 20.h),
          Text(
            'Fleet Overview',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          _statsGrid(fleet, routes, owner, c.status),
          SizedBox(height: 20.h),
          Text(
            'Company Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          _infoRow('Registration', c.registrationNumber),
          _infoRow('Phone', c.phone),
          _infoRow('Address', c.address),
          _infoRow('Type', c.type.name),
          _infoRow('Industry', c.industry.name),
        ],
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────
  Widget _headerCard(Company c) {
    return Card(
      color: AppColors.info.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.directions_bus,
                size: 30.w,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    c.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${c.city}, ${c.country}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                  ),
                ],
              ),
            ),
            _statusBadge(c.status),
          ],
        ),
      ),
    );
  }

  Widget _statsGrid(int fleet, int routes, String owner, CompanyStatus status) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.6,
      children: [
        _statCard(
          'Total Buses',
          '$fleet',
          Icons.directions_bus,
          AppColors.info,
        ),
        _statCard(
          'Active Routes',
          '$routes',
          Icons.alt_route,
          AppColors.success,
        ),
        _statCard('Owner', owner, Icons.person, AppColors.warning),
        _statCard('Status', status.name, Icons.verified, AppColors.primary),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22.w, color: color),
          SizedBox(height: 8.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(CompanyStatus status) {
    final color = switch (status) {
      CompanyStatus.active => AppColors.success,
      CompanyStatus.pending => AppColors.warning,
      CompanyStatus.suspended => AppColors.error,
      _ => AppColors.gray500,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
