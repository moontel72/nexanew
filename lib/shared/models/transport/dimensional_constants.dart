// NEXATRACE — DIMENSIONAL CONSTANTS
// ==================================
// Industry‑standard default dimensions for seat parts, aisle width,
// and inter‑seat gap used by the physics‑based layout validator.
//
// 100 % pure Dart.

import 'package:trace_odd/shared/models/transport/feet_inches.dart';

/// Physical space between the back of one seat row and the front
/// of the next row (knee‑room + seat‑back thickness).
const FeetInches kDefaultInterSeatGap = FeetInches(feet: 1, inches: 0);

/// Standard centre aisle width.
const FeetInches kDefaultAisleWidth = FeetInches(feet: 1, inches: 6);

/// Minimum safe aisle width for emergency egress.
const FeetInches kMinAisleWidth = FeetInches(feet: 1, inches: 0);

/// Standard seat footprint (1 passenger).
const FeetInches kDefaultSeatLength = FeetInches(feet: 2, inches: 6);
const FeetInches kDefaultSeatWidth = FeetInches(feet: 1, inches: 6);

/// Sleeper berth footprint (1 passenger lying down).
const FeetInches kDefaultSleeperLength = FeetInches(feet: 6, inches: 0);
const FeetInches kDefaultSleeperWidth = FeetInches(feet: 2, inches: 0);

/// Business‑class / VIP seat footprint.
const FeetInches kDefaultBizSeatLength = FeetInches(feet: 3, inches: 0);
const FeetInches kDefaultBizSeatWidth = FeetInches(feet: 2, inches: 0);

/// Folding / jump seat.
const FeetInches kDefaultFoldSeatLength = FeetInches(feet: 1, inches: 6);
const FeetInches kDefaultFoldSeatWidth = FeetInches(feet: 1, inches: 0);
