// NEXATRACE — BUS DIMENSIONS
// ===========================
// 3‑axis physical boundaries of the bus interior (length × width × height).
// Provides static presets for standard South Asian transit vehicles.
//
// 100 % pure Dart — zero Flutter dependencies.

import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';

class BusDimensions extends Equatable {
  final FeetInches length;
  final FeetInches width;
  final FeetInches height;

  const BusDimensions({
    required this.length,
    required this.width,
    required this.height,
  });

  // ═══════════════════════════════════════════════════════════
  // PRESETS
  // ═══════════════════════════════════════════════════════════

  /// 30′ × 7′6″ × 6′6″
  factory BusDimensions.standardCoach() => BusDimensions(
    length: const FeetInches(feet: 30, inches: 0),
    width: const FeetInches(feet: 7, inches: 6),
    height: const FeetInches(feet: 6, inches: 6),
  );

  /// 35′ × 8′0″ × 7′0″
  factory BusDimensions.largeCoach() => BusDimensions(
    length: const FeetInches(feet: 35, inches: 0),
    width: const FeetInches(feet: 8, inches: 0),
    height: const FeetInches(feet: 7, inches: 0),
  );

  /// 20′ × 6′6″ × 5′6″
  factory BusDimensions.coaster() => BusDimensions(
    length: const FeetInches(feet: 20, inches: 0),
    width: const FeetInches(feet: 6, inches: 6),
    height: const FeetInches(feet: 5, inches: 6),
  );

  /// 12′ × 5′6″ × 4′6″
  factory BusDimensions.hiace() => BusDimensions(
    length: const FeetInches(feet: 12, inches: 0),
    width: const FeetInches(feet: 5, inches: 6),
    height: const FeetInches(feet: 4, inches: 6),
  );

  /// 30′ × 8′0″ × 7′0″
  factory BusDimensions.sleeper() => BusDimensions(
    length: const FeetInches(feet: 30, inches: 0),
    width: const FeetInches(feet: 8, inches: 0),
    height: const FeetInches(feet: 7, inches: 0),
  );

  /// Convert to logical pixels for the canvas.
  double get lengthPx => length.toPixels;
  double get widthPx => width.toPixels;
  double get heightPx => height.toPixels;

  BusDimensions copyWith({
    FeetInches? length,
    FeetInches? width,
    FeetInches? height,
  }) => BusDimensions(
    length: length ?? this.length,
    width: width ?? this.width,
    height: height ?? this.height,
  );

  @override
  List<Object?> get props => [length, width, height];
}
