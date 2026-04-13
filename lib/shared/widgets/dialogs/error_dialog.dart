// Error Dialog Widget for NexaTrace System
// This file contains the error dialog widget used throughout the application

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCancelButton;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onConfirm,
    this.onCancel,
    this.showCancelButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyles.heading6.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        if (showCancelButton && onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: Text(
              'Cancel',
              style: TextStyles.buttonMedium.copyWith(color: AppColors.gray600),
            ),
          ),
        ElevatedButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            buttonText!,
            style: TextStyles.buttonMedium.copyWith(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class NetworkErrorDialog extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const NetworkErrorDialog({super.key, this.onRetry, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Network Error',
      message: 'Please check your internet connection and try again.',
      buttonText: 'Retry',
      showCancelButton: true,
      onConfirm: onRetry,
      onCancel: onCancel ?? () => Navigator.of(context).pop(),
    );
  }
}

class ServerErrorDialog extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const ServerErrorDialog({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Server Error',
      message: errorMessage ??
          'Something went wrong on our end. Please try again later.',
      buttonText: 'Retry',
      showCancelButton: true,
      onConfirm: onRetry,
      onCancel: onCancel ?? () => Navigator.of(context).pop(),
    );
  }
}

class ValidationErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onConfirm;

  const ValidationErrorDialog(
      {super.key, required this.message, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Validation Error',
      message: message,
      buttonText: 'OK',
      onConfirm: onConfirm,
    );
  }
}

class PermissionErrorDialog extends StatelessWidget {
  final String permission;
  final VoidCallback? onSettings;
  final VoidCallback? onCancel;

  const PermissionErrorDialog({
    super.key,
    required this.permission,
    this.onSettings,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDialog(
      title: 'Permission Required',
      message: 'Please grant $permission permission to use this feature.',
      buttonText: 'Open Settings',
      showCancelButton: true,
      onConfirm: onSettings,
      onCancel: onCancel ?? () => Navigator.of(context).pop(),
    );
  }
}

class ConfirmationErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: AppColors.warning, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyles.heading6.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            cancelText,
            style: TextStyles.buttonMedium.copyWith(color: AppColors.gray600),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            confirmText,
            style: TextStyles.buttonMedium.copyWith(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class SessionExpiredDialog extends StatelessWidget {
  final VoidCallback onLogin;

  const SessionExpiredDialog({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.login, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Session Expired',
              style: TextStyles.heading6.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      content: Text(
        'Your session has expired. Please login again to continue.',
        style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        ElevatedButton(
          onPressed: onLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Login',
            style: TextStyles.buttonMedium.copyWith(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class CustomErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final List<Widget> actions;

  const CustomErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor = AppColors.error,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyles.heading6.copyWith(color: iconColor),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      actions: actions,
    );
  }
}
