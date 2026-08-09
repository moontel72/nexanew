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

final class LiveScoreConnected extends LiveScoreState {
  final LiveScoreSnapshot score;
  final bool isWebSocket;
  final List<CommentaryModel> commentary;

  const LiveScoreConnected({
    required this.score,
    this.isWebSocket = true,
    this.commentary = const [],
  });

  LiveScoreConnected copyWith({
    LiveScoreSnapshot? score,
    bool? isWebSocket,
    List<CommentaryModel>? commentary,
  }) => LiveScoreConnected(
    score: score ?? this.score,
    isWebSocket: isWebSocket ?? this.isWebSocket,
    commentary: commentary ?? this.commentary,
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

final class _ScoreUpdated extends LiveScoreEvent {
  final LiveScoreSnapshot score;
  const _ScoreUpdated(this.score);
}

final class DisconnectFromMatch extends LiveScoreEvent {}

// ─── BLoC ────────────────────────────────────────────────

class LiveScoreBloc extends Bloc<LiveScoreEvent, LiveScoreState> {
  final CricketRepository _repo;
  StreamSubscription? _wsSubscription;
  String? _currentMatchId;

  LiveScoreBloc({required CricketRepository repo})
    : _repo = repo,
      super(LiveScoreInitial()) {
    on<ConnectToMatch>(_onConnect);
    on<_ScoreUpdated>(_onScoreUpdated);
    on<DisconnectFromMatch>(_onDisconnect);
  }

  Future<void> _onConnect(
    ConnectToMatch e,
    Emitter<LiveScoreState> emit,
  ) async {
    emit(LiveScoreLoading());
    _currentMatchId = e.matchId;

    // Fetch initial score via REST
    try {
      final initial = await _repo.fetchScore(e.matchId);
      if (initial != null) {
        emit(LiveScoreConnected(score: initial, isWebSocket: false));
      }
    } catch (_) {}

    // Subscribe to WebSocket for real-time updates
    _wsSubscription?.cancel();
    _repo.subscribeToScore(e.matchId);
    _wsSubscription = _repo.scoreStream.listen((score) {
      if (!isClosed) add(_ScoreUpdated(score));
    });
  }

  void _onScoreUpdated(_ScoreUpdated e, Emitter<LiveScoreState> emit) {
    emit(LiveScoreConnected(score: e.score, isWebSocket: true));
  }

  void _onDisconnect(DisconnectFromMatch e, Emitter<LiveScoreState> emit) {
    _wsSubscription?.cancel();
    _repo.unsubscribeFromScore(_currentMatchId ?? '');
    _currentMatchId = null;
    emit(LiveScoreInitial());
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }
}
