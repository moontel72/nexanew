import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/replay_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────────

sealed class ReplayState {
  const ReplayState();
}

class ReplayIdle extends ReplayState {}

class ReplayLoading extends ReplayState {}

class ReplayEventsLoaded extends ReplayState {
  final String matchId;
  final List<ReplayEventModel> events;
  final int currentTimestampMs;
  const ReplayEventsLoaded({
    required this.matchId,
    required this.events,
    this.currentTimestampMs = 0,
  });
  ReplayEventsLoaded copyWith({
    String? matchId,
    List<ReplayEventModel>? events,
    int? currentTimestampMs,
  }) => ReplayEventsLoaded(
    matchId: matchId ?? this.matchId,
    events: events ?? this.events,
    currentTimestampMs: currentTimestampMs ?? this.currentTimestampMs,
  );
}

class ReplayClipReady extends ReplayState {
  final ReplayClipModel clip;
  final String previewUrl;
  const ReplayClipReady({required this.clip, required this.previewUrl});
}

class ReplayClipPublished extends ReplayState {
  final ReplayClipModel clip;
  const ReplayClipPublished(this.clip);
}

class ReplayError extends ReplayState {
  final String message;
  const ReplayError(this.message);
}

// ─── Events ──────────────────────────────────────────────────

sealed class ReplayEvent {
  const ReplayEvent();
}

class LoadReplayEvents extends ReplayEvent {
  final String matchId;
  const LoadReplayEvents(this.matchId);
}

class MarkEvent extends ReplayEvent {
  final String matchId;
  final String eventType;
  final int frameTimestamp;
  final String? annotation;
  const MarkEvent({
    required this.matchId,
    required this.eventType,
    required this.frameTimestamp,
    this.annotation,
  });
}

class AnnotateEvent extends ReplayEvent {
  final String eventId;
  final String annotation;
  const AnnotateEvent(this.eventId, this.annotation);
}

class CreateClip extends ReplayEvent {
  final String matchId;
  final String eventId;
  final int bufferBeforeMs;
  final int bufferAfterMs;
  final double playbackSpeed;
  const CreateClip({
    required this.matchId,
    required this.eventId,
    this.bufferBeforeMs = 5000,
    this.bufferAfterMs = 5000,
    this.playbackSpeed = 1.0,
  });
}

class PublishClip extends ReplayEvent {
  final String clipId;
  const PublishClip(this.clipId);
}

class DeleteClip extends ReplayEvent {
  final String clipId;
  const DeleteClip(this.clipId);
}

// ─── BLoC ────────────────────────────────────────────────────

class ReplayBloc extends Bloc<ReplayEvent, ReplayState> {
  final CricketRepository _repo;

  ReplayBloc({required CricketRepository repo})
    : _repo = repo,
      super(ReplayIdle()) {
    on<LoadReplayEvents>(_onLoad);
    on<MarkEvent>(_onMark);
    on<AnnotateEvent>(_onAnnotate);
    on<CreateClip>(_onCreateClip);
    on<PublishClip>(_onPublish);
    on<DeleteClip>(_onDelete);
  }

  Future<void> _onLoad(LoadReplayEvents e, Emitter<ReplayState> emit) async {
    emit(ReplayLoading());
    try {
      final events = await _repo.getReplayEvents(e.matchId);
      emit(ReplayEventsLoaded(matchId: e.matchId, events: events));
    } catch (err) {
      emit(ReplayError(err.toString()));
    }
  }

  Future<void> _onMark(MarkEvent e, Emitter<ReplayState> emit) async {
    emit(ReplayLoading());
    try {
      await _repo.markReplayEvent(
        e.matchId,
        e.eventType,
        e.frameTimestamp,
        annotation: e.annotation,
      );
      add(LoadReplayEvents(e.matchId));
    } catch (err) {
      emit(ReplayError(err.toString()));
    }
  }

  Future<void> _onAnnotate(AnnotateEvent e, Emitter<ReplayState> emit) async {
    try {
      await _repo.annotateEvent(e.eventId, e.annotation);
      final s = state;
      if (s is ReplayEventsLoaded) add(LoadReplayEvents(s.matchId));
    } catch (err) {
      emit(ReplayError(err.toString()));
    }
  }

  Future<void> _onCreateClip(CreateClip e, Emitter<ReplayState> emit) async {
    emit(ReplayLoading());
    try {
      final clip = await _repo.createClip(
        e.matchId,
        e.eventId,
        bufferBeforeMs: e.bufferBeforeMs,
        bufferAfterMs: e.bufferAfterMs,
        speed: e.playbackSpeed,
      );
      if (clip != null) {
        emit(ReplayClipReady(clip: clip, previewUrl: clip.clipFilePath));
      } else {
        emit(const ReplayError('Failed to create clip.'));
      }
    } catch (err) {
      emit(ReplayError(err.toString()));
    }
  }

  Future<void> _onPublish(PublishClip e, Emitter<ReplayState> emit) async {
    try {
      final ok = await _repo.publishClip(e.clipId);
      if (ok) {
        final s = state;
        if (s is ReplayClipReady) emit(ReplayClipPublished(s.clip));
      }
    } catch (err) {
      emit(ReplayError(err.toString()));
    }
  }

  Future<void> _onDelete(DeleteClip e, Emitter<ReplayState> emit) async {
    try {
      await _repo.deleteClip(e.clipId);
      final s = state;
      if (s is ReplayEventsLoaded) add(LoadReplayEvents(s.matchId));
    } catch (err) {
      emit(ReplayError(err.toString()));
    }
  }
}
