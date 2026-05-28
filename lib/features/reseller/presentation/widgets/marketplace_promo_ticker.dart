import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trace_odd/shared/theme/colors.dart';

// ============================================================================
// MarketplacePromoTicker — Vertical auto-scrolling sidebar promo
// ============================================================================

class PromoItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const PromoItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

class MarketplacePromoTicker extends StatefulWidget {
  final List<PromoItem> promos;
  final String headerTitle;
  final Duration scrollInterval;

  const MarketplacePromoTicker({
    super.key,
    required this.promos,
    this.headerTitle = 'Hot Deals',
    this.scrollInterval = const Duration(milliseconds: 2200),
  });

  @override
  State<MarketplacePromoTicker> createState() => _MarketplacePromoTickerState();
}

class _MarketplacePromoTickerState extends State<MarketplacePromoTicker> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promos.isEmpty) return const SizedBox.shrink();

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _startAutoScroll(widget.promos.length));

    return Container(
      width: 0.2.sw,
      margin: EdgeInsets.fromLTRB(12.w, 0, 6.w, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _header(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              itemCount: widget.promos.length * 50,
              itemBuilder: (_, i) =>
                  _card(widget.promos[i % widget.promos.length]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Row(children: [
        Icon(Icons.local_offer_rounded, color: Colors.white, size: 16.sp),
        SizedBox(width: 6.w),
        Expanded(
            child: Text(widget.headerTitle,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700))),
        _PulsingDot(),
      ]));

  Widget _card(PromoItem promo) => Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: promo.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: promo.color.withValues(alpha: 0.18), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: promo.onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                        color: promo.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r)),
                    child:
                        Icon(promo.icon, color: promo.color, size: 16.sp)),
                SizedBox(height: 6.h),
                Text(promo.title,
                    style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center),
                SizedBox(height: 2.h),
                Text(promo.subtitle,
                    style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: promo.color),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ));

  void _startAutoScroll(int itemCount) {
    _timer?.cancel();
    if (itemCount == 0) return;
    _timer = Timer.periodic(widget.scrollInterval, (_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final cur = _scrollController.position.pixels;
      final step = 95.h;
      if (cur + step >= max) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut);
      } else {
        _scrollController.animateTo(cur + step,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut);
      }
    });
  }
}

// ── Pulsing live dot ──────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
                color: Color(0xFF00FF88), shape: BoxShape.circle)),
      ),
    );
  }
}
