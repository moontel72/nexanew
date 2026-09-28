import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/constants/api_endpoints.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:trace_odd/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';

/// Marketplace oversight — READ-ONLY, shared by the Super Admin and the
/// `commercial_marketplace` Sub-Admin (MASTER-TASK-LIST item #11).
///
/// The owner's rule: both roles own no factory and no product, so this screen
/// only *shows* the marketplace — never creates or edits a listing or an order.
/// It is one screen used two ways:
///   * inside a panel shell (Super Admin) — `standalone: false`, bare content;
///   * as its own route (Sub-Admin)      — `standalone: true`, its own app bar.
class MarketplaceOversightScreen extends StatefulWidget {
  const MarketplaceOversightScreen({
    super.key,
    this.standalone = false,
    this.backRoute,
  });

  /// When true the screen renders its own Scaffold + app bar.
  final bool standalone;

  /// Where the back button goes when there is no history to pop
  /// (e.g. `/sub-admin/dashboard`). Ignored when [standalone] is false.
  final String? backRoute;

  @override
  State<MarketplaceOversightScreen> createState() =>
      _MarketplaceOversightScreenState();
}

class _MarketplaceOversightScreenState extends State<MarketplaceOversightScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final _api = ApiService();
  final _searchController = TextEditingController();

  // Marketplace preview (what buyers see) — public read, no auth surprises.
  List<Map<String, dynamic>> _preview = [];
  bool _previewLoading = false;
  String? _previewError;

  // Orders + summary (read-only oversight).
  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic> _summary = const {};
  bool _ordersLoading = false;
  String? _ordersError;
  bool _ordersLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreview();
      _loadOrders();
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
    if (_tabController.index == 1 && !_ordersLoaded && !_ordersLoading) {
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
      final results = await Future.wait([
        _api.get(ApiEndpoints.adminMarketplaceOrders),
        _api.get(ApiEndpoints.adminMarketplaceSummary),
      ]);

      final ordersRes = results[0];
      final ordersMap = ordersRes is Map
          ? ordersRes.cast<String, dynamic>()
          : <String, dynamic>{};
      final data = ordersMap['data'];
      _orders = data is List
          ? data.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
          : <Map<String, dynamic>>[];

      final summaryRes = results[1];
      final summaryMap = summaryRes is Map
          ? summaryRes.cast<String, dynamic>()
          : <String, dynamic>{};
      final summaryData = summaryMap['data'];
      _summary = summaryData is Map
          ? summaryData.cast<String, dynamic>()
          : <String, dynamic>{};

      _ordersLoaded = true;
    } catch (e) {
      _ordersError = e.toString();
    }

    if (mounted) {
      setState(() => _ordersLoading = false);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────

  String _money(dynamic value, [String currency = 'PKR']) {
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

  void _onBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(widget.backRoute ?? '/dashboard');
  }

  // ─── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.secondary,
          tabs: const [
            Tab(text: 'Marketplace'),
            Tab(text: 'Orders'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_previewTab(), _ordersTab()],
          ),
        ),
      ],
    );

    if (!widget.standalone) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Marketplace',
        showBackButton: true,
        onBackPressed: _onBack,
      ),
      body: content,
    );
  }

  // ─── Tab 1: the marketplace as buyers see it ─────────────────────

  Widget _previewTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _loadPreview(),
                  decoration: InputDecoration(
                    hintText: 'Search the marketplace…',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _loadPreview,
                icon: const Icon(Icons.refresh),
              ),
            ],
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
          description: 'Products published to the marketplace appear here.',
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
    final price = item['wholesale_price'] ?? item['price'];
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

  // ─── Tab 2: read-only orders + summary ───────────────────────────

  Widget _ordersTab() {
    if (_ordersLoading && _orders.isEmpty) {
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

    return Column(
      children: [
        _summaryCard(),
        Expanded(
          child: _orders.isEmpty
              ? const Center(
                  child: EmptyState(
                    title: 'No orders yet',
                    description:
                        'Reseller orders placed on the marketplace appear here.',
                    icon: Icons.receipt_long_outlined,
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) => _orderCard(_orders[index]),
                ),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    final byStatus = _summary['by_status'];
    final statuses = byStatus is List
        ? byStatus.whereType<Map>().map((e) => e.cast<String, dynamic>())
        : const Iterable<Map<String, dynamic>>.empty();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _summaryTile(
                      'Orders',
                      '${_summary['total_orders'] ?? 0}',
                    ),
                  ),
                  Expanded(
                    child: _summaryTile(
                      'Value',
                      _money(_summary['total_value']),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _loadOrders,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: statuses.map((s) {
                  final status = s['status']?.toString() ?? '';
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${_statusLabel(status)}: ${s['count'] ?? 0}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(status),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
        ),
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final status = order['order_status']?.toString() ?? 'pending';
    final currency = order['currency']?.toString() ?? 'PKR';
    final reseller = order['reseller'];
    final factory = order['factory'];
    final resellerName = reseller is Map
        ? (reseller['business_name']?.toString().isNotEmpty == true
              ? reseller['business_name'].toString()
              : (reseller['name']?.toString() ?? 'Reseller'))
        : 'Reseller';
    final factoryName = factory is Map
        ? (factory['name']?.toString() ?? '')
        : '';
    final items = order['items'];
    final itemCount = items is List ? items.length : 0;
    final createdAt = _dateLabel(order['created_at']);

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
                '${factoryName.isEmpty ? '' : 'from $factoryName  ·  '}'
                '$itemCount item${itemCount == 1 ? '' : 's'}  ·  '
                '${_money(order['grand_total'], currency)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (createdAt.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  createdAt,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
