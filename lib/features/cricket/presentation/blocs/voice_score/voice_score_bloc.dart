import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/cricket_repository.dart';
import 'speech_service.dart';

// ─── States ──────────────────────────────────────────────

sealed class VoiceScoreState {
  const VoiceScoreState();
}

final class VoiceScoreIdle extends VoiceScoreState {}

final class VoiceScoreListening extends VoiceScoreState {
  final String transcript;
  final bool isFinal;

  const VoiceScoreListening({this.transcript = '', this.isFinal = false});
}

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

/// Generic feedback for applied / rejected outcomes.
final class VoiceScoreNotice extends VoiceScoreState {
  final String message;
  const VoiceScoreNotice(this.message);
}

final class VoiceScoreError extends VoiceScoreState {
  final String message;
  const VoiceScoreError(this.message);
}

// ─── Events ──────────────────────────────────────────────

sealed class VoiceScoreEvent {
  const VoiceScoreEvent();
}

final class StartListening extends VoiceScoreEvent {
  final String matchId;
  const StartListening(this.matchId);
}

final class StopListening extends VoiceScoreEvent {}

final class TranscriptReceived extends VoiceScoreEvent {
  final String text;
  final bool isFinal;
  const TranscriptReceived(this.text, this.isFinal);
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

final class RejectVoiceScore extends VoiceScoreEvent {
  final String logId;
  const RejectVoiceScore(this.logId);
}

final class CancelVoiceScore extends VoiceScoreEvent {}

// ─── BLoC ────────────────────────────────────────────────

class VoiceScoreBloc extends Bloc<VoiceScoreEvent, VoiceScoreState> {
  final CricketRepository _repo;
  final SpeechService _speech;

  StreamSubscription<SpeechTranscript>? _transcriptSub;
  StreamSubscription<String>? _speechErrorSub;
  String? _activeMatchId;

  VoiceScoreBloc({
    required CricketRepository repo,
    SpeechService? speech,
  }) : _repo = repo,
       _speech = speech ?? createSpeechService(),
       super(VoiceScoreIdle()) {
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<TranscriptReceived>(_onTranscriptReceived);
    on<ProcessTranscript>(_onProcess);
    on<ApplyVoiceScore>(_onApply);
    on<RejectVoiceScore>(_onReject);
    on<CancelVoiceScore>(_onCancel);

    _transcriptSub = _speech.transcripts.listen((t) {
      if (!isClosed) add(TranscriptReceived(t.text, t.isFinal));
    });
    _speechErrorSub = _speech.errors.listen((message) {
      if (!isClosed) add(_SpeechError(message));
    });
    on<_SpeechError>((e, emit) => emit(VoiceScoreError(e.message)));
  }

  Future<void> _onStartListening(
    StartListening e,
    Emitter<VoiceScoreState> emit,
  ) async {
    _activeMatchId = e.matchId;
    if (!_speech.isSupported) {
      emit(
        const VoiceScoreError(
          'Speech input is not supported in this browser — type the score instead.',
        ),
      );
      return;
    }
    try {
      await _speech.start();
      emit(const VoiceScoreListening());
    } catch (err) {
      emit(VoiceScoreError(err.toString()));
    }
  }

  Future<void> _onStopListening(
    StopListening e,
    Emitter<VoiceScoreState> emit,
  ) async {
    await _speech.stop();
  }

  void _onTranscriptReceived(
    TranscriptReceived e,
    Emitter<VoiceScoreState> emit,
  ) {
    if (state is! VoiceScoreListening) return;

    if (e.isFinal && e.text.trim().isNotEmpty) {
      // Completed utterance → stop the mic and parse automatically.
      final matchId = _activeMatchId;
      if (matchId != null && matchId.isNotEmpty) {
        _speech.stop();
        add(ProcessTranscript(matchId, e.text.trim()));
      }
      return;
    }

    emit(VoiceScoreListening(transcript: e.text, isFinal: e.isFinal));
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
      emit(
        ok
            ? const VoiceScoreNotice('Score applied to the live match.')
            : const VoiceScoreError('Failed to apply score.'),
      );
    } catch (err) {
      emit(VoiceScoreError(err.toString()));
    }
  }

  Future<void> _onReject(
    RejectVoiceScore e,
    Emitter<VoiceScoreState> emit,
  ) async {
    try {
      await _repo.rejectVoiceScore(e.logId);
      emit(const VoiceScoreNotice('Voice input rejected.'));
    } catch (_) {
      emit(const VoiceScoreError('Failed to reject voice input.'));
    }
  }

  void _onCancel(CancelVoiceScore e, Emitter<VoiceScoreState> emit) {
    _speech.stop();
    emit(VoiceScoreIdle());
  }

  @override
  Future<void> close() {
    _transcriptSub?.cancel();
    _speechErrorSub?.cancel();
    _speech.stop();
    return super.close();
  }
}

/// Internal event for speech recognition errors.
final class _SpeechError extends VoiceScoreEvent {
  final String message;
  const _SpeechError(this.message);
}
