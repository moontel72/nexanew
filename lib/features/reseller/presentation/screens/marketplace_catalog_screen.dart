import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _businessVerified = true; // optimistic default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBusinessProof();
      context.read<ResellerMarketplaceBloc>().add(
        ResellerMarketplaceFactorySelected(widget.factoryId),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkBusinessProof() async {
    final prefs = await SharedPreferences.getInstance();
    final verified = prefs.getBool('reseller_business_proof_uploaded') ?? false;
    if (mounted) setState(() => _businessVerified = verified);
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

  // ── Add to cart helper ───────────────────────────────────────────
  void _addToCart(ResellerMarketplaceProductModel product) {
    context.read<ResellerCartBloc>().add(AddToCart(product: product));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
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
        title: widget.factoryName,
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
              onRetry: () => context.read<ResellerMarketplaceBloc>().add(
                ResellerMarketplaceRefreshRequested(),
              ),
            );
          }

          // ── Loaded ────────────────────────────────────────────
          final products = _filtered(state.products);
          final categories = _categories(state.products);

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

              // ── Category chips ────────────────────────────────
              if (categories.isNotEmpty)
                SizedBox(
                  height: 38.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (_, i) {
                      final isAll = i == 0;
                      final cat = isAll ? null : categories[i - 1];
                      final selected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(isAll ? 'All' : cat!),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat),
                        labelStyle: TextStyle(fontSize: 12.sp),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                      );
                    },
                  ),
                ),
              SizedBox(height: 4.h),

              // ── Product grid ──────────────────────────────────
              Expanded(
                child: products.isEmpty
                    ? const EmptyState(
                        title: '',
                        description: 'No products match your search.',
                        icon: Icons.search_off,
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
                                  childAspectRatio: 0.68,
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
              'Factory Promotions — Bulk discounts available. '
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

  // ── Product card for grid ────────────────────────────────────────
  Widget _productGridCard(ResellerMarketplaceProductModel p) {
    final cardColor = p.category.toLowerCase() == 'food'
        ? AppColors.foodProduct
        : p.category.toLowerCase() == 'medical'
        ? AppColors.medicalProduct
        : AppColors.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {} /* future: product detail */,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image area ──────────────────────────────────
            Expanded(
              flex: 5,
              child: Container(
                color: AppColors.gray50,
                child: Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 40.sp,
                    color: AppColors.gray300,
                  ),
                ),
              ),
            ),

            // ── Info area ───────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    if (p.category.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          p.category,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: cardColor,
                          ),
                        ),
                      ),
                    SizedBox(height: 4.h),

                    // Name
                    Text(
                      p.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Price + Cart button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${p.currency} ${p.price.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
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
                  ],
                ),
              ),
            ),
          ],
        ),
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
