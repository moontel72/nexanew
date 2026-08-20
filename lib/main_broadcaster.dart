import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/app_theme.dart';

import 'features/broadcaster/presentation/broadcaster_page.dart';

/// Todd Broadcaster — mobile ground camera app.
///
/// A standalone Flutter entrypoint (build with
/// `flutter build apk -t lib/main_broadcaster.dart`) that turns a phone
/// into a WHIP camera source for the T-Odd media engine.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BroadcasterApp());
}

/// The broadcaster shell: dark control-room styling matching the Studio.
class BroadcasterApp extends StatelessWidget {
  const BroadcasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todd Broadcaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: const BroadcasterPage(),
    );
  }
}
