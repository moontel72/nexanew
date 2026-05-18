import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/foundation.dart';

import 'package:nexatrace_system/features/factory/driver/app/driver_app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverAppInitializer();
  }
}
