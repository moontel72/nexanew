import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ────────────────────────────────────────────────────

sealed class FixtureState {
  const FixtureState();
}

final class FixtureInitial extends FixtureState {
  const FixtureInitial();
}

final class FixtureLoading extends FixtureState {
  const FixtureLoading();
}

final class FixtureLoaded extends FixtureState {
  final String tournamentId;
  final List<MatchModel> matches;
  final List<TeamModel> teams;
  final List<GroundModel> grounds;

  /// null = all stages.
  final String? stageFilter;

  const FixtureLoaded({
    required this.tournamentId,
    this.matches = const [],
    this.teams = const [],
    this.grounds = const [],
    this.stageFilter,
  });

  FixtureLoaded copyWith({
    List<MatchModel>? matches,
    List<TeamModel>? teams,
    List<GroundModel>? grounds,
    String? stageFilter,
    bool clearStageFilter = false,
  }) => FixtureLoaded(
    tournamentId: tournamentId,
    matches: matches ?? this.matches,
    teams: teams ?? this.teams,
    grounds: grounds ?? this.grounds,
    stageFilter: clearStageFilter ? null : (stageFilter ?? this.stageFilter),
  );
}

final class FixtureError extends FixtureState {
  final String message;
  const FixtureError(this.message);
}

/// Transient notice after a mutation. Listeners use [action] to decide
/// whether to react (e.g. a form only closes on `saveMatch` success).
final class FixtureNotice extends FixtureState {
  final String action;
  final bool success;
  final String message;

  const FixtureNotice({
    required this.action,
    required this.success,
    required this.message,
  });
}

// ─── Events ────────────────────────────────────────────────────

sealed class FixtureEvent {
  const FixtureEvent();
}

final class LoadFixtures extends FixtureEvent {
  final String? tournamentId;
  const LoadFixtures({this.tournamentId});
}

final class RefreshFixtures extends FixtureEvent {
  const RefreshFixtures();
}

final class SetStageFilter extends FixtureEvent {
  final String? stage;
  const SetStageFilter(this.stage);
}

final class CreateMatchRequested extends FixtureEvent {
  final String tournamentId;
  final String teamAId;
  final String teamBId;
  final DateTime scheduledAt;
  final String matchType;
  final String? venue;
  final String? groundId;
  final int? oversPerSide;
  final String? stage;

  const CreateMatchRequested({
    required this.tournamentId,
    required this.teamAId,
    required this.teamBId,
    required this.scheduledAt,
    required this.matchType,
    this.venue,
    this.groundId,
    this.oversPerSide,
    this.stage,
  });
}

final class UpdateMatchRequested extends FixtureEvent {
  final String matchId;
  final String? teamAId;
  final String? teamBId;
  final DateTime? scheduledAt;
  final String? matchType;
  final String? venue;
  final String? groundId;
  final int? oversPerSide;
  final String? stage;

  const UpdateMatchRequested({
    required this.matchId,
    this.teamAId,
    this.teamBId,
    this.scheduledAt,
    this.matchType,
    this.venue,
    this.groundId,
    this.oversPerSide,
    this.stage,
  });
}

final class DeleteMatchRequested extends FixtureEvent {
  final String matchId;
  const DeleteMatchRequested(this.matchId);
}

final class ChangeMatchStatusRequested extends FixtureEvent {
  final String matchId;
  final String status;
  const ChangeMatchStatusRequested(this.matchId, this.status);
}

final class GenerateFixturesRequested extends FixtureEvent {
  final String tournamentId;
  final String format;
  final List<String> teamIds;
  final DateTime startDate;
  final int matchIntervalDays;
  final String? kickoffTime;
  final int? matchGapHours;
  final String matchType;
  final int? oversPerSide;
  final String? venue;
  final String? groundId;
  final String stage;

  const GenerateFixturesRequested({
    required this.tournamentId,
    required this.format,
    required this.startDate,
    this.teamIds = const [],
    this.matchIntervalDays = 1,
    this.kickoffTime,
    this.matchGapHours,
    this.matchType = 't20',
    this.oversPerSide,
    this.venue,
    this.groundId,
    this.stage = 'group_stage',
  });
}

final class CreateGroundRequested extends FixtureEvent {
  final String name;
  final String? location;
  const CreateGroundRequested({required this.name, this.location});
}

// ─── BLoC ──────────────────────────────────────────────────────

class FixtureBloc extends Bloc<FixtureEvent, FixtureState> {
  final CricketRepository _repo;

  /// Last successfully loaded state — lets refreshes triggered by
  /// mutations keep the active stage filter.
  FixtureLoaded? _lastLoaded;

  FixtureBloc({required CricketRepository repo})
    : _repo = repo,
      super(const FixtureInitial()) {
    on<LoadFixtures>(_onLoad);
    on<RefreshFixtures>(_onRefresh);
    on<SetStageFilter>(_onSetStageFilter);
    on<CreateMatchRequested>(_onCreateMatch);
    on<UpdateMatchRequested>(_onUpdateMatch);
    on<DeleteMatchRequested>(_onDeleteMatch);
    on<ChangeMatchStatusRequested>(_onChangeStatus);
    on<GenerateFixturesRequested>(_onGenerate);
    on<CreateGroundRequested>(_onCreateGround);
  }

  Future<void> _onLoad(LoadFixtures e, Emitter<FixtureState> emit) async {
    emit(const FixtureLoading());
    try {
      var tournamentId = e.tournamentId;
      if (tournamentId == null || tournamentId.isEmpty) {
        tournamentId = (await _repo.getActiveTournament())?.id;
      }
      if (tournamentId == null || tournamentId.isEmpty) {
        emit(
          const FixtureError(
            'No active tournament found. Activate a tournament first.',
          ),
        );
        return;
      }
      final loaded = await _fetchAll(tournamentId);
      _lastLoaded = loaded;
      emit(loaded);
    } catch (error) {
      emit(FixtureError(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(RefreshFixtures e, Emitter<FixtureState> emit) async {
    final current = state;
    final tournamentId = current is FixtureLoaded
        ? current.tournamentId
        : _lastLoaded?.tournamentId;
    final previousFilter =
        _lastLoaded?.stageFilter ??
        (current is FixtureLoaded ? current.stageFilter : null);

    emit(const FixtureLoading());
    try {
      var tid = tournamentId;
      if (tid == null || tid.isEmpty) {
        tid = (await _repo.getActiveTournament())?.id;
      }
      if (tid == null || tid.isEmpty) {
        emit(const FixtureError('No active tournament found.'));
        return;
      }
      final loaded = await _fetchAll(tid);
      _lastLoaded = loaded;
      emit(loaded.copyWith(stageFilter: previousFilter));
    } catch (error) {
      emit(FixtureError(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onSetStageFilter(SetStageFilter e, Emitter<FixtureState> emit) {
    final s = state;
    if (s is FixtureLoaded) {
      emit(s.copyWith(clearStageFilter: e.stage == null, stageFilter: e.stage));
    }
  }

  Future<FixtureLoaded> _fetchAll(String tournamentId) async {
    final results = await Future.wait<Object>([
      _repo.getManagerMatches(tournamentId: tournamentId),
      _repo.getAllTeams(),
      _repo.getGrounds(),
    ]);
    return FixtureLoaded(
      tournamentId: tournamentId,
      matches: results[0] as List<MatchModel>,
      teams: results[1] as List<TeamModel>,
      grounds: results[2] as List<GroundModel>,
    );
  }

  Future<void> _onCreateMatch(
    CreateMatchRequested e,
    Emitter<FixtureState> emit,
  ) async {
    try {
      await _repo.createMatch(
        tournamentId: e.tournamentId,
        teamAId: e.teamAId,
        teamBId: e.teamBId,
        scheduledAt: e.scheduledAt,
        matchType: e.matchType,
        venue: e.venue,
        groundId: e.groundId,
        oversPerSide: e.oversPerSide,
        stage: e.stage,
      );
      emit(
        const FixtureNotice(
          action: 'saveMatch',
          success: true,
          message: 'Fixture saved.',
        ),
      );
    } catch (error) {
      emit(
        FixtureNotice(
          action: 'saveMatch',
          success: false,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
    add(const RefreshFixtures());
  }

  Future<void> _onUpdateMatch(
    UpdateMatchRequested e,
    Emitter<FixtureState> emit,
  ) async {
    try {
      await _repo.updateMatch(
        matchId: e.matchId,
        teamAId: e.teamAId,
        teamBId: e.teamBId,
        scheduledAt: e.scheduledAt,
        matchType: e.matchType,
        venue: e.venue,
        groundId: e.groundId,
        oversPerSide: e.oversPerSide,
        stage: e.stage,
      );
      emit(
        const FixtureNotice(
          action: 'saveMatch',
          success: true,
          message: 'Fixture updated.',
        ),
      );
    } catch (error) {
      emit(
        FixtureNotice(
          action: 'saveMatch',
          success: false,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
    add(const RefreshFixtures());
  }

  Future<void> _onDeleteMatch(
    DeleteMatchRequested e,
    Emitter<FixtureState> emit,
  ) async {
    try {
      await _repo.deleteMatch(e.matchId);
      emit(
        const FixtureNotice(
          action: 'deleteMatch',
          success: true,
          message: 'Fixture deleted.',
        ),
      );
    } catch (error) {
      emit(
        FixtureNotice(
          action: 'deleteMatch',
          success: false,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
    add(const RefreshFixtures());
  }

  Future<void> _onChangeStatus(
    ChangeMatchStatusRequested e,
    Emitter<FixtureState> emit,
  ) async {
    try {
      await _repo.updateMatchStatus(e.matchId, e.status);
      emit(
        FixtureNotice(
          action: 'statusChange',
          success: true,
          message: e.status == 'cancelled'
              ? 'Fixture cancelled.'
              : 'Fixture re-opened.',
        ),
      );
    } catch (error) {
      emit(
        FixtureNotice(
          action: 'statusChange',
          success: false,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
    add(const RefreshFixtures());
  }

  Future<void> _onGenerate(
    GenerateFixturesRequested e,
    Emitter<FixtureState> emit,
  ) async {
    try {
      final count = await _repo.generateFixtures(
        tournamentId: e.tournamentId,
        format: e.format,
        teamIds: e.teamIds,
        startDate: e.startDate,
        matchIntervalDays: e.matchIntervalDays,
        kickoffTime: e.kickoffTime,
        matchGapHours: e.matchGapHours,
        matchType: e.matchType,
        oversPerSide: e.oversPerSide,
        venue: e.venue,
        groundId: e.groundId,
        stage: e.stage,
      );
      emit(
        FixtureNotice(
          action: 'generate',
          success: true,
          message: '$count fixtures generated.',
        ),
      );
    } catch (error) {
      emit(
        FixtureNotice(
          action: 'generate',
          success: false,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
    add(const RefreshFixtures());
  }

  Future<void> _onCreateGround(
    CreateGroundRequested e,
    Emitter<FixtureState> emit,
  ) async {
    try {
      await _repo.createGround(name: e.name, location: e.location);
      emit(
        const FixtureNotice(
          action: 'groundCreated',
          success: true,
          message: 'Ground added.',
        ),
      );
    } catch (error) {
      emit(
        FixtureNotice(
          action: 'groundCreated',
          success: false,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
    add(const RefreshFixtures());
  }
}
