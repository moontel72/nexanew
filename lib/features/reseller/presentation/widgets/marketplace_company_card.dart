import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/status_badge.dart';

// ============================================================================
// MarketplaceCompanyCard — B2B grid card for marketplace
// ============================================================================

class MarketplaceCompanyCard extends StatelessWidget {
  final Map<String, dynamic> factory;
  final VoidCallback? onTap;

  const MarketplaceCompanyCard({super.key, required this.factory, this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = factory['name']?.toString() ?? 'Unknown';
    final status = factory['status']?.toString() ?? 'active';
    final city =
        factory['city']?.toString() ?? factory['location']?.toString() ?? '';
    final productCount =
        int.tryParse(factory['product_count']?.toString() ?? '0') ?? 0;
    final info = StatusInfo.from(status);
    final initials = _initials(name);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _colorBar(info.color),
              Expanded(flex: 4, child: Center(child: _logo(initials))),
              Expanded(
                flex: 5,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _nameText(name),
                      SizedBox(height: 4.h),
                      StatusBadge(label: info.label, color: info.color),
                      SizedBox(height: 6.h),
                      if (city.isNotEmpty) _locationRow(city),
                      SizedBox(height: 4.h),
                      _productCountChip(productCount),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorBar(Color color) => Container(
      height: 4.h,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            color,
            color.withValues(alpha: 0.5)
          ]),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))));

  Widget _logo(String initials) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.primaryDark.withValues(alpha: 0.06)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14.r),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.2),
      ),
      child: Center(
          child: Text(initials,
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5))),
    );
  }

  Widget _nameText(String name) => Text(name,
      style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.gray900,
          height: 1.15),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center);

  Widget _locationRow(String city) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_on_rounded, size: 11.sp, color: AppColors.gray400),
        SizedBox(width: 2.w),
        Flexible(
            child: Text(city,
                style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ]);

  Widget _productCountChip(int count) => Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
          color: AppColors.gray50, borderRadius: BorderRadius.circular(6.r)),
      child: Text('$count products',
          style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600)));

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, math.min(2, name.length)).toUpperCase();
  }
}
