import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/marketplace/reseller_marketplace_bloc.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/order/reseller_order_bloc.dart';
import 'package:nexatrace_system/shared/models/order/order_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class MarketplaceOrderHistoryScreen extends StatefulWidget {
  const MarketplaceOrderHistoryScreen({super.key});

  @override
  State<MarketplaceOrderHistoryScreen> createState() =>
      _MarketplaceOrderHistoryScreenState();
}

class _MarketplaceOrderHistoryScreenState
    extends State<MarketplaceOrderHistoryScreen> {
  bool _initialised = false;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    final prefs = await SharedPreferences.getInstance();
    final resellerId = prefs.getString('reseller_current_user_id') ?? 'unknown';

    if (!mounted) return;

    context.read<ResellerOrderBloc>().add(
      FetchOrderHistoryRequested(
        resellerId: resellerId,
        page: _page,
        limit: 20,
      ),
    );
    _initialised = true;
  }

  void _loadMore() {
    if (!_hasMore || _loadingMore) return;
    _loadingMore = true;
    _page++;
    _load().then((_) {
      if (mounted) setState(() => _loadingMore = false);
    });
  }

  String _factoryName(String factoryId) {
    final factories = context.read<ResellerMarketplaceBloc>().state.factories;
    for (final f in factories) {
      if (f['id']?.toString() == factoryId) {
        return f['name']?.toString() ?? factoryId;
      }
    }
    return factoryId;
  }

  String _statusLabel(String status) {
    return switch (status.toLowerCase()) {
      'pending' => 'Pending',
      'processing' => 'Processing',
      'shipped' => 'Shipped',
      'delivered' => 'Delivered',
      'cancelled' => 'Cancelled',
      _ => status,
    };
  }

  Color _statusColor(String status) {
    return switch (status.toLowerCase()) {
      'pending' => AppColors.gray500,
      'processing' => AppColors.info,
      'shipped' => AppColors.primary,
      'delivered' => AppColors.success,
      'cancelled' => AppColors.error,
      _ => AppColors.gray500,
    };
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Order History', showBackButton: true),
      body: BlocBuilder<ResellerOrderBloc, ResellerOrderState>(
        builder: (context, state) {
          // ── Loading ───────────────────────────────────────────
          if (!_initialised ||
              (state.status == OrderStatus.loading && _page == 1)) {
            return const Center(child: LoadingIndicator());
          }

          // ── Error on first load ──────────────────────────────
          if (state.status == OrderStatus.failure &&
              state.orderHistory.isEmpty) {
            return ErrorState(
              title: 'Error',
              message: state.errorMessage ?? 'Failed to load orders',
              onRetry: () => _load(refresh: true),
            );
          }

          // ── Empty ────────────────────────────────────────────
          if (state.orderHistory.isEmpty) {
            return EmptyState(
              title: 'No Orders Yet',
              description:
                  'Your purchase history will appear here.\nStart shopping from the marketplace.',
              icon: Icons.receipt_long_outlined,
              actionButton: PrimaryButton(
                text: 'Go to Marketplace',
                onPressed: () => context.go('/reseller/marketplace'),
              ),
            );
          }

          // ── List ─────────────────────────────────────────────
          return NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll is ScrollEndNotification &&
                  scroll.metrics.pixels >=
                      scroll.metrics.maxScrollExtent - 100) {
                _loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 80.h),
              itemCount: state.orderHistory.length + (_loadingMore ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (_, i) {
                if (i >= state.orderHistory.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _orderCard(state.orderHistory[i]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _orderCard(OrderModel order) {
    final status = order.orderStatus;
    final color = _statusColor(status);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: InkWell(
        onTap: () => context.go('/reseller/marketplace/orders/${order.id}'),
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              // ── Status dot ──────────────────────────────────
              Container(
                width: 10.w,
                height: 10.h,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 10.w),

              // ── Info ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _factoryName(order.factoryId),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${order.items.length} items • '
                      '${order.currency} ${order.totalAmount.toStringAsFixed(0)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                    ),
                  ],
                ),
              ),

              // ── Status badge + date ─────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatDate(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray400,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
