import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/cart/reseller_cart_bloc.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/marketplace/reseller_marketplace_bloc.dart';
import 'package:nexatrace_system/shared/models/reseller/reseller_marketplace_product_model.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/inputs/search_field.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class MarketplaceCatalogScreen extends StatefulWidget {
  final String factoryId;
  final String factoryName;

  const MarketplaceCatalogScreen({
    super.key,
    required this.factoryId,
    required this.factoryName,
  });

  @override
  State<MarketplaceCatalogScreen> createState() =>
      _MarketplaceCatalogScreenState();
}

class _MarketplaceCatalogScreenState extends State<MarketplaceCatalogScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategory;
  String? _selectedFactoryFilter; // null = all factories
  bool _businessVerified = true; // optimistic default

  /// Whether the screen is in "all factories" mode.
  bool get _isAllFactoriesMode => widget.factoryId.isEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBusinessProof();
      if (_isAllFactoriesMode) {
        final tenantId = context.read<ResellerMarketplaceBloc>().state.tenantId;
        context.read<ResellerMarketplaceBloc>().add(
          ResellerMarketplaceAllProductsRequested(tenantId: tenantId),
        );
      } else {
        context.read<ResellerMarketplaceBloc>().add(
          ResellerMarketplaceFactorySelected(widget.factoryId),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkBusinessProof() async {
    try {
      final res = await ApiService().get(
        ApiEndpoints.resellerProofStatus,
        requiresAuth: true,
      );
      final data = res is Map ? res : (res['data'] is Map ? res['data'] : null);
      final approved = data?['purchase_approved'] == true;
      if (mounted) setState(() => _businessVerified = approved);
    } catch (_) {
      if (mounted) setState(() => _businessVerified = true);
    }
  }

  // ── Filtering ────────────────────────────────────────────────────
  List<ResellerMarketplaceProductModel> _filtered(
    List<ResellerMarketplaceProductModel> products,
  ) {
    var list = products;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            (p.sku.toLowerCase().contains(q)) ||
            (p.category.toLowerCase().contains(q));
      }).toList();
    }
    if (_selectedCategory != null) {
      list = list
          .where(
            (p) => p.category.toLowerCase() == _selectedCategory!.toLowerCase(),
          )
          .toList();
    }
    // Client-side factory filter (only in "all factories" mode)
    if (_selectedFactoryFilter != null && _selectedFactoryFilter!.isNotEmpty) {
      list = list.where((p) => p.factoryId == _selectedFactoryFilter).toList();
    }
    return list;
  }

  List<String> _categories(List<ResellerMarketplaceProductModel> products) {
    return products
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  // ── Factory name lookup helper ──────────────────────────────────
  String _factoryNameFor(String factoryId) {
    final factories = context.read<ResellerMarketplaceBloc>().state.factories;
    for (final f in factories) {
      if (f['id']?.toString() == factoryId) {
        return f['name']?.toString() ?? factoryId;
      }
    }
    return factoryId;
  }

  // ── Add to cart helper ───────────────────────────────────────────
  void _addToCart(ResellerMarketplaceProductModel product, {int quantity = 1}) {
    context.read<ResellerCartBloc>().add(
      AddToCart(product: product, quantity: quantity),
    );
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          quantity > 1
              ? '${product.name} × $quantity added to cart'
              : '${product.name} added to cart',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80.h, left: 16.w, right: 16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isAllFactoriesMode ? 'All Products' : widget.factoryName,
        showBackButton: true,
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
                        minHeight: 18.h,
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
          if (state.status == ResellerMarketplaceStatus.loading) {
            return const Center(child: LoadingIndicator());
          }

          // ── Error ─────────────────────────────────────────────
          if (state.status == ResellerMarketplaceStatus.error) {
            return ErrorState(
              title: 'Error',
              message: state.errorMessage ?? 'Failed to load products',
              onRetry: () {
                if (_isAllFactoriesMode) {
                  final tenantId = context
                      .read<ResellerMarketplaceBloc>()
                      .state
                      .tenantId;
                  context.read<ResellerMarketplaceBloc>().add(
                    ResellerMarketplaceAllProductsRequested(tenantId: tenantId),
                  );
                } else {
                  context.read<ResellerMarketplaceBloc>().add(
                    ResellerMarketplaceRefreshRequested(),
                  );
                }
              },
            );
          }

          // ── Loaded ────────────────────────────────────────────
          final products = _filtered(state.products);
          final categories = _categories(state.products);
          // Compute factory counts for filter chips (all-factories mode)
          final factoryCounts = <String, int>{};
          if (_isAllFactoriesMode) {
            for (final p in state.products) {
              factoryCounts[p.factoryId] =
                  (factoryCounts[p.factoryId] ?? 0) + 1;
            }
          }

          return Column(
            children: [
              // ── Internal factory promotions banner (6O/6P) ──
              _promotionsBanner(),

              // ── Search ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: SearchField(
                  controller: _searchController,
                  hintText: 'Search products, SKU, category...',
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () => setState(() => _query = ''),
                ),
              ),

              // ── Factory filter chips (all-factories mode only) ─
              if (_isAllFactoriesMode && state.factories.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _filterChip(
                        'All Factories (${state.products.length})',
                        _selectedFactoryFilter == null,
                        () => setState(() => _selectedFactoryFilter = null),
                      ),
                      ...state.factories.map((f) {
                        final fid = f['id']?.toString();
                        final fname = f['name']?.toString() ?? 'Factory';
                        final count = factoryCounts[fid] ?? 0;
                        return _filterChip(
                          '$fname ($count)',
                          _selectedFactoryFilter == fid,
                          () => setState(() => _selectedFactoryFilter = fid),
                        );
                      }),
                    ],
                  ),
                ),

              // ── Category chips ────────────────────────────────
              if (categories.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _filterChip(
                        'All',
                        _selectedCategory == null,
                        () => setState(() => _selectedCategory = null),
                      ),
                      ...categories.map(
                        (cat) => _filterChip(
                          cat,
                          _selectedCategory == cat,
                          () => setState(() => _selectedCategory = cat),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 4.h),

              // ── Product grid ──────────────────────────────────
              Expanded(
                child: products.isEmpty
                    ? Builder(
                        builder: (context) {
                          if (kDebugMode) {
                            debugPrint(
                              'MARKETPLACE_CATALOG: No products. '
                              'All products count: ${state.products.length}, '
                              'Filtered count: ${products.length}',
                            );
                          }
                          return const EmptyState(
                            title: '',
                            description: 'No products match your search.',
                            icon: Icons.search_off,
                          );
                        },
                      )
                    : LayoutBuilder(
                        builder: (_, constraints) {
                          final crossAxisCount = constraints.maxWidth > 600
                              ? 3
                              : 2;
                          return GridView.builder(
                            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 10.h,
                                  crossAxisSpacing: 10.w,
                                  childAspectRatio: 0.62,
                                ),
                            itemCount: products.length,
                            itemBuilder: (_, i) =>
                                _productGridCard(products[i]),
                          );
                        },
                      ),
              ),

              // ── Business proof banner ─────────────────────────
              if (!_businessVerified) _verificationBanner(),
            ],
          );
        },
      ),
    );
  }

  // ── Promotions banner (Feature 6O/6P placeholder) ────────────────
  Widget _promotionsBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.campaign_outlined, color: AppColors.accent, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              _isAllFactoriesMode
                  ? 'Factory Promotions — Bulk discounts available across all factories.'
                  : 'Factory Promotions — Bulk discounts available. '
                        'Contact ${widget.factoryName} for wholesale rates.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chip helper ──────────────────────────────────────────
  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.gray50,
      selectedColor: AppColors.primary,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
        width: 1,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      labelPadding: EdgeInsets.symmetric(horizontal: 2.w),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    );
  }

  // ── Product card for grid ────────────────────────────────────────
  Widget _productGridCard(ResellerMarketplaceProductModel p) {
    final factoryName = p.factoryName ?? _factoryNameFor(p.factoryId);
    final unitPrice = p.unitPrice;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Factory label ──────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 0),
            child: Row(
              children: [
                Icon(Icons.factory, size: 12.sp, color: AppColors.gray500),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    'Sold by: $factoryName',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // ── Image area ──────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                height: 100.h,
                color: AppColors.gray50,
                child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                    ? Image.network(
                        p.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _imageLoadingPlaceholder();
                        },
                        errorBuilder: (_, __, ___) =>
                            _productImagePlaceholder(),
                      )
                    : _productImagePlaceholder(),
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // ── Offer badges row ──────────────────────────────
          if (p.hasOffer)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Wrap(
                spacing: 4.w,
                runSpacing: 2.h,
                children: [
                  if (p.promoDiscount != null && p.promoDiscount! > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00CC66).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        '${p.promoDiscount!.toStringAsFixed(0)}% Off',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00994C),
                        ),
                      ),
                    ),
                  if (p.bonusThreshold != null && p.bonusQuantity != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        'Buy ${p.bonusThreshold} Get ${p.bonusQuantity} Free',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          if (p.hasOffer) SizedBox(height: 4.h),

          // ── Product name ─────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              p.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: 2.h),

          // ── Price ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              '${p.currency} ${unitPrice.toStringAsFixed(0)} / unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 13.sp,
              ),
            ),
          ),

          const Spacer(),

          // ── Divider ──────────────────────────────────────
          Divider(height: 1, thickness: 1, color: AppColors.gray100),

          // ── Buttons row ──────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _showPackageModal(p),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 6.h,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View Packages',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _addToCart(p),
                  borderRadius: BorderRadius.circular(6.r),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.add_shopping_cart_rounded,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0F4FF), Color(0xFFE8EDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 40.sp,
          color: AppColors.gray300,
        ),
      ),
    );
  }

  Widget _imageLoadingPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0F4FF), Color(0xFFE8EDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ── Package Selection Modal Bottom Sheet ────────────────────────
  void _showPackageModal(ResellerMarketplaceProductModel product) {
    final factoryName =
        product.factoryName ?? _factoryNameFor(product.factoryId);
    int unitQty = product.moq ?? 1;
    int cartonQty = product.cartonPrice != null ? 1 : 0;
    int wholesaleQty = product.wholesalePrice != null ? 1 : 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Factory header
              Row(
                children: [
                  if (product.factoryLogo != null &&
                      product.factoryLogo!.isNotEmpty)
                    ClipOval(
                      child: Image.network(
                        product.factoryLogo!,
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.factory,
                          size: 24.sp,
                          color: AppColors.gray500,
                        ),
                      ),
                    )
                  else
                    Icon(Icons.factory, size: 24.sp, color: AppColors.gray500),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      factoryName,
                      style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              // Product name
              Text(
                product.name,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray700,
                ),
              ),
              SizedBox(height: 10.h),

              Divider(height: 1, color: AppColors.gray100),
              SizedBox(height: 10.h),

              // ── Volume discount info ──────────────────────
              if (product.volumeDiscounts != null &&
                  product.volumeDiscounts!.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.discount,
                        size: 18.sp,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Volume Discount: Buy more and save!',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
              ],

              // ── Unit package tile ─────────────────────────
              _packageTile(
                ctx: ctx,
                icon: Icons.inventory_2_outlined,
                label: 'Unit',
                pricePer:
                    '${product.currency} ${product.unitPrice.toStringAsFixed(0)} / unit',
                moq: 'MOQ: ${product.moq ?? 1} units',
                quantity: unitQty,
                onChanged: (v) => setSheetState(() => unitQty = v),
                onAdd: () {
                  _addToCart(product, quantity: unitQty);
                  Navigator.of(ctx).pop();
                },
              ),
              SizedBox(height: 8.h),

              // ── Carton package tile (if applicable) ──────
              if (product.cartonPrice != null) ...[
                _packageTile(
                  ctx: ctx,
                  icon: Icons.inventory_outlined,
                  label: 'Carton',
                  pricePer:
                      '${product.currency} ${product.cartonPrice!.toStringAsFixed(0)} / carton',
                  moq: '',
                  quantity: cartonQty,
                  onChanged: (v) => setSheetState(() => cartonQty = v),
                  onAdd: () {
                    _addToCart(product, quantity: cartonQty);
                    Navigator.of(ctx).pop();
                  },
                ),
                SizedBox(height: 8.h),
              ],

              // ── Wholesale package tile (if applicable) ───
              if (product.wholesalePrice != null) ...[
                _packageTile(
                  ctx: ctx,
                  icon: Icons.warehouse_outlined,
                  label: 'Wholesale',
                  pricePer:
                      '${product.currency} ${product.wholesalePrice!.toStringAsFixed(0)} / bulk',
                  moq: '',
                  quantity: wholesaleQty,
                  onChanged: (v) => setSheetState(() => wholesaleQty = v),
                  onAdd: () {
                    _addToCart(product, quantity: wholesaleQty);
                    Navigator.of(ctx).pop();
                  },
                ),
                SizedBox(height: 8.h),
              ],

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Single package type tile with quantity selector and Add to Cart.
  Widget _packageTile({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required String pricePer,
    required String moq,
    required int quantity,
    required ValueChanged<int> onChanged,
    required VoidCallback onAdd,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(icon, size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                label,
                style: Theme.of(
                  ctx,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                pricePer,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (moq.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              moq,
              style: TextStyle(fontSize: 11.sp, color: AppColors.gray500),
            ),
          ],
          SizedBox(height: 8.h),

          // Quantity selector + Add to Cart
          Row(
            children: [
              // Minus
              InkWell(
                onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray300),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16.sp,
                    color: AppColors.gray600,
                  ),
                ),
              ),
              // Quantity display
              SizedBox(
                width: 40.w,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Plus
              InkWell(
                onTap: () => onChanged(quantity + 1),
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray300),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Icon(Icons.add, size: 16.sp, color: AppColors.gray600),
                ),
              ),
              const Spacer(),
              // Add to Cart button
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: Icon(Icons.add_shopping_cart_rounded, size: 16.sp),
                label: Text('Add to Cart', style: TextStyle(fontSize: 12.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Business verification banner ─────────────────────────────────
  Widget _verificationBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(
            color: AppColors.warning.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.warning,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Please upload Business Proof to complete your first purchase.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.gray700),
            ),
          ),
          TextButton(
            onPressed: () {
              /* TODO: navigate to profile upload */
            },
            child: Text(
              'Upload',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}
