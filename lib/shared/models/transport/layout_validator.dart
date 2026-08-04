// NEXATRACE — LAYOUT VALIDATOR
// =============================
// Stateless utility performing spatial‑footprint validation
// against physical bus dimensions, component registry, and
// seat‑matrix configuration.
//
// 100 % pure Dart.

import 'package:trace_odd/shared/models/transport/bus_dimensions.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';
import 'package:trace_odd/shared/models/transport/dimensional_constants.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';
import 'package:trace_odd/shared/models/transport/layout_validation_result.dart';

class LayoutValidator {
  const LayoutValidator._();

  /// Calculates the total length required by the current seat matrix.
  ///
  /// Formula:
  ///   Total = (Rows × PartLength) + ((Rows − 1) × InterSeatGap)
  static FeetInches calculateRequiredLength({
    required int rows,
    required FeetInches partLength,
    required FeetInches interSeatGap,
  }) {
    if (rows <= 0) return FeetInches.zero;
    final partTotal = partLength * rows;
    final gapTotal = interSeatGap * (rows - 1);
    return partTotal + gapTotal;
  }

  /// Calculates the total width required by the seat arrangement.
  ///
  /// Formula:
  ///   Total = (LeftSeats + RightSeats) x PartWidth + AisleWidth
  static FeetInches calculateRequiredWidth({
    required int leftSeats,
    required int rightSeats,
    required FeetInches partWidth,
    required FeetInches aisleWidth,
  }) {
    final totalSeats = leftSeats + rightSeats;
    final seatWidth = partWidth * totalSeats;
    return seatWidth + aisleWidth;
  }

  /// Run all validations and return the first failure, or success.
  static ValidationResult validateAll({
    required BusDimensions dimensions,
    required ComponentRegistry registry,
    required int rows,
    required int leftSeats,
    required int rightSeats,
  }) {
    final partLength = registry.maxPartLength;
    final partWidth = registry.maxPartWidth;
    final aisle = registry.aisleWidth;
    final gap = registry.interSeatGap;

    // ── Length check ──
    final requiredLength = calculateRequiredLength(
      rows: rows,
      partLength: partLength,
      interSeatGap: gap,
    );
    if (requiredLength > dimensions.length) {
      return ValidationFailure(
        violation: ValidationViolation.lengthExceeded,
        available: dimensions.length,
        required: requiredLength,
        shortage: requiredLength - dimensions.length,
        userMessage:
            'Total layout length (${requiredLength.displayString}) '
            'exceeds bus interior length '
            '(${dimensions.length.displayString}) by '
            '${(requiredLength - dimensions.length).displayString}. '
            'Reduce rows or use smaller seat parts.',
      );
    }

    // ── Width check ──
    final requiredWidth = calculateRequiredWidth(
      leftSeats: leftSeats,
      rightSeats: rightSeats,
      partWidth: partWidth,
      aisleWidth: aisle,
    );
    if (requiredWidth > dimensions.width) {
      return ValidationFailure(
        violation: ValidationViolation.widthExceeded,
        available: dimensions.width,
        required: requiredWidth,
        shortage: requiredWidth - dimensions.width,
        userMessage:
            'Total layout width (${requiredWidth.displayString}) '
            'exceeds bus interior width '
            '(${dimensions.width.displayString}) by '
            '${(requiredWidth - dimensions.width).displayString}. '
            'Reduce seats per side or use smaller seat parts.',
      );
    }

    // ── Aisle width minimum ──
    if (aisle < kMinAisleWidth) {
      return ValidationFailure(
        violation: ValidationViolation.aisleTooNarrow,
        available: aisle,
        required: kMinAisleWidth,
        shortage: kMinAisleWidth - aisle,
        userMessage:
            'Aisle width (${aisle.displayString}) is below the '
            'minimum 1′0″ required for emergency egress.',
      );
    }

    // ── Table gap check (face-to-face seating) ──
    final tableSpec = registry.parts[SeatPartType.table];
    final hasReverseSeats =
        registry.parts.containsKey(SeatPartType.reverseSeat) ||
        registry.parts.containsKey(SeatPartType.businessReverseSeat);
    if (tableSpec != null && hasReverseSeats) {
      // Table sits between face-to-face seats — use faceToFaceGap.
      final tableGap = registry.faceToFaceGap;
      final minGapForTable =
          tableSpec.length + const FeetInches(feet: 0, inches: 10);
      if (tableGap < minGapForTable) {
        return ValidationFailure(
          violation: ValidationViolation.tableGapTooNarrow,
          available: tableGap,
          required: minGapForTable,
          shortage: minGapForTable - tableGap,
          userMessage:
              'Face‑to‑face gap (${tableGap.displayString}) is too narrow '
              'for a table (${tableSpec.length.displayString}) between '
              'facing seats. Minimum required: ${minGapForTable.displayString} '
              '(table depth + 10″ clearance). Increase the Face‑to‑Face Gap.',
        );
      }
    }

    return const ValidationSuccess();
  }

  /// Quick length‑only check for UI previews.
  static ValidationResult validateLength({
    required BusDimensions dimensions,
    required FeetInches partLength,
    required FeetInches interSeatGap,
    required int rows,
  }) {
    final required = calculateRequiredLength(
      rows: rows,
      partLength: partLength,
      interSeatGap: interSeatGap,
    );
    if (required > dimensions.length) {
      return ValidationFailure(
        violation: ValidationViolation.lengthExceeded,
        available: dimensions.length,
        required: required,
        shortage: required - dimensions.length,
        userMessage:
            'Layout length (${required.displayString}) exceeds '
            'bus length (${dimensions.length.displayString}).',
      );
    }
    return const ValidationSuccess();
  }
}
