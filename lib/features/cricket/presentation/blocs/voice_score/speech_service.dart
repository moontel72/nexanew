// Speech-to-text service for the Voice-to-Score panel.
//
// Platform-conditional: browser SpeechRecognition (Web Speech API) on
// web — the manager panel is a web-only deployment — and an explicit
// unsupported stub on native. No third-party dependencies, no API keys,
// no hardcoded endpoints: recognition happens locally in the browser
// and the transcript is sent to the existing voice-score API.

import 'speech_service_web.dart'
    if (dart.library.io) 'speech_service_io.dart' as platform;

/// A recognized phrase chunk. [isFinal] marks the completed utterance.
class SpeechTranscript {
  final String text;
  final bool isFinal;

  const SpeechTranscript({required this.text, this.isFinal = false});
}

/// Platform speech recognition contract.
abstract class SpeechService {
  /// Streams recognized text (interim + final chunks).
  Stream<SpeechTranscript> get transcripts;

  /// Streams recognition errors (mic denied, network, unsupported).
  Stream<String> get errors;

  /// Whether this platform/browser can recognize speech at all.
  bool get isSupported;

  /// Whether a recognition session is currently running.
  bool get isActive;

  /// Start recognizing. Throws when the microphone cannot be started.
  Future<void> start();

  /// Stop recognizing.
  Future<void> stop();
}

/// Create the platform speech service.
SpeechService createSpeechService() => platform.createSpeechService();
