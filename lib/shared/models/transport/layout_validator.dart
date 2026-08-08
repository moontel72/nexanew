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

  /// Single source of truth: computes required length for any layout mode.
  /// Uses face‑to‑face formula when table + reverse seats are registered,
  /// otherwise the standard inter‑seat gap formula.
  static FeetInches getRequiredLength({
    required int rows,
    required ComponentRegistry registry,
  }) {
    if (rows <= 0) return FeetInches.zero;
    final partLength = registry.maxPartLength;
    final bool faceToFace =
        registry.parts.containsKey(SeatPartType.table) &&
        (registry.parts.containsKey(SeatPartType.standardSeat) ||
            registry.parts.containsKey(SeatPartType.businessSeat)) &&
        (registry.parts.containsKey(SeatPartType.reverseSeat) ||
            registry.parts.containsKey(SeatPartType.businessReverseSeat));
    if (faceToFace) {
      // Row 1 is solo forward; pairs start at row 2.
      final int pairCount = (rows - 1) ~/ 2;
      return partLength * rows + registry.faceToFaceGap * pairCount;
    }
    return partLength * rows + registry.interSeatGap * (rows - 1);
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
    FeetInches sideSeatGap = FeetInches.zero,
  }) {
    final totalSeats = leftSeats + rightSeats;
    final seatWidth = partWidth * totalSeats;
    final leftGaps = leftSeats > 1 ? sideSeatGap * (leftSeats - 1) : FeetInches.zero;
    final rightGaps = rightSeats > 1 ? sideSeatGap * (rightSeats - 1) : FeetInches.zero;
    return seatWidth + leftGaps + rightGaps + aisleWidth;
  }

  /// Run all validations and return the first failure, or success.
  static ValidationResult validateAll({
    required BusDimensions dimensions,
    required ComponentRegistry registry,
    required int rows,
    required int leftSeats,
    required int rightSeats,
  }) {
    final partWidth = registry.maxPartWidth;
    final aisle = registry.aisleWidth;

    // ── Length check ──
    final requiredLength = getRequiredLength(rows: rows, registry: registry);
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
      sideSeatGap: registry.sideSeatGap,
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
      // Table length = depth between rows (occupies the gap).
      final tableDepth = tableSpec.length;
      final tableGap = registry.faceToFaceGap;
      final minGapForTable = tableDepth + const FeetInches(feet: 0, inches: 10);
      if (tableGap < minGapForTable) {
        return ValidationFailure(
          violation: ValidationViolation.tableGapTooNarrow,
          available: tableGap,
          required: minGapForTable,
          shortage: minGapForTable - tableGap,
          userMessage:
              'Face‑to‑face gap (${tableGap.displayString}) is too narrow '
              'for a table (${tableDepth.displayString} depth) between '
              'facing seats. Minimum required: ${minGapForTable.displayString} '
              '(table depth + 10″ clearance). Increase the Face‑to‑Face Gap.',
        );
      }
    }

    // -- Face-to-face: last row must be forward-facing --
    // Rows alternate (fwd, rev, fwd, rev...) so an even row count
    // would place a reverse seat in the last row, which is unsafe.
    final bool f2f = registry.parts.containsKey(SeatPartType.table) &&
        (registry.parts.containsKey(SeatPartType.standardSeat) ||
            registry.parts.containsKey(SeatPartType.businessSeat)) &&
        (registry.parts.containsKey(SeatPartType.reverseSeat) ||
            registry.parts.containsKey(SeatPartType.businessReverseSeat));
    if (f2f && rows > 1 && rows % 2 == 0) {
      return ValidationFailure(
        violation: ValidationViolation.lastRowMustBeForward,
        available: FeetInches.zero,
        required: FeetInches.zero,
        shortage: FeetInches.zero,
        userMessage:
            'Face-to-face layout requires an odd number of rows '
            'so the last row is forward-facing. '
            'Add or remove 1 row (currently $rows).',
      );
    }

    return const ValidationSuccess();
  }
}
