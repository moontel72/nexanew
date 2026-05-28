import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/constants/api_endpoints.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_bloc.dart';
import 'package:trace_odd/shared/models/code/bundle_model.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';

/// Orders Hub Screen
///
/// Tabbed management hub for Factory Admin Orders with five tabs:
/// - New (draft)
/// - Pending (pending_store_linking)
/// - Linked (store_linked)
/// - Completed (delivered)
/// - Reseller (reseller_orders from marketplace)
///
/// Uses the existing [BundleBloc] for bundle tabs and direct API for reseller orders.
class OrdersHubScreen extends StatefulWidget {
  const OrdersHubScreen({super.key});

  @override
  State<OrdersHubScreen> createState() => _OrdersHubScreenState();
}

class _OrdersHubScreenState extends State<OrdersHubScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // Reseller orders state
  List<Map<String, dynamic>> _resellerOrders = [];
  bool _resellerLoading = false;
  String? _resellerError;

  static const _tabs = <_OrderTab>[
    _OrderTab(label: 'New', status: 'draft', icon: Icons.description_outlined),
    _OrderTab(
      label: 'Pending',
      status: 'pending_store_linking',
      icon: Icons.hourglass_empty_outlined,
    ),
    _OrderTab(
      label: 'Linked',
      status: 'store_linked',
      icon: Icons.link_outlined,
    ),
    _OrderTab(
      label: 'Completed',
      status: 'delivered',
      icon: Icons.check_circle_outline,
    ),
    _OrderTab(
      label: 'Reseller',
      status: 'reseller',
      icon: Icons.storefront_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BundleBloc>().add(const LoadBundles());
      _fetchResellerOrders();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final tab = _tabs[_tabController.index];
      if (tab.status == 'reseller' &&
          _resellerOrders.isEmpty &&
          !_resellerLoading) {
        _fetchResellerOrders();
      }
    }
  }

  Future<void> _fetchResellerOrders() async {
    setState(() {
      _resellerLoading = true;
      _resellerError = null;
    });
    try {
      final res = await ApiService().get(ApiEndpoints.factoryResellerOrders);
      final map = res is Map
          ? res.cast<String, dynamic>()
          : <String, dynamic>{};
      final data = map['data'];
      if (data is List) {
        _resellerOrders = data.cast<Map<String, dynamic>>();
      } else {
        _resellerOrders = [];
      }
    } catch (e) {
      _resellerError = e.toString();
    }
    if (mounted) {
      setState(() => _resellerLoading = false);
    }
  }

  Future<void> _updateResellerOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      await ApiService().patch(
        ApiEndpoints.factoryResellerOrderStatus(orderId),
        body: {'order_status': newStatus},
      );
      await _fetchResellerOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'draft':
        return AppColors.warning;
      case 'pending_store_linking':
        return AppColors.accent;
      case 'store_linked':
        return AppColors.info;
      case 'delivered':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'shipped':
        return AppColors.accent;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'pending_store_linking':
        return 'Pending Linking';
      case 'store_linked':
        return 'Store Linked';
      case 'delivered':
        return 'Delivered';
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.65),
          tabs: _tabs
              .map(
                (t) => Tab(
                  icon: Icon(t.icon, size: 20.sp),
                  text: t.label,
                ),
              )
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          // ── Reseller tab uses its own data source ──────────────
          if (tab.status == 'reseller') {
            return _buildResellerOrdersTab(tab);
          }

          // ── Bundle tabs use BundleBloc ─────────────────────────
          return BlocBuilder<BundleBloc, BundleState>(
            builder: (context, state) {
              if (state.status == BundleStatus.loading &&
                  state.bundles.isEmpty) {
                return const Center(child: LoadingIndicator());
              }

              if (state.status == BundleStatus.error && state.bundles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage ?? 'Failed to load bundles',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<BundleBloc>().add(const LoadBundles()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final filtered = state.bundles
                  .where((b) => b.status == tab.status)
                  .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tab.icon, size: 56.w, color: AppColors.textDisabled),
                      SizedBox(height: 12.h),
                      Text(
                        'No ${tab.label} Orders',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        tab.status == 'draft'
                            ? 'Create a new order to get started.'
                            : 'Orders will appear here when they move to this stage.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<BundleBloc>().add(const LoadBundles());
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final b = filtered[i];
                    return _BundleCard(
                      bundle: b,
                      statusColor: _statusColor(b.status),
                      statusLabel: _statusLabel(b.status),
                      onTap: () => context.push('/factory/orders/${b.id}'),
                    );
                  },
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  /// Builds the Reseller Orders tab content, fetching from /factory/reseller-orders.
  Widget _buildResellerOrdersTab(_OrderTab tab) {
    if (_resellerLoading && _resellerOrders.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (_resellerError != null && _resellerOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _resellerError!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchResellerOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_resellerOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 56.w, color: AppColors.textDisabled),
            SizedBox(height: 12.h),
            Text(
              'No Reseller Orders',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Orders placed by resellers on the marketplace will appear here.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchResellerOrders,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _resellerOrders.length,
        itemBuilder: (_, i) {
          final order = _resellerOrders[i];
          return _ResellerOrderCard(
            order: order,
            statusColor: _statusColor(order['orderStatus']?.toString() ?? ''),
            statusLabel: _statusLabel(order['orderStatus']?.toString() ?? ''),
            onStatusChanged: (newStatus) {
              _updateResellerOrderStatus(
                order['id']?.toString() ?? '',
                newStatus,
              );
            },
          );
        },
      ),
    );
  }
}

/// Data class for defining a tab in the Orders hub.
class _OrderTab {
  final String label;
  final String status;
  final IconData icon;

  const _OrderTab({
    required this.label,
    required this.status,
    required this.icon,
  });
}

/// Card widget for displaying a bundle/order summary.
class _BundleCard extends StatelessWidget {
  final BundleModel bundle;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onTap;

  const _BundleCard({
    required this.bundle,
    required this.statusColor,
    required this.statusLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              // Left icon
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.layers_outlined,
                  color: statusColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // Middle content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bundle.orderReference.isNotEmpty
                          ? bundle.orderReference
                          : bundle.bundleCode,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      bundle.bundleCode,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        _metricChip(
                          Icons.all_inbox_outlined,
                          '${bundle.totalCartons} cartons',
                        ),
                        SizedBox(width: 10.w),
                        _metricChip(
                          Icons.inventory_2_outlined,
                          '${bundle.totalPackets} packets',
                        ),
                      ],
                    ),
                    if (bundle.storeKeeperName != null &&
                        bundle.storeKeeperName!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 13.sp,
                            color: AppColors.accent,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            bundle.storeKeeperName!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Right status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textTertiary),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

/// Card widget for displaying a reseller (marketplace) order.
class _ResellerOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  final String statusLabel;
  final void Function(String newStatus) onStatusChanged;

  const _ResellerOrderCard({
    required this.order,
    required this.statusColor,
    required this.statusLabel,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final resellerName =
        order['resellerBusinessName']?.toString() ??
        order['resellerName']?.toString() ??
        'Unknown';
    final grandTotal = (order['grandTotal'] is num)
        ? (order['grandTotal'] as num).toDouble()
        : 0.0;
    final items = order['items'];
    final itemCount = items is List ? items.length : 0;
    final currency = order['currency']?.toString() ?? 'PKR';
    final currentStatus = order['orderStatus']?.toString() ?? 'pending';

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Left icon
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.storefront_outlined,
                    color: AppColors.accent,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                // Middle content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resellerName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '$itemCount item${itemCount == 1 ? '' : 's'} · $currency ${grandTotal.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (order['resellerCity']?.toString().isNotEmpty == true)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13.sp,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                order['resellerCity'].toString(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Right status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
            // ── Status action chips ────────────────────────────
            SizedBox(height: 10.h),
            Row(
              children: [
                if (currentStatus == 'pending')
                  _statusChip('Confirm', AppColors.info, () {
                    onStatusChanged('confirmed');
                  }),
                if (currentStatus == 'confirmed')
                  _statusChip('Ship', AppColors.accent, () {
                    onStatusChanged('shipped');
                  }),
                if (currentStatus == 'shipped')
                  _statusChip('Deliver', AppColors.success, () {
                    onStatusChanged('delivered');
                  }),
                if (currentStatus != 'cancelled' &&
                    currentStatus != 'delivered')
                  _statusChip('Cancel', AppColors.error, () {
                    onStatusChanged('cancelled');
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }
}
