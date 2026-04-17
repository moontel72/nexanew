// App Decorations for NexaTrace System
// This file defines common decorations (borders, shadows, gradients) for the application

import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppDecorations {
  // Input borders
  static InputBorder get inputBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray300, width: 1),
      );

  static InputBorder get inputBorderFocused => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      );

  static InputBorder get inputBorderError => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      );

  static InputBorder get inputBorderErrorFocused => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      );

  static InputBorder get inputBorderSuccess => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.success, width: 1),
      );

  static InputBorder get inputBorderDisabled => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: AppColors.gray300.withOpacity(0.5), width: 1),
      );

  // Card decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get primaryGradientCard => BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      );

  static BoxDecoration get secondaryGradientCard => BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.secondaryDark],
        ),
      );

  static BoxDecoration get accentGradientCard => BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, AppColors.accentDark],
        ),
      );

  static BoxDecoration get surfaceDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      );

  // Dark mode card decorations
  static BoxDecoration get darkCardDecoration => BoxDecoration(
        color: AppColors.gray800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get darkSurfaceDecoration => BoxDecoration(
        color: AppColors.gray800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray700),
      );

  // Button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 48),
        maximumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyles.buttonLarge,
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.3),
      );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 48),
        maximumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyles.buttonLarge,
        elevation: 2,
        shadowColor: AppColors.secondary.withOpacity(0.3),
      );

  static ButtonStyle get accentButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 48),
        maximumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyles.buttonLarge,
        elevation: 2,
        shadowColor: AppColors.accent.withOpacity(0.3),
      );

  static ButtonStyle get outlineButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        minimumSize: const Size(double.infinity, 48),
        maximumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyles.buttonLarge,
      );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyles.buttonMedium,
      );

  static ButtonStyle get iconButtonStyle => IconButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.transparent,
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );

  static ButtonStyle get dangerButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyles.buttonLarge,
      );

  // Badge decorations
  static BoxDecoration get successBadge => BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      );

  static BoxDecoration get warningBadge => BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      );

  static BoxDecoration get errorBadge => BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error),
      );

  static BoxDecoration get infoBadge => BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info),
      );

  // Chip decorations
  static BoxDecoration get chipDecoration => BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(16),
      );

  static BoxDecoration get selectedChipDecoration => BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      );

  // Progress bar decorations
  static BoxDecoration get progressBarBackground => BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(4),
      );

  static BoxDecoration get progressBarForeground => BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      );

  // List tile decorations
  static BoxDecoration get listTileDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      );

  static BoxDecoration get selectedListTileDecoration => BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary),
      );

  // Avatar decorations
  static BoxDecoration get avatarDecoration => BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      );

  static BoxDecoration get avatarBorderDecoration => BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      );

  // Divider decorations
  static BoxDecoration get dividerDecoration => BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
            width: 1,
          ),
        ),
      );

  // Shadow decorations
  static List<BoxShadow> get smallShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get largeShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // Glass morphism effect
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Get decoration by status
  static BoxDecoration getStatusDecoration(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'active':
      case 'completed':
        return successBadge;
      case 'warning':
      case 'pending':
      case 'in_progress':
        return warningBadge;
      case 'error':
      case 'failed':
      case 'cancelled':
        return errorBadge;
      case 'info':
      case 'default':
      default:
        return infoBadge;
    }
  }

  // Get button style by type
  static ButtonStyle getButtonStyle(String type) {
    switch (type.toLowerCase()) {
      case 'primary':
        return primaryButtonStyle;
      case 'secondary':
        return secondaryButtonStyle;
      case 'accent':
        return accentButtonStyle;
      case 'outline':
        return outlineButtonStyle;
      case 'text':
        return textButtonStyle;
      case 'danger':
        return dangerButtonStyle;
      default:
        return primaryButtonStyle;
    }
  }
}
