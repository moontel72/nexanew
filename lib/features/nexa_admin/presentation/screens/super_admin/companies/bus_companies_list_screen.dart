// View All Bus Companies Screen — Super Admin lists bus fleet companies
// Layout matches ResellerManagementListScreen pattern

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/company/bus_company_model.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/companies/company_management_bloc.dart';
import 'package:nexatrace_system/shared/models/company/company_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/inputs/search_field.dart';

/// Bus Companies List Screen — Displays all bus fleet companies
class BusCompaniesListScreen extends StatefulWidget {
  final bool inShell;

  const BusCompaniesListScreen({super.key, this.inShell = false});

  @override
  State<BusCompaniesListScreen> createState() => _BusCompaniesListScreenState();
}

class _BusCompaniesListScreenState extends State<BusCompaniesListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _search = '';
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _load() {
    context.read<CompanyManagementBloc>().add(
      CompanyManagementEvent.loadCompanies(
        search: _search,
        status: _statusFilter,
        sortBy: 'created_at',
        sortOrder: 'desc',
        page: 1,
        perPage: 50,
      ),
    );
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_search != v) {
        _search = v;
        _load();
      }
    });
  }

  Color _statusColor(CompanyStatus s) {
    switch (s) {
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

  Widget _filterChip(String label, String? value, String? current) {
    final selected = value == current;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _statusFilter = value);
          _load();
        },
        selectedColor: AppColors.info.withValues(alpha: 0.15),
        checkmarkColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Fleet Companies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Bus Company',
            onPressed: () => context.go('/bus-companies/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
            child: SearchField(
              controller: _searchController,
              hintText: 'Search by name, email, or city...',
              onChanged: _onSearch,
            ),
          ),
          SizedBox(height: 8.h),

          // ── Status filter chips ─────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _filterChip('All', null, _statusFilter),
                _filterChip('Active', 'active', _statusFilter),
                _filterChip('Pending', 'pending', _statusFilter),
                _filterChip('Suspended', 'suspended', _statusFilter),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          const Divider(),
          SizedBox(height: 4.h),

          // ── List ────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<CompanyManagementBloc, CompanyManagementState>(
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
                        final bus = companies
                            .where((c) => c.isBusCompany)
                            .toList();

                        if (bus.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_bus,
                                  size: 64,
                                  color: AppColors.gray300,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No bus companies found',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: AppColors.gray500),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 80.h),
                          itemCount: bus.length,
                          separatorBuilder: (_, __) => SizedBox(height: 6.h),
                          itemBuilder: (_, i) => _busCard(bus[i]),
                        );
                      },
                  orElse: () =>
                      const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Bus company card ─────────────────────────────────────────
  Widget _busCard(Company c) {
    final fleet = c.fleetSize;
    final routes = c.activeRoutes;
    final owner = c.busOwnerName;
    final color = _statusColor(c.status);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1 — icon + name + status badge
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.directions_bus, size: 22.w, color: color),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        c.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    c.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            const Divider(),
            SizedBox(height: 6.h),

            // Row 2 — fleet stats
            Row(
              children: [
                _meta(Icons.confirmation_number, '$fleet buses'),
                SizedBox(width: 18.w),
                _meta(Icons.alt_route, '$routes routes'),
                const Spacer(),
                _meta(Icons.phone, c.phone),
              ],
            ),
            SizedBox(height: 6.h),

            // Row 3 — owner + location
            Text(
              '$owner  •  ${c.city}, ${c.country}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.w, color: AppColors.gray400),
        SizedBox(width: 4.w),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}
