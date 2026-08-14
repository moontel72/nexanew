// Web implementation of the shared HLS player.
//
// Uses an HtmlElementView hosting a <video> element driven by hls.js.
// The hls.js bundle is a vendored static asset (`web/vendor/hls.min.js`),
// loaded once per page on demand — no CDN dependency, no hardcoded URLs.
//
// The hls.js wiring is emitted as an inline script string, so no Dart-side
// JS interop is required (dart:js_util was removed in modern Dart SDKs).

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

const String _hlsScriptPath = 'vendor/hls.min.js';
const String _hlsScriptMarker = 'data-traceodd-hls';

/// View ids already registered — platformViewRegistry throws when the
/// same view type is registered twice (widget rebuilds must not re-register).
final Set<String> _registeredViews = <String>{};

Widget buildPlatformHlsPlayer({
  required BuildContext context,
  required String url,
  bool autoPlay = false,
}) {
  final viewId = 'traceodd_hls_${url.hashCode}';
  final elementId = 'hls_video_$viewId';

  if (_registeredViews.add(viewId)) {
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final video = html.VideoElement()
        ..id = elementId
        ..controls = true
        ..autoplay = autoPlay
        ..muted = autoPlay
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain';

      _attachHls(elementId, url);
      return video;
    });
  }

  return HtmlElementView(viewType: viewId);
}

/// Emits an inline script that wires hls.js to the video element.
/// Falls back to native <video> HLS (Safari) when hls.js is missing or
/// unsupported by the browser.
void _attachHls(String elementId, String url) {
  final wiring = html.ScriptElement()
    ..text =
        '''
(function () {
  var video = document.getElementById(${jsonEncode(elementId)});
  if (!video) return;
  if (window.Hls && Hls.isSupported()) {
    var hls = new Hls();
    hls.attachMedia(video);
    hls.loadSource(${jsonEncode(url)});
  } else {
    video.src = ${jsonEncode(url)};
  }
})();
''';

  void inject() {
    html.document.body?.append(wiring);
  }

  // hls.js is loaded once per page; every subsequent player reuses it.
  final existing = html.document.querySelector('script[$_hlsScriptMarker]');
  if (existing != null) {
    inject();
    return;
  }

  final loader = html.ScriptElement()
    ..src = _hlsScriptPath
    ..async = false
    ..setAttribute(_hlsScriptMarker, '1');

  loader.onLoad.listen((_) => inject());
  loader.onError.listen((_) => inject());
  html.document.head?.append(loader);
}
