// Native stub — browser SpeechRecognition is unavailable on io platforms.
// The cricket manager panel is deployed as a web build; typed input remains
// the fallback everywhere.

import 'dart:async';

import 'speech_service.dart';

SpeechService createSpeechService() => UnsupportedSpeechService();

class UnsupportedSpeechService implements SpeechService {
  final StreamController<SpeechTranscript> _transcripts =
      StreamController<SpeechTranscript>.broadcast();
  final StreamController<String> _errors = StreamController<String>.broadcast();

  @override
  Stream<SpeechTranscript> get transcripts => _transcripts.stream;

  @override
  Stream<String> get errors => _errors.stream;

  @override
  bool get isSupported => false;

  @override
  bool get isActive => false;

  @override
  Future<void> start() async {
    throw UnsupportedError(
      'Speech input is not supported on this platform — type the score instead.',
    );
  }

  @override
  Future<void> stop() async {}
}
