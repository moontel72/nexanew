import '../../../data/models/cricket_models.dart';

sealed class TeamState {
  const TeamState();
}

final class TeamInitial extends TeamState {
  const TeamInitial();
}

final class TeamLoading extends TeamState {
  const TeamLoading();
}

final class TeamSuccess extends TeamState {
  final TeamModel team;
  const TeamSuccess(this.team);
}

final class TeamFailure extends TeamState {
  final String message;
  const TeamFailure(this.message);
}

final class TeamsLoaded extends TeamState {
  final List<TeamModel> teams;
  const TeamsLoaded(this.teams);
}
