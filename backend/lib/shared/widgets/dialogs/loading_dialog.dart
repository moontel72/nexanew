// Loading Dialog Widget for NexaTrace System
// This file contains the loading dialog widget used throughout the application

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class LoadingDialog extends StatelessWidget {
  final String? message;
  final bool dismissible;
  final Color? backgroundColor;
  final Color? progressColor;
  final double progressSize;

  const LoadingDialog({
    super.key,
    this.message,
    this.dismissible = false,
    this.backgroundColor,
    this.progressColor,
    this.progressSize = 40.0,
  });

  static Future<void> show({
    required BuildContext context,
    String? message,
    bool dismissible = false,
    Color? backgroundColor,
    Color? progressColor,
    double progressSize = 40.0,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => LoadingDialog(
        message: message,
        dismissible: dismissible,
        backgroundColor: backgroundColor,
        progressColor: progressColor,
        progressSize: progressSize,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Dialog(
        backgroundColor: backgroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: progressSize,
                height: progressSize,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? AppColors.primary,
                  ),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16.0),
                Text(
                  message!,
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? progressColor;
  final double progressSize;

  const LoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor,
    this.progressColor,
    this.progressSize = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: progressSize,
                    height: progressSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 4.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor ?? AppColors.primary,
                      ),
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16.0),
                    Text(
                      message!,
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Loading dialog with custom content
class CustomLoadingDialog extends StatelessWidget {
  final Widget? customContent;
  final String? title;
  final String? message;
  final bool showProgress;
  final Color? progressColor;
  final double progressSize;
  final bool dismissible;

  const CustomLoadingDialog({
    super.key,
    this.customContent,
    this.title,
    this.message,
    this.showProgress = true,
    this.progressColor,
    this.progressSize = 40.0,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: TextStyles.heading6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
              ],
              if (customContent != null)
                customContent!
              else ...[
                if (showProgress)
                  SizedBox(
                    width: progressSize,
                    height: progressSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor ?? AppColors.primary,
                      ),
                    ),
                  ),
                if (message != null) ...[
                  if (showProgress) const SizedBox(height: 16.0),
                  Text(
                    message!,
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Loading dialog with progress percentage
class ProgressDialog extends StatefulWidget {
  final String title;
  final String? message;
  final double progress;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showPercentage;
  final bool dismissible;

  const ProgressDialog({
    super.key,
    required this.title,
    this.message,
    required this.progress,
    this.progressColor,
    this.backgroundColor,
    this.showPercentage = true,
    this.dismissible = false,
  });

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.dismissible,
      child: Dialog(
        backgroundColor: widget.backgroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyles.heading6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.message != null) ...[
                const SizedBox(height: 8.0),
                Text(
                  widget.message!,
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24.0),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80.0,
                    height: 80.0,
                    child: CircularProgressIndicator(
                      value: widget.progress,
                      strokeWidth: 8.0,
                      backgroundColor: AppColors.gray200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.progressColor ?? AppColors.primary,
                      ),
                    ),
                  ),
                  if (widget.showPercentage)
                    Text(
                      '${(widget.progress * 100).toInt()}%',
                      style: TextStyles.heading6.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Loading dialog with indeterminate progress
class IndeterminateProgressDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool dismissible;

  const IndeterminateProgressDialog({
    super.key,
    required this.title,
    this.message,
    this.progressColor,
    this.backgroundColor,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Dialog(
        backgroundColor: backgroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyles.heading6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 8.0),
                Text(
                  message!,
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24.0),
              SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  strokeWidth: 4.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Loading dialog with success/error state
class StatusDialog extends StatelessWidget {
  final String title;
  final String message;
  final DialogStatus status;
  final VoidCallback? onDismiss;
  final bool autoDismiss;
  final Duration dismissDuration;

  const StatusDialog({
    super.key,
    required this.title,
    required this.message,
    required this.status,
    this.onDismiss,
    this.autoDismiss = true,
    this.dismissDuration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    if (autoDismiss) {
      final navigator = Navigator.of(context);
      Future.delayed(dismissDuration, () {
        if (navigator.canPop()) {
          navigator.pop();
          onDismiss?.call();
        }
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, size: 60.0, color: status.color),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: TextStyles.heading6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              message,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!autoDismiss) ...[
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum DialogStatus {
  success,
  error,
  warning,
  info;

  IconData get icon {
    switch (this) {
      case DialogStatus.success:
        return Icons.check_circle;
      case DialogStatus.error:
        return Icons.error;
      case DialogStatus.warning:
        return Icons.warning;
      case DialogStatus.info:
        return Icons.info;
    }
  }

  Color get color {
    switch (this) {
      case DialogStatus.success:
        return AppColors.success;
      case DialogStatus.error:
        return AppColors.error;
      case DialogStatus.warning:
        return AppColors.warning;
      case DialogStatus.info:
        return AppColors.info;
    }
  }
}
