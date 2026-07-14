// NEXATRACE — LAYOUT VALIDATION RESULT
// =====================================
// Sealed‑class hierarchy carrying validation outcomes
// with human‑readable messages and dimensional data.
//
// 100 % pure Dart.

import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';

/// Category of validation violation.
enum ValidationViolation {
  lengthExceeded,
  widthExceeded,
  aisleTooNarrow,
  insufficientInterSeatGap,
  unknownPartType,
}

/// Immutable result of layout validation.
sealed class ValidationResult extends Equatable {
  const ValidationResult();

  @override
  List<Object?> get props => [];
}

class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();
}

class ValidationFailure extends ValidationResult {
  final ValidationViolation violation;
  final FeetInches available;
  final FeetInches required;
  final FeetInches shortage;
  final String userMessage;

  const ValidationFailure({
    required this.violation,
    required this.available,
    required this.required,
    required this.shortage,
    required this.userMessage,
  });

  @override
  List<Object?> get props => [
    violation,
    available,
    required,
    shortage,
    userMessage,
  ];
}
