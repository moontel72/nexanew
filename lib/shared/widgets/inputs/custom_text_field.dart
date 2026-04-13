// Custom Text Field Widget for NexaTrace System
// This file contains the custom text field widget used throughout the application

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final bool showCounter;
  final bool showClearButton;
  final bool isRequired;
  final String? errorText;
  final bool showError;
  final bool autoValidate;
  final String? helperText;
  final TextStyle? helperStyle;
  final bool expands;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.focusNode,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius = 8.0,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 14.0,
    ),
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.showCounter = false,
    this.showClearButton = false,
    this.isRequired = false,
    this.errorText,
    this.showError = false,
    this.autoValidate = false,
    this.helperText,
    this.helperStyle,
    this.expands = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _showClearButton = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);

    _updateClearButtonVisibility();
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_handleTextChange);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChange);
    }

    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }

    _updateErrorState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    _updateErrorState();
  }

  void _handleTextChange() {
    _updateClearButtonVisibility();
    _updateErrorState();
    widget.onChanged?.call(_controller.text);
  }

  void _updateClearButtonVisibility() {
    setState(() {
      _showClearButton = widget.showClearButton &&
          _controller.text.isNotEmpty &&
          widget.enabled &&
          !widget.readOnly;
    });
  }

  void _updateErrorState() {
    if (widget.autoValidate && _controller.text.isNotEmpty) {
      final error = widget.validator?.call(_controller.text);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
    } else if (widget.showError && widget.errorText != null) {
      setState(() {
        _hasError = true;
        _errorText = widget.errorText;
      });
    } else {
      setState(() {
        _hasError = false;
        _errorText = null;
      });
    }
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  String? _validate(String? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }

    if (widget.validator != null) {
      return widget.validator!(value);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveFillColor =
        widget.fillColor ?? (isDarkMode ? AppColors.gray800 : AppColors.gray50);

    final effectiveBorderColor = _hasError
        ? (widget.errorBorderColor ?? AppColors.error)
        : (_isFocused
            ? (widget.focusedBorderColor ?? AppColors.primary)
            : (widget.borderColor ?? AppColors.gray300));

    final effectiveLabelStyle = widget.labelStyle ??
        TextStyles.labelMedium.copyWith(
          color: _hasError
              ? AppColors.error
              : (_isFocused ? AppColors.primary : AppColors.gray600),
        );

    final effectiveHintStyle = widget.hintStyle ??
        TextStyles.bodySmall.copyWith(color: AppColors.gray500);

    final effectiveTextStyle = widget.textStyle ??
        TextStyles.bodyMedium.copyWith(
          color: widget.enabled
              ? (isDarkMode ? AppColors.white : AppColors.gray900)
              : AppColors.gray500,
        );

    final effectiveErrorStyle = widget.errorStyle ??
        TextStyles.caption.copyWith(color: AppColors.error);

    final effectiveHelperStyle = widget.helperStyle ??
        TextStyles.caption.copyWith(color: AppColors.gray500);

    Widget? effectiveSuffixIcon = widget.suffixIcon;

    if (_showClearButton) {
      effectiveSuffixIcon = IconButton(
        icon: const Icon(Icons.clear, size: 20),
        onPressed: _clearText,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Row(
            children: [
              Text(widget.labelText!, style: effectiveLabelStyle),
              if (widget.isRequired)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    '*',
                    style: effectiveLabelStyle.copyWith(color: AppColors.error),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8.0),
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          validator: _validate,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction,
          style: effectiveTextStyle,
          expands: widget.expands,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: effectiveHintStyle,
            prefixIcon: widget.prefixIcon,
            suffixIcon: effectiveSuffixIcon,
            filled: true,
            fillColor: effectiveFillColor,
            contentPadding: widget.contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: effectiveBorderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: effectiveBorderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: _hasError
                    ? (widget.errorBorderColor ?? AppColors.error)
                    : (widget.focusedBorderColor ?? AppColors.primary),
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: widget.errorBorderColor ?? AppColors.error,
                width: 2.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: widget.errorBorderColor ?? AppColors.error,
                width: 2.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: AppColors.gray300, width: 1.0),
            ),
            counterText: widget.showCounter ? null : '',
            errorStyle: effectiveErrorStyle,
            helperText: widget.helperText,
            helperStyle: effectiveHelperStyle,
          ),
        ),
        if (_hasError && _errorText != null) ...[
          const SizedBox(height: 4.0),
          Text(
            _errorText!,
            style: effectiveErrorStyle,
          ),
        ],
      ],
    );
  }
}

// Specialized text field for email input
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final bool autoValidate;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const EmailTextField({
    super.key,
    this.controller,
    this.labelText = 'Email',
    this.hintText = 'Enter your email address',
    this.initialValue,
    this.enabled = true,
    this.autoValidate = false,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
  });

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      initialValue: initialValue,
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      autoValidate: autoValidate,
      validator: _validateEmail,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
      prefixIcon: const Icon(Icons.email_outlined),
    );
  }
}

// Specialized text field for password input
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool enabled;
  final bool autoValidate;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool showStrengthIndicator;

  const PasswordTextField({
    super.key,
    this.controller,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.enabled = true,
    this.autoValidate = false,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.showStrengthIndicator = false,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.controller,
          labelText: widget.labelText,
          hintText: widget.hintText,
          obscureText: _obscureText,
          enabled: widget.enabled,
          autoValidate: widget.autoValidate,
          validator: _validatePassword,
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: _toggleObscureText,
          ),
        ),
        if (widget.showStrengthIndicator && widget.controller != null) ...[
          const SizedBox(height: 8.0),
          // TODO: Add password strength indicator
        ],
      ],
    );
  }
}

// Specialized text field for phone number input
class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final bool autoValidate;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const PhoneTextField({
    super.key,
    this.controller,
    this.labelText = 'Phone Number',
    this.hintText = 'Enter your phone number',
    this.initialValue,
    this.enabled = true,
    this.autoValidate = false,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
  });

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]{10,15}$');
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');

    if (!phoneRegex.hasMatch(value) || digits.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      initialValue: initialValue,
      keyboardType: TextInputType.phone,
      enabled: enabled,
      autoValidate: autoValidate,
      validator: _validatePhone,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
      prefixIcon: const Icon(Icons.phone_outlined),
    );
  }
}

// Specialized text field for numeric input
class NumberTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final bool autoValidate;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final double? minValue;
  final double? maxValue;
  final bool allowDecimal;

  const NumberTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.enabled = true,
    this.autoValidate = false,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.minValue,
    this.maxValue,
    this.allowDecimal = true,
  });

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final number = allowDecimal ? double.tryParse(value) : int.tryParse(value);

    if (number == null) {
      return 'Please enter a valid number';
    }

    if (minValue != null && number < minValue!) {
      return 'Value must be at least $minValue';
    }

    if (maxValue != null && number > maxValue!) {
      return 'Value must be at most $maxValue';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: autoValidate ? _validateNumber : null,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
    );
  }
}
