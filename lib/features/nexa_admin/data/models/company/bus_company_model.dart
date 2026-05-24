// Bus Company Model — Bus fleet company extensions and helpers
// Uses the existing Company model from shared/models/company

import 'package:nexatrace_system/shared/models/company/company_model.dart';

/// Bus-specific company type constant (sent during registration)
const String busCompanyTypeId = 'bus_fleet';

/// Extension methods for Company in bus fleet context
extension BusCompanyExtension on Company {
  /// Get fleet size from notes field (parsed as JSON if possible)
  int get fleetSize {
    try {
      final n = notes;
      if (n != null && n.contains('fleet_size')) {
        // Simple integer extraction from notes
        final match = RegExp(r'fleet_size[:\s]+(\d+)').firstMatch(n);
        if (match != null) return int.parse(match.group(1)!);
      }
    } catch (_) {}
    return 0;
  }

  /// Get active routes from notes field
  int get activeRoutes {
    try {
      final n = notes;
      if (n != null && n.contains('active_routes')) {
        final match = RegExp(r'active_routes[:\s]+(\d+)').firstMatch(n);
        if (match != null) return int.parse(match.group(1)!);
      }
    } catch (_) {}
    return 0;
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
