import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/factory/store_keeper/domain/entities/scan_record.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';

class HierarchyTreeView extends StatelessWidget {
  final HierarchyNode node;
  const HierarchyTreeView({super.key, required this.node});
  @override
  Widget build(BuildContext context) => _buildNode(node, 0);
  Widget _buildNode(HierarchyNode node, int depth) {
    final colors = _colorForType(node.codeType);
    final icon = _iconForType(node.codeType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 20.w),
          child: Card(
            elevation: depth == 0 ? 3 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: colors.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(icon, color: colors, size: 18.w),
                  ),
                  Gap(12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.label ?? node.code,
                        style: TextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        node.codeType.toUpperCase(),
                        style: TextStyles.caption.copyWith(
                          color: colors,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (node.metadata != null &&
                          node.metadata!.containsKey('quantity'))
                        Text(
                          'Qty: ${node.metadata!['quantity']}',
                          style: TextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (node.children.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: (depth + 1) * 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 2,
                  height: 12.h,
                  color: AppColors.gray300,
                  margin: EdgeInsets.only(left: 27.w),
                ),
                ...node.children.map(
                  (child) => Row(
                    children: [
                      Container(
                        width: 20.w,
                        height: 2,
                        color: AppColors.gray300,
                      ),
                      Expanded(child: _buildNode(child, depth + 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'bundle':
        return AppColors.primary;
      case 'carton':
        return AppColors.accent;
      case 'packet':
        return AppColors.secondary;
      case 'unit':
        return AppColors.secondaryDark;
      default:
        return AppColors.gray500;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'bundle':
        return Icons.inventory_2;
      case 'carton':
        return Icons.inventory;
      case 'packet':
        return Icons.archive;
      case 'unit':
        return Icons.circle;
      default:
        return Icons.help_outline;
    }
  }
}
