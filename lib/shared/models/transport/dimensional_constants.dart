// NEXATRACE — DIMENSIONAL CONSTANTS
// ==================================
// Industry‑standard default dimensions for seat parts, aisle width,
// and inter‑seat gap used by the physics‑based layout validator.
//
// 100 % pure Dart.

import 'package:trace_odd/shared/models/transport/feet_inches.dart';

/// Physical scaling factor: 4 pixels represent exactly 1 inch.
/// This is the single source of truth for pixel‑to‑imperial conversion.
const double kPixelsPerInch = 4.0;

/// Safety Guidelines
const FeetInches kMinAisleWidth = FeetInches(feet: 1, inches: 0);
const FeetInches kMinInterSeatGap = FeetInches(feet: 1, inches: 0);

/// Physical space between the back of one seat row and the front
/// of the next row (knee‑room + seat‑back thickness).
const FeetInches kDefaultInterSeatGap = FeetInches(feet: 1, inches: 0);

/// Standard centre aisle width.
const FeetInches kDefaultAisleWidth = FeetInches(feet: 1, inches: 6);

/// Standard seat footprint — 1′6″ × 1′6″ (18″ × 18″).
const FeetInches kDefaultSeatLength = FeetInches(feet: 1, inches: 6);
const FeetInches kDefaultSeatWidth = FeetInches(feet: 1, inches: 6);

/// Sleeper berth footprint — 6′0″ × 2′0″.
const FeetInches kDefaultSleeperLength = FeetInches(feet: 6, inches: 0);
const FeetInches kDefaultSleeperWidth = FeetInches(feet: 2, inches: 0);

/// Business‑class / VIP seat footprint — 2′6″ × 2′0″.
const FeetInches kDefaultBusinessSeatLength = FeetInches(feet: 2, inches: 6);
const FeetInches kDefaultBusinessSeatWidth = FeetInches(feet: 2, inches: 0);

/// Folding / jump seat.
const FeetInches kDefaultFoldSeatLength = FeetInches(feet: 1, inches: 6);
const FeetInches kDefaultFoldSeatWidth = FeetInches(feet: 1, inches: 0);
