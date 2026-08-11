sealed class TeamEvent {
  const TeamEvent();
}

final class CreateTeamRequested extends TeamEvent {
  final String name;
  final String? shortCode;
  final String? homeCity;
  final String? primaryColor;

  const CreateTeamRequested({
    required this.name,
    this.shortCode,
    this.homeCity,
    this.primaryColor,
  });
}

final class LoadTeamsRequested extends TeamEvent {}
