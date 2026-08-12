// Anchor Registry
//
// GlobalKeys shared between the nav bar (scroll targets) and the section
// widgets. Pure UI plumbing — no state, no setState.

import 'package:flutter/material.dart';

class LandingAnchors {
  LandingAnchors._();

  static final GlobalKey verticals = GlobalKey(debugLabel: 'verticals');
  static final GlobalKey pricing = GlobalKey(debugLabel: 'pricing');
  static final GlobalKey roadmap = GlobalKey(debugLabel: 'roadmap');
  static final GlobalKey signup = GlobalKey(debugLabel: 'signup');

  /// Resolve a JSON anchor name to its GlobalKey, falling back to signup.
  static GlobalKey forName(String anchor) => switch (anchor) {
    'verticals' => verticals,
    'pricing' => pricing,
    'roadmap' => roadmap,
    'signup' => signup,
    _ => signup,
  };

  /// Smooth-scrolls to the target section.
  static void scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      alignment: 0.02,
    );
  }
}
