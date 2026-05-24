// Bus Company Model — Bus fleet company extensions and helpers
// Uses the existing Company model from shared/models/company

import 'dart:convert';
import 'package:nexatrace_system/shared/models/company/company_model.dart';

/// Bus-specific company type constant (stored in admin_notes JSON)
const String busCompanyTypeId = 'bus_fleet';

/// Extension methods for Company in bus fleet context
extension BusCompanyExtension on Company {
  /// Parse bus metadata from the notes field (stored as JSON)
  Map<String, dynamic>? get _busMeta {
    final n = notes;
    if (n == null || n.isEmpty) return null;
    try {
      final decoded = jsonDecode(n);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  /// Whether this company is tagged as a bus fleet company
  bool get isBusCompany {
    final meta = _busMeta;
    return meta?['company_type_tag'] == busCompanyTypeId ||
        tags.contains(busCompanyTypeId);
  }

  /// Number of buses in the fleet
  int get fleetSize {
    final meta = _busMeta;
    return meta?['fleet_size'] as int? ?? 0;
  }

  /// Number of active routes
  int get activeRoutes {
    final meta = _busMeta;
    return meta?['active_routes'] as int? ?? 0;
  }

  /// Owner name from bus registration
  String get busOwnerName {
    final meta = _busMeta;
    return meta?['owner_name']?.toString() ?? contactPerson.fullName;
  }

  /// Formatted display string for bus companies
  String get busCompanyDisplay {
    final fleet = fleetSize;
    final routes = activeRoutes;
    if (fleet > 0 || routes > 0) {
      return '$name ($fleet buses, $routes routes)';
    }
    return name;
  }
}
