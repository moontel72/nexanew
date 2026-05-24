// Bus Fleet Dashboard — Company owner's home after login
// Shows company-specific fleet stats, routes, buses

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/company/bus_company_model.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/company_management_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/auth/admin_auth_event.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/auth/admin_auth_state.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/companies/company_management_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    try {
      final repo = CompanyManagementRepository(apiService: ApiService());
      // If we have a company ID, load directly; otherwise find by auth user email
      if (widget.companyId != null) {
        final c = await repo.getCompany(widget.companyId!);
        setState(() => _company = c);
      } else {
        // Fetch companies and find the one matching the logged-in user
        final response = await repo.getCompanies(perPage: 100);
        final authState = context.read<AdminAuthBloc>().state;
        String? userEmail;
        if (authState is AdminAuthAuthenticated) {
          userEmail = authState.user.email;
        }
        if (userEmail != null) {
          final match = response.companies.where((c) {
            // Match by email or contact person email
            final notesRaw = c.notes ?? '';
            try {
              final meta = jsonDecode(notesRaw);
              if (meta is Map && meta['owner_name'] != null) return false;
            } catch (_) {}
            return c.email == userEmail || c.contactPerson.email == userEmail;
          }).toList();
          if (match.isNotEmpty) {
            setState(() => _company = match.first);
            return;
          }
        }
        // Fallback: show first bus fleet company
        final bus = response.companies.where((c) => c.isBusCompany).toList();
        if (bus.isNotEmpty) setState(() => _company = bus.first);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = _company;

    return Scaffold(
      appBar: AppBar(
        title: Text(company?.name ?? 'Bus Fleet Dashboard'),
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
            onPressed: () {
              context.read<AdminAuthBloc>().add(AdminLogoutRequested());
              context.go('/bus-fleet/login');
            },
          ),
        ],
      ),
      body: _buildBody(company),
    );
  }

  Widget _buildBody(Company? company) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(_error!, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton(onPressed: _loadCompany, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (company == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final fleet = company.fleetSize;
    final routes = company.activeRoutes;
    final owner = company.busOwnerName;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Company Header ───────────────────────────────
          Card(
            color: AppColors.info.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
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
                          company.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          company.email,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.gray600),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${company.city}, ${company.country}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.gray500),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(company.status),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // ── Stats Grid ──────────────────────────────────
          Text(
            'Fleet Overview',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          GridView.count(
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
              _statCard(
                'Status',
                company.status.name,
                Icons.verified,
                AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // ── Quick Info ──────────────────────────────────
          Text(
            'Company Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          _infoRow('Registration', company.registrationNumber),
          _infoRow('Phone', company.phone),
          _infoRow('Address', company.address),
          _infoRow('Type', company.type.name),
          _infoRow('Industry', company.industry.name),
        ],
      ),
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
