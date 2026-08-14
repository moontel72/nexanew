import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class StreamPlayerState {
  const StreamPlayerState();
}

final class StreamPlayerInitial extends StreamPlayerState {}

final class StreamPlayerLoading extends StreamPlayerState {}

final class StreamPlayerReady extends StreamPlayerState {
  final List<StreamModel> streams;
  final String? activeStreamUrl;
  final int activeCameraIndex;

  const StreamPlayerReady({
    this.streams = const [],
    this.activeStreamUrl,
    this.activeCameraIndex = 0,
  });

  StreamPlayerReady copyWith({
    List<StreamModel>? streams,
    String? activeStreamUrl,
    int? activeCameraIndex,
  }) => StreamPlayerReady(
    streams: streams ?? this.streams,
    activeStreamUrl: activeStreamUrl ?? this.activeStreamUrl,
    activeCameraIndex: activeCameraIndex ?? this.activeCameraIndex,
  );
}

final class StreamPlayerOffline extends StreamPlayerState {
  final String message;
  const StreamPlayerOffline(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class StreamPlayerEvent {
  const StreamPlayerEvent();
}

final class LoadStreams extends StreamPlayerEvent {
  final String matchId;
  const LoadStreams(this.matchId);
}

final class SwitchCamera extends StreamPlayerEvent {
  final int index;
  const SwitchCamera(this.index);
}

final class ActivateStream extends StreamPlayerEvent {
  final String matchId;
  final String streamId;
  const ActivateStream(this.matchId, this.streamId);
}

/// Realtime program-feed change pushed by the manager's camera switch.
final class _StreamContextUpdated extends StreamPlayerEvent {
  final CricketStreamUpdate update;
  const _StreamContextUpdated(this.update);
}

// ─── BLoC ────────────────────────────────────────────────

class StreamPlayerBloc extends Bloc<StreamPlayerEvent, StreamPlayerState> {
  final CricketRepository _repo;

  StreamSubscription<CricketStreamUpdate>? _realtimeSub;
  String? _matchId;

  StreamPlayerBloc({required CricketRepository repo})
    : _repo = repo,
      super(StreamPlayerInitial()) {
    on<LoadStreams>(_onLoad);
    on<SwitchCamera>(_onSwitch);
    on<ActivateStream>(_onActivate);
    on<_StreamContextUpdated>(_onStreamContextUpdated);
  }

  Future<void> _onLoad(LoadStreams e, Emitter<StreamPlayerState> emit) async {
    emit(StreamPlayerLoading());
    _matchId = e.matchId;

    try {
      final streams = await _repo.getStreams(e.matchId);
      if (streams.isEmpty) {
        emit(const StreamPlayerOffline('Stream starting soon...'));
      } else {
        final primary = streams.firstWhere(
          (s) => s.isLive,
          orElse: () => streams.first,
        );
        emit(
          StreamPlayerReady(
            streams: streams,
            activeStreamUrl: primary.hlsPlaylistUrl,
            activeCameraIndex: streams.indexOf(primary),
          ),
        );
      }
    } catch (err) {
      emit(StreamPlayerOffline('Failed to load stream: $err'));
    }

    // Director feed: the manager's activation instantly overrides whatever
    // the viewer is watching. Subscribe once and keep it for the page's
    // lifetime.
    _realtimeSub ??= _repo.streamUpdates.listen((update) {
      if (!isClosed) add(_StreamContextUpdated(update));
    });
  }

  void _onStreamContextUpdated(
    _StreamContextUpdated e,
    Emitter<StreamPlayerState> emit,
  ) {
    final update = e.update;

    if (update.isLive) {
      final s = state;
      if (s is! StreamPlayerReady) {
        // Player was offline — refresh the camera list with the new feed.
        final matchId = _matchId;
        if (matchId != null) add(LoadStreams(matchId));
        return;
      }
      final index = s.streams.indexWhere((c) => c.id == update.streamId);
      emit(
        StreamPlayerReady(
          streams: s.streams,
          activeStreamUrl: update.hlsPlaylistUrl ?? s.activeStreamUrl,
          activeCameraIndex: index >= 0 ? index : s.activeCameraIndex,
        ),
      );
    } else {
      emit(const StreamPlayerOffline('The live stream has ended.'));
    }
  }

  void _onSwitch(SwitchCamera e, Emitter<StreamPlayerState> emit) {
    final s = state;
    if (s is! StreamPlayerReady || e.index >= s.streams.length) return;
    emit(
      s.copyWith(
        activeStreamUrl: s.streams[e.index].hlsPlaylistUrl,
        activeCameraIndex: e.index,
      ),
    );
  }

  Future<void> _onActivate(
    ActivateStream e,
    Emitter<StreamPlayerState> emit,
  ) async {
    final ok = await _repo.activateStream(e.matchId, e.streamId);
    if (ok) add(LoadStreams(e.matchId));
  }

  @override
  Future<void> close() {
    _realtimeSub?.cancel();
    return super.close();
  }
}
