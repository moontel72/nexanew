import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/core/theme/branding_config.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Interactive seat grid visualizer.  States: 0=Available (green outline),
/// 1=Booked (gray filled), 2=Selected (brand solid).  Under 100 lines.
class SeatSelectionGridWidget extends StatelessWidget {
  final List<int> seatMatrix; // 0=available, 1=booked, 2=selected
  final int columns;
  final void Function(int index)? onSeatTap;
  final double seatPrice;

  const SeatSelectionGridWidget({
    super.key,
    required this.seatMatrix,
    this.columns = 4,
    this.onSeatTap,
    this.seatPrice = 0,
  });

  @override
  Widget build(BuildContext context) {
    final brand = BrandingConfig.forPanel(UserPanel.customer);
    final tt = Theme.of(context).textTheme;
    final rows = (seatMatrix.length / columns).ceil();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: brand.primaryColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.event_seat, size: 18.sp, color: brand.primaryColor),
              Gap(6.w),
              Text(
                'Select Seat',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (seatPrice > 0)
                Text(
                  'Rs. ${seatPrice.toInt()}/seat',
                  style: tt.labelSmall?.copyWith(color: AppColors.gray600),
                ),
            ],
          ),
          Gap(8.h),
          for (int r = 0; r < rows; r++)
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(columns, (c) {
                  final idx = r * columns + c;
                  if (idx >= seatMatrix.length) return SizedBox(width: 48.w);
                  final state = seatMatrix[idx];
                  return GestureDetector(
                    onTap: state != 1 && onSeatTap != null
                        ? () => onSeatTap!(idx)
                        : null,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: state == 2
                            ? brand.primaryColor
                            : state == 1
                            ? AppColors.gray300
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: state == 2
                              ? brand.primaryColor
                              : state == 1
                              ? AppColors.gray300
                              : AppColors.success.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: state == 2
                                ? Colors.white
                                : state == 1
                                ? AppColors.gray500
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          Gap(6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend('Available', AppColors.success, tt),
              Gap(12.w),
              _legend('Booked', AppColors.gray400, tt),
              Gap(12.w),
              _legend('Selected', brand.primaryColor, tt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color, TextTheme tt) => Row(
    children: [
      Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(3.r),
          border: Border.all(color: color),
        ),
      ),
      Gap(4.w),
      Text(label, style: tt.labelSmall?.copyWith(color: AppColors.gray600)),
    ],
  );
}
