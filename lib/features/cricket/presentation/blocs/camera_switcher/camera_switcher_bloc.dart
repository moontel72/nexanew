import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class CameraSwitcherState {}

final class CameraSwitcherInitial extends CameraSwitcherState {}

final class CameraSwitcherLoading extends CameraSwitcherState {}

final class CameraSwitcherLoaded extends CameraSwitcherState {
  final List<StreamModel> cameras;
  final int activeIndex;
  final bool hasFailover;

  const CameraSwitcherLoaded({
    this.cameras = const [],
    this.activeIndex = 0,
    this.hasFailover = false,
  });

  CameraSwitcherLoaded copyWith({
    List<StreamModel>? cameras,
    int? activeIndex,
    bool? hasFailover,
  }) =>
      CameraSwitcherLoaded(
        cameras: cameras ?? this.cameras,
        activeIndex: activeIndex ?? this.activeIndex,
        hasFailover: hasFailover ?? this.hasFailover,
      );
}

final class CameraSwitcherError extends CameraSwitcherState {
  final String message;
  const CameraSwitcherError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class CameraSwitcherEvent {}

final class LoadCameras extends CameraSwitcherEvent {
  final String matchId;
  const LoadCameras(this.matchId);
}

final class ToggleCamera extends CameraSwitcherEvent {
  final String matchId;
  final int cameraIndex;
  const ToggleCamera(this.matchId, this.cameraIndex);
}

// ─── BLoC ────────────────────────────────────────────────

class CameraSwitcherBloc
    extends Bloc<CameraSwitcherEvent, CameraSwitcherState> {
  final CricketRepository _repo;

  CameraSwitcherBloc({required CricketRepository repo})
      : _repo = repo,
        super(CameraSwitcherInitial()) {
    on<LoadCameras>(_onLoad);
    on<ToggleCamera>(_onToggle);
  }

  Future<void> _onLoad(
      LoadCameras e, Emitter<CameraSwitcherState> emit) async {
    emit(CameraSwitcherLoading());
    try {
      final cameras = await _repo.getManagerStreams(e.matchId);
      final liveIndex = cameras.indexWhere((c) => c.isLive);
      final hasFailover = cameras.any((c) => c.failoverPriority > 0);
      emit(CameraSwitcherLoaded(
        cameras: cameras,
        activeIndex: liveIndex >= 0 ? liveIndex : 0,
        hasFailover: hasFailover,
      ));
    } catch (err) {
      emit(CameraSwitcherError(err.toString()));
    }
  }

  Future<void> _onToggle(
      ToggleCamera e, Emitter<CameraSwitcherState> emit) async {
    final s = state;
    if (s is! CameraSwitcherLoaded) return;
    final camera = s.cameras[e.cameraIndex];

    if (camera.isLive) {
      await _repo.deactivateStream(e.matchId, camera.id);
    } else {
      await _repo.activateStream(e.matchId, camera.id);
    }
    // Reload cameras after toggle
    add(LoadCameras(e.matchId));
  }
}
