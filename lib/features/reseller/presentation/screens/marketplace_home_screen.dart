import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/cart/reseller_cart_bloc.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/marketplace/reseller_marketplace_bloc.dart';
import 'package:nexatrace_system/features/reseller/presentation/widgets/marketplace_company_card.dart';
import 'package:nexatrace_system/features/reseller/presentation/widgets/marketplace_promo_ticker.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/carousel/banner_carousel.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/pagination/pagination_bar.dart';

// ============================================================================
// MarketplaceHomeScreen — Premium B2B Marketplace (composes shared widgets)
// ============================================================================

class MarketplaceHomeScreen extends StatefulWidget {
  const MarketplaceHomeScreen({super.key});
  @override
  State<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends State<MarketplaceHomeScreen> {
  String _query = '';
  int _page = 1;
  static const int _perPage = 30;
  static const int _columns = 3;

  static const _banners = [
    BannerData(
      companyName: 'Maxi Electronic',
      tagline: 'Premium Electronics — Up to 40% Off',
      gradientColors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
      icon: Icons.bolt_rounded,
      accentColor: Color(0xFFFFB800),
    ),
    BannerData(
      companyName: 'Moon Medi',
      tagline: 'Certified Medical Supplies — Bulk Rates',
      gradientColors: [Color(0xFF1A0A2E), Color(0xFF2D1B69)],
      icon: Icons.medical_services_rounded,
      accentColor: Color(0xFF00E5FF),
    ),
    BannerData(
      companyName: 'NexaTrace Verified',
      tagline: 'Trusted Factories with Real-Time Tracking',
      gradientColors: [Color(0xFF0D2137), Color(0xFF0066CC)],
      icon: Icons.verified_rounded,
      accentColor: AppColors.accent,
    ),
    BannerData(
      companyName: 'Flash Deals',
      tagline: 'Limited-Time Wholesale Discounts Available',
      gradientColors: [Color(0xFF3D0A0A), Color(0xFFCC3300)],
      icon: Icons.local_fire_department_rounded,
      accentColor: AppColors.warning,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ResellerMarketplaceBloc>().state.tenantId.isEmpty) {
        context
            .read<ResellerMarketplaceBloc>()
            .add(ResellerMarketplaceBootRequested(tenantId: 'default'));
      }
    });
  }

  // ── Filter & paginate ──────────────────────────────────────────
  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> src) {
    if (_query.isEmpty) return src;
    final q = _query.toLowerCase();
    return src.where((f) {
      final n = (f['name']?.toString() ?? '').toLowerCase();
      final c = (f['city']?.toString() ?? '').toLowerCase();
      final l = (f['location']?.toString() ?? '').toLowerCase();
      return n.contains(q) || c.contains(q) || l.contains(q);
    }).toList();
  }

  int _totalPages(List<Map<String, dynamic>> items) =>
      (items.length / _perPage).ceil().clamp(1, 9999);

  List<Map<String, dynamic>> _paginated(List<Map<String, dynamic>> items) {
    final start = (_page - 1) * _perPage;
    final end = math.min(start + _perPage, items.length);
    if (start >= items.length) {
      _page = _totalPages(items);
      return _paginated(items);
    }
    return items.sublist(start, end);
  }

  // ── Promo items for sidebar ticker ────────────────────────────
  List<PromoItem> _buildPromos(List<Map<String, dynamic>> factories) {
    final items = <PromoItem>[];
    for (var i = 0; i < factories.length && items.length < 12; i++) {
      final f = factories[i];
      final name = f['name']?.toString() ?? 'Factory';
      final discount = 5 + (i * 7) % 40;
      items.add(PromoItem(
        title: name,
        subtitle: 'Up to $discount% off',
        icon: Icons.discount_rounded,
        color: _paletteColor(i),
        onTap: () => setState(() => _query = name),
      ));
    }
    if (items.length < 8) {
      items.addAll([
        PromoItem(title: 'Bulk Orders', subtitle: 'Save up to 25%', icon: Icons.inventory_2_rounded, color: AppColors.success),
        PromoItem(title: 'Free Shipping', subtitle: 'On orders > \$500', icon: Icons.local_shipping_rounded, color: AppColors.info),
        PromoItem(title: 'New Arrivals', subtitle: 'Just landed', icon: Icons.new_releases_rounded, color: const Color(0xFF7C3AED)),
        PromoItem(title: 'Price Drop', subtitle: 'Lowest this month', icon: Icons.trending_down_rounded, color: AppColors.error),
        PromoItem(title: 'Verified Only', subtitle: 'Trusted suppliers', icon: Icons.verified_rounded, color: AppColors.primary),
        PromoItem(title: 'Flash Sale', subtitle: 'Ending soon!', icon: Icons.bolt_rounded, color: AppColors.accent),
      ]);
    }
    return items;
  }

  static const _palette = [
    AppColors.success, AppColors.info, AppColors.accent, AppColors.error,
    AppColors.primary, Color(0xFF7C3AED), Color(0xFF059669), Color(0xFFDC2626),
  ];
  Color _paletteColor(int i) => _palette[i % _palette.length];

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: CustomAppBar(
        title: 'NexaTrace Marketplace',
        showBackButton: false,
        actions: [_cartBadge()],
      ),
      body: BlocBuilder<ResellerMarketplaceBloc, ResellerMarketplaceState>(
        builder: (context, state) {
          if (state.status == ResellerMarketplaceStatus.initial ||
              state.status == ResellerMarketplaceStatus.loading) {
            return const Center(child: LoadingIndicator());
          }
          if (state.status == ResellerMarketplaceStatus.error) {
            return ErrorState(
              title: 'Error',
              message: state.errorMessage ?? 'Failed to load factories',
              onRetry: () => context
                  .read<ResellerMarketplaceBloc>()
                  .add(ResellerMarketplaceRefreshRequested()),
            );
          }

          final all = state.factories;
          if (all.isEmpty) {
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

          final filtered = _filtered(all);
          final paginated = _paginated(filtered);
          final totalPages = _totalPages(filtered);

          return Column(
            children: [
              _searchBar(),
              const BannerCarousel(banners: _banners),
              SizedBox(height: 8.h),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(title: '', description: 'No factories match "$_query"', icon: Icons.search_off)
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        MarketplacePromoTicker(promos: _buildPromos(all)),
                        Expanded(
                          flex: 4,
                          child: _grid(paginated, totalPages),
                        ),
                      ]),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Cart badge ─────────────────────────────────────────────────
  Widget _cartBadge() {
    return BlocBuilder<ResellerCartBloc, ResellerCartState>(
      builder: (_, cart) => Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            tooltip: 'Cart',
            onPressed: () => context.go('/marketplace/cart'),
          ),
          if (cart.itemCount > 0)
            Positioned(
              right: 4, top: 4,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
                child: Text('${cart.itemCount}',
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }

  // ── Modern search bar ──────────────────────────────────────────
  Widget _searchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() { _query = v; _page = 1; }),
        style: TextStyle(fontSize: 14.sp, color: AppColors.gray900),
        decoration: InputDecoration(
          hintText: 'Search factories by name, city, or location...',
          hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.gray400),
          prefixIcon: Container(
            margin: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: AppColors.gray400, size: 20.sp),
                  onPressed: () => setState(() { _query = ''; _page = 1; }),
                )
              : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  // ── Company grid ────────────────────────────────────────────────
  Widget _grid(List<Map<String, dynamic>> paginated, int totalPages) {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.factory_rounded, size: 14.sp, color: AppColors.primary),
                  SizedBox(width: 4.w),
                  Text('${paginated.length} Companies',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ]),
              ),
              const Spacer(),
              Icon(Icons.sort_rounded, size: 16.sp, color: AppColors.gray400),
              SizedBox(width: 4.w),
              Text('Sorted by relevance', style: TextStyle(fontSize: 10.sp, color: AppColors.gray400)),
            ],
          ),
        ),
        // GridView
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(10.w, 4.h, 14.w, 8.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columns,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 0.72,
            ),
            itemCount: paginated.length,
            itemBuilder: (_, i) {
              final f = paginated[i];
              final id = f['id']?.toString() ?? '';
              final name = f['name']?.toString() ?? '';
              return MarketplaceCompanyCard(
                factory: f,
                onTap: () => context.go('/marketplace/catalog?factoryId=$id&factoryName=${Uri.encodeComponent(name)}'),
              );
            },
          ),
        ),
        // Pagination
        PaginationBar(
          currentPage: _page,
          totalPages: totalPages,
          onPageChanged: (p) => setState(() => _page = p),
        ),
      ],
    );
  }
}
