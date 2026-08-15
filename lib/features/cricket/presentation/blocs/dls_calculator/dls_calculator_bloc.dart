import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/dls_math.dart';

// ─── States ──────────────────────────────────────────────

sealed class DlsCalculatorState {
  const DlsCalculatorState();
}

/// All calculator inputs live here; the result is derived on every event.
final class DlsCalculatorReady extends DlsCalculatorState {
  final int oversPerSide;
  final int team1Score;
  final int team1StopOversRemaining;
  final int team1ResumeOversRemaining;
  final int team2StopOversRemaining;
  final int team2ResumeOversRemaining;

  const DlsCalculatorReady({
    this.oversPerSide = 20,
    this.team1Score = 150,
    this.team1StopOversRemaining = 0,
    this.team1ResumeOversRemaining = 0,
    this.team2StopOversRemaining = 0,
    this.team2ResumeOversRemaining = 0,
  });

  DlsCalculatorReady copyWith({
    int? oversPerSide,
    int? team1Score,
    int? team1StopOversRemaining,
    int? team1ResumeOversRemaining,
    int? team2StopOversRemaining,
    int? team2ResumeOversRemaining,
  }) => DlsCalculatorReady(
    oversPerSide: oversPerSide ?? this.oversPerSide,
    team1Score: team1Score ?? this.team1Score,
    team1StopOversRemaining:
        team1StopOversRemaining ?? this.team1StopOversRemaining,
    team1ResumeOversRemaining:
        team1ResumeOversRemaining ?? this.team1ResumeOversRemaining,
    team2StopOversRemaining:
        team2StopOversRemaining ?? this.team2StopOversRemaining,
    team2ResumeOversRemaining:
        team2ResumeOversRemaining ?? this.team2ResumeOversRemaining,
  );

  DlsResult get result => computeDls(
    oversPerSide: oversPerSide,
    team1Score: team1Score,
    team1StopOversRemaining: team1StopOversRemaining.toDouble(),
    team1ResumeOversRemaining: team1ResumeOversRemaining.toDouble(),
    team2StopOversRemaining: team2StopOversRemaining.toDouble(),
    team2ResumeOversRemaining: team2ResumeOversRemaining.toDouble(),
  );

  /// Interruption inputs constrained to the innings length.
  bool get isValid =>
      oversPerSide > 0 &&
      team1Score >= 0 &&
      team1StopOversRemaining <= oversPerSide &&
      team1ResumeOversRemaining <= team1StopOversRemaining &&
      team2StopOversRemaining <= oversPerSide &&
      team2ResumeOversRemaining <= team2StopOversRemaining;
}

// ─── Events ──────────────────────────────────────────────

sealed class DlsCalculatorEvent {
  const DlsCalculatorEvent();
}

final class SetOversPerSide extends DlsCalculatorEvent {
  final int overs;
  const SetOversPerSide(this.overs);
}

final class SetTeam1Score extends DlsCalculatorEvent {
  final int score;
  const SetTeam1Score(this.score);
}

final class SetTeam1Stop extends DlsCalculatorEvent {
  final int overs;
  const SetTeam1Stop(this.overs);
}

final class SetTeam1Resume extends DlsCalculatorEvent {
  final int overs;
  const SetTeam1Resume(this.overs);
}

final class SetTeam2Stop extends DlsCalculatorEvent {
  final int overs;
  const SetTeam2Stop(this.overs);
}

final class SetTeam2Resume extends DlsCalculatorEvent {
  final int overs;
  const SetTeam2Resume(this.overs);
}

// ─── BLoC ────────────────────────────────────────────────

class DlsCalculatorBloc extends Bloc<DlsCalculatorEvent, DlsCalculatorState> {
  DlsCalculatorBloc() : super(const DlsCalculatorReady()) {
    on<SetOversPerSide>((e, emit) {
      final s = state as DlsCalculatorReady;
      emit(
        s.copyWith(
          oversPerSide: e.overs,
          team1StopOversRemaining: s.team1StopOversRemaining.clamp(0, e.overs),
          team1ResumeOversRemaining: s.team1ResumeOversRemaining.clamp(
            0,
            e.overs,
          ),
          team2StopOversRemaining: s.team2StopOversRemaining.clamp(0, e.overs),
          team2ResumeOversRemaining: s.team2ResumeOversRemaining.clamp(
            0,
            e.overs,
          ),
        ),
      );
    });
    on<SetTeam1Score>((e, emit) {
      emit((state as DlsCalculatorReady).copyWith(team1Score: e.score));
    });
    on<SetTeam1Stop>((e, emit) {
      final s = state as DlsCalculatorReady;
      emit(
        s.copyWith(
          team1StopOversRemaining: e.overs.clamp(0, s.oversPerSide),
          team1ResumeOversRemaining: s.team1ResumeOversRemaining.clamp(
            0,
            e.overs,
          ),
        ),
      );
    });
    on<SetTeam1Resume>((e, emit) {
      final s = state as DlsCalculatorReady;
      emit(
        s.copyWith(
          team1ResumeOversRemaining: e.overs.clamp(
            0,
            s.team1StopOversRemaining,
          ),
        ),
      );
    });
    on<SetTeam2Stop>((e, emit) {
      final s = state as DlsCalculatorReady;
      emit(
        s.copyWith(
          team2StopOversRemaining: e.overs.clamp(0, s.oversPerSide),
          team2ResumeOversRemaining: s.team2ResumeOversRemaining.clamp(
            0,
            e.overs,
          ),
        ),
      );
    });
    on<SetTeam2Resume>((e, emit) {
      final s = state as DlsCalculatorReady;
      emit(
        s.copyWith(
          team2ResumeOversRemaining: e.overs.clamp(
            0,
            s.team2StopOversRemaining,
          ),
        ),
      );
    });
  }
}
