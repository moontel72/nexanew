// Web implementation of the WHEP (WebRTC) player.
//
// Mirrors `hls_video_player_web.dart`: an HtmlElementView hosting a real
// <video> element, with the wiring emitted as an inline script so no Dart-side
// JS interop is required. The client itself is the vendored
// `web/vendor/whep.js` (same contract as the director app's `whep.ts`), so the
// page and Todd Studio exercise identical logic.
//
// A status line is rendered inside the view: WHEP failures are otherwise
// invisible (a black rectangle), and "worked for two minutes then stopped"
// needs a reason on screen, not in a console the operator has to open.

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

const String _whepScriptPath = 'vendor/whep.js';
const String _whepScriptMarker = 'data-traceodd-whep';

/// View ids already registered — the registry throws when a view type is
/// registered twice, and widget rebuilds must not re-register.
final Set<String> _registeredViews = <String>{};

Widget buildPlatformWhepPlayer({
  required BuildContext context,
  required String url,
  required String token,
  List<dynamic> iceServers = const [],
  bool autoPlay = true,
}) {
  final config = jsonEncode({
    'url': url,
    'token': token,
    'iceServers': iceServers,
    'autoPlay': autoPlay,
  });

  final viewId = 'traceodd_whep_${url.hashCode}_${token.hashCode}';
  final elementId = 'whep_video_$viewId';
  final statusId = 'whep_status_$viewId';

  if (_registeredViews.add(viewId)) {
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final wrapper = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.position = 'relative'
        ..style.background = '#000000';

      final video = html.VideoElement()
        ..id = elementId
        ..controls = true
        ..autoplay = autoPlay
        ..muted = autoPlay
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain';
      video.setAttribute('playsinline', '');
      video.setAttribute('data-whep-config', config);

      // Empty by default: only failures write here, so a healthy feed shows no
      // overlay at all.
      final status = html.DivElement()
        ..id = statusId
        ..text = ''
        ..style.position = 'absolute'
        ..style.left = '8px'
        ..style.bottom = '8px'
        ..style.padding = '4px 8px'
        ..style.borderRadius = '4px'
        ..style.background = 'rgba(0, 0, 0, 0.62)'
        ..style.color = '#ffffff'
        ..style.font = '12px ui-monospace, Menlo, Consolas, monospace';

      wrapper.children.addAll([video, status]);
      _attachWhep(elementId, statusId);
      return wrapper;
    });
  }

  return HtmlElementView(viewType: viewId);
}

/// Emits an inline script that loads the vendored WHEP client and starts a
/// watch with the config embedded on the video element.
void _attachWhep(String elementId, String statusId) {
  final wiring = html.ScriptElement()
    ..text =
        '''
(function () {
  var video = document.getElementById(${jsonEncode(elementId)});
  var status = document.getElementById(${jsonEncode(statusId)});
  if (!video) return;

  var config = {};
  try {
    config = JSON.parse(video.getAttribute('data-whep-config') || '{}');
  } catch (e) {
    config = {};
  }

  function say(text) {
    if (status) {
      status.textContent = text || '';
    }
  }

  function start() {
    if (!window.ToddWhep) {
      say('Live video client failed to load');
      return;
    }
    window.ToddWhep.watch({
      url: config.url,
      token: config.token,
      video: video,
      iceServers: config.iceServers || [],
      onState: function (state, detail) {
        if (state === 'watching') {
          say('');
        } else if (state === 'retrying') {
          say('Connecting to live video…');
        } else {
          say('Live video unavailable' + (detail ? ': ' + detail : ''));
        }
      }
    });
  }

  if (window.ToddWhep) {
    start();
    return;
  }

  var existing = document.querySelector('script[$_whepScriptMarker]');
  if (existing) {
    existing.addEventListener('load', start);
    existing.addEventListener('error', function () {
      say('Live video client failed to load');
    });
    return;
  }

  var loader = document.createElement('script');
  loader.src = ${jsonEncode(_whepScriptPath)};
  loader.async = false;
  loader.setAttribute('data-traceodd-whep', '1');
  loader.onload = start;
  loader.onerror = function () {
    say('Live video client failed to load');
  };
  document.head.appendChild(loader);
})();
''';

  html.document.body?.append(wiring);
}
