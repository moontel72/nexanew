import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ============================================================================
// PaginationBar — Reusable page navigation
// ============================================================================

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final Color activeColor;
  final Color inactiveTextColor;
  final Color borderColor;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.activeColor = const Color(0xFF0066CC),
    this.inactiveTextColor = const Color(0xFF666666),
    this.borderColor = const Color(0xFFCCCCCC),
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final pages = _computePages();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: const Color(0xFFE6E6E6), width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _navButton(
            icon: Icons.chevron_left_rounded,
            enabled: currentPage > 1,
            onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          ),
          ...pages.map((p) => p < 0 ? _ellipsis() : _pageChip(p)),
          _navButton(
            icon: Icons.chevron_right_rounded,
            enabled: currentPage < totalPages,
            onTap: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
          SizedBox(width: 10.w),
          Text('Page $currentPage of $totalPages',
              style:
                  TextStyle(fontSize: 10.sp, color: const Color(0xFF999999))),
        ],
      ),
    );
  }

  List<int> _computePages() {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }
    final pages = <int>[1];
    if (currentPage > 3) pages.add(-1);
    for (var i = math.max(2, currentPage - 1);
        i <= math.min(totalPages - 1, currentPage + 1);
        i++) {
      pages.add(i);
    }
    if (currentPage < totalPages - 2) pages.add(-2);
    pages.add(totalPages);
    return pages;
  }

  Widget _pageChip(int page) {
    final isActive = page == currentPage;
    return GestureDetector(
      onTap: () => onPageChanged(page),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: isActive ? null : Border.all(color: borderColor, width: 1),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Center(
          child: Text('$page',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : inactiveTextColor)),
        ),
      ),
    );
  }

  Widget _ellipsis() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child:
          Icon(Icons.more_horiz, size: 16.sp, color: const Color(0xFF999999)),
    );
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
              color: enabled ? borderColor : const Color(0xFFE6E6E6),
              width: 1),
        ),
        child: Icon(icon,
            size: 18.sp,
            color: enabled
                ? const Color(0xFF4D4D4D)
                : const Color(0xFFB3B3B3)),
      ),
    );
  }
}
