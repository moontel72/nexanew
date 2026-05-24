import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/marketplace/reseller_marketplace_bloc.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/order/reseller_order_bloc.dart';
import 'package:nexatrace_system/shared/models/order/order_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class MarketplaceOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const MarketplaceOrderDetailScreen({super.key, required this.orderId});

  @override
  State<MarketplaceOrderDetailScreen> createState() =>
      _MarketplaceOrderDetailScreenState();
}

class _MarketplaceOrderDetailScreenState
    extends State<MarketplaceOrderDetailScreen> {
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResellerOrderBloc>().add(
        FetchOrderDetailRequested(widget.orderId),
      );
      _initialised = true;
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
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year}  ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _productName(item) {
    return item.metadata?['product_name']?.toString() ?? item.productId;
  }

  // ── Static timeline steps ────────────────────────────────────────
  List<_StatusStep> _buildTimeline(String status) {
    final steps = <_StatusStep>[
      _StatusStep('Order Placed', Icons.receipt_long, true),
      _StatusStep('Factory Accepted', Icons.checklist, false),
      _StatusStep('Store Keeper Scanned', Icons.qr_code_scanner, false),
      _StatusStep('Out for Delivery', Icons.local_shipping, false),
      _StatusStep('Delivered', Icons.check_circle, false),
    ];

    final statuses = [
      'pending',
      'processing',
      'shipped',
      'shipped', // out-for-delivery is same as shipped for now
      'delivered',
    ];

    for (int i = 0; i < steps.length; i++) {
      if (i <= statuses.indexOf(status.toLowerCase())) {
        steps[i] = steps[i].copyWith(completed: true);
      } else {
        steps[i] = steps[i].copyWith(completed: false);
      }
    }

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Order Detail', showBackButton: true),
      body: BlocBuilder<ResellerOrderBloc, ResellerOrderState>(
        builder: (context, state) {
          // ── Loading ───────────────────────────────────────────
          if (!_initialised || state.status == OrderStatus.loading) {
            return const Center(child: LoadingIndicator());
          }

          // ── Error ─────────────────────────────────────────────
          if (state.status == OrderStatus.failure ||
              state.selectedOrder == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 12.h),
                    Text(state.errorMessage ?? 'Order not found'),
                    SizedBox(height: 12.h),
                    PrimaryButton(
                      text: 'Retry',
                      onPressed: () => context.read<ResellerOrderBloc>().add(
                        FetchOrderDetailRequested(widget.orderId),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final order = state.selectedOrder!;
          final status = order.orderStatus;
          final color = _statusColor(status);
          final timeline = _buildTimeline(status);
          final isDelivered = status.toLowerCase() == 'delivered';

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Order summary card ──────────────────────────
                _summaryCard(order, status, color),
                SizedBox(height: 14.h),

                // ── Items list ──────────────────────────────────
                _sectionTitle('Items (${order.items.length})'),
                SizedBox(height: 6.h),
                ...order.items.map((item) => _itemRow(item)),
                SizedBox(height: 14.h),

                // ── Status timeline ─────────────────────────────
                _sectionTitle('Status Timeline'),
                SizedBox(height: 6.h),
                _timelineWidget(timeline),
                SizedBox(height: 24.h),

                // ── QR scan CTA (if delivered) ──────────────────
                if (isDelivered)
                  PrimaryButton(
                    text: 'Scan to Confirm Receipt',
                    icon: Icons.qr_code_scanner,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'QR scanning will be available in the next update.',
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Summary card ─────────────────────────────────────────────────
  Widget _summaryCard(OrderModel order, String status, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            const Divider(),
            SizedBox(height: 8.h),

            // Info rows
            _infoRow('Factory', _factoryName(order.factoryId)),
            _infoRow(
              'Total',
              '${order.currency} ${order.totalAmount.toStringAsFixed(0)}',
            ),
            _infoRow('Items', '${order.items.length}'),
            _infoRow('Ordered', _formatDate(order.createdAt)),
            if (order.updatedAt != null && order.updatedAt != order.createdAt)
              _infoRow('Last Updated', _formatDate(order.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── Section title ────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  // ── Item row ─────────────────────────────────────────────────────
  Widget _itemRow(item) {
    final name = _productName(item);
    final lineTotal = item.unitPrice * item.quantity;

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: AppColors.gray100),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${item.unitPrice.toStringAsFixed(0)} PKR × ${item.quantity}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray500,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${lineTotal.toStringAsFixed(0)} PKR',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Timeline stepper ─────────────────────────────────────────────
  Widget _timelineWidget(List<_StatusStep> steps) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          children: steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isLast = i == steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Connector + icon ────────────────────────
                  SizedBox(
                    width: 32.w,
                    child: Column(
                      children: [
                        Container(
                          width: 28.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: step.completed
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.gray100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step.icon,
                            size: 16.sp,
                            color: step.completed
                                ? AppColors.success
                                : AppColors.gray400,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: step.completed
                                  ? AppColors.success.withValues(alpha: 0.3)
                                  : AppColors.gray200,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),

                  // ── Label ───────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
                      child: Text(
                        step.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: step.completed
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: step.completed
                              ? AppColors.textPrimary
                              : AppColors.gray500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Timeline helper model ───────────────────────────────────────────
class _StatusStep {
  final String label;
  final IconData icon;
  final bool completed;

  const _StatusStep(this.label, this.icon, this.completed);

  _StatusStep copyWith({String? label, IconData? icon, bool? completed}) {
    return _StatusStep(
      label ?? this.label,
      icon ?? this.icon,
      completed ?? this.completed,
    );
  }
}
