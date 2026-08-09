import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/cricket_repository.dart';

// ─── States ──────────────────────────────────────────────

sealed class VoiceScoreState {
  const VoiceScoreState();
}

final class VoiceScoreIdle extends VoiceScoreState {}

final class VoiceScoreListening extends VoiceScoreState {}

final class VoiceScoreProcessing extends VoiceScoreState {
  final String transcript;
  const VoiceScoreProcessing(this.transcript);
}

final class VoiceScoreParsed extends VoiceScoreState {
  final String logId;
  final Map<String, dynamic> parsedData;
  final String transcript;

  const VoiceScoreParsed({
    required this.logId,
    required this.parsedData,
    required this.transcript,
  });
}

final class VoiceScoreApplied extends VoiceScoreState {
  final String message;
  const VoiceScoreApplied(this.message);
}

final class VoiceScoreError extends VoiceScoreState {
  final String message;
  const VoiceScoreError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class VoiceScoreEvent {
  const VoiceScoreEvent();
}

final class ProcessTranscript extends VoiceScoreEvent {
  final String matchId;
  final String transcript;
  const ProcessTranscript(this.matchId, this.transcript);
}

final class ApplyVoiceScore extends VoiceScoreEvent {
  final String logId;
  const ApplyVoiceScore(this.logId);
}

final class CancelVoiceScore extends VoiceScoreEvent {}

// ─── BLoC ────────────────────────────────────────────────

class VoiceScoreBloc extends Bloc<VoiceScoreEvent, VoiceScoreState> {
  final CricketRepository _repo;

  VoiceScoreBloc({required CricketRepository repo})
    : _repo = repo,
      super(VoiceScoreIdle()) {
    on<ProcessTranscript>(_onProcess);
    on<ApplyVoiceScore>(_onApply);
    on<CancelVoiceScore>(_onCancel);
  }

  Future<void> _onProcess(
    ProcessTranscript e,
    Emitter<VoiceScoreState> emit,
  ) async {
    emit(VoiceScoreProcessing(e.transcript));
    try {
      final result = await _repo.processVoiceScore(e.matchId, e.transcript);
      if (result == null) {
        emit(const VoiceScoreError('Failed to parse voice input.'));
        return;
      }
      emit(
        VoiceScoreParsed(
          logId: result['voice_log_id'] as String,
          parsedData: result['parsed'] as Map<String, dynamic>,
          transcript: e.transcript,
        ),
      );
    } catch (err) {
      emit(VoiceScoreError(err.toString()));
    }
  }

  Future<void> _onApply(
    ApplyVoiceScore e,
    Emitter<VoiceScoreState> emit,
  ) async {
    emit(const VoiceScoreProcessing('Applying...'));
    try {
      final ok = await _repo.applyVoiceScore(e.logId);
      if (ok) {
        emit(const VoiceScoreApplied('Score applied successfully.'));
      } else {
        emit(const VoiceScoreError('Failed to apply score.'));
      }
    } catch (err) {
      emit(VoiceScoreError(err.toString()));
    }
  }

  void _onCancel(CancelVoiceScore e, Emitter<VoiceScoreState> emit) {
    emit(VoiceScoreIdle());
  }
}
