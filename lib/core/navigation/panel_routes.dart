// Panel Route Matrix — Type-safe panel enumeration + route isolation
//
// Maps each of the 6 NexaTrace panels to its backend route prefix, auth guard,
// and the complete set of API endpoints exposed by the 26-step backend.
//
// Architecture constraint: a user authenticated into one panel MUST NOT
// be able to navigate into another panel's routes.  This enum drives
// that isolation through strict prefix-matching in the GoRouter redirect
// and the Dio interceptor's token scoping.

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────
// Panel Enumeration
// ─────────────────────────────────────────────────────────────

/// The six distinct operational panels in the NexaTrace ecosystem.
/// Each maps to a backend route prefix and an isolated set of endpoints
/// as defined in `routes/panels/*.php`.
enum UserPanel {
  /// Super Admin — Modules 1, 2  (12 endpoints)
  /// Prefix: /api/v1/super-admin
  superAdmin,

  /// Factory Admin — Modules 3, 4, 5, 8  (17 endpoints)
  /// Prefix: /api/v1/factory
  factory,

  /// Marketplace (Reseller + Shopkeeper) — Modules 6, 7, 12  (19 endpoints)
  /// Prefix: /api/v1/marketplace
  marketplace,

  /// Truck Fleet (Goods Co + Truck Owner + Driver) — Modules 9, 10, 11  (1 endpoint)
  /// Prefix: /api/v1/truck-fleet
  truckFleet,

  /// Bus Fleet (Bus Admin + Owner + Driver) — Modules 13, 14, 15  (10 endpoints)
  /// Prefix: /api/v1/bus-fleet
  busFleet,

  /// Customer Super-App (universal) — Modules 8, 25  (4 endpoints)
  /// Prefix: /api/v1/consumer  (backend contract retained)
  customer;

  /// The backend API prefix for this panel (no trailing slash).
  String get apiPrefix {
    switch (this) {
      case UserPanel.superAdmin:
        return '/api/v1/super-admin';
      case UserPanel.factory:
        return '/api/v1/factory';
      case UserPanel.marketplace:
        return '/api/v1/marketplace';
      case UserPanel.truckFleet:
        return '/api/v1/truck-fleet';
      case UserPanel.busFleet:
        return '/api/v1/bus-fleet';
      case UserPanel.customer:
        return '/api/v1/consumer';
    }
  }

  /// The Flutter route prefix used by GoRouter for this panel.
  String get routePrefix {
    switch (this) {
      case UserPanel.superAdmin:
        return '/super-admin';
      case UserPanel.factory:
        return '/factory';
      case UserPanel.marketplace:
        return '/marketplace';
      case UserPanel.truckFleet:
        return '/truck-fleet';
      case UserPanel.busFleet:
        return '/bus-fleet';
      case UserPanel.customer:
        return '/customer';
    }
  }

  /// Human-readable label for UI display.
  String get label {
    switch (this) {
      case UserPanel.superAdmin:
        return 'Super Admin';
      case UserPanel.factory:
        return 'Factory';
      case UserPanel.marketplace:
        return 'Marketplace';
      case UserPanel.truckFleet:
        return 'Truck Fleet';
      case UserPanel.busFleet:
        return 'Bus Fleet';
      case UserPanel.customer:
        return 'Customer';
    }
  }

  /// Token storage key used by flutter_secure_storage for this panel.
  /// Each panel gets its own key to prevent cross-contamination when
  /// multiple fleet apps share the same origin (e.g. on web).
  String get tokenStorageKey {
    switch (this) {
      case UserPanel.superAdmin:
        return 'super_admin_auth_token';
      case UserPanel.factory:
        return 'factory_auth_token';
      case UserPanel.marketplace:
        return 'marketplace_auth_token';
      case UserPanel.truckFleet:
        return 'truck_fleet_auth_token';
      case UserPanel.busFleet:
        return 'bus_fleet_auth_token';
      case UserPanel.customer:
        return 'customer_auth_token';
    }
  }

  /// The set of driver types allowed to use this panel.
  /// Used by EnsureDriverType middleware (Step 19) for 3-way isolation.
  Set<String> get allowedDriverTypes {
    switch (this) {
      case UserPanel.factory:
        return {'factory'};
      case UserPanel.truckFleet:
        return {'truck'};
      case UserPanel.busFleet:
        return {'bus'};
      default:
        return {}; // Not a driver panel
    }
  }

  /// Resolve a [UserPanel] from a raw backend string (e.g. from login response).
  static UserPanel fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'super_admin':
      case 'superadmin':
      case 'super-admin':
        return UserPanel.superAdmin;
      case 'factory':
        return UserPanel.factory;
      case 'marketplace':
      case 'reseller':
      case 'shopkeeper':
      case 'shop_keeper':
        return UserPanel.marketplace;
      case 'truck_fleet':
      case 'truckfleet':
      case 'truck-fleet':
      case 'truck':
        return UserPanel.truckFleet;
      case 'bus_fleet':
      case 'busfleet':
      case 'bus-fleet':
      case 'bus':
        return UserPanel.busFleet;
      case 'consumer':
      case 'customer':
        return UserPanel.customer;
      default:
        debugPrint(
          'PANEL_ROUTES: Unknown panel type "$value", defaulting to customer',
        );
        return UserPanel.customer;
    }
  }

  /// Detect which panel a request path belongs to.
  /// Returns null if the path doesn't match any panel prefix.
  static UserPanel? detectFromPath(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    for (final panel in UserPanel.values) {
      if (normalized.startsWith(panel.apiPrefix)) {
        return panel;
      }
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────
// Panel Route Configuration
// ─────────────────────────────────────────────────────────────

/// Static configuration constants for all panel routes.
/// Mirrors the backend's `routes/panels/*.php` files and `ApiConfig`.
class PanelRouteConfig {
  PanelRouteConfig._();

  /// Backend server base URL (Hetzner dedicated).
  static const String baseUrl = 'http://135.181.46.27';

  /// Full API base URL with version.
  static const String apiBaseUrl = '$baseUrl/api/v1';

  /// Timeout values (milliseconds).
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;

  /// Retry configuration for transient failures.
  static const int maxRetries = 3;
  static const Duration retryInterval = Duration(seconds: 2);

  // ── Complete endpoint registry per panel ──────────────────

  /// Super Admin panel (12 endpoints) — Modules 1, 2, 13, 26
  static const superAdminEndpoints = <String>[
    '/api/v1/super-admin/financial/vouchers/pending',
    '/api/v1/super-admin/financial/vouchers/settle',
    '/api/v1/super-admin/financial/withdrawals/pending',
    '/api/v1/super-admin/financial/withdrawals/process',
    '/api/v1/super-admin/financial/settlements/history',
    '/api/v1/super-admin/security/infractions',
    '/api/v1/super-admin/security/audit-ledger',
    '/api/v1/admin/notifications/blast',
    '/api/v1/admin/notifications/logs',
    '/api/v1/admin/notifications/stats',
    '/api/v1/analytics/dashboard',
    '/api/v1/analytics/charts',
    '/api/v1/analytics/health',
    '/api/v1/analytics/summary',
  ];

  /// Factory panel (17 endpoints) — Modules 3, 4, 5, 8, 15, 17, 22, 23
  static const factoryEndpoints = <String>[
    '/api/v1/factory/production/batches',
    '/api/v1/factory/production/generate-serials',
    '/api/v1/factory/production/seal',
    '/api/v1/factory/production/release',
    '/api/v1/factory/production/verify-serial',
    '/api/v1/factory/dispatch/create',
    '/api/v1/factory/dispatch/handshake',
    '/api/v1/factory/dispatch/complete-transfer',
    '/api/v1/factory/dispute/nfc-checkin',
    '/api/v1/factory/dispute/photo-evidence',
    '/api/v1/factory/codes/bulk',
    '/api/v1/factory/driver/handshake/arrived',
    '/api/v1/factory/driver/handshake',
  ];

  /// Marketplace panel (19 endpoints) — Modules 6, 7, 12, 18, 20, 21, 23, 24
  static const marketplaceEndpoints = <String>[
    '/api/v1/marketplace/catalog/search',
    '/api/v1/marketplace/catalog/facets',
    '/api/v1/marketplace/catalog',
    '/api/v1/marketplace/storefronts',
    '/api/v1/marketplace/pools',
    '/api/v1/marketplace/shop/cash-out',
    '/api/v1/marketplace/reseller/dashboard',
    '/api/v1/marketplace/matrix/validate-territory',
    '/api/v1/marketplace/matrix/challenge-otp',
    '/api/v1/marketplace/matrix/verify-otp',
    '/api/v1/marketplace/matrix/enforce-msrp',
    '/api/v1/marketplace/retail/dispatch',
    '/api/v1/marketplace/retail/stock-in',
    '/api/v1/marketplace/subscription/validate-listing',
    '/api/v1/marketplace/subscription/otp-gate',
    '/api/v1/marketplace/subscription/tier',
    '/api/v1/marketplace/claims/submit',
    '/api/v1/marketplace/claims/approve',
    '/api/v1/marketplace/claims/reject',
    '/api/v1/marketplace/consumer/verify',
  ];

  /// Truck Fleet panel (1 endpoint) — Modules 9, 10, 11
  static const truckFleetEndpoints = <String>[
    '/api/v1/truck-fleet/retail/verify-pickup',
    '/api/v1/freight/loads',
    '/api/v1/freight/stats',
  ];

  /// Bus Fleet panel (10+ endpoints) — Modules 13, 14, 15, 16
  static const busFleetEndpoints = <String>[
    '/api/v1/bus-fleet/trips',
    '/api/v1/bus-fleet/trips/active',
    '/api/v1/bus-fleet/driver/start-trip',
    '/api/v1/bus-fleet/driver/update-location',
    '/api/v1/bus-fleet/driver/complete-trip',
    '/api/v1/bus-fleet/owners/layouts',
    '/api/v1/bus-fleet/qr/register',
    '/api/v1/bus-fleet/qr/scan',
    '/api/v1/bus-fleet/bookings',
    '/api/v1/bus-fleet/vouchers/create',
    // Storekeeper Inventory (Module 16)
    '/api/v1/bus-fleet/storekeeper/dashboard',
    '/api/v1/bus-fleet/storekeeper/categories',
    '/api/v1/bus-fleet/storekeeper/items',
    '/api/v1/bus-fleet/storekeeper/issuances',
    '/api/v1/bus-fleet/storekeeper/reconciliations',
    // Storekeeper HR Management
    '/api/v1/bus-fleet/storekeepers',
    // Storekeeper Reports
    '/api/v1/bus-fleet/storekeeper/audit-trail',
    '/api/v1/bus-fleet/storekeeper/settlement-report',
  ];

  /// Customer panel (4 endpoints) — Modules 8, 25
  static const customerEndpoints = <String>[
    '/api/v1/consumer/transit/search',
    '/api/v1/consumer/transit/seat-grid',
    '/api/v1/consumer/fleet/auction',
    '/api/v1/consumer/chat/send',
    '/api/v1/consumer/verify',
    '/api/v1/user/notifications/preferences',
    '/api/v1/sync/submit',
    '/api/v1/sync/status',
  ];

  /// Returns the list of endpoint prefixes for a given panel.
  static List<String> endpointsFor(UserPanel panel) {
    switch (panel) {
      case UserPanel.superAdmin:
        return superAdminEndpoints;
      case UserPanel.factory:
        return factoryEndpoints;
      case UserPanel.marketplace:
        return marketplaceEndpoints;
      case UserPanel.truckFleet:
        return truckFleetEndpoints;
      case UserPanel.busFleet:
        return busFleetEndpoints;
      case UserPanel.customer:
        return customerEndpoints;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Panel Auth State
// ─────────────────────────────────────────────────────────────

/// Immutable value object representing the current user's panel session.
/// Used to drive GoRouter redirect guards and Dio interceptor token scoping.
class PanelAuthState {
  /// The panel the user is currently authenticated into.
  final UserPanel panel;

  /// Whether the user is currently authenticated.
  final bool isAuthenticated;

  /// The user's ID within this panel.
  final String? userId;

  /// The stored auth token.
  final String? token;

  /// Additional metadata (factory ID, company ID, driver type, etc.).
  final Map<String, dynamic> metadata;

  const PanelAuthState({
    required this.panel,
    this.isAuthenticated = false,
    this.userId,
    this.token,
    this.metadata = const {},
  });

  /// Unauthenticated state for a given panel.
  factory PanelAuthState.unauthenticated(UserPanel panel) =>
      PanelAuthState(panel: panel, isAuthenticated: false);

  /// Copy this state with new values.
  PanelAuthState copyWith({
    UserPanel? panel,
    bool? isAuthenticated,
    String? userId,
    String? token,
    Map<String, dynamic>? metadata,
  }) {
    return PanelAuthState(
      panel: panel ?? this.panel,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Whether the user's driver type matches what this panel requires.
  bool get isDriverTypeValid {
    final allowed = panel.allowedDriverTypes;
    if (allowed.isEmpty) return true; // Not a driver panel — no restriction.
    final driverType = metadata['driver_type']?.toString().toLowerCase();
    if (driverType == null) return false;
    return allowed.contains(driverType);
  }

  @override
  String toString() =>
      'PanelAuthState(panel: ${panel.label}, authenticated: $isAuthenticated, '
      'userId: $userId, driverTypeValid: $isDriverTypeValid)';
}
