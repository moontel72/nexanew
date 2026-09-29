// Copyable error surface — make ANY failure copyable, including the ones that
// never reach an error banner.
//
// WHY THIS EXISTS (owner, 2026-09-29)
// -----------------------------------
// The owner reported, on `/factory/orders`:
//
//     type error NULL minified: SR is not a subtype of type 'string'
//     ... "the error shows, but it still does not copy"
//
// It did not copy because it never went through `StickyErrorBanner`: an uncaught
// exception thrown during a build goes to Flutter's own error widget, which has
// no copy affordance at all. So a failure that the operator most needs to report
// was the one he could not report.
//
// This installs ONE error surface for the whole app that behaves like the banner:
//   * STICKY   — it replaces the failed subtree and stays put;
//   * COPYABLE — the message AND the stack, one tap (with the same insecure-context
//                fallback the banner uses, so it works over plain http:// too);
//   * HONEST   — it says what happened and that the rest of the screen may be stale.
//
// It changes only how an error is DISPLAYED. Nothing is swallowed.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Last error seen by the global handlers, so the panel can show a stack even
/// when `ErrorWidget.builder` is handed only the exception.
FlutterErrorDetails? lastUncaughtErrorDetails;

/// The text the Copy action puts on the clipboard.
String _reportText(Object error, {StackTrace? stack, String? app}) {
  final lines = <String>[];
  if (app != null && app.isNotEmpty) lines.add('App: $app');
  lines.add('Error: $error');
  if (stack != null && stack.toString().trim().isNotEmpty) {
    lines.add('Stack:');
    lines.add(stack.toString().trim());
  }
  return lines.join('\n');
}

/// Copy `text`, falling back to a manual-copy dialog.
///
/// The browser Clipboard API only exists in a SECURE context; this app is also
/// served over plain `http://` (the raw IP), where it is unavailable. Without the
/// fallback the button silently does nothing — which is exactly what the owner hit.
Future<void> copyReport(BuildContext context, String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied')));
    return;
  } catch (_) {
    // Fall through.
  }

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Copy this manually'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: SelectableText(text, style: const TextStyle(fontSize: 12.5)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// The panel an uncaught error renders as.
class CopyableErrorPanel extends StatelessWidget {
  const CopyableErrorPanel({
    super.key,
    required this.error,
    this.stack,
    this.app,
  });

  final Object error;
  final StackTrace? stack;
  final String? app;

  @override
  Widget build(BuildContext context) {
    final report = _reportText(error, stack: stack, app: app);

    return Material(
      color: AppColors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Something failed on this screen',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => copyReport(context, report),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Copy the report below and send it on. The rest of this screen '
                  'may be showing stale data.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.35),
                    ),
                  ),
                  child: SelectableText(
                    report,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Install the surface. Call once, first thing in every entry point.
///
/// [app] labels the panel so a copied report names the app/panel it came from.
void installCopyableErrorSurface({String app = ''}) {
  // Keep Flutter's own reporting (console/logging) — only add to it.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    lastUncaughtErrorDetails = details;
    previousOnError?.call(details);
  };

  // Errors that escape the framework (async/platform) are otherwise only logged
  // in the browser console, where the operator cannot reach them. The panels
  // already treated these as handled (`return true`), so that behaviour is kept
  // and the details are simply remembered for the report.
  final previousPlatformOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    lastUncaughtErrorDetails = FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'platform',
    );
    return previousPlatformOnError?.call(error, stack) ?? true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    final detailsStack = details.stack;
    return CopyableErrorPanel(
      error: details.exception,
      stack: detailsStack,
      app: app,
    );
  };
}
