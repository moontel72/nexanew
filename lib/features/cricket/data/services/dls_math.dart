import 'dart:math' as math;

/// Phase 5 — simplified Duckworth-Lewis-Stern style calculator.
///
/// Uses the standard exponential resource-curve model published alongside
/// the DLS method:
///
///   R(u) = 100 · (1 − e^(−b·u)) / (1 − e^(−b·U))
///
/// where u = overs remaining, U = total overs per side, and b is the curve
/// steepness constant. Rain interruptions remove resources equal to the
/// difference between the curve values at stoppage and resumption.
///
/// NOTE: this is an approximation for advisory use at club level — it does
/// not ship the proprietary ICC DLS tables and does not model wicket-loss
/// resources. Labeled as such in the UI.
class DlsResult {
  final double team1ResourcesPercent;
  final double team2ResourcesPercent;
  final int parScore;
  final int target;

  const DlsResult({
    required this.team1ResourcesPercent,
    required this.team2ResourcesPercent,
    required this.parScore,
    required this.target,
  });
}

const double _curveSteepness = 0.09;

double resourcesRemaining(double oversRemaining, double totalOvers) {
  if (totalOvers <= 0) return 0;
  if (oversRemaining <= 0) return 0;
  final numerator = 1 - math.exp(-_curveSteepness * oversRemaining);
  final denominator = 1 - math.exp(-_curveSteepness * totalOvers);
  return 100 * numerator / denominator;
}

/// Resources lost by a rain interruption between [oversRemainingAtStop]
/// and [oversRemainingAtResume] (resume <= stop).
double resourcesLost(
  double oversRemainingAtStop,
  double oversRemainingAtResume,
  double totalOvers,
) {
  if (oversRemainingAtStop <= oversRemainingAtResume) return 0;
  return resourcesRemaining(oversRemainingAtStop, totalOvers) -
      resourcesRemaining(oversRemainingAtResume, totalOvers);
}

DlsResult computeDls({
  required int oversPerSide,
  required int team1Score,
  double team1StopOversRemaining = 0,
  double team1ResumeOversRemaining = 0,
  double team2StopOversRemaining = 0,
  double team2ResumeOversRemaining = 0,
}) {
  final total = oversPerSide.toDouble();

  final team1Lost = resourcesLost(
    team1StopOversRemaining,
    team1ResumeOversRemaining,
    total,
  );
  final team2Lost = resourcesLost(
    team2StopOversRemaining,
    team2ResumeOversRemaining,
    total,
  );

  final team1Resources = (100 - team1Lost).clamp(0.0, 100.0);
  final team2Resources = (100 - team2Lost).clamp(0.0, 100.0);

  final par = team1Resources > 0
      ? (team1Score * team2Resources / team1Resources).ceil()
      : 0;

  return DlsResult(
    team1ResourcesPercent: team1Resources,
    team2ResourcesPercent: team2Resources,
    parScore: par,
    target: par + 1,
  );
}
