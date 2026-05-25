// View All Goods Companies Screen — Super Admin lists goods logistics fleet companies
// Layout matches BusCompaniesListScreen pattern

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/company/goods_company_model.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/companies/company_management_bloc.dart';
import 'package:nexatrace_system/shared/models/company/company_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/inputs/search_field.dart';

/// Goods Companies List Screen — Displays all goods logistics fleet companies
class GoodsCompaniesListScreen extends StatefulWidget {
  final bool inShell;

  const GoodsCompaniesListScreen({super.key, this.inShell = false});

  @override
  State<GoodsCompaniesListScreen> createState() =>
      _GoodsCompaniesListScreenState();
}

class _GoodsCompaniesListScreenState extends State<GoodsCompaniesListScreen> {
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
    if (!mounted) return;
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
        selectedColor: AppColors.success.withValues(alpha: 0.15),
        checkmarkColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goods Logistics Companies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Goods Company',
            onPressed: () => context.go('/goods-companies/add'),
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
                        final goods = companies
                            .where((c) => c.isGoodsCompany)
                            .toList();

                        if (goods.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_shipping,
                                  size: 64,
                                  color: AppColors.gray300,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No goods companies found',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: AppColors.gray500),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 80.h),
                          itemCount: goods.length,
                          separatorBuilder: (_, __) => SizedBox(height: 6.h),
                          itemBuilder: (_, i) => _goodsCard(goods[i]),
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

  // ── Goods company card ─────────────────────────────────────────
  Widget _goodsCard(Company c) {
    final trucks = c.truckCount;
    final size = c.fleetSize;
    final owner = c.goodsOwnerName;
    final color = _statusColor(c.status);
    final isPending = c.status == CompanyStatus.pending;
    final isActive = c.status == CompanyStatus.active;
    final isSuspended = c.status == CompanyStatus.suspended;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1 — icon + name + status badge + menu
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.local_shipping, size: 22.w, color: color),
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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (action) => _handleAction(action, c),
                  itemBuilder: (_) => [
                    if (isPending)
                      const PopupMenuItem(
                        value: 'approve',
                        child: ListTile(
                          leading: Icon(
                            Icons.verified,
                            color: AppColors.success,
                          ),
                          title: Text('Approve (Activate)'),
                          dense: true,
                        ),
                      ),
                    if (isActive)
                      const PopupMenuItem(
                        value: 'suspend',
                        child: ListTile(
                          leading: Icon(
                            Icons.pause_circle,
                            color: AppColors.warning,
                          ),
                          title: Text('Suspend'),
                          dense: true,
                        ),
                      ),
                    if (isSuspended)
                      const PopupMenuItem(
                        value: 'activate',
                        child: ListTile(
                          leading: Icon(
                            Icons.play_circle,
                            color: AppColors.success,
                          ),
                          title: Text('Activate'),
                          dense: true,
                        ),
                      ),
                    if (isActive || isSuspended)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: ListTile(
                          leading: Icon(
                            Icons.stop_circle,
                            color: AppColors.gray500,
                          ),
                          title: Text('Deactivate'),
                          dense: true,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, color: AppColors.success),
                        title: Text('Edit Company'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: AppColors.error),
                        title: Text('Delete'),
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            const Divider(),
            SizedBox(height: 6.h),

            // Row 2 — fleet stats
            Row(
              children: [
                _meta(Icons.local_shipping, '$trucks trucks'),
                SizedBox(width: 18.w),
                _meta(Icons.inventory, '$size fleet'),
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

            // Row 4 — Quick action buttons
            SizedBox(height: 10.h),
            Row(
              children: [
                if (isPending)
                  _actionBtn(
                    'Approve',
                    Icons.verified,
                    AppColors.success,
                    () => _approve(c),
                  ),
                if (isActive) ...[
                  _actionBtn(
                    'Suspend',
                    Icons.pause_circle,
                    AppColors.warning,
                    () => _suspend(c),
                  ),
                  SizedBox(width: 8.w),
                  _actionBtn(
                    'Deactivate',
                    Icons.stop_circle,
                    AppColors.gray600,
                    () => _setStatus(c, 'inactive'),
                  ),
                ],
                if (isSuspended)
                  _actionBtn(
                    'Activate',
                    Icons.play_circle,
                    AppColors.success,
                    () => _activate(c),
                  ),
                if (!isPending) ...[
                  SizedBox(width: 8.w),
                  _actionBtn(
                    'Edit',
                    Icons.edit,
                    AppColors.success,
                    () => _edit(c),
                  ),
                ],
                SizedBox(width: 8.w),
                _actionBtn(
                  'Delete',
                  Icons.delete_outline,
                  AppColors.error,
                  () => _confirmDelete(c),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.w, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────
  void _handleAction(String action, Company c) {
    switch (action) {
      case 'approve':
        _approve(c);
      case 'suspend':
        _suspend(c);
      case 'activate':
        _activate(c);
      case 'deactivate':
        _setStatus(c, 'inactive');
      case 'edit':
        _edit(c);
      case 'delete':
        _confirmDelete(c);
    }
  }

  void _approve(Company c) {
    context.read<CompanyManagementBloc>().add(
      CompanyManagementEvent.updateCompanyStatus(id: c.id, status: 'active'),
    );
    _load();
  }

  void _activate(Company c) {
    context.read<CompanyManagementBloc>().add(
      CompanyManagementEvent.updateCompanyStatus(id: c.id, status: 'active'),
    );
    _load();
  }

  void _suspend(Company c) {
    context.read<CompanyManagementBloc>().add(
      CompanyManagementEvent.updateCompanyStatus(id: c.id, status: 'suspended'),
    );
    _load();
  }

  void _setStatus(Company c, String status) {
    context.read<CompanyManagementBloc>().add(
      CompanyManagementEvent.updateCompanyStatus(id: c.id, status: status),
    );
    _load();
  }

  void _edit(Company c) {
    context.go('/companies/${c.id}');
  }

  void _confirmDelete(Company c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goods Company?'),
        content: Text(
          'Are you sure you want to delete "${c.name}"?\n\n'
          'This action cannot be undone. All associated data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<CompanyManagementBloc>().add(
                CompanyManagementEvent.deleteCompany(c.id),
              );
              Navigator.pop(ctx);
              _load();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
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
