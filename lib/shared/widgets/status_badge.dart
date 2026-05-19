import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ============================================================================
// StatusBadge — Colored dot + label pill
// ============================================================================

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double? fontSize;
  final double dotSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.fontSize,
    this.dotSize = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize.w,
            height: dotSize.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 4.w),
          Text(label,
              style: TextStyle(
                  fontSize: fontSize ?? 9.sp,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

// ============================================================================
// StatusInfo — helper to resolve label + color from status string
// ============================================================================
class StatusInfo {
  final String label;
  final Color color;
  const StatusInfo(this.label, this.color);

  static StatusInfo from(String status, {Color defaultColor = const Color(0xFF808080)}) {
    switch (status.toLowerCase()) {
      case 'active':
        return const StatusInfo('Active', Color(0xFF00CC66));
      case 'inactive':
        return const StatusInfo('Inactive', Color(0xFFFF9900));
      case 'suspended':
        return const StatusInfo('Suspended', Color(0xFFFF3333));
      default:
        return StatusInfo(status, defaultColor);
    }
  }

  static Color colorFor(String status, {Color defaultColor = const Color(0xFF808080)}) {
    return from(status, defaultColor: defaultColor).color;
  }
}
