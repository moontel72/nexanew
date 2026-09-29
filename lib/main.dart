//lib/main.dart
// test
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:trace_odd/app/app_initializer.dart';
import 'package:trace_odd/shared/widgets/feedback/copyable_error_surface.dart';
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
  // One surface for the whole app: any uncaught error (including a build-time
  // type error, which used to reach Flutter's own error widget and had NO copy
  // affordance) now renders as a panel with the message, the stack and a Copy
  // button. Flutter's own console reporting is preserved.
  installCopyableErrorSurface(app: 'Trace Odd admin panel');
}

class NexaTraceApp extends StatelessWidget {
  const NexaTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppInitializer();
  }
}
