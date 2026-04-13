import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nexatrace_system/core/widgets/app_initializer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

SemanticsHandle? _semanticsHandle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  if (kIsWeb) {
    // Use history mode (no hash in URL) for clean URLs
    usePathUrlStrategy();
    _semanticsHandle ??= RendererBinding.instance.ensureSemantics();
  }

  runApp(const NexaTraceApp());
}

class NexaTraceApp extends StatelessWidget {
  const NexaTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppInitializer();
  }
}
