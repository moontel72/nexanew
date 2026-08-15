import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class SquadSetupState {
  const SquadSetupState();
}

final class SquadSetupInitial extends SquadSetupState {}

final class SquadSetupLoading extends SquadSetupState {}

final class SquadSetupError extends SquadSetupState {
  final String message;
  const SquadSetupError(this.message);
}

/// Lineup builder state: the playing XI (batting order) and bench for the
/// selected team. All reordering/add/remove operations happen here — the
/// page is a pure function of this state.
final class SquadSetupLoaded extends SquadSetupState {
  final String matchId;
  final MatchModel? match;
  final List<PlayerModel> allPlayers;
  final List<MatchSquadModel> squads;
  final String? selectedTeamId;

  /// Current XI in batting order.
  final List<PlayerModel> xi;
  final bool saving;

  const SquadSetupLoaded({
    required this.matchId,
    this.match,
    this.allPlayers = const [],
    this.squads = const [],
    this.selectedTeamId,
    this.xi = const [],
    this.saving = false,
  });

  SquadSetupLoaded copyWith({
    MatchModel? match,
    List<PlayerModel>? allPlayers,
    List<MatchSquadModel>? squads,
    String? selectedTeamId,
    List<PlayerModel>? xi,
    bool? saving,
  }) => SquadSetupLoaded(
    matchId: matchId,
    match: match ?? this.match,
    allPlayers: allPlayers ?? this.allPlayers,
    squads: squads ?? this.squads,
    selectedTeamId: selectedTeamId ?? this.selectedTeamId,
    xi: xi ?? this.xi,
    saving: saving ?? this.saving,
  );

  /// Registered players of the selected team who are not in the XI.
  List<PlayerModel> get bench => allPlayers
      .where((p) => p.teamId == selectedTeamId && !xi.any((x) => x.id == p.id))
      .toList();

  String? get selectedTeamName {
    final t = match;
    if (t == null) return null;
    return selectedTeamId == t.teamAId ? t.teamAName : t.teamBName;
  }
}

final class SquadSetupSaved extends SquadSetupState {
  final String teamName;
  const SquadSetupSaved(this.teamName);
}

// ─── Events ──────────────────────────────────────────────

sealed class SquadSetupEvent {
  const SquadSetupEvent();
}

final class LoadSquadSetup extends SquadSetupEvent {
  final String matchId;
  const LoadSquadSetup(this.matchId);
}

final class SelectSquadTeam extends SquadSetupEvent {
  final String teamId;
  const SelectSquadTeam(this.teamId);
}

final class AddToXi extends SquadSetupEvent {
  final String playerId;
  const AddToXi(this.playerId);
}

final class RemoveFromXi extends SquadSetupEvent {
  final String playerId;
  const RemoveFromXi(this.playerId);
}

final class MoveXiUp extends SquadSetupEvent {
  final int index;
  const MoveXiUp(this.index);
}

final class MoveXiDown extends SquadSetupEvent {
  final int index;
  const MoveXiDown(this.index);
}

final class SaveSquad extends SquadSetupEvent {}

// ─── BLoC ────────────────────────────────────────────────

class SquadSetupBloc extends Bloc<SquadSetupEvent, SquadSetupState> {
  final CricketRepository _repo;
  String? _matchId;

  SquadSetupBloc({required CricketRepository repo})
    : _repo = repo,
      super(SquadSetupInitial()) {
    on<LoadSquadSetup>(_onLoad);
    on<SelectSquadTeam>(_onSelectTeam);
    on<AddToXi>(_onAddToXi);
    on<RemoveFromXi>(_onRemoveFromXi);
    on<MoveXiUp>(_onMoveUp);
    on<MoveXiDown>(_onMoveDown);
    on<SaveSquad>(_onSave);
  }

  Future<void> _onLoad(LoadSquadSetup e, Emitter<SquadSetupState> emit) async {
    _matchId = e.matchId;
    emit(SquadSetupLoading());

    MatchModel? match;
    List<PlayerModel> players = const [];
    List<MatchSquadModel> squads = const [];
    try {
      match = await _repo.getMatch(e.matchId);
      players = await _repo.getAllPlayers();
      squads = await _repo.getMatchSquads(e.matchId);
    } catch (_) {
      emit(const SquadSetupError('Failed to load squad data.'));
      return;
    }

    emit(
      _buildLoaded(
        match: match,
        players: players,
        squads: squads,
        selectedTeamId: match?.teamAId,
      ),
    );
  }

  void _onSelectTeam(SelectSquadTeam e, Emitter<SquadSetupState> emit) {
    final s = state;
    if (s is! SquadSetupLoaded) return;
    emit(
      s.copyWith(
        selectedTeamId: e.teamId,
        xi: _xiFor(s.squads, s.allPlayers, e.teamId),
      ),
    );
  }

  void _onAddToXi(AddToXi e, Emitter<SquadSetupState> emit) {
    final s = state;
    if (s is! SquadSetupLoaded) return;
    final player = _findPlayer(s.allPlayers, e.playerId);
    if (player == null ||
        s.xi.length >= 11 ||
        s.xi.any((x) => x.id == player.id)) {
      return;
    }
    emit(s.copyWith(xi: [...s.xi, player]));
  }

  void _onRemoveFromXi(RemoveFromXi e, Emitter<SquadSetupState> emit) {
    final s = state;
    if (s is! SquadSetupLoaded) return;
    emit(s.copyWith(xi: s.xi.where((x) => x.id != e.playerId).toList()));
  }

  void _onMoveUp(MoveXiUp e, Emitter<SquadSetupState> emit) {
    final s = state;
    if (s is! SquadSetupLoaded || e.index <= 0) return;
    final list = [...s.xi];
    final moved = list.removeAt(e.index);
    list.insert(e.index - 1, moved);
    emit(s.copyWith(xi: list));
  }

  void _onMoveDown(MoveXiDown e, Emitter<SquadSetupState> emit) {
    final s = state;
    if (s is! SquadSetupLoaded || e.index >= s.xi.length - 1) return;
    final list = [...s.xi];
    final moved = list.removeAt(e.index);
    list.insert(e.index + 1, moved);
    emit(s.copyWith(xi: list));
  }

  Future<void> _onSave(SaveSquad e, Emitter<SquadSetupState> emit) async {
    final s = state;
    if (s is! SquadSetupLoaded || s.selectedTeamId == null || s.xi.isEmpty) {
      return;
    }

    emit(s.copyWith(saving: true));

    final entries = [
      for (var i = 0; i < s.xi.length; i++)
        {'player_id': s.xi[i].id, 'batting_order': i + 1},
    ];

    try {
      await _repo.saveMatchSquad(_matchId!, s.selectedTeamId!, entries);
      emit(SquadSetupSaved(s.selectedTeamName ?? 'Team'));
    } catch (err) {
      // Surface the server's message, then restore the editable state.
      final error = SquadSetupError(
        err.toString().replaceFirst('Exception: ', ''),
      );
      emit(error);
      emit(
        _buildLoaded(
          match: s.match,
          players: s.allPlayers,
          squads: s.squads,
          selectedTeamId: s.selectedTeamId,
        ),
      );
    }
  }

  // ── Helpers ─────────────────────────────────────────────

  static PlayerModel? _findPlayer(List<PlayerModel> players, String id) {
    for (final p in players) {
      if (p.id == id) return p;
    }
    return null;
  }

  static MatchSquadModel? _findSquad(
    List<MatchSquadModel> squads,
    String teamId,
  ) {
    for (final s in squads) {
      if (s.teamId == teamId) return s;
    }
    return null;
  }

  SquadSetupLoaded _buildLoaded({
    required MatchModel? match,
    required List<PlayerModel> players,
    required List<MatchSquadModel> squads,
    String? selectedTeamId,
  }) {
    final teamId = selectedTeamId ?? match?.teamAId;
    return SquadSetupLoaded(
      matchId: _matchId ?? '',
      match: match,
      allPlayers: players,
      squads: squads,
      selectedTeamId: teamId,
      xi: _xiFor(squads, players, teamId),
    );
  }

  /// Rebuild the XI (in batting order) for [teamId] from the stored squad.
  List<PlayerModel> _xiFor(
    List<MatchSquadModel> squads,
    List<PlayerModel> players,
    String? teamId,
  ) {
    if (teamId == null) return const [];
    final squad = _findSquad(squads, teamId);
    if (squad == null || squad.players.isEmpty) return const [];

    final ordered = [...squad.players];
    ordered.sort(
      (a, b) => (a.battingOrder ?? 999).compareTo(b.battingOrder ?? 999),
    );

    final xi = <PlayerModel>[];
    for (final sp in ordered) {
      final player = _findPlayer(players, sp.playerId);
      if (player != null) xi.add(player);
    }
    return xi;
  }
}
