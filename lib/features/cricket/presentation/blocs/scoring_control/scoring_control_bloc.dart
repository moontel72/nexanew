import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class ScoringControlState {
  const ScoringControlState();
}

final class ScoringControlInitial extends ScoringControlState {}

final class ScoringControlLoading extends ScoringControlState {}

final class ScoringControlError extends ScoringControlState {
  final String message;
  const ScoringControlError(this.message);
}

/// All selection state for the scoring console: players on the crease,
/// bowler, toss form, wicket form, and eligibility data. This state is the
/// single source of truth for the left scoring panel — no widget-local
/// state (setState) is used anywhere.
final class ScoringControlLoaded extends ScoringControlState {
  final String matchId;
  final MatchModel? match;
  final List<PlayerModel> players;
  final List<MatchSquadModel> squads;

  /// Batting/bowling team IDs (batting side may flip between innings).
  final String? battingTeamId;
  final String? bowlingTeamId;

  // On-field selections — kept in sync with the backend's realtime
  // snapshot (the engine owns rotation truth; the UI follows it).
  final String? strikerId;
  final String? nonStrikerId;
  final String? bowlerId;
  final int totalBalls;
  final int? maxOversPerBowler;
  final List<BowlerStats> bowlers;
  final List<PlayerStats> batters;
  final String? lastOverBowlerId;

  /// Legacy mode: submit balls without player attribution.
  final bool playerTrackingDisabled;

  // Toss form.
  final bool showTossForm;
  final String? tossWinnerTeamId;
  final String tossDecision;

  // Wicket form.
  final bool showWicketForm;
  final String wicketType;
  final String? wicketDismissedId;
  final String? wicketNextBatterId;

  /// Wicket sheet mode: normal dismissal or retired hurt.
  final String wicketMode;

  /// Phase 5 — boundary waiting for a shot-direction pick.
  final int? pendingBoundaryRuns;

  const ScoringControlLoaded({
    required this.matchId,
    this.match,
    this.players = const [],
    this.squads = const [],
    this.battingTeamId,
    this.bowlingTeamId,
    this.strikerId,
    this.nonStrikerId,
    this.bowlerId,
    this.totalBalls = 0,
    this.maxOversPerBowler,
    this.bowlers = const [],
    this.batters = const [],
    this.lastOverBowlerId,
    this.playerTrackingDisabled = false,
    this.showTossForm = false,
    this.tossWinnerTeamId,
    this.tossDecision = 'bat',
    this.showWicketForm = false,
    this.wicketType = 'bowled',
    this.wicketDismissedId,
    this.wicketNextBatterId,
    this.wicketMode = 'wicket',
    this.pendingBoundaryRuns,
  });

  ScoringControlLoaded copyWith({
    MatchModel? match,
    List<PlayerModel>? players,
    List<MatchSquadModel>? squads,
    String? battingTeamId,
    String? bowlingTeamId,
    String? strikerId,
    String? nonStrikerId,
    String? bowlerId,
    int? totalBalls,
    int? maxOversPerBowler,
    List<BowlerStats>? bowlers,
    List<PlayerStats>? batters,
    String? lastOverBowlerId,
    bool? playerTrackingDisabled,
    bool? showTossForm,
    String? tossWinnerTeamId,
    String? tossDecision,
    bool? showWicketForm,
    String? wicketType,
    String? wicketDismissedId,
    String? wicketNextBatterId,
    String? wicketMode,
    int? pendingBoundaryRuns,
  }) => ScoringControlLoaded(
    matchId: matchId,
    match: match ?? this.match,
    players: players ?? this.players,
    squads: squads ?? this.squads,
    battingTeamId: battingTeamId ?? this.battingTeamId,
    bowlingTeamId: bowlingTeamId ?? this.bowlingTeamId,
    strikerId: strikerId ?? this.strikerId,
    nonStrikerId: nonStrikerId ?? this.nonStrikerId,
    bowlerId: bowlerId ?? this.bowlerId,
    totalBalls: totalBalls ?? this.totalBalls,
    maxOversPerBowler: maxOversPerBowler ?? this.maxOversPerBowler,
    bowlers: bowlers ?? this.bowlers,
    batters: batters ?? this.batters,
    lastOverBowlerId: lastOverBowlerId ?? this.lastOverBowlerId,
    playerTrackingDisabled:
        playerTrackingDisabled ?? this.playerTrackingDisabled,
    showTossForm: showTossForm ?? this.showTossForm,
    tossWinnerTeamId: tossWinnerTeamId ?? this.tossWinnerTeamId,
    tossDecision: tossDecision ?? this.tossDecision,
    showWicketForm: showWicketForm ?? this.showWicketForm,
    wicketType: wicketType ?? this.wicketType,
    wicketDismissedId: wicketDismissedId ?? this.wicketDismissedId,
    wicketNextBatterId: wicketNextBatterId ?? this.wicketNextBatterId,
    wicketMode: wicketMode ?? this.wicketMode,
    pendingBoundaryRuns: pendingBoundaryRuns ?? this.pendingBoundaryRuns,
  );

  // ── Derived data for the scoring panel ─────────────────

  List<PlayerModel> get battingPlayers =>
      players.where((p) => p.teamId == battingTeamId).toList();

  List<PlayerModel> get bowlingPlayers => players
      .where(
        (p) =>
            p.teamId == bowlingTeamId ||
            (bowlingTeamId == null &&
                match != null &&
                p.teamId != battingTeamId &&
                (p.teamId == match!.teamAId || p.teamId == match!.teamBId)),
      )
      .toList();

  PlayerModel? playerById(String? id) {
    if (id == null) return null;
    for (final p in players) {
      if (p.id == id) return p;
    }
    return null;
  }

  BowlerStats? bowlerStatsFor(String? id) {
    if (id == null) return null;
    for (final b in bowlers) {
      if (b.playerId == id) return b;
    }
    return null;
  }

  MatchSquadModel? squadFor(String? teamId) {
    if (teamId == null) return null;
    for (final s in squads) {
      if (s.teamId == teamId) return s;
    }
    return null;
  }

  /// Squad players ordered by batting order.
  List<SquadPlayerModel> get orderedSquad {
    final squad = squadFor(battingTeamId);
    if (squad == null) return const [];
    final list = [...squad.players];
    list.sort(
      (a, b) => (a.battingOrder ?? 999).compareTo(b.battingOrder ?? 999),
    );
    return list;
  }

  /// First squad player (by batting order) who is not dismissed and not
  /// at the crease — the suggested replacement after a wicket.
  PlayerModel? get nextBatterSuggestion {
    final dismissedIds = batters
        .where((b) => b.dismissed)
        .map((b) => b.playerId)
        .toSet();
    final atCrease = {strikerId, nonStrikerId};
    for (final sp in orderedSquad) {
      final player = playerById(sp.playerId);
      if (player == null) continue;
      if (dismissedIds.contains(player.id) || atCrease.contains(player.id)) {
        continue;
      }
      return player;
    }
    return null;
  }

  /// Bowlers who can bowl right now: within the over limit and (when a
  /// new over starts) not the previous over's bowler.
  List<PlayerModel> get eligibleBowlers {
    final maxBalls = (maxOversPerBowler ?? 4) * 6;
    return bowlingPlayers.where((p) {
      final ballsBowled = bowlerStatsFor(p.id)?.balls ?? 0;
      if (ballsBowled >= maxBalls) return false;
      if (bowlerId == null && lastOverBowlerId == p.id) return false;
      return true;
    }).toList();
  }

  // Phase flags for the panel.
  bool get needsOpeners =>
      !playerTrackingDisabled && totalBalls == 0 && strikerId == null;

  bool get awaitingBowler =>
      !playerTrackingDisabled && totalBalls > 0 && bowlerId == null;

  bool get awaitingNextBatter =>
      !playerTrackingDisabled &&
      totalBalls > 0 &&
      strikerId == null &&
      !awaitingBowler;
}

// ─── Events ──────────────────────────────────────────────

sealed class ScoringControlEvent {
  const ScoringControlEvent();
}

final class LoadControlData extends ScoringControlEvent {
  final String matchId;
  const LoadControlData(this.matchId);
}

/// Backend push: the engine's current striker / non-striker / bowler
/// state after every recorded ball (single source of truth).
final class SyncFromSnapshot extends ScoringControlEvent {
  final LiveScoreSnapshot snapshot;
  const SyncFromSnapshot(this.snapshot);
}

final class SelectStriker extends ScoringControlEvent {
  final String playerId;
  const SelectStriker(this.playerId);
}

final class SelectNonStriker extends ScoringControlEvent {
  final String playerId;
  const SelectNonStriker(this.playerId);
}

final class SelectBowler extends ScoringControlEvent {
  final String playerId;
  const SelectBowler(this.playerId);
}

/// Manual strike swap (e.g. crossed on a run-out).
final class SwapStrike extends ScoringControlEvent {}

final class TogglePlayerTracking extends ScoringControlEvent {}

final class TossToggleForm extends ScoringControlEvent {}

final class TossSelectWinner extends ScoringControlEvent {
  final String? teamId;
  const TossSelectWinner(this.teamId);
}

final class TossSelectDecision extends ScoringControlEvent {
  final String decision;
  const TossSelectDecision(this.decision);
}

final class WicketOpen extends ScoringControlEvent {}

final class WicketSelectType extends ScoringControlEvent {
  final String type;
  const WicketSelectType(this.type);
}

final class WicketSelectDismissed extends ScoringControlEvent {
  final String playerId;
  const WicketSelectDismissed(this.playerId);
}

final class WicketSelectNextBatter extends ScoringControlEvent {
  final String playerId;
  const WicketSelectNextBatter(this.playerId);
}

final class WicketClose extends ScoringControlEvent {}

final class WicketSelectMode extends ScoringControlEvent {
  final String mode;
  const WicketSelectMode(this.mode);
}

/// Phase 5 — a FOUR/SIX was tapped and is waiting for a shot direction.
final class BoundaryTapped extends ScoringControlEvent {
  final int runs;
  const BoundaryTapped(this.runs);
}

final class CloseBoundary extends ScoringControlEvent {}

final class ResetControl extends ScoringControlEvent {}

// ─── BLoC ────────────────────────────────────────────────

class ScoringControlBloc
    extends Bloc<ScoringControlEvent, ScoringControlState> {
  final CricketRepository _repo;
  StreamSubscription<LiveScoreSnapshot>? _scoreSub;
  String? _matchId;

  ScoringControlBloc({required CricketRepository repo})
    : _repo = repo,
      super(ScoringControlInitial()) {
    on<LoadControlData>(_onLoad);
    on<SyncFromSnapshot>(_onSync);
    on<SelectStriker>(_onSelectStriker);
    on<SelectNonStriker>(_onSelectNonStriker);
    on<SelectBowler>(_onSelectBowler);
    on<SwapStrike>(_onSwapStrike);
    on<TogglePlayerTracking>(_onTogglePlayerTracking);
    on<TossToggleForm>(_onTossToggleForm);
    on<TossSelectWinner>(_onTossSelectWinner);
    on<TossSelectDecision>(_onTossSelectDecision);
    on<WicketOpen>(_onWicketOpen);
    on<WicketSelectType>(_onWicketSelectType);
    on<WicketSelectDismissed>(_onWicketSelectDismissed);
    on<WicketSelectNextBatter>(_onWicketSelectNextBatter);
    on<WicketClose>(_onWicketClose);
    on<WicketSelectMode>(_onWicketSelectMode);
    on<BoundaryTapped>(_onBoundaryTapped);
    on<CloseBoundary>(_onCloseBoundary);
    on<ResetControl>(_onReset);
  }

  Future<void> _onLoad(
    LoadControlData e,
    Emitter<ScoringControlState> emit,
  ) async {
    _matchId = e.matchId;
    emit(ScoringControlLoading());

    MatchModel? match;
    List<PlayerModel> players = const [];
    List<MatchSquadModel> squads = const [];
    LiveScoreSnapshot? initialScore;

    try {
      match = await _repo.getMatch(e.matchId);
      players = await _repo.getAllPlayers();
      squads = await _repo.getMatchSquads(e.matchId);
      initialScore = await _repo.fetchScore(e.matchId);
    } catch (_) {
      // Data is best-effort — the panel still renders with what we have.
    }

    final battingTeamId = initialScore?.battingTeamId ?? match?.teamAId ?? '';
    final bowlingTeamId = battingTeamId == match?.teamAId
        ? match?.teamBId
        : match?.teamAId;

    emit(
      ScoringControlLoaded(
        matchId: e.matchId,
        match: match,
        players: players,
        squads: squads,
        battingTeamId: battingTeamId,
        bowlingTeamId: bowlingTeamId,
      ),
    );

    if (initialScore != null) {
      add(SyncFromSnapshot(initialScore));
    }

    // Follow the backend engine's state after every recorded ball.
    _scoreSub?.cancel();
    _scoreSub = _repo.scoreStream.listen((snapshot) {
      if (!isClosed && snapshot.matchId == _matchId) {
        add(SyncFromSnapshot(snapshot));
      }
    });
  }

  void _onSync(SyncFromSnapshot e, Emitter<ScoringControlState> emit) {
    final s = state;
    if (s is! ScoringControlLoaded) return;

    final snapshot = e.snapshot;
    final current = snapshot.currentPlayers;

    String? striker = s.strikerId;
    String? nonStriker = s.nonStrikerId;
    String? bowler = s.bowlerId;
    if (current != null) {
      striker = current.striker?.playerId;
      nonStriker = current.nonStriker?.playerId;
      bowler = current.bowler?.playerId;
    }

    // When an over ends the engine clears the bowler; remember who bowled
    // the previous over so the UI can exclude them from the next pick.
    String? lastOverBowler = s.lastOverBowlerId;
    if (bowler == null && snapshot.overs > 0) {
      for (final ball in snapshot.recentBalls.reversed) {
        if (ball.bowlerId != null) {
          lastOverBowler = ball.bowlerId;
          break;
        }
      }
    } else if (bowler != null) {
      lastOverBowler = null;
    }

    emit(
      s.copyWith(
        battingTeamId: snapshot.battingTeamId ?? s.battingTeamId,
        strikerId: striker,
        nonStrikerId: nonStriker,
        bowlerId: bowler,
        totalBalls: _ballsFromOvers(snapshot.overs),
        maxOversPerBowler: snapshot.maxOversPerBowler,
        bowlers: snapshot.bowlers,
        batters: snapshot.batters,
        lastOverBowlerId: lastOverBowler,
      ),
    );
  }

  void _onSelectStriker(SelectStriker e, Emitter<ScoringControlState> emit) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    // Prevent the same player occupying both ends.
    final nonStriker = s.nonStrikerId == e.playerId
        ? s.strikerId
        : s.nonStrikerId;
    emit(s.copyWith(strikerId: e.playerId, nonStrikerId: nonStriker));
  }

  void _onSelectNonStriker(
    SelectNonStriker e,
    Emitter<ScoringControlState> emit,
  ) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    final striker = s.strikerId == e.playerId ? s.nonStrikerId : s.strikerId;
    emit(s.copyWith(strikerId: striker, nonStrikerId: e.playerId));
  }

  void _onSelectBowler(SelectBowler e, Emitter<ScoringControlState> emit) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(bowlerId: e.playerId));
  }

  void _onSwapStrike(SwapStrike e, Emitter<ScoringControlState> emit) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(strikerId: s.nonStrikerId, nonStrikerId: s.strikerId));
  }

  void _onTogglePlayerTracking(
    TogglePlayerTracking e,
    Emitter<ScoringControlState> emit,
  ) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(
      s.copyWith(
        playerTrackingDisabled: !s.playerTrackingDisabled,
        showWicketForm: false,
      ),
    );
  }

  void _onTossToggleForm(TossToggleForm e, Emitter<ScoringControlState> emit) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(showTossForm: !s.showTossForm));
  }

  void _onTossSelectWinner(
    TossSelectWinner e,
    Emitter<ScoringControlState> emit,
  ) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(tossWinnerTeamId: e.teamId));
  }

  void _onTossSelectDecision(
    TossSelectDecision e,
    Emitter<ScoringControlState> emit,
  ) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(tossDecision: e.decision));
  }

  void _onWicketOpen(WicketOpen e, Emitter<ScoringControlState> emit) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(
      s.copyWith(
        showWicketForm: true,
        wicketType: 'bowled',
        wicketMode: 'wicket',
        wicketDismissedId: s.strikerId ?? s.nonStrikerId,
        wicketNextBatterId: s.nextBatterSuggestion?.id,
      ),
    );
  }

  void _onWicketSelectType(
    WicketSelectType e,
    Emitter<ScoringControlState> emit,
  ) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(wicketType: e.type));
  }

  void _onWicketSelectDismissed(
    WicketSelectDismissed e,
    Emitter<ScoringControlState> emit,
  ) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(wicketDismissedId: e.playerId));
  }

  void _onWicketSelectNextBatter(
    WicketSelectNextBatter e,
    Emitter<ScoringControlState> emit,
  ) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(wicketNextBatterId: e.playerId));
  }

  void _onWicketClose(WicketClose e, Emitter<ScoringControlState> emit) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(showWicketForm: false));
  }

  void _onWicketSelectMode(
    WicketSelectMode e,
    Emitter<ScoringControlState> emit,
  ) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(wicketMode: e.mode));
  }

  void _onBoundaryTapped(BoundaryTapped e, Emitter<ScoringControlState> emit) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(pendingBoundaryRuns: e.runs));
  }

  void _onCloseBoundary(CloseBoundary e, Emitter<ScoringControlState> emit) {
    final s = state;
    if (s is! ScoringControlLoaded) return;
    emit(s.copyWith(pendingBoundaryRuns: null));
  }

  void _onReset(ResetControl e, Emitter<ScoringControlState> emit) {
    _scoreSub?.cancel();
    _scoreSub = null;
    _matchId = null;
    emit(ScoringControlInitial());
  }

  @override
  Future<void> close() {
    _scoreSub?.cancel();
    return super.close();
  }

  /// Overs display float (x.y) → total legal balls.
  static int _ballsFromOvers(double overs) {
    final whole = overs.floor();
    final fraction = ((overs - whole) * 10).round();
    return whole * 6 + fraction;
  }
}
