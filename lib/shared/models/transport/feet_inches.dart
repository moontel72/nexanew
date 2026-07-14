// NEXATRACE — FEET & INCHES VALUE OBJECT
// ========================================
// Immutable imperial measurement type with auto-normalization,
// arithmetic operators, and pixel conversion.
//
// 100 % pure Dart — zero Flutter dependencies.

import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/dimensional_constants.dart';

class FeetInches extends Equatable {
  final int feet;
  final int inches;

  /// Primary constructor. Requires normalized inches ([inches] < 12).
  /// For runtime calculations / user inputs, always use
  /// [FeetInches.normalize] or [FeetInches.fromTotalInches].
  const FeetInches({required this.feet, required this.inches})
    : assert(
        inches >= 0 && inches < 12,
        'Inches must be normalized between 0 and 11.',
      );

  /// Auto-normalizes inches >= 12 on construction.
  factory FeetInches.normalize(int feet, int inches) {
    final extraFeet = inches ~/ 12;
    final remainingInches = inches % 12;
    return FeetInches(feet: feet + extraFeet, inches: remainingInches);
  }

  factory FeetInches.fromTotalInches(double total) {
    final totalRounded = total.round();
    return FeetInches.normalize(totalRounded ~/ 12, totalRounded % 12);
  }

  factory FeetInches.fromPixels(double pixels) =>
      FeetInches.fromTotalInches(pixels / kPixelsPerInch);

  static const zero = FeetInches(feet: 0, inches: 0);

  double get totalInches => (feet * 12.0) + inches;
  double get toPixels => totalInches * kPixelsPerInch;
  String get displayString => inches == 0 ? "$feet'" : "$feet' $inches\"";
  bool get isZero => feet == 0 && inches == 0;

  FeetInches operator +(FeetInches other) =>
      FeetInches.fromTotalInches(totalInches + other.totalInches);

  FeetInches operator -(FeetInches other) {
    final diff = totalInches - other.totalInches;
    return diff < 0 ? FeetInches.zero : FeetInches.fromTotalInches(diff);
  }

  FeetInches operator *(int factor) =>
      FeetInches.fromTotalInches(totalInches * factor);

  bool operator >(FeetInches other) => totalInches > other.totalInches;
  bool operator >=(FeetInches other) => totalInches >= other.totalInches;
  bool operator <(FeetInches other) => totalInches < other.totalInches;
  bool operator <=(FeetInches other) => totalInches <= other.totalInches;

  @override
  List<Object?> get props => [feet, inches];
}
