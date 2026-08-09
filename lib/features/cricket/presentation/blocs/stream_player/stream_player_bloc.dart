import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class StreamPlayerState {}

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
  }) =>
      StreamPlayerReady(
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

sealed class StreamPlayerEvent {}

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

// ─── BLoC ────────────────────────────────────────────────

class StreamPlayerBloc extends Bloc<StreamPlayerEvent, StreamPlayerState> {
  final CricketRepository _repo;

  StreamPlayerBloc({required CricketRepository repo})
      : _repo = repo,
        super(StreamPlayerInitial()) {
    on<LoadStreams>(_onLoad);
    on<SwitchCamera>(_onSwitch);
    on<ActivateStream>(_onActivate);
  }

  Future<void> _onLoad(
      LoadStreams e, Emitter<StreamPlayerState> emit) async {
    emit(StreamPlayerLoading());
    try {
      final streams = await _repo.getPublicStreams(e.matchId);
      if (streams.isEmpty) {
        emit(const StreamPlayerOffline('Stream starting soon...'));
        return;
      }
      final primary = streams.firstWhere(
        (s) => s.isLive,
        orElse: () => streams.first,
      );
      emit(StreamPlayerReady(
        streams: streams,
        activeStreamUrl: primary.hlsPlaylistUrl,
        activeCameraIndex: streams.indexOf(primary),
      ));
    } catch (e) {
      emit(StreamPlayerOffline('Failed to load stream: $e'));
    }
  }

  void _onSwitch(SwitchCamera e, Emitter<StreamPlayerState> emit) {
    final s = state;
    if (s is! StreamPlayerReady || e.index >= s.streams.length) return;
    emit(s.copyWith(
      activeStreamUrl: s.streams[e.index].hlsPlaylistUrl,
      activeCameraIndex: e.index,
    ));
  }

  Future<void> _onActivate(
      ActivateStream e, Emitter<StreamPlayerState> emit) async {
    final ok = await _repo.activateStream(e.matchId, e.streamId);
    if (ok) add(LoadStreams(e.matchId));
  }
}
