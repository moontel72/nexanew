// Landing Icon Mapper
//
// Maps icon keys from the landing JSON (`verticals[].icon`) to Material
// icons. The JSON stays the source of truth; adding a new icon key is a
// single map-entry change here.

import 'package:flutter/material.dart';

class LandingIcons {
  LandingIcons._();

  static IconData forKey(String key) => switch (key) {
    'bus' => Icons.directions_bus_filled,
    'truck' => Icons.local_shipping,
    'storefront' => Icons.storefront,
    'factory' => Icons.factory,
    'cricket' => Icons.sports_cricket,
    'iot' => Icons.gps_fixed,
    'superapp' => Icons.widgets,
    _ => Icons.layers,
  };
}
