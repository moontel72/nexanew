// Goods Company Model — Goods logistics fleet company extensions and helpers
// Uses the existing Company model from shared/models/company

import 'dart:convert';
import 'package:nexatrace_system/shared/models/company/company_model.dart';

/// Goods-specific company type constant (stored in admin_notes JSON)
const String goodsCompanyTypeId = 'goods_fleet';

/// Extension methods for Company in goods logistics fleet context
extension GoodsCompanyExtension on Company {
  /// Parse goods metadata from the notes field (stored as JSON)
  Map<String, dynamic>? get _goodsMeta {
    final n = notes;
    if (n == null || n.isEmpty) return null;
    try {
      final decoded = jsonDecode(n);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  /// Whether this company is tagged as a goods logistics fleet company
  bool get isGoodsCompany {
    final meta = _goodsMeta;
    return meta?['company_type_tag'] == goodsCompanyTypeId ||
        tags.contains(goodsCompanyTypeId);
  }

  /// Number of trucks in the fleet
  int get truckCount {
    final meta = _goodsMeta;
    return meta?['truck_count'] as int? ?? 0;
  }

  /// Total fleet size
  int get fleetSize {
    final meta = _goodsMeta;
    return meta?['fleet_size'] as int? ?? 0;
  }

  /// Owner name from goods registration
  String get goodsOwnerName {
    final meta = _goodsMeta;
    return meta?['owner_name']?.toString() ?? contactPerson.fullName;
  }

  /// Formatted display string for goods companies
  String get goodsCompanyDisplay {
    final trucks = truckCount;
    final size = fleetSize;
    if (trucks > 0 || size > 0) {
      return '$name ($trucks trucks, $size fleet)';
    }
    return name;
  }
}
