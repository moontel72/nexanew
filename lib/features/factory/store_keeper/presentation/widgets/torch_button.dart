import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class TorchButton extends StatelessWidget {
  final bool isTorchOn;
  final VoidCallback onToggle;
  final double size;
  const TorchButton({
    super.key,
    required this.isTorchOn,
    required this.onToggle,
    this.size = 56,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onToggle,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isTorchOn ? AppColors.accent : Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: isTorchOn
                ? AppColors.accent.withOpacity(0.5)
                : Colors.black.withOpacity(0.2),
            blurRadius: isTorchOn ? 16 : 8,
            spreadRadius: isTorchOn ? 2 : 0,
          ),
        ],
        border: Border.all(
          color: isTorchOn ? AppColors.accent : Colors.white30,
          width: 2,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isTorchOn ? Icons.flash_on : Icons.flash_off,
          key: ValueKey(isTorchOn),
          color: isTorchOn ? Colors.white : AppColors.accent,
          size: 28.w,
        ),
      ),
    ),
  );
}
