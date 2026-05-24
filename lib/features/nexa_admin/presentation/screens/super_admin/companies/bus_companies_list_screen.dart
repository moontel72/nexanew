// View All Bus Companies Screen — Super Admin lists bus fleet companies
// Shows companies filtered by tags containing 'bus_fleet'

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/company/bus_company_model.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/companies/company_management_bloc.dart';
import 'package:nexatrace_system/shared/models/company/company_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

/// Bus Companies List Screen — Displays all bus fleet companies
class BusCompaniesListScreen extends StatefulWidget {
  final bool inShell;

  const BusCompaniesListScreen({super.key, this.inShell = false});

  @override
  State<BusCompaniesListScreen> createState() => _BusCompaniesListScreenState();
}

class _BusCompaniesListScreenState extends State<BusCompaniesListScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  String _currentSearch = '';
  String? _currentStatus;

  @override
  void initState() {
    super.initState();
    _loadBusCompanies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _loadBusCompanies() {
    context.read<CompanyManagementBloc>().add(
      CompanyManagementEvent.loadCompanies(
        search: _currentSearch,
        status: _currentStatus,
        sortBy: 'created_at',
        sortOrder: 'desc',
        page: 1,
        perPage: 50,
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      setState(() => _currentSearch = value);
      _loadBusCompanies();
    });
  }

  void _onAddBusCompany() => context.go('/bus-companies/add');

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        _buildHeader(),
        Gap(12.h),
        _buildSearchBar(),
        Gap(12.h),
        _buildFilterChips(),
        Gap(12.h),
        Expanded(child: _buildCompanyList()),
      ],
    );

    if (widget.inShell) {
      return Padding(padding: EdgeInsets.all(16.w), child: body);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bus Companies')),
      body: Padding(padding: EdgeInsets.all(16.w), child: body),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.directions_bus, size: 22.w, color: AppColors.info),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bus Fleet Companies',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Manage registered bus transport companies',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _onAddBusCompany,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Bus Company'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search bus companies...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _currentSearch = '');
                  _loadBusCompanies();
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _currentStatus == null,
            onSelected: (_) {
              setState(() => _currentStatus = null);
              _loadBusCompanies();
            },
          ),
          Gap(8.w),
          FilterChip(
            label: const Text('Active'),
            selected: _currentStatus == 'active',
            onSelected: (_) {
              setState(() => _currentStatus = 'active');
              _loadBusCompanies();
            },
          ),
          Gap(8.w),
          FilterChip(
            label: const Text('Pending'),
            selected: _currentStatus == 'pending',
            onSelected: (_) {
              setState(() => _currentStatus = 'pending');
              _loadBusCompanies();
            },
          ),
          Gap(8.w),
          FilterChip(
            label: const Text('Suspended'),
            selected: _currentStatus == 'suspended',
            onSelected: (_) {
              setState(() => _currentStatus = 'suspended');
              _loadBusCompanies();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyList() {
    return BlocBuilder<CompanyManagementBloc, CompanyManagementState>(
      builder: (context, state) {
        return state.maybeWhen(
          loaded:
              (
                companies,
                total,
                page,
                perPage,
                totalPages,
                search,
                status,
                verificationStatus,
                country,
                planType,
                sortBy,
                sortOrder,
                statistics,
                filterOptions,
              ) {
                final busCompanies = companies
                    .where((c) => c.tags.contains('bus_fleet'))
                    .toList();

                if (busCompanies.isEmpty) return _emptyState();

                return RefreshIndicator(
                  onRefresh: () async => _loadBusCompanies(),
                  child: ListView.separated(
                    itemCount: busCompanies.length,
                    separatorBuilder: (_, __) => Gap(12.h),
                    itemBuilder: (_, i) => _busCompanyCard(busCompanies[i]),
                  ),
                );
              },
          orElse: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _busCompanyCard(Company company) {
    final fleetSize = company.fleetSize;
    final routes = company.activeRoutes;
    final statusStr = company.status.name;
    final ownerName = company.contactPerson.fullName;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: _statusColor(company.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: _statusColor(company.status),
                    size: 24.w,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Gap(4.h),
                      Text(
                        company.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(statusStr),
              ],
            ),
            Gap(12.h),
            Divider(color: AppColors.border),
            Gap(8.h),
            Row(
              children: [
                _chip(Icons.confirmation_number, '$fleetSize buses'),
                Gap(16.w),
                _chip(Icons.alt_route, '$routes routes'),
                const Spacer(),
                _chip(Icons.phone, company.phone),
              ],
            ),
            Gap(8.h),
            Text(
              'Owner: $ownerName',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.gray700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.w, color: AppColors.gray500),
        Gap(4.w),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColorByName(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(CompanyStatus status) {
    switch (status) {
      case CompanyStatus.active:
        return AppColors.success;
      case CompanyStatus.pending:
        return AppColors.warning;
      case CompanyStatus.suspended:
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  Color _statusColorByName(String name) {
    switch (name.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'suspended':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus, size: 64, color: AppColors.gray300),
          Gap(16.h),
          Text(
            'No Bus Companies Found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.gray600),
          ),
          Gap(8.h),
          Text(
            _currentSearch.isNotEmpty
                ? 'No bus companies match your search.'
                : 'No bus companies have been registered yet.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
          ),
          Gap(16.h),
          ElevatedButton.icon(
            onPressed: _onAddBusCompany,
            icon: const Icon(Icons.add),
            label: const Text('Add Bus Company'),
          ),
        ],
      ),
    );
  }
}
