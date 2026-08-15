import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class ScorecardState {
  const ScorecardState();
}

final class ScorecardInitial extends ScorecardState {}

final class ScorecardLoading extends ScorecardState {}

final class ScorecardError extends ScorecardState {
  final String message;
  const ScorecardError(this.message);
}

final class ScorecardLoaded extends ScorecardState {
  final ScorecardModel scorecard;
  const ScorecardLoaded(this.scorecard);
}

// ─── Events ──────────────────────────────────────────────

sealed class ScorecardEvent {
  const ScorecardEvent();
}

final class LoadScorecard extends ScorecardEvent {
  final String matchId;
  const LoadScorecard(this.matchId);
}

final class RefreshScorecard extends ScorecardEvent {}

// ─── BLoC ────────────────────────────────────────────────

class ScorecardBloc extends Bloc<ScorecardEvent, ScorecardState> {
  final CricketRepository _repo;
  String? _matchId;

  ScorecardBloc({required CricketRepository repo})
    : _repo = repo,
      super(ScorecardInitial()) {
    on<LoadScorecard>(_onLoad);
    on<RefreshScorecard>(_onRefresh);
  }

  Future<void> _onLoad(LoadScorecard e, Emitter<ScorecardState> emit) async {
    _matchId = e.matchId;
    emit(ScorecardLoading());

    final scorecard = await _repo.getScorecard(e.matchId);
    if (scorecard != null) {
      emit(ScorecardLoaded(scorecard));
    } else {
      emit(const ScorecardError('Failed to load scorecard.'));
    }
  }

  Future<void> _onRefresh(
    RefreshScorecard e,
    Emitter<ScorecardState> emit,
  ) async {
    final matchId = _matchId;
    if (matchId == null) return;
    final scorecard = await _repo.getScorecard(matchId);
    if (scorecard != null) {
      emit(ScorecardLoaded(scorecard));
    }
  }
}
