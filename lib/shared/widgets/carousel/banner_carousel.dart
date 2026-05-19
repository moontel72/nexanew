import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ============================================================================
// BannerCarousel — Reusable auto-scrolling banner slider
// ============================================================================

class BannerData {
  final String companyName;
  final String tagline;
  final List<Color> gradientColors;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const BannerData({
    required this.companyName,
    required this.tagline,
    required this.gradientColors,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });
}

class BannerCarousel extends StatefulWidget {
  final List<BannerData> banners;
  final double height;
  final Duration autoScrollInterval;
  final Color dotColor;
  final Color activeDotColor;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.height = 210,
    this.autoScrollInterval = const Duration(seconds: 4),
    this.dotColor = const Color(0x80B3B3B3),
    this.activeDotColor = const Color(0xFF0066CC),
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _controller;
  late final Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(widget.autoScrollInterval, (_) {
        if (_controller.hasClients) {
          final next = (_currentIndex + 1) % widget.banners.length;
          _controller.animateToPage(next,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut);
        }
      });
    } else {
      _timer = Timer.periodic(const Duration(days: 365), (_) {}); // no-op
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height.h,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: widget.banners.length,
              padEnds: false,
              itemBuilder: (_, i) => _slide(widget.banners[i], i),
            ),
          ),
          SizedBox(height: 8.h),
          _dots(),
        ],
      ),
    );
  }

  Widget _slide(BannerData banner, int index) {
    final isActive = index == _currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: banner.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: banner.gradientColors.last.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          _decorCircle(right: -30, top: -40, size: 160, opacity: 0.08),
          _decorCircle(left: -20, bottom: -30, size: 100, opacity: 0.06),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _featuredChip(banner.accentColor),
                      SizedBox(height: 10.h),
                      Text(banner.companyName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 6.h),
                      Text(banner.tagline,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12.sp)),
                      SizedBox(height: 12.h),
                      _ctaButton(banner),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 600),
                      scale: isActive ? 1.0 : 0.85,
                      child: Container(
                        width: 75.w,
                        height: 75.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(banner.icon,
                            color: banner.accentColor, size: 40.sp),
                      ),
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

  Widget _decorCircle(
      {double? right,
      double? top,
      double? left,
      double? bottom,
      required double size,
      required double opacity}) {
    return Positioned(
      right: right,
      top: top,
      left: left,
      bottom: bottom,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withValues(alpha: opacity), width: 1.5),
        ),
      ),
    );
  }

  Widget _featuredChip(Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text('FEATURED',
          style: TextStyle(
              color: color,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2)),
    );
  }

  Widget _ctaButton(BannerData banner) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: banner.onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8.r),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text('Explore Now →',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.banners.length, (i) {
        final isActive = i == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 24.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: isActive ? widget.activeDotColor : widget.dotColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
