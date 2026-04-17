// Icon Button Widget for NexaTrace System
// This file contains the IconButton widget used throughout the application

import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class IconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const IconButton({
    super.key,
    required this.icon,
    this.size = 24,
    this.color = AppColors.white,
    this.backgroundColor = AppColors.primary,
    this.onPressed,
    this.isDisabled = false,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDisabled ? AppColors.gray300 : backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            icon,
            size: size,
            color: isDisabled ? AppColors.gray500 : color,
          ),
        ),
      ),
    );
  }
}

class IconButtonWithText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double iconSize;
  final double textSize;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double spacing;

  const IconButtonWithText({
    super.key,
    required this.icon,
    required this.text,
    this.iconSize = 20,
    this.textSize = 14,
    this.iconColor = AppColors.white,
    this.textColor = AppColors.white,
    this.backgroundColor = AppColors.primary,
    this.onPressed,
    this.isDisabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = 8,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDisabled ? AppColors.gray300 : backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: isDisabled ? AppColors.gray500 : iconColor,
              ),
              SizedBox(width: spacing),
              Text(
                text,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                  color: isDisabled ? AppColors.gray500 : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final double elevation;

  const FloatingIconButton({
    super.key,
    required this.icon,
    this.size = 56,
    this.color = AppColors.white,
    this.backgroundColor = AppColors.primary,
    this.onPressed,
    this.isDisabled = false,
    this.elevation = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDisabled ? AppColors.gray300 : backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: elevation,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: Icon(
              icon,
              size: size * 0.5,
              color: isDisabled ? AppColors.gray500 : color,
            ),
          ),
        ),
      ),
    );
  }
}

class IconToggleButton extends StatefulWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final double size;
  final Color color;
  final Color selectedColor;
  final Color backgroundColor;
  final Color selectedBackgroundColor;
  final ValueChanged<bool>? onChanged;
  final bool initialValue;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const IconToggleButton({
    super.key,
    required this.icon,
    this.selectedIcon,
    this.size = 24,
    this.color = AppColors.gray600,
    this.selectedColor = AppColors.primary,
    this.backgroundColor = Colors.transparent,
    this.selectedBackgroundColor = const Color(0x1A6A5AE0),
    this.onChanged,
    this.initialValue = false,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 8,
  });

  @override
  State<IconToggleButton> createState() => _IconToggleButtonState();
}

class _IconToggleButtonState extends State<IconToggleButton> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          _isSelected ? widget.selectedBackgroundColor : widget.backgroundColor,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: InkWell(
        onTap: () {
          setState(() {
            _isSelected = !_isSelected;
          });
          widget.onChanged?.call(_isSelected);
        },
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _isSelected ? widget.selectedColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Icon(
            _isSelected ? (widget.selectedIcon ?? widget.icon) : widget.icon,
            size: widget.size,
            color: _isSelected ? widget.selectedColor : widget.color,
          ),
        ),
      ),
    );
  }
}

class IconButtonWithBadge extends StatelessWidget {
  final IconData icon;
  final String badgeText;
  final double size;
  final Color color;
  final Color backgroundColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const IconButtonWithBadge({
    super.key,
    required this.icon,
    required this.badgeText,
    this.size = 24,
    this.color = AppColors.white,
    this.backgroundColor = AppColors.primary,
    this.badgeColor = AppColors.error,
    this.badgeTextColor = AppColors.white,
    this.onPressed,
    this.isDisabled = false,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: icon,
          size: size,
          color: color,
          backgroundColor: backgroundColor,
          onPressed: onPressed,
          isDisabled: isDisabled,
          padding: padding,
          borderRadius: borderRadius,
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeTextColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
