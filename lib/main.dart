//lib/main.dart
// test deploy
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:trace_odd/core/widgets/app_initializer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

SemanticsHandle? _semanticsHandle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  // Initialize error handling
  _setupErrorHandling();

  if (kIsWeb) {
    // Use history mode (no hash in URL) for clean URLs
    usePathUrlStrategy();
    _semanticsHandle ??= RendererBinding.instance.ensureSemantics();
  }

  runApp(const NexaTraceApp());
}

void _setupErrorHandling() {
  // Set up Flutter error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Log to error logger
    // ErrorLogger.error('Flutter error', details.exception, details.stack);
  };

  // Set up platform error handling
  PlatformDispatcher.instance.onError = (error, stack) {
    // ErrorLogger.error('Platform error', error, stack);
    return true;
  };
}

class NexaTraceApp extends StatelessWidget {
  const NexaTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppInitializer();
  }
}
