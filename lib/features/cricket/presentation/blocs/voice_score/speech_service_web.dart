// Browser SpeechRecognition implementation (Chrome / Edge / Safari).

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import 'speech_service.dart';

SpeechService createSpeechService() => WebSpeechService();

class WebSpeechService implements SpeechService {
  final StreamController<SpeechTranscript> _transcriptController =
      StreamController<SpeechTranscript>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  html.SpeechRecognition? _recognition;
  bool _active = false;

  @override
  Stream<SpeechTranscript> get transcripts => _transcriptController.stream;

  @override
  Stream<String> get errors => _errorController.stream;

  @override
  bool get isSupported {
    try {
      // Constructing a recognition session is the most reliable feature
      // probe across browsers.
      html.SpeechRecognition();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  bool get isActive => _active;

  @override
  Future<void> start() async {
    if (!isSupported) {
      throw UnsupportedError(
        'Speech recognition is not supported in this browser.',
      );
    }
    if (_active) return;

    _active = true;
    _start();
  }

  void _start() {
    try {
      final rec = html.SpeechRecognition()
        ..continuous = true
        ..interimResults = true
        ..lang = 'en-US';

      rec.onResult.listen((event) {
        final results = event.results;
        if (results == null) return;
        for (final result in results) {
          final length = result.length ?? 0;
          if (length == 0) continue;
          final transcript = result.item(0).transcript ?? '';
          if (transcript.trim().isEmpty) continue;
          _transcriptController.add(
            SpeechTranscript(
              text: transcript,
              isFinal: result.isFinal ?? false,
            ),
          );
        }
      });

      rec.onError.listen((event) {
        _active = false;
        _recognition = null;
        _errorController.add(
          event.message ?? event.error ?? 'Speech recognition error.',
        );
      });

      rec.onEnd.listen((_) {
        _recognition = null;
        if (!_active) return;
        // Browsers stop recognition after silence even in continuous mode —
        // restart while the manager is still in listening mode.
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_active) _start();
        });
      });

      rec.start();
      _recognition = rec;
    } catch (e) {
      _active = false;
      _recognition = null;
      _errorController.add('Failed to start microphone: $e');
    }
  }

  @override
  Future<void> stop() async {
    _active = false;
    try {
      _recognition?.stop();
    } catch (_) {}
    _recognition = null;
  }
}
