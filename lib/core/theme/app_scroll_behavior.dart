// WebAppScrollBehavior — Enables mouse/trackpad drag-to-scroll on Flutter Web
//
// Flutter Web by default restricts drag-to-scroll to touch devices only.
// This override adds mouse and trackpad to the dragDevices set so that
// users can click-and-drag scrollbar thumbs and scroll tracks with any
// pointing device (desktop mouse, laptop trackpad, touchscreen).

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class WebAppScrollBehavior extends MaterialScrollBehavior {
  const WebAppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}
