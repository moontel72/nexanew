import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:trace_odd/core/services/api_client.dart';

import '../../broadcaster_constants.dart';

/// Raised when a WHIP ingest is rejected by the media engine.
class WhipException implements Exception {
  WhipException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Parsed parts of a complete WHIP ingest URL.
///
/// Matches `https://host/api/v1/whip/ingest/{room}[/{camera}]?token=…` —
/// the exact format the Studio's "hand this to the camera operator" card
/// and Book 3 publish. An operator can paste that single URL and every
/// connection field fills itself, eliminating manual room/camera/token
/// splitting.
class WhipUrlParts {
  const WhipUrlParts({
    required this.baseUrl,
    required this.roomId,
    required this.cameraId,
    required this.token,
  });

  final String baseUrl;
  final String roomId;
  final String cameraId;
  final String token;
}

/// A live WHIP ingest session: PeerConnection + captured MediaStream.
class WhipSession {
  WhipSession({
    required this.pc,
    required this.stream,
    this.resourceUrl,
    this.token,
  });

  final RTCPeerConnection pc;
  final MediaStream stream;

  /// Session resource from the 201 response's `Location` header. Sending
  /// `DELETE` on it frees the engine slot immediately — without it the
  /// engine keeps the old session for its full disconnected grace (up to
  /// 5 min) and a quick re-publish restarts on a stale camera state.
  final String? resourceUrl;
  final String? token;

  Future<void> close() async {
    final location = resourceUrl;
    if (location != null && location.isNotEmpty) {
      // Best-effort, idempotent: the engine may already have pruned the
      // session. Never let a DELETE failure block the local teardown.
      try {
        await ApiClient()
            .deleteRaw(
              location,
              headers: <String, String>{
                if (token != null && token!.isNotEmpty)
                  'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 3));
      } catch (_) {
        // Ignore — session teardown proceeds regardless.
      }
    }
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

  /// Media engine base URL (see [BroadcasterConstants.engineUrlHint]).
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

  /// Parses a complete WHIP ingest URL into its connection fields.
  ///
  /// Accepts both forms the Studio hands out:
  /// `…/api/v1/whip/ingest/{room}/{camera}?token=…` (with token) and
  /// `…/api/v1/whip/ingest/{room}/{camera}` (token pasted separately).
  ///
  /// Tolerant of real-world paste mistakes: surrounding `<…>`, `(…)` or
  /// quotes, a stripped `https://` scheme, trailing sentence punctuation
  /// (`.`/`,`/`;` added by chat and email clients), and share links that
  /// wrap the ingest URL (`?url=<encoded url>`).
  /// Returns null when [input] is not a valid WHIP ingest URL.
  static WhipUrlParts? parseWhipUrl(String input) {
    var text = input.trim();

    // Unwrap common share decorations: <url>, (url), "url" or 'url'.
    if ((text.startsWith('<') && text.endsWith('>')) ||
        (text.startsWith('(') && text.endsWith(')')) ||
        (text.startsWith('"') && text.endsWith('"')) ||
        (text.startsWith("'") && text.endsWith("'"))) {
      text = text.substring(1, text.length - 1).trim();
    }
    if (text.isEmpty) return null;

    // Chat/email clients often append punctuation to a pasted URL. It can
    // never be part of a valid ingest token, so only strip when a query is
    // present (the path may legally end with any of these characters).
    if (text.contains('?') || text.contains('&')) {
      while (text.endsWith('.') || text.endsWith(',') || text.endsWith(';')) {
        text = text.substring(0, text.length - 1);
      }
    }

    // Some clients strip the scheme when copying — restore it.
    if (!text.contains('://')) {
      text = 'https://$text';
    }

    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }

    // Share links that wrap the ingest URL (e.g. the broadcaster deep link
    // `https://broadcaster.traceodd.com/?url=<encoded>`) — unwrap and
    // re-parse the inner URL.
    final wrapped =
        uri.queryParameters['url'] ?? uri.queryParameters['whip_url'];
    if (wrapped != null && wrapped.isNotEmpty) {
      return parseWhipUrl(wrapped);
    }

    final segments = uri.pathSegments
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    if (segments.length < 5 ||
        segments[0] != 'api' ||
        segments[1] != 'v1' ||
        segments[2] != 'whip' ||
        segments[3] != 'ingest') {
      return null;
    }
    return WhipUrlParts(
      baseUrl: '${uri.scheme}://${uri.authority}',
      roomId: segments[4],
      cameraId: segments.length >= 6 ? segments[5] : '',
      token: (uri.queryParameters['token'] ?? '').trim(),
    );
  }

  /// Guards against the two most common paste mistakes:
  /// 1. A trailing slash on the origin (`https://host/`) producing a
  ///    `//api/…` path that never matches an engine route (empty 404).
  /// 2. The full `…/api/v1/whip/ingest/{room}/{camera}` URL pasted into the
  ///    base-URL field, producing a doubled path (also an empty 404).
  static String _normalizeBaseUrl(String baseUrl) {
    var url = baseUrl.trim();
    const marker = '/api/v1/whip/ingest/';
    final markerIndex = url.indexOf(marker);
    if (markerIndex != -1) {
      url = url.substring(0, markerIndex);
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Maps a rejected ingest to an actionable hint for the operator.
  static String _hintFor(int statusCode) {
    return switch (statusCode) {
      401 =>
        'ingest token expired or invalid — generate a fresh one in the Studio',
      403 =>
        'token is scoped to a different room/camera — use the exact URL the Studio generated',
      404 =>
        'room or camera not found — verify the WHIP URL; rooms are cleared when the engine restarts',
      409 =>
        'the engine still has a live session for this camera — retry; it is replaced automatically',
      429 => 'too many attempts — wait a moment and retry',
      _ => 'check the engine base URL and that the engine is reachable',
    };
  }

  /// Posts a WHIP offer for `stream` and returns the live session.
  Future<WhipSession> connect({
    required String roomId,
    required String cameraId,
    required String token,
    required MediaStream stream,
    required String stunUrl,
    String? turnUrl,
    String? turnUsername,
    String? turnPassword,
  }) async {
    final iceServers = <Map<String, dynamic>>[];
    // An empty STUN field silently produces host-only candidates, which
    // fail behind carrier NAT. Fall back to the default public STUN so a
    // blank form still yields a working media path.
    final effectiveStun = stunUrl.trim().isEmpty
        ? BroadcasterConstants.defaultStunUrl
        : stunUrl.trim();
    iceServers.add(<String, dynamic>{'urls': effectiveStun});
    if (turnUrl != null && turnUrl.isNotEmpty) {
      iceServers.add(<String, dynamic>{
        'urls': turnUrl,
        if (turnUsername != null && turnUsername.isNotEmpty)
          'username': turnUsername,
        if (turnPassword != null && turnPassword.isNotEmpty)
          'credential': turnPassword,
      });
    }

    final pc = await createPeerConnection(<String, dynamic>{
      'iceServers': iceServers,
    });
    for (final track in stream.getTracks()) {
      await pc.addTrack(track, stream);
    }
    // Force VP8 first for the video m-line. Several Android devices hang
    // their hardware H.264 encoder on cold start (MediaCodec never emits
    // a frame — audio flows, video never arrives, sometimes only after
    // an app lifecycle event). VP8 is libvpx's software encoder and
    // starts producing frames immediately.
    for (final transceiver in await pc.getTransceivers()) {
      if (transceiver.sender.track?.kind != 'video') continue;
      try {
        await transceiver.setCodecPreferences(<RTCRtpCodecCapability>[
          RTCRtpCodecCapability(mimeType: 'video/VP8', clockRate: 90000),
          RTCRtpCodecCapability(mimeType: 'video/H264', clockRate: 90000),
        ]);
        debugPrint('[broadcaster] video codec preference: VP8 first');
      } catch (_) {
        // Preference unsupported on this platform — keep the defaults.
      }
    }

    final offer = await pc.createOffer(<String, dynamic>{});
    await pc.setLocalDescription(offer);
    // Non-trickle ICE: the engine answers only after gathering completes.
    await waitForIceGatheringComplete(pc);

    // Guard against a dead media path: if the network blocked STUN and no
    // TURN relay is configured, the offer carries host candidates only and
    // the engine can never reach us behind carrier NAT. Fail fast with a
    // fixable message instead of a 20s "Connecting…" that ends in failure.
    final local = await pc.getLocalDescription();
    if (local == null) {
      await pc.close();
      throw WhipException('Could not produce a local SDP offer.');
    }
    // A host-only offer (STUN unreachable) is still posted: the engine
    // learns the phone's reflexive candidate from the first RTP packets
    // even without STUN, so blocking here produced false negatives on
    // carrier networks that throttle STUN. ICE failures surface through
    // the connection-state reconnect flow instead.
    if (!_sdpHasPublicCandidate(local.sdp ?? '')) {
      debugPrint(
        '[broadcaster] STUN gave no srflx/relay candidate — posting '
        'host-only offer (reflexive discovery may still connect).',
      );
    }

    final uri = Uri.parse(
      '${_normalizeBaseUrl(baseUrl)}/api/v1/whip/ingest/$roomId/$cameraId',
    ).replace(queryParameters: <String, String>{'token': token});

    final response = await ApiClient().postRaw(
      uri.toString(),
      headers: <String, String>{
        'Content-Type': 'application/sdp',
        // The engine prefers the RFC 6750 bearer header and falls back to
        // the `?token=` query parameter. Sending both keeps the URL-based
        // operator flow intact while surviving environments that truncate
        // or strip long query strings.
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: local.sdp,
    );

    if (response.statusCode != 201) {
      await pc.close();
      final body = response.body.trim();
      throw WhipException(
        'WHIP ingest rejected (${response.statusCode}): '
        '${_hintFor(response.statusCode)}'
        '${body.isEmpty ? '' : ' — $body'}',
      );
    }

    await pc.setRemoteDescription(
      RTCSessionDescription(response.body, 'answer'),
    );
    return WhipSession(
      pc: pc,
      stream: stream,
      resourceUrl: response.headers['location'],
      token: token,
    );
  }

  /// Polls until ICE gathering completes (bounded by
  /// [BroadcasterConstants.iceGatherMaxWait]). Returns true when the
  /// gathering state actually reached `complete`, false when the bound
  /// elapsed first (a slow STUN lookup, not a failure by itself).
  static Future<bool> waitForIceGatheringComplete(RTCPeerConnection pc) async {
    final deadline = DateTime.now().add(BroadcasterConstants.iceGatherMaxWait);
    while (DateTime.now().isBefore(deadline)) {
      if (pc.iceGatheringState ==
          RTCIceGatheringState.RTCIceGatheringStateComplete) {
        return true;
      }
      await Future<void>.delayed(BroadcasterConstants.iceGatherPollStep);
    }
    return false;
  }

  /// True when the SDP offer carries at least one `srflx` (STUN) or
  /// `relay` (TURN) candidate. Host-only offers cannot traverse carrier
  /// NAT — the engine would have no routable address to reach.
  static bool _sdpHasPublicCandidate(String sdp) {
    for (final line in sdp.split('\r\n')) {
      if (!line.startsWith('a=candidate:')) continue;
      if (line.contains(' typ srflx ') || line.contains(' typ relay ')) {
        return true;
      }
    }
    return false;
  }
}
