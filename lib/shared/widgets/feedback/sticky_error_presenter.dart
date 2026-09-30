// Presenter for the shared sticky error banner.
//
// WHY THIS EXISTS (owner's rule: "a failure must STAY, be COPYABLE and be
// CLOSABLE"). The banner itself is an inline widget, which is right for a screen
// that owns a body area. But many screens report failures from a `BlocListener`
// (fixture notices, live-score notices, upload results, …) where there is no inline
// slot — those used a red SnackBar that vanished, so the failure could never be read
// or copied.
//
// `showStickyError` renders the SAME `StickyErrorBanner` inside a persistent
// SnackBar: it stays until the operator closes it (the banner's own X), it copies
// (including the manual-copy fallback over plain http://), and it needs no
// per-screen state or body restructuring — so a `BlocListener` can report a failure
// properly with one line.
//
// Success/informational notices keep their normal SnackBar; this is for FAILURES.
import 'package:flutter/material.dart';
import 'package:trace_odd/shared/widgets/feedback/sticky_error_banner.dart';

void showStickyError(BuildContext context, String message, {String? source}) {
  final messenger = ScaffoldMessenger.of(context);
  // One failure at a time: a newer failure replaces the previous one.
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      // Long on purpose: the banner waits for the operator, it never self-dismisses.
      duration: const Duration(days: 1),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      behavior: SnackBarBehavior.floating,
      content: StickyErrorBanner(
        message: message,
        source: source,
        onDismiss: messenger.hideCurrentSnackBar,
      ),
    ),
  );
}
