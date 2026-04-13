// Success Dialog Widget for NexaTrace System
// This file contains the success dialog widget used throughout the application

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;
  final bool showCloseButton;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? buttonColor;
  final double iconSize;
  final double borderRadius;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
    this.showCloseButton = true,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.buttonColor,
    this.iconSize = 64,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor ?? AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button (optional)
            if (showCloseButton)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

            // Success icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.success).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.check_circle,
                size: iconSize * 0.6,
                color: iconColor ?? AppColors.success,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: TextStyles.heading5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Action button
            if (buttonText != null && onPressed != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor ?? AppColors.success,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    buttonText!,
                    style: TextStyles.buttonMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Success dialog with custom actions
class SuccessDialogWithActions extends StatelessWidget {
  final String title;
  final String message;
  final List<DialogAction> actions;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;

  const SuccessDialogWithActions({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
    this.icon,
    this.iconColor,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.success).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.check_circle,
                size: iconSize * 0.6,
                color: iconColor ?? AppColors.success,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: TextStyles.heading5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: actions.map((action) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: action.isPrimary
                        ? ElevatedButton(
                            onPressed: action.onPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  action.color ?? AppColors.success,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              action.text,
                              style: TextStyles.buttonMedium.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: action.onPressed,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: action.color ?? AppColors.success,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              action.text,
                              style: TextStyles.buttonMedium.copyWith(
                                color: action.color ?? AppColors.success,
                              ),
                            ),
                          ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog action model
class DialogAction {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color? color;

  const DialogAction({
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.color,
  });
}

// Success dialog with auto close
class AutoCloseSuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final Duration autoCloseDuration;
  final VoidCallback? onAutoClose;

  const AutoCloseSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.autoCloseDuration = const Duration(seconds: 3),
    this.onAutoClose,
  });

  @override
  State<AutoCloseSuccessDialog> createState() => _AutoCloseSuccessDialogState();
}

class _AutoCloseSuccessDialogState extends State<AutoCloseSuccessDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.autoCloseDuration, () {
      if (mounted) {
        Navigator.pop(context);
        widget.onAutoClose?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SuccessDialog(
      title: widget.title,
      message: widget.message,
      showCloseButton: false,
    );
  }
}

// Success dialog with progress indicator
class SuccessDialogWithProgress extends StatelessWidget {
  final String title;
  final String message;
  final String progressMessage;
  final double progress;
  final String? buttonText;
  final VoidCallback? onPressed;
  final bool showProgress;

  const SuccessDialogWithProgress({
    super.key,
    required this.title,
    required this.message,
    required this.progressMessage,
    this.progress = 0.0,
    this.buttonText,
    this.onPressed,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 40,
                color: AppColors.success,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: TextStyles.heading5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            if (showProgress) ...[
              const SizedBox(height: 24),

              // Progress message
              Text(
                progressMessage,
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.gray200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.success,
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],

            const SizedBox(height: 24),

            // Action button
            if (buttonText != null && onPressed != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    buttonText!,
                    style: TextStyles.buttonMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show success dialog
void showSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? buttonText,
  VoidCallback? onPressed,
  bool barrierDismissible = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => SuccessDialog(
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    ),
  );
}

// Helper function to show auto-close success dialog
void showAutoCloseSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  Duration autoCloseDuration = const Duration(seconds: 3),
  VoidCallback? onAutoClose,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AutoCloseSuccessDialog(
      title: title,
      message: message,
      autoCloseDuration: autoCloseDuration,
      onAutoClose: onAutoClose,
    ),
  );
}
