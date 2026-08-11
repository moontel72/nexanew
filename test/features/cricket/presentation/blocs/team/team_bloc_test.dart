import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/team/team_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/team/team_event.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/team/team_state.dart';

/// Manual fake that records calls and returns canned responses.
class FakeCricketRepository implements CricketRepository {
  TeamModel? _createTeamResult;
  Object? _createTeamError;
  List<TeamModel>? _allTeamsResult;
  Object? _allTeamsError;

  void stubCreateTeam(TeamModel result) => _createTeamResult = result;
  void stubCreateTeamError(Object error) => _createTeamError = error;
  void stubAllTeams(List<TeamModel> result) => _allTeamsResult = result;
  void stubAllTeamsError(Object error) => _allTeamsError = error;

  @override
  Future<TeamModel> createTeam({
    required String name,
    String? shortCode,
    String? homeCity,
    String? primaryColor,
    String? details,
  }) async {
    if (_createTeamError != null) throw _createTeamError!;
    if (_createTeamResult != null) return _createTeamResult!;
    throw Exception('createTeam not stubbed');
  }

  @override
  Future<List<TeamModel>> getAllTeams() async {
    if (_allTeamsError != null) throw _allTeamsError!;
    if (_allTeamsResult != null) return _allTeamsResult!;
    throw Exception('getAllTeams not stubbed');
  }

  // Unused members — throw if called by mistake
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeCricketRepository fakeRepo;
  late TeamBloc bloc;

  setUp(() {
    fakeRepo = FakeCricketRepository();
    bloc = TeamBloc(repo: fakeRepo);
  });

  tearDown(() {
    bloc.close();
  });

  group('TeamBloc', () {
    test('initial state is TeamInitial', () {
      expect(bloc.state, isA<TeamInitial>());
    });

    group('CreateTeamRequested', () {
      final testTeam = TeamModel(
        id: '123',
        name: 'Test Team',
        shortCode: 'TT',
        teamCode: '001',
        playerCount: 0,
      );

      test('emits TeamLoading then TeamSuccess on success', () async {
        fakeRepo.stubCreateTeam(testTeam);

        final states = <TeamState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(const CreateTeamRequested(name: 'Test Team'));

        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], isA<TeamLoading>());
        expect(states[1], isA<TeamSuccess>());
        expect((states[1] as TeamSuccess).team.name, 'Test Team');
        expect((states[1] as TeamSuccess).team.teamCode, '001');

        await subscription.cancel();
      });

      test('emits TeamLoading then TeamFailure on error', () async {
        fakeRepo.stubCreateTeamError(
          Exception('Server error: team name already exists'),
        );

        final states = <TeamState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(const CreateTeamRequested(name: 'Bad Team'));

        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], isA<TeamLoading>());
        expect(states[1], isA<TeamFailure>());
        expect(
          (states[1] as TeamFailure).message,
          contains('team name already exists'),
        );

        await subscription.cancel();
      });

      test('emits TeamFailure with fallback for non-Exception error', () async {
        fakeRepo.stubCreateTeamError('raw string error');

        final states = <TeamState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(const CreateTeamRequested(name: 'Test'));

        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[1], isA<TeamFailure>());
        expect(
          (states[1] as TeamFailure).message,
          'An unexpected error occurred',
        );

        await subscription.cancel();
      });
    });

    group('LoadTeamsRequested', () {
      final testTeams = [
        const TeamModel(id: '1', name: 'Team A', shortCode: 'TA'),
        const TeamModel(id: '2', name: 'Team B', shortCode: 'TB'),
      ];

      test('emits TeamLoading then TeamsLoaded on success', () async {
        fakeRepo.stubAllTeams(testTeams);

        final states = <TeamState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(LoadTeamsRequested());

        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[0], isA<TeamLoading>());
        expect(states[1], isA<TeamsLoaded>());
        expect((states[1] as TeamsLoaded).teams.length, 2);

        await subscription.cancel();
      });

      test('emits TeamFailure on error', () async {
        fakeRepo.stubAllTeamsError(Exception('Network error'));

        final states = <TeamState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(LoadTeamsRequested());

        await Future<void>.delayed(Duration.zero);

        expect(states.length, 2);
        expect(states[1], isA<TeamFailure>());
        expect((states[1] as TeamFailure).message, contains('Network error'));

        await subscription.cancel();
      });
    });
  });
}
