import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class PlayerCareerState {
  const PlayerCareerState();
}

final class PlayerCareerInitial extends PlayerCareerState {}

final class PlayerCareerLoading extends PlayerCareerState {}

final class PlayerCareerLoaded extends PlayerCareerState {
  final PlayerCareerModel career;
  const PlayerCareerLoaded(this.career);
}

final class PlayerCareerError extends PlayerCareerState {
  final String message;
  const PlayerCareerError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class PlayerCareerEvent {
  const PlayerCareerEvent();
}

final class LoadPlayerCareer extends PlayerCareerEvent {
  final String playerId;
  const LoadPlayerCareer(this.playerId);
}

// ─── BLoC ────────────────────────────────────────────────

class PlayerCareerBloc extends Bloc<PlayerCareerEvent, PlayerCareerState> {
  final CricketRepository _repo;

  PlayerCareerBloc({required CricketRepository repo})
    : _repo = repo,
      super(PlayerCareerInitial()) {
    on<LoadPlayerCareer>(_onLoad);
  }

  Future<void> _onLoad(
    LoadPlayerCareer event,
    Emitter<PlayerCareerState> emit,
  ) async {
    emit(PlayerCareerLoading());
    try {
      final career = await _repo.getPlayerCareer(event.playerId);
      if (career != null) {
        emit(PlayerCareerLoaded(career));
      } else {
        emit(const PlayerCareerError('No career data found.'));
      }
    } catch (e) {
      emit(PlayerCareerError(e.toString()));
    }
  }
}
