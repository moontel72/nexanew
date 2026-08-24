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
// canonical Trace Odd badge (`assets/logo/traceodd_logo.svg`) is used.

import 'package:flutter/material.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/traceodd_brand_tokens.dart';

/// Immutable brand profile for a single tenant context.
class BrandProfile {
  /// Displayed enterprise / workspace name.
  final String enterpriseTitle;

  /// Subtitle shown beneath the logo (e.g. "Factory Admin Portal").
  final String workspaceBanner;

  /// Path to the logo asset (canonical: `assets/logo/traceodd_logo.svg`).
  /// Falls back to the panel's fallbackIcon if null / missing.
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

  // ── Trace Odd brand palette (master identity colors) ─────
  // All values come from TraceOddBrandTokens — the single source of truth
  // for the brand (badge gold + cream). Never hardcode hex here.
  static const Color _traceOddPrimary = TraceOddBrandTokens.gold;
  static const Color _traceOddSecondary = TraceOddBrandTokens.goldLight;

  // ── Default Trace Odd brand (fallback for all panels) ─────

  static const BrandProfile _nexaTraceDefault = BrandProfile(
    enterpriseTitle: 'Trace Odd',
    workspaceBanner: 'Enterprise Authentication Platform',
    logoAssetPath: TraceOddBrandTokens.logoAsset,
    fallbackIcon: Icons.verified_user,
    primaryColor: _traceOddPrimary,
    secondaryColor: _traceOddSecondary,
  );

  // ── Panel-specific brand profiles ─────────────────────────

  /// Super Admin panel — always uses Trace Odd master branding.
  static const BrandProfile _superAdminBrand = BrandProfile(
    enterpriseTitle: 'Trace Odd',
    workspaceBanner: 'Super Admin Control Panel',
    logoAssetPath: TraceOddBrandTokens.logoAsset,
    fallbackIcon: Icons.admin_panel_settings,
    primaryColor: _traceOddPrimary,
    secondaryColor: _traceOddSecondary,
  );

  /// Factory Admin panel — third-party factory brand.
  /// Title, logo, and color are resolved dynamically from the factory's
  /// registered company profile.  Falls back to Trace Odd accent.
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

  /// Reseller / Marketplace panel — Trace Odd Marketplace master brand.
  static const BrandProfile _resellerBrand = BrandProfile(
    enterpriseTitle: 'Trace Odd',
    workspaceBanner: 'B2B Marketplace & Reseller Portal',
    logoAssetPath: TraceOddBrandTokens.logoAsset,
    fallbackIcon: Icons.storefront,
    primaryColor: _traceOddPrimary,
    secondaryColor: _traceOddSecondary,
  );

  /// Driver Mobile Portal — inherits factory context brand.
  static const BrandProfile _driverBrand = BrandProfile(
    enterpriseTitle: 'Driver Portal',
    workspaceBanner: 'Delivery & Dispatch Terminal',
    logoAssetPath: null, // Inherited from factory context
    fallbackIcon: Icons.local_shipping,
    primaryColor: const Color(0xFF0D9488), // Industrial Teal
  );

  /// Customer Super-App — always Trace Odd master brand.
  static const BrandProfile _customerBrand = BrandProfile(
    enterpriseTitle: 'Trace Odd',
    workspaceBanner: 'Product Authentication & Transit',
    logoAssetPath: TraceOddBrandTokens.logoAsset,
    fallbackIcon: Icons.qr_code_scanner,
    primaryColor: _traceOddPrimary,
    secondaryColor: _traceOddSecondary,
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

  /// Returns the default Trace Odd brand (used when no panel context exists).
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
