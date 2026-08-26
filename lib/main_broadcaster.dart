import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/app_theme.dart';

import 'features/broadcaster/data/services/whip_client.dart';
import 'features/broadcaster/presentation/broadcaster_cubit.dart';
import 'features/broadcaster/presentation/broadcaster_page.dart';

/// Todd Broadcaster — mobile ground camera app.
///
/// A standalone Flutter entrypoint (build with
/// `flutter build apk -t lib/main_broadcaster.dart`) that turns a phone
/// into a WHIP camera source for the T-Odd media engine.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BroadcasterApp(initialConfig: _deepLinkConfig()));
}

/// Resolves a connection config from the launch URL so a director can
/// hand a camera operator a single link that pre-fills every field:
///
///   https://broadcaster.traceodd.com/?url=<whipped ingest URL>
///
/// or with the fields inline:
///
///   https://broadcaster.traceodd.com/?base=…&room=…&camera=…&token=…
///
/// Returns null on unsupported platforms (e.g. the APK, where operators
/// paste the URL into the form) or when no parameters are present.
BroadcasterConfig? _deepLinkConfig() {
  if (!kIsWeb) return null;

  final uri = Uri.base;
  final wrapped = uri.queryParameters['url'] ?? uri.queryParameters['whip_url'];
  if (wrapped != null && wrapped.isNotEmpty) {
    final parts = WhipClient.parseWhipUrl(wrapped);
    if (parts != null) {
      return BroadcasterConfig(
        baseUrl: parts.baseUrl,
        roomId: parts.roomId,
        cameraId: parts.cameraId,
        token: parts.token,
      );
    }
  }

  final roomId = uri.queryParameters['room'] ?? uri.queryParameters['room_id'];
  final cameraId =
      uri.queryParameters['camera'] ?? uri.queryParameters['camera_id'];
  final token = uri.queryParameters['token'];
  final baseUrl =
      uri.queryParameters['base'] ?? uri.queryParameters['base_url'];
  if ((roomId ?? '').isNotEmpty && (cameraId ?? '').isNotEmpty) {
    return BroadcasterConfig(
      baseUrl: baseUrl?.trim() ?? '',
      roomId: roomId!.trim(),
      cameraId: cameraId!.trim(),
      token: token?.trim() ?? '',
    );
  }
  return null;
}

/// The broadcaster shell: dark control-room styling matching the Studio.
class BroadcasterApp extends StatelessWidget {
  const BroadcasterApp({super.key, this.initialConfig});

  /// Pre-filled connection config from a deep link, if any.
  final BroadcasterConfig? initialConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todd Broadcaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: BroadcasterPage(initialConfig: initialConfig),
    );
  }
}
