import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class TournamentHubState {
  const TournamentHubState();
}

final class TournamentHubInitial extends TournamentHubState {}

final class TournamentHubLoading extends TournamentHubState {}

final class TournamentHubLoaded extends TournamentHubState {
  final List<PointsTableEntry> standings;
  final List<TopPerformer> mostRuns;
  final List<TopPerformer> mostWickets;

  const TournamentHubLoaded({
    required this.standings,
    required this.mostRuns,
    required this.mostWickets,
  });
}

final class TournamentHubError extends TournamentHubState {
  final String message;
  const TournamentHubError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class TournamentHubEvent {
  const TournamentHubEvent();
}

final class LoadTournamentHub extends TournamentHubEvent {
  final String tournamentId;
  const LoadTournamentHub(this.tournamentId);
}

// ─── BLoC ────────────────────────────────────────────────

class TournamentHubBloc extends Bloc<TournamentHubEvent, TournamentHubState> {
  final CricketRepository _repo;

  TournamentHubBloc({required CricketRepository repo})
    : _repo = repo,
      super(TournamentHubInitial()) {
    on<LoadTournamentHub>(_onLoad);
  }

  Future<void> _onLoad(
    LoadTournamentHub event,
    Emitter<TournamentHubState> emit,
  ) async {
    emit(TournamentHubLoading());
    try {
      final standings = await _repo.getStandings(event.tournamentId);
      final performers = await _repo.getTopPerformers(event.tournamentId);
      emit(
        TournamentHubLoaded(
          standings: standings,
          mostRuns: performers['most_runs'] ?? [],
          mostWickets: performers['most_wickets'] ?? [],
        ),
      );
    } catch (e) {
      emit(TournamentHubError(e.toString()));
    }
  }
}
