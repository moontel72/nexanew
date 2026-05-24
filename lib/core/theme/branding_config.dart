// Branding Configuration — Dynamic multi-tenant branding engine
//
// Injects logo paths, enterprise titles, and core primary color profiles
// based on the targeted route panel.  Eliminates the need for 5 discrete
// application entry blocks by providing a single functional injection point.
//
// Integration: call `BrandingConfig.forPanel(panel)` from any login screen
// or shell widget to receive the correct brand parameters.
//
// Asset fallback policy: if a panel-specific asset is missing, the
// base NexaTrace asset tree under `assets/images/` is used instead.

import 'package:flutter/material.dart';
import 'package:nexatrace_system/core/navigation/panel_routes.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

/// Immutable brand profile for a single tenant context.
class BrandProfile {
  /// Displayed enterprise / workspace name.
  final String enterpriseTitle;

  /// Subtitle shown beneath the logo (e.g. "Factory Admin Portal").
  final String workspaceBanner;

  /// Path to the logo asset in `assets/images/logos/`.
  /// Falls back to `assets/images/nexatrace_logo.png` if null / missing.
  final String? logoAssetPath;

  /// Icon shown when no logo asset is available.
  final IconData fallbackIcon;

  /// Primary brand color used for icon badge, buttons, and accents.
  final Color primaryColor;

  /// Secondary brand color for gradient backgrounds.
  final Color? secondaryColor;

  const BrandProfile({
    required this.enterpriseTitle,
    required this.workspaceBanner,
    this.logoAssetPath,
    required this.fallbackIcon,
    required this.primaryColor,
    this.secondaryColor,
  });
}

/// Static branding configuration controller.
///
/// Usage:
/// ```dart
/// final brand = BrandingConfig.forPanel(UserPanel.factory);
/// // brand.enterpriseTitle → "Acme Widgets" (from factory context)
/// // brand.primaryColor → Color(0xFF00CC66)
/// ```
class BrandingConfig {
  BrandingConfig._();

  // ── Default NexaTrace brand (fallback for all panels) ─────

  static const BrandProfile _nexaTraceDefault = BrandProfile(
    enterpriseTitle: 'NexaTrace',
    workspaceBanner: 'Enterprise Authentication Platform',
    logoAssetPath: 'assets/images/logos/nexatrace_logo.png',
    fallbackIcon: Icons.verified_user,
    primaryColor: AppColors.primary, // #0066CC
  );

  // ── Panel-specific brand profiles ─────────────────────────

  /// Super Admin panel — always uses NexaTrace branding.
  static const BrandProfile _superAdminBrand = BrandProfile(
    enterpriseTitle: 'NexaTrace',
    workspaceBanner: 'Super Admin Control Panel',
    logoAssetPath: 'assets/images/logos/nexatrace_logo.png',
    fallbackIcon: Icons.admin_panel_settings,
    primaryColor: AppColors.primary,
  );

  /// Factory Admin panel — third-party factory brand.
  /// Title, logo, and color are resolved dynamically from the factory's
  /// registered company profile.  Falls back to NexaTrace green.
  static const BrandProfile _factoryDefaultBrand = BrandProfile(
    enterpriseTitle: 'Factory Portal',
    workspaceBanner: 'Production & Serialization Dashboard',
    logoAssetPath: null, // Dynamically resolved from factory context
    fallbackIcon: Icons.factory,
    primaryColor: AppColors.secondary, // #00CC66
  );

  /// Store Keeper panel — inherits its parent factory's brand.
  static const BrandProfile _storeKeeperBrand = BrandProfile(
    enterpriseTitle: 'Store Keeper',
    workspaceBanner: 'Inventory & Dispatch Terminal',
    logoAssetPath: null, // Inherited from factory context
    fallbackIcon: Icons.inventory_2,
    primaryColor: AppColors.accent, // #FF9900
  );

  /// Reseller / Shopkeeper panel — NexaTrace Marketplace brand.
  static const BrandProfile _resellerBrand = BrandProfile(
    enterpriseTitle: 'NexaTrace',
    workspaceBanner: 'B2B Marketplace & Reseller Portal',
    logoAssetPath: 'assets/images/logos/nexatrace_logo.png',
    fallbackIcon: Icons.storefront,
    primaryColor: const Color(0xFF673AB7), // Deep Purple
  );

  /// Driver Mobile Portal — inherits factory context brand.
  static const BrandProfile _driverBrand = BrandProfile(
    enterpriseTitle: 'Driver Portal',
    workspaceBanner: 'Delivery & Dispatch Terminal',
    logoAssetPath: null, // Inherited from factory context
    fallbackIcon: Icons.local_shipping,
    primaryColor: const Color(0xFF0D9488), // Industrial Teal
  );

  /// Customer Super-App — always NexaTrace brand.
  static const BrandProfile _customerBrand = BrandProfile(
    enterpriseTitle: 'NexaTrace',
    workspaceBanner: 'Product Authentication & Transit',
    logoAssetPath: 'assets/images/logos/nexatrace_logo.png',
    fallbackIcon: Icons.qr_code_scanner,
    primaryColor: AppColors.primary,
  );

  // ── Public API ────────────────────────────────────────────

  /// Returns the brand profile for [panel].
  ///
  /// If [factoryName] is provided (Factory, Store Keeper, Driver panels),
  /// the enterprise title is customised accordingly.
  static BrandProfile forPanel(
    UserPanel panel, {
    String? factoryName,
    String? factoryLogoPath,
  }) {
    switch (panel) {
      case UserPanel.superAdmin:
        return _superAdminBrand;

      case UserPanel.factory:
        if (factoryName != null) {
          return BrandProfile(
            enterpriseTitle: factoryName,
            workspaceBanner: _factoryDefaultBrand.workspaceBanner,
            logoAssetPath: factoryLogoPath,
            fallbackIcon: _factoryDefaultBrand.fallbackIcon,
            primaryColor: _factoryDefaultBrand.primaryColor,
          );
        }
        return _factoryDefaultBrand;

      case UserPanel.marketplace:
        return _resellerBrand;

      case UserPanel.truckFleet:
        return _driverBrand;

      case UserPanel.busFleet:
        // Bus fleet drivers also inherit factory-like context.
        if (factoryName != null) {
          return BrandProfile(
            enterpriseTitle: factoryName,
            workspaceBanner: 'Bus Fleet Operations',
            logoAssetPath: factoryLogoPath,
            fallbackIcon: Icons.directions_bus,
            primaryColor: const Color(0xFF0D9488),
          );
        }
        return BrandProfile(
          enterpriseTitle: 'Bus Fleet',
          workspaceBanner: 'Passenger Transit Operations',
          logoAssetPath: null,
          fallbackIcon: Icons.directions_bus,
          primaryColor: const Color(0xFF0D9488),
        );

      case UserPanel.customer:
        return _customerBrand;
    }
  }

  /// Returns the default NexaTrace brand (used when no panel context exists).
  static BrandProfile get defaultBrand => _nexaTraceDefault;

  /// Convenience: resolve a brand profile from a route path string.
  /// Used by the auth template when the panel is not yet fully resolved.
  static BrandProfile fromRoute(String routePath) {
    final panel = UserPanel.detectFromPath(routePath);
    if (panel != null) return forPanel(panel);

    // Heuristic fallback for Flutter route prefixes:
    if (routePath.contains('/factory/store-keeper')) {
      return _storeKeeperBrand;
    }
    if (routePath.contains('/factory')) {
      return _factoryDefaultBrand;
    }
    if (routePath.contains('/driver')) {
      return _driverBrand;
    }
    if (routePath.contains('/reseller') || routePath.contains('/marketplace')) {
      return _resellerBrand;
    }
    return _nexaTraceDefault;
  }
}
