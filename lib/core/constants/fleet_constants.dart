// Fleet Constants — Local Pakistani transport taxonomy classifiers
//
// Two strict enums mapping the localized fleet divisions per the semantic
// alignment audit: BusCategory for passenger transit and TruckCategory for
// goods/logistics.  Each provides metadata extensions for capacity, local
// name, and primary operational mode.
//
// Backend mapping: these enums feed into a future `vehicle_class` column on
// `freight_loads` and `bus_layouts` tables.

// ─────────────────────────────────────────────────────────────
// Bus Category — Passenger Transit (Modules 13–15)
// ─────────────────────────────────────────────────────────────

enum BusCategory {
  /// Toyota Hiace / similar — 13 seats, 4 rows × (2L + aisle + 1R) + 1 driver.
  /// Fixed-route short commutes, city-to-city ~100 km radius.
  hiace13,

  /// Toyota Coaster / similar — 29 seats, 9 rows × (2L + aisle + 1R) + 2 driver.
  /// Regional inter-city shuttles, 200–400 km.
  coaster29,

  /// Luxury Coach (Yutong, Daewoo, etc.) — 45 seats, 11 rows × (2L + aisle + 2R) + 1.
  /// Premier long-haul charters, 400–1000+ km.
  luxuryCoach45,

  /// Double-decker high-capacity — 55–70 seats, 14 rows × 2 decks.
  /// Ultra-long-haul or high-density urban corridors.
  doubleDecker,
}

extension BusCategoryMeta on BusCategory {
  String get localName => switch (this) {
    BusCategory.hiace13 => 'Hiace (13-Seater)',
    BusCategory.coaster29 => 'Coaster (29-Seater)',
    BusCategory.luxuryCoach45 => 'Luxury Coach (45-Seater)',
    BusCategory.doubleDecker => 'Double Decker (55–70)',
  };

  int get seatCapacity => switch (this) {
    BusCategory.hiace13 => 13,
    BusCategory.coaster29 => 29,
    BusCategory.luxuryCoach45 => 45,
    BusCategory.doubleDecker => 55,
  };

  String get operationalMode => switch (this) {
    BusCategory.hiace13 => 'fixed_short',
    BusCategory.coaster29 => 'regional_intercity',
    BusCategory.luxuryCoach45 => 'long_haul_charter',
    BusCategory.doubleDecker => 'ultra_long_haul',
  };

  int get defaultRows => switch (this) {
    BusCategory.hiace13 => 4,
    BusCategory.coaster29 => 9,
    BusCategory.luxuryCoach45 => 11,
    BusCategory.doubleDecker => 14,
  };

  static BusCategory fromString(String? s) => switch (s?.toLowerCase()) {
    'hiace13' || 'hiace' || 'hiace_13' => BusCategory.hiace13,
    'coaster29' || 'coaster' || 'coaster_29' => BusCategory.coaster29,
    'luxurycoach45' || 'luxury_coach' || 'coach' => BusCategory.luxuryCoach45,
    'doubledecker' || 'double_decker' => BusCategory.doubleDecker,
    _ => BusCategory.hiace13,
  };
}

// ─────────────────────────────────────────────────────────────
// Truck Category — Goods / Logistics (Modules 9–11)
// ─────────────────────────────────────────────────────────────

enum TruckCategory {
  /// Suzuki Pickup / similar — 1–3 ton, last-mile urban delivery, shopkeeper restock.
  pickup1To3Ton,

  /// Shahzore Loader — 6–8 ton, open-top, kisaan-to-mandi agricultural produce.
  shahzoreLoader,

  /// Standard Mazda / Hino — 5–10 ton, enclosed cargo, mid-tier B2B freight.
  standardMazda,

  /// Trela / 22-wheeler — 40+ ton flatbed, heavy industrial cross-country hauling.
  trelaMultiAxle,
}

extension TruckCategoryMeta on TruckCategory {
  String get localName => switch (this) {
    TruckCategory.pickup1To3Ton => 'Pickup (1–3 Ton)',
    TruckCategory.shahzoreLoader => 'Shahzore Loader (6–8 Ton)',
    TruckCategory.standardMazda => 'Standard Mazda (5–10 Ton)',
    TruckCategory.trelaMultiAxle => 'Trela Multi-Axle (40+ Ton)',
  };

  double get minTonnage => switch (this) {
    TruckCategory.pickup1To3Ton => 1.0,
    TruckCategory.shahzoreLoader => 6.0,
    TruckCategory.standardMazda => 5.0,
    TruckCategory.trelaMultiAxle => 40.0,
  };

  double get maxTonnage => switch (this) {
    TruckCategory.pickup1To3Ton => 3.0,
    TruckCategory.shahzoreLoader => 8.0,
    TruckCategory.standardMazda => 10.0,
    TruckCategory.trelaMultiAxle => 80.0,
  };

  String get operationalDomain => switch (this) {
    TruckCategory.pickup1To3Ton => 'last_mile_urban',
    TruckCategory.shahzoreLoader => 'agro_mandi_distribution',
    TruckCategory.standardMazda => 'mid_tier_b2b_freight',
    TruckCategory.trelaMultiAxle => 'heavy_industrial_long_haul',
  };

  static TruckCategory fromString(String? s) => switch (s?.toLowerCase()) {
    'pickup1to3ton' || 'pickup' || 'pickup_1_3' => TruckCategory.pickup1To3Ton,
    'shahzoreloader' || 'shahzore' || 'loader' => TruckCategory.shahzoreLoader,
    'standardmazda' || 'mazda' || 'standard' => TruckCategory.standardMazda,
    'trelamultiaxle' || 'trela' || 'multi_axle' => TruckCategory.trelaMultiAxle,
    _ => TruckCategory.standardMazda,
  };
}
