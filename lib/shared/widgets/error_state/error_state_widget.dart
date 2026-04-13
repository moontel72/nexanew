// Error State Widget for NexaTrace System
// Provides consistent error display across the application

import 'package:flutter/material.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onRetry;
  final String retryButtonText;
  final bool showRetryButton;
  final EdgeInsetsGeometry padding;

  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor = AppColors.error,
    this.onRetry,
    this.retryButtonText = 'Try Again',
    this.showRetryButton = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
  });

  factory ErrorState.networkError({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return ErrorState(
      title: 'Connection Error',
      message: customMessage ??
          'Unable to connect to the server. Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      iconColor: AppColors.warning,
      onRetry: onRetry,
    );
  }

  factory ErrorState.serverError({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return ErrorState(
      title: 'Server Error',
      message: customMessage ??
          'Something went wrong on our end. Please try again later.',
      icon: Icons.cloud_off,
      iconColor: AppColors.error,
      onRetry: onRetry,
    );
  }

  factory ErrorState.notFound({
    String? customTitle,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      title: customTitle ?? 'Not Found',
      message: customMessage ?? 'The requested resource could not be found.',
      icon: Icons.search_off,
      iconColor: AppColors.info,
      onRetry: onRetry,
    );
  }

  factory ErrorState.unauthorized({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return ErrorState(
      title: 'Access Denied',
      message: customMessage ??
          'You don\'t have permission to access this resource.',
      icon: Icons.lock_outline,
      iconColor: AppColors.warning,
      onRetry: onRetry,
    );
  }

  factory ErrorState.empty({
    String? customTitle,
    String? customMessage,
    VoidCallback? onRetry,
    String? retryButtonText,
  }) {
    return ErrorState(
      title: customTitle ?? 'No Data',
      message: customMessage ?? 'There\'s nothing to display here yet.',
      icon: Icons.inbox_outlined,
      iconColor: AppColors.info,
      onRetry: onRetry,
      retryButtonText: retryButtonText ?? 'Refresh',
    );
  }

  factory ErrorState.generic({
    required String title,
    required String message,
    VoidCallback? onRetry,
    IconData? icon,
    Color? iconColor,
  }) {
    return ErrorState(
      title: title,
      message: message,
      icon: icon ?? Icons.error_outline,
      iconColor: iconColor ?? AppColors.error,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
            ),

            const SizedBox(height: 24),

            // Error Title
            Text(
              title,
              style: TextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Error Message
            Text(
              message,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Retry Button (if provided)
            if (showRetryButton && onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  retryButtonText,
                  style: TextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),

            // Alternative action if no retry but still shows button
            if (showRetryButton && onRetry == null)
              Text(
                'Please contact support if the issue persists.',
                style: TextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

// Error State with Image (for more visual errors)
class ErrorStateWithImage extends StatelessWidget {
  final String title;
  final String message;
  final String imageAsset;
  final VoidCallback? onRetry;
  final String retryButtonText;
  final bool showRetryButton;
  final EdgeInsetsGeometry padding;

  const ErrorStateWithImage({
    super.key,
    required this.title,
    required this.message,
    required this.imageAsset,
    this.onRetry,
    this.retryButtonText = 'Try Again',
    this.showRetryButton = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
  });

  factory ErrorStateWithImage.networkError({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return ErrorStateWithImage(
      title: 'No Internet Connection',
      message: customMessage ??
          'Please check your internet connection and try again.',
      imageAsset: 'assets/images/errors/no_internet.png',
      onRetry: onRetry,
    );
  }

  factory ErrorStateWithImage.serverError({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return ErrorStateWithImage(
      title: 'Server Maintenance',
      message: customMessage ??
          'Our servers are currently undergoing maintenance. Please try again later.',
      imageAsset: 'assets/images/errors/server_down.png',
      onRetry: onRetry,
    );
  }

  factory ErrorStateWithImage.empty({
    String? customTitle,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWithImage(
      title: customTitle ?? 'Nothing Here',
      message: customMessage ?? 'Start by adding some data to see it here.',
      imageAsset: 'assets/images/errors/empty_state.png',
      onRetry: onRetry,
      retryButtonText: 'Add Data',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error Image
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.broken_image,
                      size: 60,
                      color: AppColors.textTertiary,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Error Title
            Text(
              title,
              style: TextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Error Message
            Text(
              message,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Retry Button (if provided)
            if (showRetryButton && onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  retryButtonText,
                  style: TextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Error State for List Views
class ListErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isFullScreen;

  const ListErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFullScreen) {
      return ErrorState.generic(
        title: 'Failed to Load',
        message: message,
        onRetry: onRetry,
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

// Error State with Custom Actions
class ErrorStateWithActions extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  const ErrorStateWithActions({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor = AppColors.error,
    required this.actions,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
            ),

            const SizedBox(height: 24),

            // Error Title
            Text(
              title,
              style: TextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Error Message
            Text(
              message,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Custom Actions
            if (actions.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: actions
                    .map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: action,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
