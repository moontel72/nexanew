import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ────────────────────────────────────────────────────

sealed class TournamentSetupState {
  const TournamentSetupState();
}

final class TournamentSetupInitial extends TournamentSetupState {
  const TournamentSetupInitial();
}

final class TournamentSetupLoading extends TournamentSetupState {
  const TournamentSetupLoading();
}

final class TournamentSetupLoaded extends TournamentSetupState {
  final List<TournamentModel> tournaments;
  const TournamentSetupLoaded(this.tournaments);
}

final class TournamentSetupError extends TournamentSetupState {
  final String message;
  const TournamentSetupError(this.message);
}

/// Transient notice after a mutation; forms close on their own action.
final class TournamentSetupNotice extends TournamentSetupState {
  final String action;
  final bool success;
  final String message;

  const TournamentSetupNotice({
    required this.action,
    required this.success,
    required this.message,
  });
}

// ─── Events ────────────────────────────────────────────────────

sealed class TournamentSetupEvent {
  const TournamentSetupEvent();
}

final class LoadTournaments extends TournamentSetupEvent {
  const LoadTournaments();
}

final class RefreshTournaments extends TournamentSetupEvent {
  const RefreshTournaments();
}

final class CreateTournamentRequested extends TournamentSetupEvent {
  final String name;
  final String? location;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;

  const CreateTournamentRequested({
    required this.name,
    this.location,
    required this.startDate,
    required this.endDate,
    this.description,
  });
}

final class UpdateTournamentRequested extends TournamentSetupEvent {
  final String tournamentId;
  final String? name;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final String? status;
  final bool? isActive;

  const UpdateTournamentRequested({
    required this.tournamentId,
    this.name,
    this.location,
    this.startDate,
    this.endDate,
    this.description,
    this.status,
    this.isActive,
  });
}

final class ActivateTournamentRequested extends TournamentSetupEvent {
  final String tournamentId;
  const ActivateTournamentRequested(this.tournamentId);
}

// ─── BLoC ──────────────────────────────────────────────────────

class TournamentSetupBloc
    extends Bloc<TournamentSetupEvent, TournamentSetupState> {
  final CricketRepository _repo;

  TournamentSetupBloc({required CricketRepository repo})
    : _repo = repo,
      super(const TournamentSetupInitial()) {
    on<LoadTournaments>(_onLoad);
    on<RefreshTournaments>(_onRefresh);
    on<CreateTournamentRequested>(_onCreate);
    on<UpdateTournamentRequested>(_onUpdate);
    on<ActivateTournamentRequested>(_onActivate);
  }

  Future<void> _onLoad(
    LoadTournaments e,
    Emitter<TournamentSetupState> emit,
  ) async {
    emit(const TournamentSetupLoading());
    try {
      emit(TournamentSetupLoaded(await _repo.getTournaments()));
    } catch (error) {
      emit(
        TournamentSetupError(error.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  Future<void> _onRefresh(
    RefreshTournaments e,
    Emitter<TournamentSetupState> emit,
  ) async {
    emit(const TournamentSetupLoading());
    try {
      emit(TournamentSetupLoaded(await _repo.getTournaments()));
    } catch (error) {
      emit(
        TournamentSetupError(error.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  Future<void> _onCreate(
    CreateTournamentRequested e,
    Emitter<TournamentSetupState> emit,
  ) async {
    try {
      await _repo.createTournament(
        name: e.name,
        location: e.location,
        startDate: e.startDate,
        endDate: e.endDate,
        description: e.description,
      );
      emit(
        const TournamentSetupNotice(
          action: 'saveTournament',
          success: true,
          message: 'Tournament created.',
        ),
      );
    } catch (error) {
      emit(
        TournamentSetupNotice(
          action: 'saveTournament',
          success: false,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
    add(const RefreshTournaments());
  }

  Future<void> _onUpdate(
    UpdateTournamentRequested e,
    Emitter<TournamentSetupState> emit,
  ) async {
    try {
      await _repo.updateTournament(
        tournamentId: e.tournamentId,
        name: e.name,
        location: e.location,
        startDate: e.startDate,
        endDate: e.endDate,
        description: e.description,
        status: e.status,
        isActive: e.isActive,
      );
      emit(
        const TournamentSetupNotice(
          action: 'saveTournament',
          success: true,
          message: 'Tournament updated.',
        ),
      );
    } catch (error) {
      emit(
        TournamentSetupNotice(
          action: 'saveTournament',
          success: false,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
    add(const RefreshTournaments());
  }

  Future<void> _onActivate(
    ActivateTournamentRequested e,
    Emitter<TournamentSetupState> emit,
  ) async {
    try {
      await _repo.activateTournament(e.tournamentId);
      emit(
        const TournamentSetupNotice(
          action: 'activate',
          success: true,
          message:
              'Tournament activated. It is now available to the '
              'Fixture Scheduler and public portal.',
        ),
      );
    } catch (error) {
      emit(
        TournamentSetupNotice(
          action: 'activate',
          success: false,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
    add(const RefreshTournaments());
  }
}
