import 'package:flutter/material.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

/// Empty state widget for displaying when no data is available
class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;
  final Widget? actionButton;
  final bool showIcon;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.iconSize = 64,
    this.actionButton,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showIcon)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (iconColor ?? theme.primaryColor).withValues(alpha: 0.1),
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? theme.primaryColor,
                ),
              ),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-configured empty states for common scenarios
class EmptyStates {
  static Widget noCodes({
    String? title,
    String? description,
    VoidCallback? onGeneratePressed,
  }) {
    return EmptyState(
      title: title ?? 'No Codes Found',
      description: description ??
          'Start by generating your first batch of codes to track your products.',
      icon: Icons.qr_code_scanner_outlined,
      iconColor: AppColors.primary,
      actionButton: onGeneratePressed != null
          ? ElevatedButton.icon(
              onPressed: onGeneratePressed,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Generate Codes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            )
          : null,
    );
  }

  static Widget noProducts({
    String? title,
    String? description,
    VoidCallback? onAddPressed,
  }) {
    return EmptyState(
      title: title ?? 'No Products Found',
      description: description ??
          'Add your first product to start linking codes and tracking inventory.',
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.secondary,
      actionButton: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            )
          : null,
    );
  }

  static Widget noSearchResults({
    String? title,
    String? description,
  }) {
    return EmptyState(
      title: title ?? 'No Results Found',
      description: description ??
          'Try adjusting your search terms or filters to find what you\'re looking for.',
      icon: Icons.search_off_outlined,
      iconColor: AppColors.grey,
    );
  }

  static Widget noConnection({
    String? title,
    String? description,
    VoidCallback? onRetryPressed,
  }) {
    return EmptyState(
      title: title ?? 'No Internet Connection',
      description: description ??
          'Please check your connection and try again to access your data.',
      icon: Icons.wifi_off_outlined,
      iconColor: AppColors.warning,
      actionButton: onRetryPressed != null
          ? OutlinedButton.icon(
              onPressed: onRetryPressed,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            )
          : null,
    );
  }

  static Widget loading({
    String? title,
    String? description,
  }) {
    return EmptyState(
      title: title ?? 'Loading...',
      description: description ?? 'Please wait while we fetch your data.',
      icon: Icons.hourglass_empty_outlined,
      iconColor: AppColors.info,
      showIcon: false,
    );
  }
}
