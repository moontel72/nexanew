import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class CameraSwitcherState {
  const CameraSwitcherState();
}

final class CameraSwitcherInitial extends CameraSwitcherState {}

final class CameraSwitcherLoading extends CameraSwitcherState {}

final class CameraSwitcherLoaded extends CameraSwitcherState {
  final List<StreamModel> cameras;
  final int activeIndex;
  final bool hasFailover;

  /// Transient feedback shown once via BlocListener.
  final String? notice;

  const CameraSwitcherLoaded({
    this.cameras = const [],
    this.activeIndex = 0,
    this.hasFailover = false,
    this.notice,
  });

  CameraSwitcherLoaded copyWith({
    List<StreamModel>? cameras,
    int? activeIndex,
    bool? hasFailover,
    String? notice,
  }) => CameraSwitcherLoaded(
    cameras: cameras ?? this.cameras,
    activeIndex: activeIndex ?? this.activeIndex,
    hasFailover: hasFailover ?? this.hasFailover,
    notice: notice,
  );
}

final class CameraSwitcherError extends CameraSwitcherState {
  final String message;
  const CameraSwitcherError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class CameraSwitcherEvent {
  const CameraSwitcherEvent();
}

final class LoadCameras extends CameraSwitcherEvent {
  final String matchId;
  const LoadCameras(this.matchId);
}

/// Activate / deactivate a camera. Carries the stream id (not a list
/// index — camera numbers are not contiguous list positions).
final class ToggleCamera extends CameraSwitcherEvent {
  final String matchId;
  final String streamId;
  const ToggleCamera(this.matchId, this.streamId);
}

final class CreateCamera extends CameraSwitcherEvent {
  final String matchId;
  final String cameraLabel;
  final int cameraNumber;
  final bool isPrimary;
  const CreateCamera({
    required this.matchId,
    required this.cameraLabel,
    required this.cameraNumber,
    this.isPrimary = false,
  });
}

final class DeleteCamera extends CameraSwitcherEvent {
  final String matchId;
  final String streamId;
  const DeleteCamera(this.matchId, this.streamId);
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
    on<CreateCamera>(_onCreate);
    on<DeleteCamera>(_onDelete);
  }

  Future<void> _onLoad(LoadCameras e, Emitter<CameraSwitcherState> emit) async {
    emit(CameraSwitcherLoading());
    try {
      final cameras = await _repo.getManagerStreams(e.matchId);
      final liveIndex = cameras.indexWhere((c) => c.isLive);
      final hasFailover = cameras.any((c) => c.failoverPriority > 0);
      emit(
        CameraSwitcherLoaded(
          cameras: cameras,
          activeIndex: liveIndex >= 0 ? liveIndex : 0,
          hasFailover: hasFailover,
        ),
      );
    } catch (err) {
      emit(CameraSwitcherError(err.toString()));
    }
  }

  Future<void> _onToggle(
    ToggleCamera e,
    Emitter<CameraSwitcherState> emit,
  ) async {
    final s = state;
    if (s is! CameraSwitcherLoaded) return;

    final camera = s.cameras.where((c) => c.id == e.streamId).firstOrNull;
    if (camera == null) return;

    final ok = camera.isLive
        ? await _repo.deactivateStream(e.matchId, camera.id)
        : await _repo.activateStream(e.matchId, camera.id);

    emit(
      s.copyWith(
        notice: ok
            ? 'Camera ${camera.cameraNumber} ${camera.isLive ? 'deactivated' : 'activated'}.'
            : 'Failed to toggle camera ${camera.cameraNumber}.',
      ),
    );
    // Reload cameras after toggle.
    add(LoadCameras(e.matchId));
  }

  Future<void> _onCreate(
    CreateCamera e,
    Emitter<CameraSwitcherState> emit,
  ) async {
    final s = state;
    if (s is! CameraSwitcherLoaded) return;

    final created = await _repo.createStream(
      e.matchId,
      cameraLabel: e.cameraLabel,
      cameraNumber: e.cameraNumber,
      isPrimary: e.isPrimary,
    );

    emit(
      s.copyWith(
        notice: created != null
            ? 'Camera ${created.cameraNumber} created — share the RTMP key with the camera operator.'
            : 'Failed to create camera stream.',
      ),
    );
    add(LoadCameras(e.matchId));
  }

  Future<void> _onDelete(
    DeleteCamera e,
    Emitter<CameraSwitcherState> emit,
  ) async {
    final s = state;
    if (s is! CameraSwitcherLoaded) return;

    final ok = await _repo.deleteStream(e.matchId, e.streamId);
    emit(
      s.copyWith(notice: ok ? 'Camera deleted.' : 'Failed to delete camera.'),
    );
    add(LoadCameras(e.matchId));
  }
}
