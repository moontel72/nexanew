import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';

class DriverFeatureScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget child;

  const DriverFeatureScaffold({
    super.key,
    required this.title,
    this.actions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title, actions: actions),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: child,
        ),
      ),
    );
  }
}

