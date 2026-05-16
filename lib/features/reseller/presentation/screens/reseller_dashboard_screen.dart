import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/auth/reseller_auth_bloc.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/dashboard/reseller_dashboard_bloc.dart';
import 'package:nexatrace_system/shared/models/reseller/reseller_employee_model.dart';
import 'package:nexatrace_system/shared/models/reseller/reseller_shop_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class ResellerDashboardScreen extends StatefulWidget {
  const ResellerDashboardScreen({super.key});

  @override
  State<ResellerDashboardScreen> createState() =>
      _ResellerDashboardScreenState();
}

class _ResellerDashboardScreenState extends State<ResellerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResellerDashboardBloc>().add(
        ResellerDashboardLoadRequested(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Reseller Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<ResellerAuthBloc>().add(ResellerLogoutRequested());
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocBuilder<ResellerDashboardBloc, ResellerDashboardState>(
        builder: (context, state) {
          if (state is ResellerDashboardLoading ||
              state is ResellerDashboardInitial) {
            return const Center(child: LoadingIndicator());
          }

          if (state is ResellerDashboardError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.w,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    PrimaryButton(
                      text: 'Retry',
                      onPressed: () => context
                          .read<ResellerDashboardBloc>()
                          .add(ResellerDashboardLoadRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          final loaded = state as ResellerDashboardLoaded;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _marketplaceCard(),
                SizedBox(height: 12.h),
                _orderHistoryCard(),
                SizedBox(height: 12.h),
                _walletCard(loaded),
                SizedBox(height: 12.h),
                _shopsCard(loaded),
                SizedBox(height: 12.h),
                _employeesCard(loaded),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _walletCard(ResellerDashboardLoaded state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 8.h),
            Text(
              'Balance: ${state.wallet.formattedBalance}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Cancel Bit (Fee 10)',
                    onPressed: () {
                      context.read<ResellerDashboardBloc>().add(
                        ResellerCancelBitRequested(fee: 10),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Anti-fraud micro-fee is deducted on Bit cancellation (Phase 1: 6M).',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shopsCard(ResellerDashboardLoaded state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shops',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
                ),
                IconButton(
                  onPressed: () => _createShopDialog(),
                  icon: const Icon(Icons.add_business),
                  tooltip: 'Add Shop',
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (state.shops.isEmpty)
              Text(
                'No shops yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              )
            else
              Column(children: state.shops.map((s) => _shopRow(s)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _employeesCard(ResellerDashboardLoaded state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Employees',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
                ),
                IconButton(
                  onPressed: state.shops.isEmpty
                      ? null
                      : () => _createEmployeeDialog(state.shops),
                  icon: const Icon(Icons.person_add_alt_1),
                  tooltip: 'Add Employee',
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (state.employees.isEmpty)
              Text(
                'No employees yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              )
            else
              Column(
                children: state.employees.map((e) => _employeeRow(e)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _shopRow(ResellerShopModel shop) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(shop.name),
      subtitle: Text(shop.isActive ? 'Active' : 'Inactive'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.error),
        tooltip: 'Delete Shop',
        onPressed: () {
          context.read<ResellerDashboardBloc>().add(
            ResellerDeleteShopRequested(shop.id),
          );
        },
      ),
    );
  }

  Widget _employeeRow(ResellerEmployeeModel employee) {
    final roleText = switch (employee.role) {
      ResellerEmployeeRole.shopManager => 'Shop Manager',
      ResellerEmployeeRole.cashier => 'Cashier',
      ResellerEmployeeRole.stockKeeper => 'Stock Keeper',
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(employee.name),
      subtitle: Text('$roleText • Shop: ${employee.shopId}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.error),
        tooltip: 'Delete Employee',
        onPressed: () {
          context.read<ResellerDashboardBloc>().add(
            ResellerDeleteEmployeeRequested(employee.id),
          );
        },
      ),
    );
  }

  Future<void> _createShopDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Shop'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Shop name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    context.read<ResellerDashboardBloc>().add(
      ResellerCreateShopRequested(name),
    );
  }

  Future<void> _createEmployeeDialog(List<ResellerShopModel> shops) async {
    final nameController = TextEditingController();
    ResellerEmployeeRole role = ResellerEmployeeRole.shopManager;
    String shopId = shops.first.id;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: shopId,
                items: shops
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) shopId = v;
                },
                decoration: const InputDecoration(
                  labelText: 'Shop',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<ResellerEmployeeRole>(
                value: role,
                items: ResellerEmployeeRole.values
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(
                          r == ResellerEmployeeRole.shopManager
                              ? 'Shop Manager'
                              : r == ResellerEmployeeRole.cashier
                              ? 'Cashier'
                              : 'Stock Keeper',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) role = v;
                },
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    final name = nameController.text;
    nameController.dispose();
    if (result != true) return;
    if (name.trim().isEmpty) return;

    context.read<ResellerDashboardBloc>().add(
      ResellerCreateEmployeeRequested(shopId: shopId, name: name, role: role),
    );
  }

  Widget _marketplaceCard() {
    return Card(
      elevation: 2,
      color: AppColors.primary.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => context.go('/reseller/marketplace'),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visit Marketplace',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Browse products from multiple factories',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderHistoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => context.go('/reseller/marketplace/orders'),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.success,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchase History',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Track your orders and delivery status',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
