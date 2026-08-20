import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

/// Raised when a WHIP ingest is rejected by the media engine.
class WhipException implements Exception {
  WhipException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// A live WHIP ingest session: PeerConnection + captured MediaStream.
class WhipSession {
  WhipSession({required this.pc, required this.stream});

  final RTCPeerConnection pc;
  final MediaStream stream;

  Future<void> close() async {
    try {
      await pc.close();
    } catch (_) {
      // Already closed.
    }
    try {
      await stream.dispose();
    } catch (_) {
      // Already disposed.
    }
  }
}

/// Client for RFC draft-ietf-wish-whip against the T-Odd media engine.
///
/// Flow: capture camera → offer (non-trickle, matching the server) →
/// POST `/api/v1/whip/ingest/{room}/{camera}?token=…` → SDP answer.
class WhipClient {
  WhipClient({required this.baseUrl});

  /// Media engine base URL (e.g. `https://studio.traceodd.com`).
  final String baseUrl;

  /// Opens the device camera + microphone with the requested profile.
  Future<MediaStream> openCamera({
    required String facingMode,
    required int width,
    required int height,
    required int fps,
    required bool audioEnabled,
  }) async {
    final constraints = <String, dynamic>{
      'audio': audioEnabled,
      'video': <String, dynamic>{
        'facingMode': facingMode,
        'width': <String, dynamic>{'ideal': width},
        'height': <String, dynamic>{'ideal': height},
        'frameRate': <String, dynamic>{'ideal': fps},
      },
    };
    return navigator.mediaDevices.getUserMedia(constraints);
  }

  /// Posts a WHIP offer for `stream` and returns the live session.
  Future<WhipSession> connect({
    required String roomId,
    required String cameraId,
    required String token,
    required MediaStream stream,
    required String stunUrl,
    String? turnUrl,
  }) async {
    final iceServers = <Map<String, dynamic>>[];
    if (stunUrl.isNotEmpty) {
      iceServers.add(<String, dynamic>{'urls': stunUrl});
    }
    if (turnUrl != null && turnUrl.isNotEmpty) {
      iceServers.add(<String, dynamic>{'urls': turnUrl});
    }

    final pc = await createPeerConnection(<String, dynamic>{
      'iceServers': iceServers,
    });
    for (final track in stream.getTracks()) {
      await pc.addTrack(track, stream);
    }

    final offer = await pc.createOffer(<String, dynamic>{});
    await pc.setLocalDescription(offer);
    // Non-trickle ICE: the engine answers only after gathering completes.
    await waitForIceGatheringComplete(pc);

    final uri = Uri.parse(
      '$baseUrl/api/v1/whip/ingest/$roomId/$cameraId',
    ).replace(queryParameters: <String, String>{'token': token});
    final local = await pc.getLocalDescription();
    if (local == null) {
      await pc.close();
      throw WhipException('Could not produce a local SDP offer.');
    }

    final response = await http.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/sdp'},
      body: local.sdp,
    );

    if (response.statusCode != 201) {
      await pc.close();
      throw WhipException(
        'WHIP ingest rejected (${response.statusCode}): ${response.body}',
      );
    }

    await pc.setRemoteDescription(
      RTCSessionDescription(response.body, 'answer'),
    );
    return WhipSession(pc: pc, stream: stream);
  }

  /// Polls until ICE gathering completes (bounded at ~3 seconds).
  static Future<void> waitForIceGatheringComplete(RTCPeerConnection pc) async {
    const maxWait = Duration(seconds: 3);
    const step = Duration(milliseconds: 50);
    final deadline = DateTime.now().add(maxWait);
    while (DateTime.now().isBefore(deadline)) {
      if (pc.iceGatheringState ==
          RTCIceGatheringState.RTCIceGatheringStateComplete) {
        return;
      }
      await Future<void>.delayed(step);
    }
  }
}
