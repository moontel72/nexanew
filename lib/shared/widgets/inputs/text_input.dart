// TextInput Widget for NexaTrace System
// A reusable text input widget wrapping Flutter's TextFormField

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';

/// A reusable text input widget that wraps Flutter's [TextFormField].
///
/// This widget provides consistent styling across the NexaTrace application
/// with proper validation support and theme integration.
///
/// Example usage:
/// ```dart
/// TextInput(
///   label: 'Email',
///   hint: 'Enter your email',
///   controller: _emailController,
///   validator: TextInput.validateEmail,
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class TextInput extends StatelessWidget {
  /// The label text displayed above the input field.
  final String? label;

  /// The hint text displayed inside the input field when empty.
  final String? hint;

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// An optional method that validates the input.
  /// Returns an error string to display if the input is invalid, or null otherwise.
  final String? Function(String?)? validator;

  /// Whether to hide the text being edited (e.g., for passwords).
  final bool obscureText;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// Whether the text field is enabled.
  final bool enabled;

  /// An icon to show before the input text.
  final Widget? prefixIcon;

  /// An icon to show after the input text.
  final Widget? suffixIcon;

  /// The maximum number of lines for the text field.
  final int maxLines;

  /// Called when the text being edited changes.
  final ValueChanged<String>? onChanged;

  /// An object that can be used to manage keyboard focus.
  final FocusNode? focusNode;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Creates a [TextInput] widget.
  const TextInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
  });

  /// Validates that a field is not empty.
  ///
  /// [value] is the value to validate.
  /// [fieldName] is an optional field name to include in the error message.
  ///
  /// Returns an error message if validation fails, null otherwise.
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      final field = fieldName ?? 'This field';
      return '$field is required';
    }
    return null;
  }

  /// Validates that a value is a valid email address.
  ///
  /// [value] is the value to validate.
  ///
  /// Returns an error message if validation fails, null otherwise.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates that a value is a valid phone number.
  ///
  /// [value] is the value to validate.
  /// Accepts digits, spaces, hyphens, plus signs, and parentheses.
  /// Requires at least 10 digits.
  ///
  /// Returns an error message if validation fails, null otherwise.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final digits = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length < 10) {
      return 'Please enter a valid phone number (at least 10 digits)';
    }

    if (digits.length > 15) {
      return 'Phone number is too long';
    }

    return null;
  }

  /// Validates that a value meets a minimum length requirement.
  ///
  /// [value] is the value to validate.
  /// [minLength] is the minimum required length.
  ///
  /// Returns an error message if validation fails, null otherwise.
  static String? validateMinLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (value.length < minLength) {
      return 'Must be at least $minLength characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveFillColor = isDarkMode
        ? AppColors.gray800
        : AppColors.inputBackground;

    final effectiveLabelStyle = TextStyles.labelMedium.copyWith(
      color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
    );

    final effectiveHintStyle = TextStyles.bodySmall.copyWith(
      color: AppColors.gray500,
    );

    final effectiveTextStyle = TextStyles.bodyMedium.copyWith(
      color: enabled
          ? (isDarkMode ? AppColors.white : AppColors.textPrimary)
          : AppColors.textDisabled,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: effectiveLabelStyle),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          onChanged: onChanged,
          textInputAction: textInputAction,
          style: effectiveTextStyle,
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: effectiveHintStyle,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: effectiveFillColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.border, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.border, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.error, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.error, width: 2.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(
                color: AppColors.gray300,
                width: 1.0,
              ),
            ),
            errorStyle: TextStyles.caption.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}
