import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/cricket_repository.dart';
import 'team_event.dart';
import 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final CricketRepository _repo;

  TeamBloc({required CricketRepository repo})
    : _repo = repo,
      super(const TeamInitial()) {
    on<CreateTeamRequested>(_onCreateTeam);
    on<LoadTeamsRequested>(_onLoadTeams);
  }

  Future<void> _onCreateTeam(
    CreateTeamRequested event,
    Emitter<TeamState> emit,
  ) async {
    emit(const TeamLoading());
    try {
      final team = await _repo.createTeam(
        name: event.name,
        shortCode: event.shortCode,
        homeCity: event.homeCity,
        primaryColor: event.primaryColor,
        details: event.details,
      );
      emit(TeamSuccess(team));
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'An unexpected error occurred';
      emit(TeamFailure(msg));
    }
  }

  Future<void> _onLoadTeams(
    LoadTeamsRequested event,
    Emitter<TeamState> emit,
  ) async {
    emit(const TeamLoading());
    try {
      final teams = await _repo.getAllTeams();
      emit(TeamsLoaded(teams));
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Failed to load teams';
      emit(TeamFailure(msg));
    }
  }
}
