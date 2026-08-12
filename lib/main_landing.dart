// Landing Site Entrypoint — www.traceodd.com
//
// Standalone Flutter web build for the Trace Odd single-page brand landing
// site. Served from the domain root by Nginx (traceodd.com + www).
// No admin/auth dependencies — fully isolated from the panel apps.
//
// Build: flutter build web --release --target=lib/main_landing.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'features/landing/presentation/pages/landing_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) usePathUrlStrategy();
  runApp(const LandingApp());
}

class LandingApp extends StatelessWidget {
  const LandingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trace Odd',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C49F),
          secondary: Color(0xFF00C49F),
        ),
      ),
      home: const LandingProviders(child: LandingPage()),
    );
  }
}
