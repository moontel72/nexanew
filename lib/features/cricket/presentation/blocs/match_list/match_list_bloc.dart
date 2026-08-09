import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class MatchListState {}

final class MatchListInitial extends MatchListState {}

final class MatchListLoading extends MatchListState {}

final class MatchListLoaded extends MatchListState {
  final TournamentModel? tournament;
  final List<MatchModel> liveMatches;
  final List<MatchModel> allMatches;

  const MatchListLoaded({
    this.tournament,
    this.liveMatches = const [],
    this.allMatches = const [],
  });
}

final class MatchListError extends MatchListState {
  final String message;
  const MatchListError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class MatchListEvent {}

final class LoadMatches extends MatchListEvent {}

final class RefreshMatches extends MatchListEvent {}

// ─── BLoC ────────────────────────────────────────────────

class MatchListBloc extends Bloc<MatchListEvent, MatchListState> {
  final CricketRepository _repo;

  MatchListBloc({required CricketRepository repo})
      : _repo = repo,
        super(MatchListInitial()) {
    on<LoadMatches>(_onLoad);
    on<RefreshMatches>(_onRefresh);
  }

  Future<void> _onLoad(LoadMatches e, Emitter<MatchListState> emit) async {
    emit(MatchListLoading());
    try {
      final tournament = await _repo.getActiveTournament();
      final results = await Future.wait([
        _repo.getLiveMatches(tournamentId: tournament?.id),
        _repo.getAllMatches(tournamentId: tournament?.id),
      ]);
      emit(MatchListLoaded(
        tournament: tournament,
        liveMatches: results[0],
        allMatches: results[1],
      ));
    } catch (error) {
      emit(MatchListError(error.toString()));
    }
  }

  Future<void> _onRefresh(RefreshMatches e, Emitter<MatchListState> emit) async {
    final s = state;
    if (s is! MatchListLoaded) {
      add(LoadMatches());
      return;
    }
    try {
      final liveMatches = await _repo.getLiveMatches(
          tournamentId: s.tournament?.id);
      emit(s.copyWith(liveMatches: liveMatches));
    } catch (_) {}
  }
}

// Extension for copyWith on MatchListLoaded
extension _MatchListLoadedX on MatchListLoaded {
  MatchListLoaded copyWith({
    TournamentModel? tournament,
    List<MatchModel>? liveMatches,
    List<MatchModel>? allMatches,
  }) =>
      MatchListLoaded(
        tournament: tournament ?? this.tournament,
        liveMatches: liveMatches ?? this.liveMatches,
        allMatches: allMatches ?? this.allMatches,
      );
}
