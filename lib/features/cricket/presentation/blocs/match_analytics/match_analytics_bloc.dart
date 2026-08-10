import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class MatchAnalyticsState {
  const MatchAnalyticsState();
}

final class MatchAnalyticsInitial extends MatchAnalyticsState {}

final class MatchAnalyticsLoading extends MatchAnalyticsState {}

final class WagonWheelLoaded extends MatchAnalyticsState {
  final List<WagonWheelShot> shots;
  const WagonWheelLoaded(this.shots);
}

final class RunDistributionLoaded extends MatchAnalyticsState {
  final RunDistribution distribution;
  const RunDistributionLoaded(this.distribution);
}

final class ConcededRunsLoaded extends MatchAnalyticsState {
  final ConcededRunsBreakdown breakdown;
  const ConcededRunsLoaded(this.breakdown);
}

final class MatchAnalyticsError extends MatchAnalyticsState {
  final String message;
  const MatchAnalyticsError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class MatchAnalyticsEvent {
  const MatchAnalyticsEvent();
}

final class LoadWagonWheel extends MatchAnalyticsEvent {
  final String matchId;
  final String? batsmanId;
  const LoadWagonWheel(this.matchId, {this.batsmanId});
}

final class LoadRunDistribution extends MatchAnalyticsEvent {
  final String matchId;
  const LoadRunDistribution(this.matchId);
}

final class LoadConcededRuns extends MatchAnalyticsEvent {
  final String matchId;
  final String? bowlerId;
  const LoadConcededRuns(this.matchId, {this.bowlerId});
}

// ─── BLoC ────────────────────────────────────────────────

class MatchAnalyticsBloc
    extends Bloc<MatchAnalyticsEvent, MatchAnalyticsState> {
  final CricketRepository _repo;

  MatchAnalyticsBloc({required CricketRepository repo})
    : _repo = repo,
      super(MatchAnalyticsInitial()) {
    on<LoadWagonWheel>(_onWagonWheel);
    on<LoadRunDistribution>(_onRunDist);
    on<LoadConcededRuns>(_onConceded);
  }

  Future<void> _onWagonWheel(
    LoadWagonWheel event,
    Emitter<MatchAnalyticsState> emit,
  ) async {
    emit(MatchAnalyticsLoading());
    try {
      final shots = await _repo.getWagonWheel(
        event.matchId,
        batsmanId: event.batsmanId,
      );
      emit(WagonWheelLoaded(shots));
    } catch (e) {
      emit(MatchAnalyticsError(e.toString()));
    }
  }

  Future<void> _onRunDist(
    LoadRunDistribution event,
    Emitter<MatchAnalyticsState> emit,
  ) async {
    emit(MatchAnalyticsLoading());
    try {
      final dist = await _repo.getRunDistribution(event.matchId);
      if (dist != null) {
        emit(RunDistributionLoaded(dist));
      } else {
        emit(const MatchAnalyticsError('No data.'));
      }
    } catch (e) {
      emit(MatchAnalyticsError(e.toString()));
    }
  }

  Future<void> _onConceded(
    LoadConcededRuns event,
    Emitter<MatchAnalyticsState> emit,
  ) async {
    emit(MatchAnalyticsLoading());
    try {
      final b = await _repo.getConcededRuns(
        event.matchId,
        bowlerId: event.bowlerId,
      );
      if (b != null) {
        emit(ConcededRunsLoaded(b));
      } else {
        emit(const MatchAnalyticsError('No data.'));
      }
    } catch (e) {
      emit(MatchAnalyticsError(e.toString()));
    }
  }
}
