// Primary Button Widget for NexaTrace System
// This file contains the primary button widget used throughout the application

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width = double.infinity,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.white,
          disabledBackgroundColor: AppColors.gray300,
          disabledForegroundColor: AppColors.gray500,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppColors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyles.buttonMedium.copyWith(
                      color: textColor ?? AppColors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Primary Button with loading state
class PrimaryLoadingButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;
  final bool isEnabled;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double borderRadius;

  const PrimaryLoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.width = double.infinity,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.borderRadius = 8,
  });

  @override
  State<PrimaryLoadingButton> createState() => _PrimaryLoadingButtonState();
}

class _PrimaryLoadingButtonState extends State<PrimaryLoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading || !widget.isEnabled) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed();
    } catch (e) {
      // Error handling is done by the caller
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: widget.text,
      onPressed: _handlePress,
      isLoading: _isLoading,
      isEnabled: widget.isEnabled && !_isLoading,
      width: widget.width,
      height: widget.height,
      backgroundColor: widget.backgroundColor,
      textColor: widget.textColor,
      icon: widget.icon,
      borderRadius: widget.borderRadius,
    );
  }
}

// Primary Icon Button
class PrimaryIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  const PrimaryIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    iconColor ?? AppColors.white,
                  ),
                ),
              )
            : Icon(icon, color: iconColor ?? AppColors.white, size: 24),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor: AppColors.gray300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        tooltip: tooltip,
      ),
    );
  }
}

// Primary Floating Action Button
class PrimaryFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  const PrimaryFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      backgroundColor: backgroundColor ?? AppColors.primary,
      disabledElevation: 0,
      tooltip: tooltip,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  iconColor ?? AppColors.white,
                ),
              ),
            )
          : Icon(icon, color: iconColor ?? AppColors.white),
    );
  }
}
