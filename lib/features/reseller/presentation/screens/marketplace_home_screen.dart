import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/cart/reseller_cart_bloc.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/marketplace/reseller_marketplace_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/search/search_bar.dart';

class MarketplaceHomeScreen extends StatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  State<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends State<MarketplaceHomeScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context
          .read<ResellerMarketplaceBloc>()
          .state
          .tenantId
          .isEmpty;
      if (auth) {
        // Boot with a default tenant; in production this comes from auth state.
        context.read<ResellerMarketplaceBloc>().add(
          ResellerMarketplaceBootRequested(tenantId: 'default'),
        );
      }
    });
  }

  // ── filtered factory list ────────────────────────────────────────
  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> factories) {
    if (_query.isEmpty) return factories;
    final q = _query.toLowerCase();
    return factories.where((f) {
      final name = (f['name']?.toString() ?? '').toLowerCase();
      final city = (f['city']?.toString() ?? '').toLowerCase();
      final location = (f['location']?.toString() ?? '').toLowerCase();
      return name.contains(q) || city.contains(q) || location.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'NexaTrace Marketplace',
        showBackButton: false,
        actions: [
          // ── Cart badge ────────────────────────────────────────
          BlocBuilder<ResellerCartBloc, ResellerCartState>(
            builder: (_, cart) => Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                  ),
                  tooltip: 'Cart',
                  onPressed: () => context.go('/marketplace/cart'),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18.w,
                        minHeight: 18.w,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<ResellerMarketplaceBloc, ResellerMarketplaceState>(
        builder: (context, state) {
          // ── Loading ───────────────────────────────────────────
          if (state.status == ResellerMarketplaceStatus.initial ||
              state.status == ResellerMarketplaceStatus.loading) {
            return const Center(child: LoadingIndicator());
          }

          // ── Error ─────────────────────────────────────────────
          if (state.status == ResellerMarketplaceStatus.error) {
            return ErrorState(
              title: 'Error',
              message: state.errorMessage ?? 'Failed to load factories',
              onRetry: () => context.read<ResellerMarketplaceBloc>().add(
                ResellerMarketplaceRefreshRequested(),
              ),
            );
          }

          // ── Loaded ────────────────────────────────────────────
          final allFactories = state.factories;
          final filtered = _filtered(allFactories);

          if (allFactories.isEmpty) {
            return EmptyState(
              title: 'No Factories Available',
              description:
                  'No factories are available in your area yet.\nCheck back soon or contact your administrator.',
              icon: Icons.store_mall_directory_outlined,
              actionButton: TextButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.dashboard),
                label: const Text('Go to Dashboard'),
              ),
            );
          }

          return Column(
            children: [
              // ── Search bar ────────────────────────────────────
              SearchBar(
                hintText: 'Search factories by name or city...',
                onSearchChanged: (v) => setState(() => _query = v),
                showFilterButton: false,
              ),

              // ── Count chip ────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Chip(
                      avatar: Icon(
                        Icons.factory,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        '${filtered.length} Factories',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.08,
                      ),
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),

              // ── Factory grid ──────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        title: '',
                        description: 'No factories match "$_query"',
                        icon: Icons.search_off,
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _factoryCard(filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Single factory card ──────────────────────────────────────────
  Widget _factoryCard(Map<String, dynamic> f) {
    final name = f['name']?.toString() ?? 'Unknown Factory';
    final id = f['id']?.toString() ?? '';
    final status = f['status']?.toString() ?? 'active';
    final city = f['city']?.toString() ?? f['location']?.toString() ?? '';
    final productCount =
        int.tryParse(f['product_count']?.toString() ?? '0') ?? 0;

    final statusColor = switch (status.toLowerCase()) {
      'active' => AppColors.success,
      'inactive' => AppColors.warning,
      'suspended' => AppColors.error,
      _ => AppColors.gray500,
    };

    final statusLabel = switch (status.toLowerCase()) {
      'active' => 'Active',
      'inactive' => 'Inactive',
      'suspended' => 'Suspended',
      _ => status,
    };

    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => context.go(
          '/marketplace/catalog'
          '?factoryId=$id'
          '&factoryName=${Uri.encodeComponent(name)}',
        ),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              // ── Avatar ────────────────────────────────────
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.store, color: AppColors.primary, size: 24.sp),
              ),
              SizedBox(width: 12.w),

              // ── Info ──────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (city.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.sp,
                            color: AppColors.gray500,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              city,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.gray500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _badge(statusLabel, statusColor),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 14.sp,
                          color: AppColors.gray500,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          '$productCount products',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.gray500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Arrow ─────────────────────────────────────
              Icon(Icons.chevron_right, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
