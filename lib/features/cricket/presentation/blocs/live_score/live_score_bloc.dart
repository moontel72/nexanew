import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class LiveScoreState {
  const LiveScoreState();
}

final class LiveScoreInitial extends LiveScoreState {}

final class LiveScoreLoading extends LiveScoreState {}

/// A ball / undo / start request is in flight. Carries the last known
/// score so the UI never flickers back to a blank screen.
final class LiveScoreUpdating extends LiveScoreState {
  final LiveScoreSnapshot score;
  final MatchModel? match;
  const LiveScoreUpdating({required this.score, this.match});
}

final class LiveScoreConnected extends LiveScoreState {
  final LiveScoreSnapshot score;
  final bool isWebSocket;
  final List<CommentaryModel> commentary;
  final MatchModel? match;

  /// Transient feedback (success / failure) shown once via BlocListener.
  final String? notice;

  const LiveScoreConnected({
    required this.score,
    this.isWebSocket = true,
    this.commentary = const [],
    this.match,
    this.notice,
  });

  LiveScoreConnected copyWith({
    LiveScoreSnapshot? score,
    bool? isWebSocket,
    List<CommentaryModel>? commentary,
    MatchModel? match,
    String? notice,
  }) => LiveScoreConnected(
    score: score ?? this.score,
    isWebSocket: isWebSocket ?? this.isWebSocket,
    commentary: commentary ?? this.commentary,
    match: match ?? this.match,
    notice: notice,
  );
}

final class LiveScoreError extends LiveScoreState {
  final String message;
  const LiveScoreError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class LiveScoreEvent {
  const LiveScoreEvent();
}

final class ConnectToMatch extends LiveScoreEvent {
  final String matchId;
  const ConnectToMatch(this.matchId);
}

/// Record the toss and start the match in one flow.
final class StartMatch extends LiveScoreEvent {
  final String? tossWinnerTeamId;
  final String? tossDecision;
  final String? battingTeamId;
  final String? bowlingTeamId;

  /// Pass toss fields when the match is `scheduled`; null when the match
  /// is already `toss_done` and only needs starting.
  const StartMatch({
    this.tossWinnerTeamId,
    this.tossDecision,
    this.battingTeamId,
    this.bowlingTeamId,
  });
}

/// Submit one ball to the score endpoint.
final class SubmitBall extends LiveScoreEvent {
  final Map<String, dynamic> ball;
  const SubmitBall(this.ball);
}

/// Undo the last recorded ball.
final class UndoBall extends LiveScoreEvent {}

final class _ScoreUpdated extends LiveScoreEvent {
  final LiveScoreSnapshot score;
  const _ScoreUpdated(this.score);
}

final class DisconnectFromMatch extends LiveScoreEvent {}

// ─── BLoC ────────────────────────────────────────────────

class LiveScoreBloc extends Bloc<LiveScoreEvent, LiveScoreState> {
  final CricketRepository _repo;
  StreamSubscription? _wsSubscription;
  StreamSubscription<MatchUpdate>? _matchSub;
  Timer? _pollTimer;
  String? _currentMatchId;

  /// REST fallback interval when the realtime channel is unavailable.
  static const Duration pollInterval = Duration(seconds: 10);

  LiveScoreBloc({required CricketRepository repo})
    : _repo = repo,
      super(LiveScoreInitial()) {
    on<ConnectToMatch>(_onConnect);
    on<StartMatch>(_onStartMatch);
    on<SubmitBall>(_onSubmitBall);
    on<UndoBall>(_onUndoBall);
    on<_ScoreUpdated>(_onScoreUpdated);
    on<DisconnectFromMatch>(_onDisconnect);
  }

  LiveScoreSnapshot get _lastScore {
    final s = state;
    if (s is LiveScoreConnected) return s.score;
    if (s is LiveScoreUpdating) return s.score;
    return const LiveScoreSnapshot();
  }

  MatchModel? get _lastMatch {
    final s = state;
    if (s is LiveScoreConnected) return s.match;
    if (s is LiveScoreUpdating) return s.match;
    return null;
  }

  Future<void> _onConnect(
    ConnectToMatch e,
    Emitter<LiveScoreState> emit,
  ) async {
    emit(LiveScoreLoading());
    _currentMatchId = e.matchId;

    // Manager match detail (team ids for the toss flow). Non-fatal.
    MatchModel? match;
    try {
      match = await _repo.getMatch(e.matchId);
    } catch (_) {}

    // Initial score via REST.
    LiveScoreSnapshot? initial;
    try {
      initial = await _repo.fetchScore(e.matchId);
    } catch (_) {}

    emit(
      LiveScoreConnected(
        score: initial ?? const LiveScoreSnapshot(),
        isWebSocket: false,
        match: match,
      ),
    );

    // Realtime pushes (Reverb). Silent no-op when unavailable.
    _wsSubscription?.cancel();
    await _repo.subscribeToScore(e.matchId);
    _wsSubscription = _repo.scoreStream.listen((score) {
      if (!isClosed) add(_ScoreUpdated(score));
    });

    // Match lifecycle pushes (GO LIVE / break / completed) — the manager's
    // status toggle instantly updates an open public live page.
    _matchSub?.cancel();
    _matchSub = _repo.matchUpdates.listen((update) async {
      if (update.matchId != e.matchId) return;
      try {
        final refreshed = await _repo.getMatch(e.matchId);
        if (refreshed != null && !isClosed) {
          emit(
            LiveScoreConnected(
              score: _lastScore,
              isWebSocket:
                  state is LiveScoreConnected &&
                  (state as LiveScoreConnected).isWebSocket,
              match: refreshed,
            ),
          );
        }
      } catch (_) {}
    });

    // Lightweight REST polling as a fallback whenever the realtime
    // channel can't deliver (or until the first push arrives).
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(pollInterval, (_) async {
      try {
        final score = await _repo.fetchScore(e.matchId);
        if (score != null && !isClosed) {
          emit(
            LiveScoreConnected(
              score: score,
              isWebSocket:
                  state is LiveScoreConnected &&
                  (state as LiveScoreConnected).isWebSocket,
              match: _lastMatch,
            ),
          );
        }
      } catch (_) {}
    });
  }

  Future<void> _onStartMatch(StartMatch e, Emitter<LiveScoreState> emit) async {
    final matchId = _currentMatchId;
    if (matchId == null) return;

    emit(LiveScoreUpdating(score: _lastScore, match: _lastMatch));

    // Step 1: record the toss when requested.
    if (e.tossWinnerTeamId != null &&
        e.tossDecision != null &&
        e.battingTeamId != null &&
        e.bowlingTeamId != null) {
      final tossMatch = await _repo.recordToss(
        matchId,
        tossWinnerTeamId: e.tossWinnerTeamId!,
        tossDecision: e.tossDecision!,
        battingTeamId: e.battingTeamId!,
        bowlingTeamId: e.bowlingTeamId!,
      );
      if (tossMatch == null) {
        emit(
          LiveScoreConnected(
            score: _lastScore,
            match: _lastMatch,
            notice: 'Failed to record toss. Check the teams and try again.',
          ),
        );
        return;
      }
    }

    // Step 2: start the match.
    final started = await _repo.startMatch(matchId);
    if (started == null) {
      emit(
        LiveScoreConnected(
          score: _lastScore,
          match: _lastMatch,
          notice: 'Failed to start the match.',
        ),
      );
      return;
    }

    emit(
      LiveScoreConnected(
        score: _lastScore,
        match: started,
        notice: 'Match started — first innings in progress.',
      ),
    );
  }

  Future<void> _onSubmitBall(SubmitBall e, Emitter<LiveScoreState> emit) async {
    final matchId = _currentMatchId;
    if (matchId == null) return;
    final previous = _lastScore;

    emit(LiveScoreUpdating(score: previous, match: _lastMatch));

    LiveScoreSnapshot? updated;
    String? error;
    try {
      updated = await _repo.updateScore(matchId, e.ball);
    } catch (err) {
      error = err.toString().replaceFirst('Exception: ', '');
    }
    if (updated != null) {
      emit(
        LiveScoreConnected(
          score: updated,
          isWebSocket: false,
          match: _lastMatch,
          notice: 'Ball recorded.',
        ),
      );
    } else {
      emit(
        LiveScoreConnected(
          score: previous,
          match: _lastMatch,
          notice: error ?? 'Failed to record ball.',
        ),
      );
    }
  }

  Future<void> _onUndoBall(UndoBall e, Emitter<LiveScoreState> emit) async {
    final matchId = _currentMatchId;
    if (matchId == null) return;
    final previous = _lastScore;

    emit(LiveScoreUpdating(score: previous, match: _lastMatch));

    LiveScoreSnapshot? updated;
    String? error;
    try {
      updated = await _repo.undoLastBall(matchId);
    } catch (err) {
      error = err.toString().replaceFirst('Exception: ', '');
    }
    if (updated != null) {
      emit(
        LiveScoreConnected(
          score: updated,
          isWebSocket: false,
          match: _lastMatch,
          notice: 'Last ball undone.',
        ),
      );
    } else {
      emit(
        LiveScoreConnected(
          score: previous,
          match: _lastMatch,
          notice: error ?? 'Failed to undo last ball.',
        ),
      );
    }
  }

  void _onScoreUpdated(_ScoreUpdated e, Emitter<LiveScoreState> emit) {
    emit(
      LiveScoreConnected(score: e.score, isWebSocket: true, match: _lastMatch),
    );
  }

  void _onDisconnect(DisconnectFromMatch e, Emitter<LiveScoreState> emit) {
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _matchSub?.cancel();
    _matchSub = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    _repo.unsubscribeFromScore(_currentMatchId ?? '');
    _currentMatchId = null;
    emit(LiveScoreInitial());
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    _matchSub?.cancel();
    _pollTimer?.cancel();
    return super.close();
  }
}
