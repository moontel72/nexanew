import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class MatchListState {
  const MatchListState();
}

final class MatchListInitial extends MatchListState {}

final class MatchListLoading extends MatchListState {}

final class MatchListLoaded extends MatchListState {
  final TournamentModel? tournament;
  final List<MatchModel> liveMatches;
  final List<MatchModel> allMatches;

  /// Transient feedback (GO LIVE success / failure) shown via BlocListener.
  final String? notice;

  const MatchListLoaded({
    this.tournament,
    this.liveMatches = const [],
    this.allMatches = const [],
    this.notice,
  });

  MatchListLoaded copyWith({
    TournamentModel? tournament,
    List<MatchModel>? liveMatches,
    List<MatchModel>? allMatches,
    String? notice,
  }) => MatchListLoaded(
    tournament: tournament ?? this.tournament,
    liveMatches: liveMatches ?? this.liveMatches,
    allMatches: allMatches ?? this.allMatches,
    notice: notice,
  );
}

final class MatchListError extends MatchListState {
  final String message;
  const MatchListError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class MatchListEvent {
  const MatchListEvent();
}

final class LoadMatches extends MatchListEvent {}

final class RefreshMatches extends MatchListEvent {}

/// GO LIVE / lifecycle toggle — PATCHes the match status endpoint and
/// reloads the lists on success.
final class UpdateMatchStatus extends MatchListEvent {
  final String matchId;
  final String status;
  const UpdateMatchStatus(this.matchId, this.status);
}

// ─── BLoC ────────────────────────────────────────────────

class MatchListBloc extends Bloc<MatchListEvent, MatchListState> {
  final CricketRepository _repo;

  StreamSubscription<MatchUpdate>? _matchSub;

  MatchListBloc({required CricketRepository repo})
    : _repo = repo,
      super(MatchListInitial()) {
    on<LoadMatches>(_onLoad);
    on<RefreshMatches>(_onRefresh);
    on<UpdateMatchStatus>(_onUpdateStatus);
  }

  Future<void> _onLoad(LoadMatches e, Emitter<MatchListState> emit) async {
    emit(MatchListLoading());
    try {
      final tournament = await _repo.getActiveTournament();
      final results = await Future.wait([
        _repo.getLiveMatches(tournamentId: tournament?.id),
        _repo.getAllMatches(tournamentId: tournament?.id),
      ]);
      emit(
        MatchListLoaded(
          tournament: tournament,
          liveMatches: results[0],
          allMatches: results[1],
        ),
      );
      _subscribeToTournamentUpdates(tournament?.id);
    } catch (error) {
      emit(MatchListError(error.toString()));
    }
  }

  /// Instantly refresh when the backend broadcasts a match lifecycle
  /// change (GO LIVE / break / completed) on the tournament channel.
  void _subscribeToTournamentUpdates(String? tournamentId) {
    if (tournamentId == null || tournamentId.isEmpty) return;
    _matchSub ??= _repo.matchUpdates.listen((update) {
      if (update.tournamentId != tournamentId) return;
      if (isClosed) return;
      add(RefreshMatches());
      add(LoadMatches());
    });
    _repo.subscribeToTournament(tournamentId);
  }

  Future<void> _onRefresh(
    RefreshMatches e,
    Emitter<MatchListState> emit,
  ) async {
    final s = state;
    if (s is! MatchListLoaded) {
      add(LoadMatches());
      return;
    }
    try {
      final liveMatches = await _repo.getLiveMatches(
        tournamentId: s.tournament?.id,
      );
      emit(s.copyWith(liveMatches: liveMatches));
    } catch (_) {}
  }

  Future<void> _onUpdateStatus(
    UpdateMatchStatus e,
    Emitter<MatchListState> emit,
  ) async {
    final s = state;
    try {
      await _repo.updateMatchStatus(e.matchId, e.status);
      if (s is MatchListLoaded) {
        emit(
          s.copyWith(
            notice: e.status == 'live'
                ? 'Match is now LIVE — public viewers have been notified.'
                : 'Match status updated to ${e.status}.',
          ),
        );
      }
      add(LoadMatches());
    } catch (err) {
      final message = err.toString().replaceFirst('Exception: ', '');
      if (s is MatchListLoaded) {
        emit(s.copyWith(notice: message));
      } else {
        emit(MatchListError(message));
      }
    }
  }

  @override
  Future<void> close() {
    _matchSub?.cancel();
    return super.close();
  }
}
