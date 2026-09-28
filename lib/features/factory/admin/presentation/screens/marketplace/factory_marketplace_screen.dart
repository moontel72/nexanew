import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/constants/api_endpoints.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/products/products_bloc.dart';
import 'package:trace_odd/shared/models/product/product_model.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:trace_odd/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';

/// Factory panel — the Marketplace section (MASTER-TASK-LIST item #11).
///
/// The owner's design for the factory (the only role that sells here):
///   * Preview      — the whole marketplace as a buyer sees it.
///   * My Listings  — this factory's products, with publish / unpublish.
///   * Orders       — the reseller orders placed against this factory.
///
/// The reseller / shop-keeper order *cart* and the platform-wide oversight view
/// belong to other roles, not this panel.
class FactoryMarketplaceScreen extends StatefulWidget {
  const FactoryMarketplaceScreen({super.key});

  @override
  State<FactoryMarketplaceScreen> createState() =>
      _FactoryMarketplaceScreenState();
}

class _FactoryMarketplaceScreenState extends State<FactoryMarketplaceScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final _api = ApiService();
  final _searchController = TextEditingController();

  // Preview tab
  List<Map<String, dynamic>> _preview = [];
  bool _previewLoading = false;
  String? _previewError;

  // Orders tab
  List<Map<String, dynamic>> _orders = [];
  bool _ordersLoading = false;
  String? _ordersError;
  bool _ordersLoaded = false;

  static const _resellerStatuses = <String>[
    'pending',
    'confirmed',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreview();
      context.read<ProductsBloc>().add(const LoadProducts());
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 2 && !_ordersLoaded && !_ordersLoading) {
      _loadOrders();
    }
  }

  // ─── Data ────────────────────────────────────────────────────────

  Future<void> _loadPreview() async {
    setState(() {
      _previewLoading = true;
      _previewError = null;
    });

    try {
      final res = await _api.get(
        ApiEndpoints.resellerMarketplaceProducts,
        queryParameters: {
          'page': 1,
          'limit': 50,
          if (_searchController.text.trim().isNotEmpty)
            'search': _searchController.text.trim(),
        },
      );

      final map = res is Map
          ? res.cast<String, dynamic>()
          : <String, dynamic>{};
      final data = map['data'];
      _preview = data is List
          ? data.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
          : <Map<String, dynamic>>[];
    } catch (e) {
      _previewError = e.toString();
    }

    if (mounted) {
      setState(() => _previewLoading = false);
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _ordersLoading = true;
      _ordersError = null;
    });

    try {
      final res = await _api.get(ApiEndpoints.factoryResellerOrders);
      final map = res is Map
          ? res.cast<String, dynamic>()
          : <String, dynamic>{};
      final data = map['data'];
      _orders = data is List
          ? data.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
          : <Map<String, dynamic>>[];
      _ordersLoaded = true;
    } catch (e) {
      _ordersError = e.toString();
    }

    if (mounted) {
      setState(() => _ordersLoading = false);
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _api.patch(
        ApiEndpoints.factoryResellerOrderStatus(orderId),
        data: {'order_status': status},
      );
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────

  String _money(dynamic value, String currency) {
    final n = value is num
        ? value.toDouble()
        : double.tryParse('${value ?? ''}') ?? 0;
    return '$currency ${n.toStringAsFixed(2)}';
  }

  String _dateLabel(dynamic iso) {
    final raw = iso?.toString();
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'shipped':
        return AppColors.accent;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  // ─── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Marketplace',
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              _loadPreview();
              if (_ordersLoaded) _loadOrders();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.secondary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.secondary,
            tabs: const [
              Tab(text: 'Preview'),
              Tab(text: 'My Listings'),
              Tab(text: 'Orders'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_previewTab(), _myListingsTab(), _ordersTab()],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab 1: Preview the whole marketplace ────────────────────────

  Widget _previewTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _loadPreview(),
            decoration: InputDecoration(
              hintText: 'Search the marketplace…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _loadPreview();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              isDense: true,
            ),
          ),
        ),
        Expanded(child: _previewBody()),
      ],
    );
  }

  Widget _previewBody() {
    if (_previewLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_previewError != null) {
      return Center(
        child: EmptyState(
          title: 'Could not load the marketplace',
          description: _previewError!,
          icon: Icons.error_outline,
          iconColor: AppColors.error,
          actionButton: OutlinedButton.icon(
            onPressed: _loadPreview,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Retry'),
          ),
        ),
      );
    }

    if (_preview.isEmpty) {
      return const Center(
        child: EmptyState(
          title: 'Nothing listed yet',
          description:
              'Products a factory publishes to the marketplace appear here.',
          icon: Icons.storefront_outlined,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: _preview.length,
      itemBuilder: (context, index) => _previewCard(_preview[index]),
    );
  }

  Widget _previewCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Product';
    final factoryName = item['factory_name']?.toString() ?? '';
    final currency = item['currency']?.toString() ?? 'PKR';
    final wholesale = item['wholesale_price'];
    final price = wholesale ?? item['price'];
    final moq = item['moq']?.toString() ?? '1';
    final imageUrl = item['image_url']?.toString();

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: 56.w,
                height: 56.w,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (factoryName.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        factoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      '${_money(price, currency)}  ·  MOQ $moq',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.accent.withValues(alpha: 0.12),
      child: Icon(Icons.image_outlined, color: AppColors.accent, size: 24.sp),
    );
  }

  // ─── Tab 2: this factory's listings (publish / unpublish) ────────

  Widget _myListingsTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Publish a product to put it on the marketplace.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton.icon(
                onPressed: () => context.go('/factory/products/create'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, state) {
              if (state.status == ProductsStatus.loading &&
                  state.products.isEmpty) {
                return const Center(child: LoadingIndicator());
              }

              if (state.status == ProductsStatus.error &&
                  state.products.isEmpty) {
                return Center(
                  child: EmptyState(
                    title: 'Could not load your products',
                    description: state.errorMessage ?? 'Unknown error',
                    icon: Icons.error_outline,
                    iconColor: AppColors.error,
                    actionButton: OutlinedButton.icon(
                      onPressed: () => context.read<ProductsBloc>().add(
                        const LoadProducts(),
                      ),
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Retry'),
                    ),
                  ),
                );
              }

              if (state.products.isEmpty) {
                return const Center(
                  child: EmptyState(
                    title: 'No products yet',
                    description:
                        'Create a product, then publish it to the marketplace here.',
                    icon: Icons.inventory_2_outlined,
                  ),
                );
              }

              final busy = state.status == ProductsStatus.updating;

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return _listingRow(product, busy: busy);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _listingRow(ProductModel product, {required bool busy}) {
    final price = product.wholesalePrice ?? product.unitPrice;
    final priceLabel = price == null
        ? 'No price set'
        : _money(price, product.currency);

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      '$priceLabel  ·  MOQ ${product.moq}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (product.marketplaceEnabled
                                    ? AppColors.success
                                    : AppColors.textTertiary)
                                .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        product.marketplaceEnabled
                            ? 'Published'
                            : 'Not published',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: product.marketplaceEnabled
                              ? AppColors.success
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: product.marketplaceEnabled,
              onChanged: busy
                  ? null
                  : (value) {
                      context.read<ProductsBloc>().add(
                        ToggleMarketplace(
                          productId: product.id,
                          enabled: value,
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab 3: reseller orders + history ────────────────────────────

  Widget _ordersTab() {
    if (_ordersLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_ordersError != null) {
      return Center(
        child: EmptyState(
          title: 'Could not load orders',
          description: _ordersError!,
          icon: Icons.error_outline,
          iconColor: AppColors.error,
          actionButton: OutlinedButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Retry'),
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: EmptyState(
          title: 'No orders yet',
          description:
              'Reseller orders placed on your published products appear here.',
          icon: Icons.receipt_long_outlined,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: _orders.length,
      itemBuilder: (context, index) => _orderCard(_orders[index]),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final orderId = order['id']?.toString() ?? '';
    final status = order['orderStatus']?.toString() ?? 'pending';
    final resellerName =
        order['resellerBusinessName']?.toString().isNotEmpty == true
        ? order['resellerBusinessName'].toString()
        : (order['resellerName']?.toString() ?? 'Unknown reseller');
    final currency = order['currency']?.toString() ?? 'PKR';
    final items = order['items'];
    final itemCount = items is List ? items.length : 0;
    final createdAt = _dateLabel(order['createdAt']);

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    resellerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text(
                '$itemCount item${itemCount == 1 ? '' : 's'}  ·  '
                '${_money(order['grandTotal'], currency)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Row(
              children: [
                if (createdAt.isNotEmpty)
                  Expanded(
                    child: Text(
                      createdAt,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                PopupMenuButton<String>(
                  tooltip: 'Change status',
                  onSelected: (value) => _updateOrderStatus(orderId, value),
                  itemBuilder: (context) => _resellerStatuses
                      .map(
                        (s) => PopupMenuItem(
                          value: s,
                          child: Text(_statusLabel(s)),
                        ),
                      )
                      .toList(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Update status',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 20.sp,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
