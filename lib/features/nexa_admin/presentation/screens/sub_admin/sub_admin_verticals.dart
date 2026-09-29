// Canonical Sub-Admin vertical registry — single source of truth.
//
// The vertical code → label / description / icon / colour mapping was previously
// copied into three widgets (the provisioning form, the management list and the
// dashboard sidebar) and the copies had already drifted (e.g. `cricket_ops` was
// missing from one of them). Every screen that needs to render or label a
// vertical reads it from here instead, so a new vertical appears everywhere for
// free — the owner's requirement: MASTER-TASK-LIST.md §6 D3 ("make the
// Sub-Admin roles DYNAMIC, not hardcoded").
import 'package:flutter/material.dart';

/// One ecosystem vertical a sub-admin can be appointed to.
class SubAdminVertical {
  final String code;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const SubAdminVertical({
    required this.code,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class SubAdminVerticals {
  SubAdminVerticals._();

  /// Insertion order is the order the provisioning form lists them in:
  /// the four original Group-Incharge verticals, then cricket, then the
  /// C1 additions (factory), then the not-yet-built stubs.
  static const List<SubAdminVertical> all = [
    SubAdminVertical(
      code: 'bus_transit',
      label: 'Bus Transit Manager',
      description:
          'Public transport ecosystem: bus owners, routes, seat layouts, ticketing',
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF7C3AED),
    ),
    SubAdminVertical(
      code: 'goods_logistics',
      label: 'Goods & Logistics Manager',
      description:
          'Truck fleet, freight auctions, factory drivers, store keepers',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFFDB2777),
    ),
    SubAdminVertical(
      code: 'commercial_marketplace',
      label: 'Commercial Marketplace Manager',
      description:
          'B2B marketplace, anti-counterfeit, factories, resellers, shops',
      icon: Icons.storefront_rounded,
      color: Color(0xFF2563EB),
    ),
    SubAdminVertical(
      code: 'financial_auditor',
      label: 'Financial & Subscription Auditor',
      description:
          'Cross-vertical subscriptions, commissions, penalties, disputes',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFD97706),
    ),
    SubAdminVertical(
      code: 'cricket_ops',
      label: 'Cricket Operations Manager',
      description:
          'Live cricket streaming, tournament setup, scorekeeping, sponsors & manager provisioning',
      icon: Icons.sports_cricket,
      color: Color(0xFF10B981),
    ),
    // Group 3 — Factory. Vertical registered in C1 (MASTER-TASK-LIST.md §2b.1).
    SubAdminVertical(
      code: 'factory',
      label: 'Factory Manager',
      description: 'Approves the factory admin accounts of the Factory group',
      icon: Icons.precision_manufacturing_rounded,
      color: Color(0xFF0284C7),
    ),
    // Group 7 / Group 8 — stubs: the vertical exists, the panel does not yet (C0 §2b.1).
    SubAdminVertical(
      code: 'vehicle_security',
      label: 'Vehicle Security Manager (IoT)',
      description:
          'IoT vehicle tracking & immobilization — panel not built yet',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF0D9488),
    ),
    SubAdminVertical(
      code: 'trust_safety',
      label: 'Trust & Safety Manager',
      description:
          'Banknote authentication & trust surfaces — panel not built yet',
      icon: Icons.verified_user_rounded,
      color: Color(0xFF9333EA),
    ),
  ];

  /// The vertical registered under [code], or `null` if unknown / not supplied.
  static SubAdminVertical? byCode(String? code) {
    if (code == null) return null;
    for (final v in all) {
      if (v.code == code) return v;
    }
    return null;
  }

  /// Display label for [code]; falls back to the raw code, then `'Unknown'`.
  static String label(String? code) =>
      byCode(code)?.label ?? (code == null || code.isEmpty ? 'Unknown' : code);

  /// Icon for [code]; a neutral admin icon when the code is unknown.
  static IconData icon(String? code) =>
      byCode(code)?.icon ?? Icons.admin_panel_settings_rounded;

  /// Accent colour for [code]; a neutral grey when the code is unknown.
  static Color color(String? code) =>
      byCode(code)?.color ?? const Color(0xFF9E9E9E);
}
